#ifndef SCANNER_H

#include <vector>
#include <string>
#include <algorithm>
#include <stack>

#define DECLARE_LEXER(x)                   \
	extern FILE * x ## _in;                \
	extern FILE * x ## _out;               \
	extern int    x ## _lex(void);         \
	extern int    x ## _lex_destroy(void);

DECLARE_LEXER(csml);
DECLARE_LEXER(xml);

#define ECHOS(s) do {                            \
	const char * const  ss = s;                  \
	fwrite(ss, strlen(ss), sizeof(char), yyout); \
} while (0)
#define ECHOC(c) fputc(c, yyout)
#define BUFFER(s) buffer += s

extern std::vector<std::string> asymmetric_special_list;

extern bool is_asymmetric;

extern char quote;

/* used for saving sections whichs starting projection
 *  cannot be determined before reading the while
 *  (e.g. comments (single- or multiline?))
 */
extern std::string buffer;

extern std::stack<std::string> tag_stack;

extern std::string tag_candidate;

#define SCANNER_H
#endif
