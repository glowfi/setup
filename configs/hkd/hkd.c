/*
 * Copyright (c) 2021 Alessandro Mauri
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
*/

#define _POSIX_C_SOURCE 200809L
#define _DEFAULT_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <dirent.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/epoll.h>
#include <sys/inotify.h>
#include <wordexp.h>
#include <ctype.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <sys/mman.h>
#include "keys.h"

/* Value defines */
#define FILE_NAME_MAX_LENGTH 255
#define KEY_BUFFER_SIZE 16
#define BLOCK_SIZE 512

/* ANSI colors escape codes */
#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_GREEN   "\x1b[32m"
#define ANSI_COLOR_YELLOW  "\x1b[33m"
#define ANSI_COLOR_BLUE    "\x1b[34m"
#define ANSI_COLOR_MAGENTA "\x1b[35m"
#define ANSI_COLOR_CYAN    "\x1b[36m"
#define ANSI_COLOR_RESET   "\x1b[0m"

/* Macro functions */
#define yellow(str) (ANSI_COLOR_YELLOW str ANSI_COLOR_RESET)
#define green(str) (ANSI_COLOR_GREEN str ANSI_COLOR_RESET)
#define red(str) (ANSI_COLOR_RED str ANSI_COLOR_RESET)
#define test_bit(yalv, abs_b) ((((char *)abs_b)[yalv/8] & (1<<yalv%8)) > 0)
#define array_size(val) (val ? sizeof(val)/sizeof(val[0]) : 0)
#define array_size_const(val) ((int)(sizeof(val)/sizeof(val[0])))
#define wrap_err(s) "[%s] " s, __func__
#define is_empty(s) (!(s) || !(s)[0])

#define EVENT_SIZE (sizeof(struct inotify_event))
#define EVENT_BUF_LEN (1024*(EVENT_SIZE+16))
#define EVDEV_ROOT_DIR "/dev/input/"
#define LOCK_FILE "/tmp/hkd.lock"

const char *config_paths[] = {
	"$XDG_CONFIG_HOME/hkd/config",
	"$HOME/.config/hkd/config",
	"/etc/hkd/config",
};

struct key_buffer {
	unsigned short buf[KEY_BUFFER_SIZE];
	unsigned int size;
};

/* Hotkey list: linked list that holds all valid hoteys parsed from the
 * config file and the corresponding command
 * TODO: re-implement hotkey_list as a hash table to make searching O(1)
 */

union hotkey_main_data {
	struct key_buffer kb;
	char * name;
};

struct hotkey_list_e {
	union hotkey_main_data data;
	char *command;
	int fuzzy;
	struct hotkey_list_e *next;
};

struct hotkey_list_e *hotkey_list = NULL;
/* TODO: add hotkey_range struct as a second check to avoid accessing the list
 * struct {
 *     unsigned int min;
 *     unsigned int max;
 * } hotkey_range;
 */
unsigned long hotkey_size_mask = 0;
char *ext_config_file = NULL;
/* Global flags */
int vflag = 0;
int dead = 0; /* Exit flag */
/* key buffer operations */
int key_buffer_add (struct key_buffer*, unsigned short);
int key_buffer_remove (struct key_buffer*, unsigned short);
int key_buffer_compare_fuzzy (struct key_buffer *, struct key_buffer *);
int key_buffer_compare (struct key_buffer *, struct key_buffer *);
void key_buffer_reset (struct key_buffer *);
/* Other operations */
void int_handler (int signum);
void exec_command (char *);
void parse_config_file (void);
void update_descriptors_list (int **, int *);
inline void remove_lock (void);
void die (const char *, ...);
void usage (void);
int prepare_epoll (int *, int, int);
unsigned short key_to_code (char *);
const char * code_to_name (unsigned int);
/* hotkey list operations */
void hotkey_list_add (struct hotkey_list_e *, union hotkey_main_data *, char *, int);
void hotkey_list_destroy (struct hotkey_list_e *);
void hotkey_list_remove (struct hotkey_list_e *, struct hotkey_list_e *);
void replace (char **, const char *, const char *);

int main (int argc, char *argv[])
{
	int fd_num = 0;
	int *fds = NULL;
	int lock_file_descriptor;
	int opc;
	int ev_fd;
	int event_watcher = inotify_init1(IN_NONBLOCK);
	int dump = 0;
	ssize_t read_b; 				/* Read buffer */
	struct flock fl;
	struct sigaction action;
	struct input_event event;
	struct key_buffer pb = {{0}, 0};	/* Pressed keys buffer */

	/* Parse command line arguments */
	while ((opc = getopt(argc, argv, "vc:dh")) != -1) {
		switch (opc) {
		case 'v':
			vflag = 1;
			break;
		case 'c':
			ext_config_file = malloc(strlen(optarg) + 1);
			if (!ext_config_file)
				die(wrap_err("Bad malloc:"));
			 strcpy(ext_config_file, optarg);
			 break;
		case 'd':
			dump = 1;
			break;
		case 'h':
			usage();
			break;
		break;
		}
	}

	/* Handle SIGINT */
	dead = 0;
	memset(&action, 0, sizeof(action));
	action.sa_handler = int_handler;
	
	if (sigaction(SIGINT, &action, NULL) == -1)
		die(wrap_err("Error setting interrupt handler:"));
	if (sigaction(SIGUSR1, &action, NULL) == -1)
		die(wrap_err("Error setting interrupt handler:"));
	if (sigaction(SIGCHLD, &action, NULL) == -1)
		die(wrap_err("Error setting interrupt handler:"));

	/* Parse config file */
	parse_config_file();

	/* Check if hkd is already running */
	lock_file_descriptor = open(LOCK_FILE, O_RDWR | O_CREAT, 0600);
	if (lock_file_descriptor < 0)
		die(wrap_err("Can't open lock file:"));
	fl.l_start = 0;
	fl.l_len = 0;
	fl.l_type = F_WRLCK;
	fl.l_whence = SEEK_SET;
	if (fcntl(lock_file_descriptor, F_SETLK, &fl) < 0)
		die("hkd is already running");
	atexit(remove_lock);

	/* If a dump is requested print the hotkey list then exit */
	if (dump) {
		printf("DUMPING HOTKEY LIST\n\n");
		for (struct hotkey_list_e *tmp = hotkey_list; tmp; tmp = tmp->next) {
			printf("Hotkey\n");
			printf("\tKeys: ");
			for (unsigned int i = 0; i < tmp->data.kb.size; i++)
				printf("%s ", code_to_name(tmp->data.kb.buf[i]));
			printf("\n\tMatching: %s\n", tmp->fuzzy ? "fuzzy" : "ordered");
			printf("\tCommand: %s\n\n", tmp->command);
		}
		exit(EXIT_SUCCESS);
	}

	/* Load descriptors */
	update_descriptors_list(&fds, &fd_num);

	/* Prepare directory update watcher */
	if (event_watcher < 0)
		die(wrap_err("Could not call inotify_init:"));
	if (inotify_add_watch(event_watcher, EVDEV_ROOT_DIR, IN_CREATE | IN_DELETE) < 0)
		die(wrap_err("Could not add /dev/input to the watch list:"));
	/* Prepare epoll list */
	ev_fd = prepare_epoll(fds, fd_num, event_watcher);

	/* MAIN EVENT LOOP */
	mainloop_begin:
	for (;;) {
		int t = 0;
		static unsigned int prev_size;
		static struct epoll_event ev_type;
		struct hotkey_list_e *tmp;
		char buf[EVENT_BUF_LEN];

		/* On linux use epoll(2) as it gives better performance */
		if (epoll_wait(ev_fd, &ev_type, fd_num, -1) < 0 || dead) {
			if (errno != EINTR)
				break;
		}

		if (ev_type.events != EPOLLIN)
			continue;

		if (read(event_watcher, buf, EVENT_BUF_LEN) >= 0) {
			sleep(1); // wait for devices to settle
			update_descriptors_list(&fds, &fd_num);
			if (close(ev_fd) < 0)
				die(wrap_err("Could not close event fd list (ev_fd):"));
			ev_fd = prepare_epoll(fds, fd_num, event_watcher);
			goto mainloop_begin;
		}

		prev_size = pb.size;
		for (int i = 0; i < fd_num; i++) {

			read_b = read(fds[i], &event, sizeof(struct input_event));
			if (read_b != sizeof(struct input_event)) continue;

			/* Ignore touchpad events */
			if (
				event.type == EV_KEY &&
				event.code != BTN_TOUCH &&
				event.code != BTN_TOOL_FINGER &&
				event.code != BTN_TOOL_DOUBLETAP &&
				event.code != BTN_TOOL_TRIPLETAP
				) {
				switch (event.value) {
				/* Key released */
				case 0:
					key_buffer_remove(&pb, event.code);
					break;
				/* Key pressed */
				case 1:
					key_buffer_add(&pb, event.code);
					break;
				}
			}
		}

		if (pb.size <= prev_size)
			continue;

		if (vflag) {
			printf("Pressed keys: ");
			for (unsigned int i = 0; i < pb.size; i++)
				printf("%s ", code_to_name(pb.buf[i]));
			putchar('\n');
		}

		if (hotkey_size_mask & 1 << (pb.size - 1)) {
			for (tmp = hotkey_list; tmp != NULL; tmp = tmp->next) {
				if (tmp->fuzzy)
					t = key_buffer_compare_fuzzy(&pb, &tmp->data.kb);
				else
					t = key_buffer_compare(&pb, &tmp->data.kb);
				if (t)
					exec_command(tmp->command);

			}
		}
	}

	// TODO: better child handling, for now all children receive the same
	// interrupts as the father so everything should work fine
	wait(NULL);
	if (!dead)
		fprintf(stderr, red("An error occured: %s\n"), errno ? strerror(errno): "idk");
	close(ev_fd);
	close(event_watcher);
	for (int i = 0; i < fd_num; i++)
		if (close(fds[i]) == -1)
			die(wrap_err("Error closing file descriptors:"));
	return 0;
}

/* Adds a keycode to the pressed buffer if it is not already present
 * Returns non zero if the key was not added. */
int key_buffer_add (struct key_buffer *pb, unsigned short key)
{
	if (!pb) return 1;
	/* Linear search if the key is already buffered */
	for (unsigned int i = 0; i < pb->size; i++)
		if (key == pb->buf[i]) return 1;

	if (pb->size >= KEY_BUFFER_SIZE)
		return 1;

	pb->buf[pb->size++] = key;

	return 0;
}

/* Removes a keycode from a pressed buffer if it is present returns
 * non zero in case of failure (key not present or buffer empty). */
int key_buffer_remove (struct key_buffer *pb, unsigned short key)
{
	if (!pb) return 1;

	for (unsigned int i = 0; i < pb->size; i++) {
		if (pb->buf[i] == key) {
			pb->size--;
			pb->buf[i] = pb->buf[pb->size];
			return 0;
		}
	}
	return 1;
}

void key_buffer_reset (struct key_buffer *kb)
{
	kb->size = 0;
	memset(kb->buf, 0, KEY_BUFFER_SIZE * sizeof(unsigned short));
}

void int_handler (int signum)
{
	switch (signum) {
	case SIGINT:
		if (dead)
			die(wrap_err("An error occured, exiting"));
		if (vflag)
			printf(yellow("Received interrupt signal, exiting gracefully...\n"));
		dead = 1;
		break;
	case SIGUSR1:
		parse_config_file();
		break;
	case SIGCHLD:
		wait(NULL);
		break;
	}
}

/* Executes a command from a string */
void exec_command (char *command)
{
	static wordexp_t result;

	/* Expand the string for the program to run */
	switch (wordexp (command, &result, 0)) {
	case 0:
		break;
	case WRDE_NOSPACE:
		/* If the error was WRDE_NOSPACE,
		 * then perhaps part of the result was allocated */
		wordfree (&result);
		return;
	default:
		/* Some other error */
		fprintf(stderr, wrap_err("Could not parse, %s is not valid\n"), command);
		return;
	}

	pid_t cpid;
	switch (cpid = fork()) {
	case -1:
		fprintf(stderr, wrap_err("Could not create child process: %s"), strerror(errno));
		wordfree(&result);
		break;
	case 0:
		/* This is the child process, execute the command */
		execvp(result.we_wordv[0], result.we_wordv);
		die(wrap_err("%s:"), command);
		break;
	default:
		while (waitpid(cpid, NULL, WNOHANG) == -1) {}
		wordfree(&result);
		break;
	}
}

void update_descriptors_list (int **fds, int *fd_num)
{
	struct dirent *file_ent;
	char ev_path[sizeof(EVDEV_ROOT_DIR) + FILE_NAME_MAX_LENGTH + 1];
	void *tmp_p;
	int tmp_fd;
	unsigned char evtype_b[EV_MAX];
	/* Open the event directory */
	DIR *ev_dir = opendir(EVDEV_ROOT_DIR);
	if (!ev_dir)
		die(wrap_err("Could not open /dev/input:"));

	(*fd_num) = 0;

	for (;;) {

		if ((file_ent = readdir(ev_dir)) == NULL)
			break;
		/* Filter out non character devices */
		if (file_ent->d_type != DT_CHR)
			continue;

		/* Compose absolute path from relative */
		strncpy(ev_path, EVDEV_ROOT_DIR, sizeof(EVDEV_ROOT_DIR) + FILE_NAME_MAX_LENGTH);
	   	strncat(ev_path, file_ent->d_name, sizeof(EVDEV_ROOT_DIR) + FILE_NAME_MAX_LENGTH);

		/* Open device and check if it can give key events otherwise ignore it */
		tmp_fd = open(ev_path, O_RDONLY | O_NONBLOCK);
		if (tmp_fd < 0) {
			if (vflag)
				printf(red("Could not open device %s\n"), ev_path);
			continue;
		}

		memset(evtype_b, 0, sizeof(evtype_b));
		if (ioctl(tmp_fd, EVIOCGBIT(0, EV_MAX), evtype_b) < 0) {
			if (vflag)
				printf(red("Could not read capabilities of device %s\n"), ev_path);
			close(tmp_fd);
			continue;
		}

		if (!test_bit(EV_KEY, evtype_b)) {
			if (vflag)
				printf(yellow("Ignoring device %s\n"), ev_path);
			close(tmp_fd);
			continue;
		}

		tmp_p = realloc((*fds), sizeof(int) * ((*fd_num) + 1));
		if (!tmp_p)
			die(wrap_err("Realloc file descriptors:"));
		(*fds) = (int *) tmp_p;

		(*fds)[(*fd_num)] = tmp_fd;
		(*fd_num)++;
	}
	closedir(ev_dir);
	if (*fd_num) {
		if (vflag)
			printf(green("Monitoring %d devices\n"), *fd_num);
	} else {
		die(wrap_err("Could not open any devices, exiting"));
	}
}

int prepare_epoll (int *fds, int fd_num, int event_watcher)
{
 	int ev_fd = epoll_create(1);
	static struct epoll_event epoll_read_ev;
 	epoll_read_ev.events = EPOLLIN;
 	if (ev_fd < 0)
 		die(wrap_err("epoll_create failed:"));
 	if (epoll_ctl(ev_fd, EPOLL_CTL_ADD, event_watcher, &epoll_read_ev) < 0)
 		die(wrap_err("Could not add file descriptor to the epoll list:"));
 	for (int i = 0; i < fd_num; i++)
 		if (epoll_ctl(ev_fd, EPOLL_CTL_ADD, fds[i], &epoll_read_ev) < 0)
 			die(wrap_err("Could not add file descriptor to the epoll list:"));
	return ev_fd;
}

/* Checks if two key buffers contain the same keys in no specified order */
int key_buffer_compare_fuzzy (struct key_buffer *haystack, struct key_buffer *needle)
{
	int ff = 0;
	if (haystack->size != needle->size)
		return 0;
	for (int x = needle->size - 1; x >= 0; x--) {
		for (unsigned int i = 0; i < haystack->size; i++)
			ff += (needle->buf[x] == haystack->buf[i]);
		if (!ff)
			return 0;
		ff = 0;
	}
	return 1;
}

/* Checks if two key buffers are the same (same order) */
int key_buffer_compare (struct key_buffer *haystack, struct key_buffer *needle)
{
	if (haystack->size != needle->size)
		return 0;
	for (unsigned int i = 0; i < needle->size; i++) {
		if (needle->buf[i] != haystack->buf[i])
			return 0;
	}
	return 1;
}

void hotkey_list_destroy (struct hotkey_list_e *head)
{
	struct hotkey_list_e *tmp;
	for (; head; free(tmp)) {
		if (head->command)
			free(head->command);
		tmp = head;
		head = head->next;
	}
}

// FIXME: use **head or hardcode to hotkey_list
void hotkey_list_add (struct hotkey_list_e *head, union hotkey_main_data *dt, char *cmd, int f)
{
	int size;
	struct hotkey_list_e *tmp;
	if (is_empty(cmd) || !(size = strlen(cmd)))
		return;
	if (!(tmp = malloc(sizeof(struct hotkey_list_e))))
		die(wrap_err("Bad malloc:"));
	if (!(tmp->command = malloc(size + 1)))
		die(wrap_err("Bad malloc:"));
	strcpy(tmp->command, cmd);
	tmp->data = *dt;
	tmp->fuzzy = f;
	tmp->next = NULL;

	if (head) {
		for (; head->next; head = head->next);
		head->next = tmp;
	} else
		hotkey_list = tmp;
}

void hotkey_list_remove (struct hotkey_list_e *head, struct hotkey_list_e *elem)
{
	if(!head)
		return;

	if (head == elem) {
		hotkey_list = head->next;
	} else {
		for (; head && head->next != elem; head = head->next);
		if (head && head->next)
			head->next = head->next->next;
	}
	if (elem) {
		if (elem->fuzzy == -1)
			free(elem->data.name);
		free(elem->command);
		free(elem);	
	}
}

void parse_config_file (void)
{
	wordexp_t result = {0};
	int config_file;
	/* normal, skip line, get matching, get keys, get command, output */
	enum {NORM, LINE_SKIP, GET_TYPE, GET_KEYS, GET_CMD, LAST} parse_state = NORM;
	enum {HK_NORM = 0, HK_FUZZY = 1, ALIAS = -1} type;
	int eof = 0;
	int token_size = 0;
	int i_tmp = 0, linenum = 1;
	char *buffer;
	char *bb = NULL;
	char *keys = NULL;
	char *cmd = NULL;
	char *cp_tmp = NULL;
	union hotkey_main_data dt = {0};
	unsigned short us_tmp = 0;

	/* Choose config file */
	if (ext_config_file) {
		switch (wordexp(ext_config_file, &result, 0)) {
		case 0:
			break;
		case WRDE_NOSPACE:
			/* If the error was WRDE_NOSPACE,
		 	 * then perhaps part of the result was allocated */
			wordfree (&result);
			die(wrap_err("Not enough space:"));
		default:
			die(wrap_err("Path not valid:"));
		}

		config_file = open(result.we_wordv[0], O_RDONLY | O_NONBLOCK);
		wordfree(&result);
		if (config_file < 0)
			die(wrap_err("Error opening config file:"));
		free(ext_config_file);
		ext_config_file = NULL;
	} else {
		for (int i = 0; i < array_size_const(config_paths); i++) {
			switch (wordexp(config_paths[i], &result, 0)) {
			case 0:
				break;
			case WRDE_NOSPACE:
				/* If the error was WRDE_NOSPACE,
		 		 * then perhaps part of the result was allocated */
				wordfree (&result);
				die(wrap_err("Not enough space:"));
			default:
				die(wrap_err("Path not valid:"));
			}

			config_file = open(result.we_wordv[0], O_RDONLY | O_NONBLOCK);
			wordfree(&result);
			if (config_file >= 0)
				break;
			if (vflag)
				printf(yellow("config file not found at %s\n"), config_paths[i]);
		}
		if (!config_file)
			die(wrap_err("Could not open any config files, check stderr for more details"));
	}

	/* Using mmap because of simplicity, most config files are smaller than
	 * a page but this method mostly ensures that big files are taken care
	 * of efficiently and reduces the overall complexity of the code.
	 * Furthermore we only need this space when parsing the config file,
	 * afterwards we release it.
	 */
	struct stat sb;
	int file_size;
	if (fstat(config_file, &sb) == -1)
         	die("fstat");
        file_size = sb.st_size;
        // FIXME: page align size
        buffer = mmap(NULL, file_size, PROT_READ, MAP_PRIVATE, config_file, 0);
        if (buffer == MAP_FAILED)
        	die(wrap_err("mmap failed:"));
	close(config_file);
	bb = buffer;

	hotkey_list_destroy(hotkey_list);
	hotkey_list = NULL;
	while (!eof) {
	// FIXME: incorect line counting, especially for multiline commands
		switch (parse_state) {
		// First state
		case NORM:
			// remove whitespaces
			while (isblank(*bb))
				bb++;
			// get state
			switch (*bb) {
			case '\0':
				eof = 1;
				break;
			case '\n':
			case '#':
				parse_state = LINE_SKIP;
				break;
			default:
				parse_state = GET_TYPE;
				break;
			}
			break;
		// Skip line (comment)
		case LINE_SKIP:
			for (;(bb - buffer) < file_size && *bb != '\n'; bb++);
			bb++;
			linenum++;
			parse_state = NORM;
			break;
		// Get compairson method
		case GET_TYPE:
			switch (*bb) {
			case '-':
				type = HK_NORM;
				break;
			case '*':
				type = HK_FUZZY;
				break;
			case '@':
				type = ALIAS;
				break;
			default:
				die(wrap_err("Error at line %d: "
				"hotkey definition must start with '-', '*' or '@'"),
				linenum);
				break;
			}
			bb++;
			parse_state = GET_KEYS;
			break;
		// Get keys
		case GET_KEYS:
			for (token_size = 0; token_size < (file_size - (bb - buffer)) && !(bb[token_size] == ':' || bb[token_size] == '\n'); token_size++);
			if (bb[token_size] == '\n')
				die(wrap_err("Error at line %d: "
				"no command specified, missing ':' after keys"),
				linenum);
			keys = malloc(token_size + 1);
			if (!keys)
				die(wrap_err("Bad malloc parsing keys:"));
			memcpy(keys, bb, token_size);
			keys[token_size] = '\0';
			bb += token_size + 1;
			parse_state = GET_CMD;
			break;
		// Get command
		case GET_CMD:
			for (token_size = 0; token_size < (file_size - !(bb - buffer)); token_size++) {
				if (bb[token_size] == ':')
					break;
				if (bb[token_size] == '\n' && bb[token_size - token_size ? 1 : 0] != '\\')
					break;
			}
			cmd = malloc(token_size + 1);
			if (!cmd)
				die(wrap_err("Bad malloc parsing command:"));
			memcpy(cmd, bb, token_size);
			cmd[token_size] = '\0';
			bb += token_size;
			parse_state = LAST;
			break;
		case LAST:
			if (!keys)
				die(wrap_err("Keys is NULL"));
			i_tmp = strlen(keys);
			for (int i = 0; i < i_tmp; i++) {
				if (isblank(keys[i]))
					memmove(&keys[i], &keys[i + 1], i_tmp - i);
			}
			cp_tmp = strtok(keys, ",");
			if(!cp_tmp)
				die(wrap_err("Error at line %d: "
				"keys not present"), linenum - 1);

			if (type != ALIAS) {
				do {
					if (!(us_tmp = key_to_code(cp_tmp))) {
						die(wrap_err("Error at line %d: "
						"%s is not a valid key"),
						linenum - 1, cp_tmp);
					}
					if (key_buffer_add(&dt.kb, us_tmp))
						die(wrap_err("Too many keys"));
				} while ((cp_tmp = strtok(NULL, ",")));
			} else {
				if (!(dt.name = malloc(strlen(cp_tmp) + 1)))
					die(wrap_err("Bad malloc:"));
				strcpy(dt.name, cp_tmp);
			}

			/* search the command in the known aliases and replace */
			struct hotkey_list_e *hkl = hotkey_list;
			while (hkl && hkl->fuzzy == ALIAS) {
				replace(&cmd, hkl->data.name, hkl->command);
				hkl = hkl->next;
			}

			cp_tmp = cmd;
			while (isblank(*cp_tmp))
				cp_tmp++;
			if (*cp_tmp == '\0')
				die(wrap_err("Error at line %d: "
				"command not present"), linenum - 1);


			hotkey_list_add(hotkey_list, &dt, cp_tmp, type);

			if (type != ALIAS)
				key_buffer_reset(&dt.kb);
			free(keys);
			free(cmd);
			cp_tmp = keys = cmd = NULL;
			i_tmp = 0;
			parse_state = NORM;
			break;
		default:
			die(wrap_err("Unknown state"));
			break;

		}
	}
	munmap(buffer, file_size);

	for (struct hotkey_list_e *hkl = hotkey_list, *tmp; hkl;) {
		tmp = hkl;
		hkl = hkl->next;
		if (tmp->fuzzy == ALIAS)
			hotkey_list_remove(hotkey_list, tmp);
		else
			hotkey_size_mask |= 1 << (tmp->data.kb.size - 1);
	}
}

unsigned short key_to_code (char *key)
{
	for (char *tmp = key; *tmp; tmp++) {
		if (islower(*tmp))
			*tmp += 'A' - 'a';
	}
	for (int i = 0; i < array_size_const(key_conversion_table); i++) {
		if (!strcmp(key_conversion_table[i].name, key))
			return key_conversion_table[i].value;
	}
	return 0;
}

void remove_lock (void)
{
	unlink(LOCK_FILE);
}

void die(const char *fmt, ...)
{
	va_list ap;
	va_start(ap, fmt);

	fputs(ANSI_COLOR_RED, stderr);
     	vfprintf(stderr, fmt, ap);

	if (fmt[0] && fmt[strlen(fmt) - 1] == ':') {
		fputc(' ', stderr);
		perror(NULL);
	} else {
		fputc('\n', stderr);
	}
     	fputs(ANSI_COLOR_RESET, stderr);

	va_end(ap);
	exit(errno ? errno : 1);
}

const char * code_to_name (unsigned int code)
{
	for (int i = 0; i < array_size_const(key_conversion_table); i++) {
		if (key_conversion_table[i].value == code)
			return key_conversion_table[i].name;
	}
	return "Key not recognized";
}

void usage (void)
{
	puts("Usage: hkd [-vdh] [-c file]\n"
	     "\t-v        verbose, prints all the key presses and debug information\n"
	     "\t-d        dump, dumps the hotkey list and exits\n"
	     "\t-h        prints this help message\n"
	     "\t-c file   uses the specified file as config\n");
	exit(EXIT_SUCCESS);
}

/* replaces every instance of m(match) with r(eplace) inside of s */
void replace (char **s, const char *m, const char *r)
{
	if (is_empty(s) || is_empty(*s) || is_empty(m) || is_empty(r))
		return;

	int ms = strlen(m), rs = strlen(r);
	int count = 0, o = 0;
	int *offs = NULL, *t2 = NULL;
	char *t1 = NULL;
	
	while ((t1 = strstr((*s) + o, m))) {
		/* check if the match is surrounded by whitespace */
		if ((t1[ms] == '\0' || isblank(t1[ms]))
			&& isblank(t1 > *s ? *(t1 - 1) : ' ')) {
			if (!(t2 = realloc(offs, sizeof(int) * (count + 1))))
				die(wrap_err("Bad realloc:"));
			offs = t2;
			offs[count] = (t1 - *s) + (rs - ms) * count;
			count++;
		}
		o = (t1 - *s) + 1;
	}

	if (!offs)
		return;

	int nss = strlen(*s);
	if ((rs - ms) > 0) {
		if (!(t1 = realloc(*s, nss + 1 + (rs - ms) * count)))
			die(wrap_err("Bad realloc:"));
		*s = t1;
	}

	for (int i = 0; i < count; i++) {
		char* x = *s + offs[i];
		int d = strlen(x) - ms;
		memmove(x + rs, x + ms, d);
		memcpy(x, r, rs);
	}
	if (offs)
		free(offs);
}
