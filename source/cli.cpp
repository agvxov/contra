#include "cli.hpp"

#include <getopt.h>
#include <stdio.h>
#include <string.h>
#include <stack>

#include "exit_values.hpp"
#include "scanner.hpp"

extern std::stack<std::string> csml_tag_stack;
extern unsigned xml_tag_stack;

const char * const csml_extension = ".csml";

static
const char * const version =
# include "version.inc"
;

static
const char * const help_message =
"contra [options] <file>+\n"
"    -c          : the input is to be force interpeted as CSML\n"
"    -x          : the input is to be force interpeted as XML/HTML\n"
"    -s <string> : colon separeted list of option sets\n"
"    -S <string> : colon separeted list of special asymetric tags starters\n"
"    -i <string> : colon separeted list of tags which contents should be ignored\n"
"    -o <file>   : specify output file name for the NEXT input file\n"
"    -q <char>   : use <char> for quoting (default: \"'\")\n"
"    -v          : print version and quit\n"
"    -h          : print help and quit\n"
;

const char * output = NULL;
const char * input  = NULL;

enum class input_type_t {
	CSML,
	XML,
	AUTO_DETECT,
} input_type = input_type_t::AUTO_DETECT;

// ### Local functions ###
static
inline
void try_fopen(FILE * &file, const char * const path, const char * const mode) {
	file = fopen(path, mode);
	if (!file) {
		fprintf(stderr, "Error opening file '%s'.\n", path);
		fflush(stderr);
		exit(IO_ERROR);
	} 
}

static
void yylex(FILE * &yyin, FILE * &yyout, int (*yylex_)(void)) {
	if (output) {
		try_fopen(yyout, output, "w");
	} else {
		yyout = stdout;
	}
	try_fopen(yyin, input, "r");


	yylex_();

	if (yyin != stdin) {
		fclose(yyin);
	}
	if (yyout != stdout) {
		fclose(yyout);
	}
}

// ### global functions ###
extern "C"
signed parse_round1_arguments(int argc, char * * argv){
	const char * const optstring = "-" "hv" "cxs:S:i:o:q:";

    static struct option long_options[] = {
        {"help", no_argument, 0, 'h'},
        {"version", no_argument, 0, 'v'},
        {0, 0, 0, 0}
    };
	
	char opt;
    while ((opt = getopt_long(argc, argv, optstring, long_options, NULL)) != -1) {
        switch (opt) {
            case 'h': {
				fputs(help_message, stdout);
			} return EXIT_EARLY_SUCCESS;
            case 'v': {
				fputs(version, stdout);
			} return EXIT_EARLY_SUCCESS;
            case '?': {
			} return UNKNOWN_OPTION;
			default: {
			} break;
        }
    }

	return 0;
}

extern "C"
signed parse_round2_arguments(int argc, char * * argv) {
	for (int n = 0; n < argc; n++) {
		if (!strcmp(argv[n], "-c")) {
			input_type = input_type_t::CSML;
		} else if (!strcmp(argv[n], "-x")) {
			input_type = input_type_t::XML;
		} else if (!strcmp(argv[n], "-q")) {
			++n;
			quote = argv[n][0];
		} else if (!strcmp(argv[n], "-i")) {
			++n;
			parse_colon_list(argv[n], ignore_list);
		} else if (!strcmp(argv[n], "-s")) {
			++n;
			const int err = parse_sets(argv[n]);
			if (err) {
				exit(err);
			}
		} else if (!strcmp(argv[n], "-S")) {
			++n;
			parse_colon_list(argv[n], asymmetric_special_list);
		} else if (!strcmp(argv[n], "-o")) {
			++n;
			output = argv[n];
		} else {
			input = argv[n];

			if (input_type == input_type_t::AUTO_DETECT) {
				if (!strcmp(input + strlen(input) - (sizeof(csml_extension)-1), csml_extension)) {
					input_type = input_type_t::CSML;
				} else {
					input_type = input_type_t::XML;
				}
			}

			switch (input_type) {
				case input_type_t::CSML: {
					yylex(csml_in, csml_out, csml_lex);
					if (not csml_tag_stack.empty()) {
						exit(POLUTED_STACK);
					}
				} break;
				case input_type_t::XML: {
					yylex(xml_in, xml_out, xml_lex);
					if(xml_tag_stack) {
						exit(POLUTED_STACK);
					}
				} break;
				default: {
				};
			}

			output = NULL;
		}
	}

	return 0;
}

extern "C"
signed parse_colon_list(char * const list, std::vector<std::string> destination) {
	const char * delimiter = ":";
	char * data = strtok(list, delimiter);
	int i = 0;
	do {
		destination.emplace_back(data);
		++i;
	} while((data = strtok(NULL, delimiter), data));

	return 0;
}

extern "C"
signed parse_sets(char * const list) {
	const char * delimiter = ":";
	char * data = strtok(list, delimiter);
	int i = 0;
	do {
		if (!strcmp(data, "html")) {
			ignore_list.emplace_back("style");
			ignore_list.emplace_back("script");
			asymmetric_special_list.emplace_back("?");
		} else if (!strcmp(data, "xml")) {
			asymmetric_special_list.emplace_back("?");
		} else {
			return UNKNOWN_SET;
		}
		++i;
	} while((data = strtok(NULL, delimiter), data));
	
	return 0;
}
