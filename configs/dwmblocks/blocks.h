//Modify this file to change what commands output to your statusbar, and recompile using the make command.
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/
	{"",        "networkTraffic.sh",    1,		         0},
	{"",        "network.sh",       	1,		         0},
	{"",        "resources.sh",       	1,		         0},
	{"",        "volume.sh",       	    1,		         0},
	{"",        "brightness.sh",       	1,		         0},
	{"",        "battery.sh",       	1,		         0},
	{"",        "time_date.sh",       	1,		         0},
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = " | ";
static unsigned int delimLen = 5;
