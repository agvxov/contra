%{
#include "scanner.hpp"

#include <stdio.h>
#include <string>

#include "exit_values.hpp"
#include "html_special.hpp"
#include "global.hpp"

/* number of '}'s to recognize as the end
 *  of the current ignired block
 */
static int ignore_count = 1;

/* number of '}' so far; used for maximum search, updating ignore_count
 */
static int ignore_i = 1;

static
void _ECHO_CANDIDATE(){
	if (tag_candidate != "") {
		ECHOS(tag_candidate.c_str());
	}
}

#define ECHO_CANDIDATE _ECHO_CANDIDATE()
#define FLUSH_CANDIDATE do { _ECHO_CANDIDATE(); tag_candidate = ""; } while (0)

static const char COMMENT_START[] = "<!--";
static const char COMMENT_END[]   = "-->";

const char DEFAULT_QUOTE = '\'';
char quote = DEFAULT_QUOTE;

static unsigned short current_unicode_size;

static
void push_tag() {
	if (tag_candidate == "") {
		exit(TAG_NOT_NAMED);
	}

	trim(tag_candidate);
	tag_stack.push(tag_candidate);
	tag_candidate = "";
}

static
void pop_tag() {
	if (tag_stack.empty()) {
		exit(TAG_NOT_FOUND);

	}
	tag_stack.pop();
	tag_candidate = "";
}


%}

%option noyywrap
%option nodefault
%option noyylineno

%x BODY HEAD HEAD_VALUE
%x COMMENT COMMENT_MULTILINE
%x IGNORE IGNORE_COUNT_START IGNORE_COUNT_END
%x TAG_ASYMETRIC_SPECIAL
%s DECLARATION
%s UNICODE

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]
nwsnl		[^ \t\r\v\f\n]
identifier	[A-Za-z][A-Za-z0-9]*
unicode		[\300-\364]

%%
	BEGIN BODY;

<BODY>{
\/\/	{
	BEGIN COMMENT;
	ECHOS(COMMENT_START);
}
\/\*	{
	BEGIN COMMENT_MULTILINE;
	ECHOS(COMMENT_START);
}
{identifier}{wsnl}*	{
	ECHO_CANDIDATE;
	tag_candidate = yytext;
}
\(	{
	push_tag();
	ECHOS(("<" + tag_stack.top() + " ").c_str());
	BEGIN HEAD;
}
&#?{identifier};	{
	FLUSH_CANDIDATE;
	ECHO;
}
;	{
	ECHOS(("<" + tag_candidate + "/>").c_str());
	tag_candidate = "";
}
\{	{
	push_tag();
	ECHOS(("<" + tag_stack.top() + ">").c_str());
	BEGIN IGNORE_COUNT_START;
}
\}	{
	ECHO_CANDIDATE;
	ECHOS(("</" + tag_stack.top() + ">").c_str());
	pop_tag();
}
\#\!	{
	FLUSH_CANDIDATE;
	ECHOS("<!");
	BEGIN DECLARATION;
}
{unicode}	{
	FLUSH_CANDIDATE;

	const char mask = (char)0b100000000;
	const char &header = yytext[0];
	current_unicode_size = 2;
	for (int i = 2; (mask >> i) & header; i++) {
		++current_unicode_size;
	}
	yyless(0);
	BEGIN UNICODE;
}
\<{nwsnl}*	{
	{	// XXX: this is way too expensive
		const auto filter = [yyleng, yytext](std::string e){
								return e == std::string(yytext+1).substr(0, e.size());
							};
		const auto search_result = std::find_if(asymmetric_special_list.begin(),
												asymmetric_special_list.end(),
												filter
											);
		is_asymmetric = search_result != asymmetric_special_list.end();
		if (is_asymmetric) {
			ECHO;
			BEGIN TAG_ASYMETRIC_SPECIAL;
		} else {
			FLUSH_CANDIDATE;
			ECHOS("&lt;");
		}
	}
}
\>	{
	FLUSH_CANDIDATE;
	ECHOS("&gt;");
}
.|{wsnl}	{
	FLUSH_CANDIDATE;
	ECHO;
}
}

<COMMENT>{
\n	{
	ECHOS(COMMENT_END);
	ECHO;
	BEGIN BODY;
}
}

<COMMENT_MULTILINE>{
\*\/	{
	ECHOS(COMMENT_END);
	BEGIN BODY;
}
\n	{
	ECHO;
}
}

<COMMENT,COMMENT_MULTILINE>{
.	{
	ECHO;
}
}

<HEAD>{
\){wsnl}*\{	{
	ECHOC('>');
	BEGIN BODY;
}
\){wsnl}*;	{
	pop_tag();
	ECHOS("/>");
	BEGIN BODY;
}
:{wsnl}*	{
	ECHOC('=');
	ECHOC(quote);
	BEGIN HEAD_VALUE;
}
.|\n	{
	ECHO;
}
}

<HEAD_VALUE>{
,	{
	ECHOC(quote);
	BEGIN HEAD;
}
\)	{
	ECHOC(quote);
	yyless(0);
	BEGIN HEAD;
}
.|\n	{
	ECHO;
}
}

<IGNORE_COUNT_START>{
\{	{
	++ignore_count;
}
.|\n	{
	if (ignore_count == 1) {
		yyless(0);
		BEGIN BODY;
	} else {
		BUFFER(yytext);
		BEGIN IGNORE;
	}
}
}

<IGNORE_COUNT_END>{
\}	{
	if (++ignore_i >= ignore_count) {
		ignore_i = 1;
		ignore_count = 1;

		ECHOS(buffer.c_str());
		buffer = "";
		ECHOS(("</" + tag_stack.top() + ">").c_str());
		pop_tag();
		BEGIN BODY;
	}
}
.|\n	{
	while (ignore_i--) {
		BUFFER('}');
	}
	ignore_i = 1;
	BUFFER(yytext);
	BEGIN IGNORE;
}
}

<IGNORE>{
\\[{|}]	{
	ECHOC(yytext[1]);
}
\}	{
	if (ignore_count != 1) {
		BEGIN IGNORE_COUNT_END;
	} else {
		ECHOS(buffer.c_str());
		ECHOS(("</" + tag_stack.top() + ">").c_str());
		pop_tag();
		BEGIN BODY;
	}
}
.|\n	{
	BUFFER(yytext);
}
}

<TAG_ASYMETRIC_SPECIAL>{
.\>	{
	ECHO;
	is_asymmetric = std::find(asymmetric_special_list.begin(),
								asymmetric_special_list.end(),
								(std::string("") + yytext[0]))
					!= asymmetric_special_list.end();
	if (is_asymmetric) {
		BEGIN BODY;
	}
}
.|\n	{
	ECHO;
}
}

<DECLARATION>{
[^\\];	{
	ECHOC(yytext[0]);
	ECHOC('>');
	BEGIN BODY;
}
.|\n	{
	ECHO;
}
}

<UNICODE>{
(.|\n){4}	{
	static char current_unicode[5];
	memcpy(current_unicode, yytext, 5);
	current_unicode[current_unicode_size] = '\0';

	yyless(4 - current_unicode_size);
	ECHOS(utf8_to_html_special(current_unicode));
	BEGIN BODY;
}
}

<*>{
\\[(){},:;]	{
	ECHO_CANDIDATE;
	tag_candidate = "";
	ECHOC(yytext[1]);
}
}

%%
