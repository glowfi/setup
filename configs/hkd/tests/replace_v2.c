#define _POSIX_C_SOURCE 200809L

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <ctype.h>

char * replace (const char *s, const char *m, const char *r)
{
	char *new_s = strdup(s);
	int ms = strlen(m), rs = strlen(r);
	char *pos, *tmp;
	int off = 0;
	
	while((pos = strstr(new_s + off, m))) {
		int ps = strlen(pos), ss = strlen(new_s);

		if (rs > ms) {
			if (!(tmp = realloc(new_s, ss + 1 + (rs - ms))))
				exit(-10);
			new_s = tmp;
		}

		memmove(pos + rs, pos + ms, ps - ms);
		memcpy(pos, r, rs);
		off += rs;	
	}
	return new_s;
}

char * replace_fast (const char *s, const char *m, const char *r)
{
	char *new_s = strdup(s);
	int ms = strlen(m), rs = strlen(r);
	char *t1;

	int count = 0;
	int *offs = NULL, o = 0, *t2;
	int nss = strlen(new_s);
	while ((t1 = strstr(new_s + o, m))) {
		if (!(t2 = realloc(offs, sizeof(int) * (count + 1))))
			exit(-10);
		offs = t2;
		offs[count] = (t1 - new_s) + (rs - ms) * count;
		o = (t1 - new_s) + 1;
		count++;
	}

	if ((rs - ms) > 0) {
		if (!(t1 = realloc(new_s, nss + (rs - ms) * count)))
			exit(-5);
		new_s = t1;
	}

	for (int i = 0; i < count; i++) {
		char* x = new_s + offs[i];
		int d = strlen(x) - ms;
		memmove(x + rs, x + ms, d);
		memcpy(x, r, rs);
	}

	return new_s;
}

void replace_fast_2 (char **s, const char *m, const char *r)
{
	char **new_s = s;
	int ms = strlen(m), rs = strlen(r);
	char *t1;

	int count = 0;
	int *offs = NULL, o = 0, *t2;
	int nss = strlen(*new_s);
	while ((t1 = strstr(*new_s + o, m))) {
		/* check if the match is surrounded by whitespace */
		if ((t1[ms] == '\0' || isblank(t1[ms]))
			&& isblank(t1 > *new_s ? *(t1 - 1) : ' ')) {
			if (!(t2 = realloc(offs, sizeof(int) * (count + 1))))
				exit(-1);
			offs = t2;
			offs[count] = (t1 - *new_s) + (rs - ms) * count;
			count++;
		}
		o = (t1 - *new_s) + 1;

	}

	if ((rs - ms) > 0) {
		if (!(t1 = realloc(*new_s, nss + (rs - ms) * count)))
			exit(-1);
		*new_s = t1;
	}

	for (int i = 0; i < count; i++) {
		char* x = *new_s + offs[i];
		int d = strlen(x) - ms;
		memmove(x + rs, x + ms, d);
		memcpy(x, r, rs);
	}
	if (offs)
		free(offs);
}


int main(void){
	clock_t t1, t2;
	char *s = " volup";

	
	printf("Before: %s\n", s);
	if ((t1 = clock()) == (clock_t)-1)
		exit(-1);
	char *r = replace(s, "volup", "I am alive, I'm aliveeeeee!");
	t2 = clock();
	printf("After replace: %s\n", r);
	printf("Time took: %f\n\n", (t2-t1)/(CLOCKS_PER_SEC/10e3));
	free(r);


	printf("Before: %s\n", s);
	if ((t1 = clock()) == (clock_t)-1)
		exit(-1);
	char *x = replace_fast(s, "volup", "I am alive, I'm aliveeeeee!");
	t2 = clock();
	printf("After replace_fast: %s\n", x);
	printf("Time took: %f\n\n", (t2-t1)/(CLOCKS_PER_SEC/10e3));
	free(x);

	printf("Before: %s\n", s);
	char *s1 = strdup(s);
	if ((t1 = clock()) == (clock_t)-1)
		exit(-1);
	replace_fast_2(&s1, "volup", "I am alive, I'm aliveeeeee!");
	t2 = clock();
	printf("After replace_fast: %s\n", s1);
	printf("Time took: %f\n\n", (t2-t1)/(CLOCKS_PER_SEC/10e3));
	free(s1);
	
	return 0;
}
