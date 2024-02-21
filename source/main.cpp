#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <libgen.h>
#include <vector>
#include <string>

#include "cli.hpp"
#include "scanner.hpp"
#include "exit_values.hpp"

std::vector<std::string> ignore_list;
std::vector<std::string> asymmetric_special_list;

bool is_asymmetric;

std::string buffer;
std::string tag_candidate;

std::stack<std::string> tag_stack;

extern int xml_lex_destroy(void);
extern int csml_lex_destroy(void);

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

void trim(char * const s) {
	int bp = 0;
	int len = strlen(s);
	bool do_break = false;
	for (int i = 0; i < len; i++) {
		if ((s[i] >= 'A' && s[i] <= 'Z')
		||  (s[i] >= 'a' && s[i] <= 'z')
		||  (s[i] >= '0' && s[i] <= '9')
		||  (s[i] == '_')) {
			s[bp++] = s[i];
			do_break = true;
		} else if (do_break) {
			break;
		}
	}
	s[bp] = '\0';
}

void trim(std::string &s) {
	char * dup = strdup(s.c_str());
	trim(dup);
	s = std::string(dup);
	free(dup);
}

signed main(int argc, char * * argv) {
	const int b = parse_round1_arguments(argc, argv);
	switch (b) {
		case 0: break;
		case EXIT_EARLY_SUCCESS: exit(EXIT_SUCCESS);
		default: exit(b);
	}

	parse_round2_arguments(argc - 1, argv + 1);

	xml_lex_destroy();
	csml_lex_destroy();
	
	return EXIT_SUCCESS;
}
