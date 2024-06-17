%{
#include "scanner.hpp"

#include <stdio.h>

#include "global.hpp"
#include "html_special.hpp"
#include "exit_values.hpp"

static bool is_multiline_comment;
static char current_string_quote;

int state_buffer;

/* number of '{' & '}'s to be placed around the block contents
 */
static int extra_brace_count = 0;

/* number of '{' | '}'s so far; used for maximum search, updating extra_brace_count
 */
static int extra_brace_i = 0;
%}

%option noyywrap
%option nodefault
%option noyylineno

%x TAG_START TAG_MAYBE TAG
%x TAG_ASYMETRIC_SPECIAL
%x COMMENT
%x DECLARATION
%x STRING
%x BRACE_COUNT_START BRACE_COUNT_END

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]
identifier	[A-z][A-z0-9]*

%%
<INITIAL>{
\<	{
	ECHOS(buffer.c_str());
	buffer = "";
	BEGIN TAG_START;
}
\<\!--	{
	ECHOS(buffer.c_str());
	buffer = "";
	is_multiline_comment = false;
	BUFFER("//");
	BEGIN COMMENT;
}
\<\!	{
	ECHOS("#!");
	BEGIN DECLARATION;
}
&[A-z]+;	{
	BUFFER(html_special_to_utf8(html_special_table_lookup(yytext)));
}
&[0-9]+;	{
	BUFFER(html_special_to_utf8(yytext));
}
	/*
	[(){};] {
		ECHOC('\\');
		ECHOC(yytext[0]);
	}
	*/
\<\/{wsnl}*{identifier}+{wsnl}*\> {
	if (tag_stack.empty()) {
		exit(POLUTED_STACK);
	}

	char * dup = strdup(yytext);
	trim(dup);
	bool eq = (tag_stack.top() == dup);
	free(dup);
	if (not eq) {
		exit(ASSIMETRY);
	}

	for (int i = 0; i < extra_brace_count; i++) {
		ECHOC('{');
	}
	ECHOS(buffer.c_str());
	for (int i = -1; i < extra_brace_count; i++) {
		ECHOC('}');
	}

	buffer = "";
	extra_brace_count = 0;
	tag_stack.pop();
}
\{	{
	BUFFER(yytext);
    yyless(0);
	BEGIN BRACE_COUNT_START;
}
\}	{
	BUFFER(yytext);
	BEGIN BRACE_COUNT_END;
}
.|\n	{
	BUFFER(yytext);
}
}

<COMMENT>{
--\>	{
	if (is_multiline_comment) {
		buffer[1] = '*';
		buffer	 += "*/";
	}
	ECHOS(buffer.c_str());
	buffer = "";
	BEGIN INITIAL;
}
.	{
	BUFFER(yytext);
}
\n	{
	BUFFER(yytext);
	is_multiline_comment = true;
}
}

<DECLARATION>{
\>	{
	ECHOC(';');
	BEGIN INITIAL;
}
\'|\"	{
	ECHO;
	current_string_quote = yytext[0];
	state_buffer = DECLARATION;
	BEGIN STRING;
}
.|\n	{
	ECHO;
}
}

<TAG_START>{
{identifier}+	{
	ECHO;
	tag_stack.emplace(yytext);
	BEGIN TAG_MAYBE;
}
.	{
	is_asymmetric = std::find(asymmetric_special_list.begin(),
								asymmetric_special_list.end(),
								yytext)
					!= asymmetric_special_list.end();
	if (is_asymmetric) {
		ECHOC('<');
		ECHO;
		BEGIN TAG_ASYMETRIC_SPECIAL;
	} else {
		exit(UNRECOGNIZED_TAG);
	}
}
}

<TAG_MAYBE>{
\>	{
	ECHOS(" {");
	BEGIN INITIAL;
}
\/\>	{
	ECHOC(';');
	tag_stack.pop();
	BEGIN INITIAL;
}
{wsnl}	{
	ECHO;
}
.	{
	yyless(0);
	ECHOC('(');
	BEGIN TAG;
}
}

<TAG>{
\"|\'	{
	current_string_quote = yytext[0];
	state_buffer = TAG;
	BEGIN STRING;
}
=	{
	ECHOS(": ");
}
\>	{
	ECHOS(") {");
	BEGIN INITIAL;
}
\/\>	{
	ECHOS(");");
	tag_stack.pop();
	BEGIN INITIAL;
}
{ws}	{
	ECHOS(", ");
}
.|\n	{
	ECHO;
}
}

<TAG_ASYMETRIC_SPECIAL>{
.\> {
	ECHO;
	is_asymmetric = std::find(asymmetric_special_list.begin(),
								asymmetric_special_list.end(),
								(std::string("") + yytext[0]))
					!= asymmetric_special_list.end();
	if (is_asymmetric) {
		BEGIN INITIAL;
	}
}
.|\n	{
	ECHO;
}
}

<STRING>{
[^\\](\"|\')	{
	if (current_string_quote == yytext[1]) {
		{
			// XXX: this is such a hack
			switch (yytext[0]) {
				case ',':
				case '(':
				case ')':
				ECHOC('\\');
			}
			ECHOC(yytext[0]); 
		}
		if (state_buffer == DECLARATION) {
			ECHOC(yytext[1]);
		}
		BEGIN state_buffer;
	} else {
		ECHO;
	}
}
[,)(]	{
	ECHOC('\\');
	ECHOC(yytext[0]);
}
.|\n	{
	ECHO;
}
}

<BRACE_COUNT_START>{
\{	{
	++extra_brace_i;
}
}

<BRACE_COUNT_END>{
\}	{
	++extra_brace_i;
}
}

<BRACE_COUNT_START,BRACE_COUNT_END>{
.|\n	{
	yyless(0);
	if (extra_brace_i > extra_brace_count) {
		extra_brace_count = extra_brace_i;
	}
	extra_brace_i = 0;
	BEGIN INITIAL;
}
}
%%
