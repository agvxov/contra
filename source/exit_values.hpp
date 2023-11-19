const static int EXIT_EARLY_SUCCESS = 400;
enum {
	UNKNOWN_OPTION   = 1,
	IO_ERROR         = 2,
	UNKNOWN_SET      = 3,
	POPULATED_STACK  = 4,	// most likely signals that more tags were opened than closed, ie the user forgot adding a '}' somewhere
	TAG_NOT_NAMED    = 5,
	TAG_NOT_FOUND    = 6,
	UNRECOGNIZED_TAG = 7,
};
