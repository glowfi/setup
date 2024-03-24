#define _POSIX_C_SOURCE 200809L
#define _DEFAULT_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_RESET   "\x1b[0m"

#define parse_failure(str, line) {fprintf(stderr, "Error in config file at line %d: " str "\n", line); exit(EXIT_FAILURE);}

int main(int argc, char const *argv[])
{
	if (argc < 2)
		return 1;
	FILE *fd;
	fd = fopen(argv[1], "r");
	if (!fd)
		return -1;
	for (int linenum = 1;; linenum++) {
		int fuzzy = 0, tmp;
		char *line = NULL, *keys = NULL, *command = NULL;
		size_t linelen = 0;

		if (getline(&line, &linelen, fd) == -1)
			break;
		if (linelen < 2)
			continue;

		printf(ANSI_COLOR_RED "Original line:\n%s\n" ANSI_COLOR_RESET, line);

		// Remove leading spaces
		while (isspace(line[0]) && linelen > 1)
			memmove(line, &line[1], --linelen);

		// Skip comments and blank lines
		if (line[0] == '#' || !line[0]) {
			free(line);
			continue;
		}

		printf("Valid line:\n%s\n", line);

		// TODO: multiline commands, ending with "\\n"
		// TODO: better error checks in order to remove unnecessary
		// memmoves (line has to begin with cmment or "*-"), etc.

		if (line[0] == '*')
			fuzzy = 1;
		memmove(line, &line[1], --linelen);
		// Remove leading spaces
		while (isspace(line[0]) && linelen > 1)
			memmove(line, &line[1], --linelen);

		keys = strtok(line, ":");
		command = strtok(NULL, ":");
		if (!command || !keys)
			parse_failure("No command or keys specified", linenum);

		// Remove whitespaces in keys
		tmp = strlen(keys);
		for (int i = 0; i < tmp; i++) {
			if (isspace(keys[i])) {
				memmove(&line[i], &line[i + 1], --tmp);
			}
		}

		// Remove leading spaces in command
		tmp = strlen(command);
		while (isspace(command[0]) && tmp > 1)
			memmove(command, &command[1], --tmp);

		int x = 1;
		char *k = strtok(keys, ",");
		do {
			printf("Key %d: %s\n", x++, k);
		} while ((k = strtok(NULL, ",")));

		printf("Command: %s\n", command);
	}
	return 0;
}
