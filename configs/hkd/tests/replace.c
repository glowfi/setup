#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* recursively replaces every instance of m(match) with r(eplace) inside of s */
void replace (char *s, const char *m, const char *r)
{
	static int off = 0;
	int d = strlen(r) - strlen(m);
	int ss = strlen(s);
	char *pos;
	
	if ((pos = strstr(s + off, m))) {
		
		char *tmp;
		int rs = strlen(r);
		int ms = strlen(m);
		
		if (d > 0) {
			if (!(tmp = realloc(s, ss + 2 + d)))
				exit(-1);
			s = tmp;
		}
		memmove(pos + rs, pos + ms, strlen(pos) - ms + 1);
		memcpy(pos, r, rs);
		off += rs;
		replace(s, m, r);
	}
	return;
}

int main (void) {
	char *s = strdup(" volup");

	printf("original: %s\n", s);
	replace(s, "volup", "this short, like a lot--------");
	printf("replaced: %s\n", s);

	free(s);
	return 0;
}
