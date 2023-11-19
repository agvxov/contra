%{
#include "scanner.hpp"

#include <stdio.h>

#include "global.hpp"
#include "html_special.hpp"
#include "exit_values.hpp"

bool is_comment_multiline;
std::string current_tag;
unsigned xml_tag_stack = 0;
bool is_asymmetric;
char current_string_quote;

unsigned long long cursor_position = 0;
#define YY_USER_ACTION cursor_position += yyleng;

inline
static
void xml_tag_stack_push() {
	++xml_tag_stack;
}

inline
static
void xml_tag_stack_pop() {
	if (!xml_tag_stack) {
		exit(POLUTED_STACK);
	}
	--xml_tag_stack;
}
%}

%option noyywrap
%option nodefault
%option noyylineno

%x TAG_START TAG_MAYBE TAG
%x TAG_ASYMETRIC_SPECIAL
%x COMMENT
%x STRING
%x IGNORE IGNORE_COUNT_START IGNORE_COUNT_END

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]
identifier	[A-z!][A-z0-9]*

%%
<INITIAL>{
\<	{
	BEGIN TAG_START;
}
\<\!--	{
	is_comment_multiline = false;
	buffer = std::string("");
	BUFFER("//");
	BEGIN COMMENT;
}
&[A-z]+;	{
	ECHOS(html_special_to_utf8(html_special_table_lookup(yytext)));
}
&[0-9]+;	{
	ECHOS(html_special_to_utf8(yytext));
}
.|\n	{
	ECHO;
}
}

<COMMENT>{
.	{
	BUFFER(yytext);
}
\n	{
	BUFFER(yytext);
	is_comment_multiline = true;
}
--\>	{
	if (is_comment_multiline) {
		buffer[1] = '*';
		buffer   += "*/";
	}
	ECHOS(buffer.c_str());
	BEGIN INITIAL;
}
}

<TAG_START>{
\/{identifier}+{wsnl}*\>	{
	xml_tag_stack_pop();
	ECHOC('}');
	BEGIN INITIAL;
}
{identifier}+	{
	ECHO;
	current_tag = yytext;
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
	xml_tag_stack_push();
	ECHOS(" {");
	if (do_ignore(current_tag)) {
		buffer = std::string("");
		BEGIN IGNORE;
	} else {
		BEGIN INITIAL;
	}
}
\/\>	{
	ECHOC(';');
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
	BEGIN STRING;
}
=	{
	ECHOS(": ");
}
\>	{
	xml_tag_stack_push();
	ECHOS(") {");
	if (do_ignore(current_tag)) {
		buffer = std::string("");
		BEGIN IGNORE;
	} else {
		BEGIN INITIAL;
	}
}
\/\>	{
	ECHOS(");");
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
.\>	{
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
[^\\]\"|\'	{
	if (current_string_quote == yytext[1]) {
		ECHOC(yytext[0]);
		BEGIN TAG;
	} else {
		ECHO;
	}
}
,	{
	ECHOS("\\,");
}
.|\n	{
	ECHO;
}
}

<IGNORE>{
\<\/{identifier}+\>	{
	xml_tag_stack_pop();
	char * dup;
	dup = strdup(yytext);
	trim(dup);
	const int eq = !strcmp(dup, current_tag.c_str());
	free(dup);
	if (eq) {
		for (int i = 0; i < ignore_count; i++) {
			ECHOC('{');
		}
		ECHOS(buffer.c_str());
		for (int i = -1; i < ignore_count; i++) {
			ECHOC('}');
		}
		ignore_count = 1;
		BEGIN INITIAL;
	} else {
		BUFFER(yytext);
		ECHO;
	}
}
\{	{
	BUFFER(yytext);
	BEGIN IGNORE_COUNT_START;
}
\}	{
	BUFFER(yytext);
	BEGIN IGNORE_COUNT_END;
}
.|\n	{
	BUFFER(yytext);
}
}

<IGNORE_COUNT_START>{
\{	{
	BUFFER(yytext);
	++ignore_i;
}
}

<IGNORE_COUNT_END>{
\}	{
	BUFFER(yytext);
	++ignore_i;
}
}

<IGNORE_COUNT_START,IGNORE_COUNT_END>{
.|\n	{
	BUFFER(yytext);
	if (ignore_i > ignore_count) {
		ignore_count = ignore_i;
	}
	ignore_i = 0;
	BEGIN IGNORE;
}
}
%%
