#define _POSIX_C_SOURCE 200809L
#define _DEFAULT_SOURCE

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define ANSI_COLOR_RED     "\x1b[31m"
#define ANSI_COLOR_RESET   "\x1b[0m"
#define BLOCK_SIZE 256

#define parse_failure(str, line) {fprintf(stderr, "Error in config file at line %d: " str "\n", line); exit(EXIT_FAILURE);}

int main(int argc, char const *argv[])
{
	if (argc < 2)
		return 1;
	FILE *fd;
	fd = fopen(argv[1], "r");
	if (!fd)
		return -1;

	int remaining = 0;
	char block[BLOCK_SIZE + 1] = {0};
	char *bb = NULL;
	// 0: normal, 1: skip line 2: get directive 3: get keys 4: get command 5: output
	int state = 0;

	char *keys = NULL;
	char *cmd = NULL;
	int alloc_tmp = 0, alloc_size = 0;
	
	for (;;) {
		memset(block, 0, BLOCK_SIZE);
		remaining = fread(block, sizeof(char), BLOCK_SIZE, fd);
		if (!remaining)
			break;
		bb = block;
		printf("---\tblock\t---\n%s\n--------------------------\n", block);

		while (remaining > 0) {
			// printf("state: %d\n", state);
			switch (state) {
			// First state
			case 0:
				// remove whitespaces
				while (isspace(*bb) && remaining > 0)
					bb++, remaining--;
				if (remaining <= 0)
					break;
				// get state
				if (*bb == '#')
					state = 1;
				else 
					state = 2;
				break;
			// Skip line (comment)
			case 1:
				// skip line
				while (*bb != '\n' && remaining > 0)
					bb++, remaining--;
				if (remaining > 0)
					state = 0;
				break;
			// Get compairson method
			case 2:
				switch (*bb) {
				case '-':
					break;
				case '*':
					break;
				default:
					exit(-1);
					break;
				}
				bb++, remaining--;
				state = 3;
				break;
			// Get keys
			case 3:
				if (!keys) {
					if (!(keys = malloc(alloc_size = (sizeof(char) * 64))))
						exit(-1);
					memset(keys, 0, alloc_size);
					alloc_tmp = 0;
				} else if (alloc_tmp >= alloc_size) {
					if (!(keys = realloc(keys, alloc_size *= 2)))
						exit(-1);
					memset(&keys[alloc_size / 2], 0, alloc_size / 2);
				}

				for (; remaining > 0 &&
				(bb[alloc_tmp] != ':' && bb[alloc_tmp] != '\n') &&
				alloc_tmp < alloc_size;
				remaining--, alloc_tmp++);

				if (remaining <= 0 || alloc_tmp == alloc_size) {
					strncat(keys, bb, alloc_tmp);
					bb += alloc_tmp;
					break;
				} else if (bb[alloc_tmp] == ':') {
					strncat(keys, bb, alloc_tmp);
					bb += alloc_tmp + 1;
					state = 4;
					break;
				} else {
					printf("char is \\n\n");
					exit(-1);
				}
				break;
			// Get command
			case 4:
				if (!cmd) {
					if (!(cmd = malloc(alloc_size = (sizeof(char) * 128))))
						exit(-1);
					memset(cmd, 0, alloc_size);
					alloc_tmp = 0;
				} else if (alloc_tmp >= alloc_size) {
					if (!(cmd = realloc(cmd, alloc_size *= 2)))
						exit(-1);
					memset(&cmd[alloc_size / 2], 0, alloc_size / 2);
				}

				for (; remaining > 0 &&
				bb[alloc_tmp] != '\n' &&
				alloc_tmp < alloc_size;
				remaining--, alloc_tmp++);

				if (remaining <= 0 || alloc_tmp == alloc_size) {
					strncat(cmd, bb, alloc_tmp);
					bb += alloc_tmp;
					break;
				} else {
					strncat(cmd, bb, alloc_tmp);
					if (!(bb[alloc_tmp - 1] == '\\'))
						state = 5;
					bb += alloc_tmp + 1;
					break;
				}
				break;
			case 5:
				// Check and write here
				printf("Keys: %s\n", keys);
				printf("Command: %s\n", cmd);

				// DO STUFF

				free(keys);
				free(cmd);
				keys = cmd = NULL;
				state = 0;
				break;
			default:
				exit(-1);
				break;

			}
		}
	}

	return 0;
}
