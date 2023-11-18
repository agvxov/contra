#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <libgen.h>
#include <vector>
#include <string>
#include <stack>
#include <map>

#include "cli.hpp"
#include "scanner.hpp"
#include "exit_values.hpp"

extern std::stack<std::string> tag_stack;

#define DECLARE_LEXER(x)       \
	extern FILE * x ## in;     \
	extern FILE * x ## out;    \
	extern int x ## lex(void); \

DECLARE_LEXER(csml);
DECLARE_LEXER(xml);

const char DEFAULT_QUOTE = '\'';
char quote = DEFAULT_QUOTE;
char * output = NULL;
char * input  = NULL;
const char * const csml_extension = ".csml";

const std::map<const char * const, std::vector<std::string>> sets = {
	{"$html", {"style", "script"}},
};

enum class input_type_t {
	CSML,
	XML,
	AUTO_DETECT,
} input_type = input_type_t::AUTO_DETECT;

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
	/* --- Preparation --- */
	if (output) {
		try_fopen(yyout, output, "w");
	} else {
		yyout = stdout;
	}
	try_fopen(yyin, input, "r");


	/* --- Meat --- */
	yylex_();

	/* --- Clean up --- */
	if (yyin != stdin) {
		fclose(yyin);
	}
	if (yyout != stdout) {
		fclose(yyout);
	}
}

signed main(int argc, char * * argv) {
	{
		const int b = parse_round1_arguments(argc - 1, argv + 1);
		switch (b) {
			case 0: break;
			case EXIT_EARLY_SUCCESS: exit(EXIT_SUCCESS);
			default: exit(b);
		}
	}
	
	for (int n = 1; n < argc; n++) {
		if (!strcmp(argv[n], "-c")) {
			input_type = input_type_t::CSML;
		} else if (!strcmp(argv[n], "-x")) {
			input_type = input_type_t::XML;
		} else if (!strcmp(argv[n], "-q")) {
			++n;
			quote = argv[n][0];
		} else if (!strcmp(argv[n], "-i")) {
			++n;
			const char * delimiter = ":";
			char * data = strtok(argv[n], delimiter);
			int i = 0;
			do {
				if (data[0] == '$') {
					const auto &&set = sets.find("$html");
					[[ likely ]] if (set != sets.end()) {
						ignore_list.insert(ignore_list.begin(), set->second.begin(), set->second.end());
					} else {
						exit(UNKNOWN_SET);
					}
				} else [[ likely ]] {
					ignore_list.emplace_back(data);
				}
				++i;
			} while((data = strtok(NULL, delimiter), data));
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
					yylex(csmlin, csmlout, csmllex);
					if (not tag_stack.empty()) {
						exit(POPULATED_STACK);
					}
				} break;
				case input_type_t::XML: {
					yylex(xmlin, xmlout, xmllex);
				} break;
				default: {
				};
			}

			output = NULL;
		}
	}

	return EXIT_SUCCESS;
}
