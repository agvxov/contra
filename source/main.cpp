#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <libgen.h>

#include "cli.h"

extern FILE * yyin;
extern FILE * yyout;
extern int yylex(void);

const char DEFAULT_QUOTE = '\'';
char quote = DEFAULT_QUOTE;
char * output = NULL;
char * input  = NULL;
const char * const csml_extension = ".csml";

enum input_type_t {
	CSML,
	XML,
	AUTO_DETECT,
} input_type = AUTO_DETECT;

const char * const auto_output_extensions[] = {csml_extension, ".html"};

char * output_name_from_input_name(const char * const input, const char * const extension) {
	char * input_duplicate = strdup(input);
	char * dn = strdup(dirname(input_duplicate));
	char * bn = strdup(basename(input_duplicate));
	free(input_duplicate);

	char * r = (char *)malloc(strlen(dn) + strlen(bn) + strlen(extension));
	strcpy(r, dn);
	strcat(r, bn);

    const char *last_dot = strrchr(bn, '.');
    if (last_dot) {
        strncpy(r, bn, last_dot - bn);
    } else {
        strcpy(r, bn);
    }

    strcat(r, extension);

	free(dn);
	free(bn);

    return r;
}

signed main(int argc, char * * argv) {
	switch (parse_r1_arguments(argc - 1, argv + 1)) {
		case 1: {
		} return 0;
		case 2: {
		} return 1;
		default: {
		} break;
	}
	
	for (int n = argc - 1; n; n--) {
		if (!strcmp(argv[n], "-c")) {
			input_type = input_type_t::CSML;
		} else if (!strcmp(argv[n], "-x")) {
			input_type = input_type_t::XML;
		} else if (!strcmp(argv[n], "-q")) {
			++n;
			quote = argv[n][0];
		} else if (!strcmp(argv[n], "-o")) {
			++n;
			output = argv[n];
		} else {
			/* --- Preparation --- */
			input = argv[n];

			if (input_type == AUTO_DETECT) {
				if (!strcmp(input + strlen(input) - (sizeof(csml_extension)-1), csml_extension)) {
					input_type = CSML;
				} else {
					input_type = XML;
				}
			}

			if (output) {
				yyout = fopen(output, "w");
			} else {
				yyout = stdout;
			}

			yyin  = fopen(input, "r");
			yyout = fopen(output, "w");

			/* --- Meat --- */
			yylex();

			/* --- Clean up --- */
			if (yyin != stdin) {
				fclose(yyin);
			}
			if (yyout != stdout) {
				fclose(yyout);
			}
			free(output);
			output = NULL;
		}
	}
}
