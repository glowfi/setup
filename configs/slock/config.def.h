/* user and group to drop privileges to */
static const char *user  = "";
static const char *group = "";

static const char *colorname[NUMCOLS] = {
	[INIT] =   "black",     /* after initialization */
	[INPUT] =  "#458588",   /* during input */
	[FAILED] = "#CC241D",   /* wrong password */
};

/* treat a cleared input like a wrong password (color) */
static const int failonclear = 1;

/* default message */
static const char * message ="\n"
"Pssst......\n"
"\n"
"\n"
"If you are reading this and wondering what this is then let \n"
"me tell you that I am currently taking a nap PLEASE DO NOT DISTURB ME!\n"
"If you want me to wake up and make me do all the menial jobs you humans give me\n"
"then start typing the correct password.Bye can't talk much I'm feeling sleepy...\n"
"Hope you enter the wrong password.\n"
"\n"
"\n"
"\n"
"\n"
"\n"
"\n"
"\n"
"PS: If you are not my owner please take me with you.\n"
"I wont take much space and do anything you want.\n"
"My owner's a trash,he bullies me.\n";

/* text color */
static const char * text_color = "#ffffff";

/* text size (must be a valid size) */
static const char * font_name = "6x13";
