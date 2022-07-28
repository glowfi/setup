//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"",        "networkTraffic.sh",    1,		         16},
	{"",        "network.sh",       	1,		         4},
	{"",        "resources.sh",       	1,		         0},
	{"",        "volume.sh",       	    1,		         10},
	{"",        "brightness.sh",       	1,		         10},
	{"",        "battery.sh",       	1,		         3},
	{"",        "time_date.sh",       	1,		         1},
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = " | ";
static unsigned int delimLen = 5;
