#include <stdio.h>

#define HELL 10
#define IDE 220
#define MAKE_ENTRY(value) {"value", value}
const struct {
	const char * const name;
	const unsigned short value;
} init[] = {
{"lol", 1},
{"hello", HELL},
MAKE_ENTRY(IDE)
};

int main (void) {
	printf("%s\t%d\n", init[2].name, init[2].value);
	return 0;
}
