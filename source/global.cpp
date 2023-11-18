#include "global.hpp"

#include <string.h>
#include <string>
#include <vector>

std::vector<std::string> ignore_list;
int ignore_count = 1;
int ignore_i = 1;
std::string buffer;

void trim(char * const s) {
	int bp = 0;
	int len = strlen(s);
	bool do_break = false;
	int i = 0;
	for (;i < len; i++) {
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
