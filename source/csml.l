%{
#include "scanner.hpp"

#include <stdio.h>
#include <stack>
#include <string>

#include "exit_values.hpp"
#include "html_special.hpp"
#include "global.hpp"

std::stack<std::string> csml_tag_stack;

static std::string tag_candidate = "";

static
void _ECHO_CANDIDATE(){
	if (tag_candidate != "") {
		ECHOS(tag_candidate.c_str());
	}
}

#define ECHO_CANDIDATE _ECHO_CANDIDATE()

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
	csml_tag_stack.push(tag_candidate);
	tag_candidate = "";
}

static
void pop_tag() {
	if (csml_tag_stack.empty()) {
		exit(TAG_NOT_FOUND);

	}
	csml_tag_stack.pop();
	tag_candidate = "";
}


%}

%option noyywrap
%option nodefault
%option noyylineno

%x BODY HEAD HEAD_VALUE
%x COMMENT COMMENT_MULTILINE
%x IGNORE IGNORE_COUNT_START IGNORE_COUNT_END
%s UNICODE

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]
identifier	[A-z][A-z0-9]*
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
	ECHOS(("<" + csml_tag_stack.top() + " ").c_str());
	BEGIN HEAD;
}
&#?{identifier};	{
	ECHO_CANDIDATE;
	tag_candidate = "";
	ECHO;
}
;	{
	ECHOS(("<" + tag_candidate + "/>").c_str());
	tag_candidate = "";
}
\{	{
	push_tag();
	ECHOS(("<" + csml_tag_stack.top() + ">").c_str());
	if (do_ignore(csml_tag_stack.top())) {
		buffer = std::string("");
		BEGIN IGNORE_COUNT_START;
	}
}
\}	{
	ECHO_CANDIDATE;
	ECHOS(("</" + csml_tag_stack.top() + ">").c_str());
	pop_tag();
}
\<	{
	ECHO_CANDIDATE;
	tag_candidate = "";
	ECHOS("&lt;");
}
\>	{
	ECHO_CANDIDATE;
	tag_candidate = "";
	ECHOS("&gt;");
}
{unicode}	{
	ECHO_CANDIDATE;
	tag_candidate = "";

	const char mask = (char)0b100000000;
	const char &header = yytext[0];
	current_unicode_size = 2;
	for (int i = 2; (mask >> i) & header; i++) {
		++current_unicode_size;
	}
	yyless(0);
	BEGIN UNICODE;
}
.|{wsnl}	{
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
	BUFFER(yytext);
	BEGIN IGNORE;
}
}

<IGNORE_COUNT_END>{
\}	{
	if (++ignore_i >= ignore_count) {
		ignore_i = 0;
		ignore_count = 1;

		ECHOS(buffer.c_str());
		ECHOS(("</" + csml_tag_stack.top() + ">").c_str());
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
		ECHOS(("</" + csml_tag_stack.top() + ">").c_str());
		pop_tag();
		BEGIN BODY;
	}
}
.|\n	{
	BUFFER(yytext);
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
	ECHOC(yytext[1]);
}
}

%%
