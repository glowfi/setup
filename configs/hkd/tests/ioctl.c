#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <dirent.h>
#include <unistd.h>
#include <linux/input.h>

#define test_bit(yalv, abs_b) ((((char *)abs_b)[yalv/8] & (1<<yalv%8)) > 0)

const char ev_root[] = "/dev/input/";

int main (void)
{
	/* Open the event directory */
	DIR *ev_dir = opendir(ev_root);
	if (!ev_dir) 
		exit(-1);

	for (;;) {
		struct dirent *file_ent;
		char ev_path[sizeof(ev_root) + NAME_MAX + 1];
		int tmp_fd;
		unsigned char evtype_b[EV_MAX];
		
		if ((file_ent = readdir(ev_dir)) == NULL)
			break;
		/* Filter out non character devices */
		if (file_ent->d_type != DT_CHR)
			continue;
			
		/* Compose absolute path from relative */
		memset(ev_path, 0, sizeof(ev_path));
		strncpy(ev_path, ev_root, sizeof(ev_root) + NAME_MAX);
	   	strncat(ev_path, file_ent->d_name, sizeof(ev_root) + NAME_MAX);
	   	fprintf(stderr, "%s\n", ev_path);

		/* Open device and check if it can give key events otherwise ignore it */
		tmp_fd = open(ev_path, O_RDONLY | O_NONBLOCK);
		if (tmp_fd < 0) {
			fprintf(stdout, "Could not open device %s\n", ev_path);
			continue;
		}
	   	fprintf(stderr, "%s\n", ev_path);

		memset(evtype_b, 0, sizeof(evtype_b));
		if (ioctl(tmp_fd, EVIOCGBIT(0, EV_MAX), evtype_b) < 0) {
			fprintf(stdout, "Could not read capabilities of device %s\n",
				ev_path);
			close(tmp_fd);
			continue;
		}
	   	fprintf(stderr, "%s\n", ev_path);
	
		if (test_bit(EV_KEY, evtype_b))
			fprintf(stdout, "device %s has it!\n", ev_path);


		fprintf(stdout, "\n\n\n\n");
		close(tmp_fd);
	}

	printf("%d", EV_MAX);
	closedir(ev_dir);
}
