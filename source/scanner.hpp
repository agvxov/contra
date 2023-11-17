#ifndef SCANNER_H

#include <vector>
#include <string>
#include <algorithm>

#define ECHOS(s) fwrite(s, strlen(s), sizeof(char), yyout)
#define ECHOC(c) fputc(c, yyout)

extern std::vector<std::string> ignore_list;

inline
bool do_ignore(const std::string &current_tag) {
	return std::find(ignore_list.begin(),
	                 ignore_list.end(),
	                 current_tag)
		!= ignore_list.end();
} 

extern int ignore_count;	// number of '{' / '}'s to be placed around the current ignored block
extern int ignore_i; // number of '}'s so far

#define SCANNER_H
#endif
