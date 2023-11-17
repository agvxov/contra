%{
#include "scanner.hpp"

#include <stdio.h>

bool is_comment_multiline = false;
unsigned long long comment_begining;
std::string current_tag;
long ignore_start;
static int ignore_count = 1;
static int ignore_i = 1;

unsigned long long cursor_position = 0;
#define YY_USER_ACTION cursor_position += yyleng;
%}

%option noyywrap
%option nodefault
%option noyylineno

%x TAG_START TAG_MAYBE TAG
%x COMMENT
%x STRING
%x IGNORE IGNORE_SEEK IGNORE_COUNT_START IGNORE_COUNT_END

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]
identifier	[A-z][A-z0-9]*

%%
<INITIAL>{
\<	{
	BEGIN TAG_START;
}
\<\!--	{
	comment_begining = cursor_position;
	ECHOS("//");
	BEGIN COMMENT;
}
.|\n	{
	ECHO;
}
}

<COMMENT>{
.	{
	ECHO;
}
\n	{
	is_comment_multiline = true;
}
--\>	{
	if (is_comment_multiline) {
		auto buffer = ftell(yyin);
		fseek(yyin, comment_begining+1, SEEK_SET);
		fputc('*', yyin);
		fseek(yyin, buffer, SEEK_SET);
	}
	BEGIN INITIAL;
}
}

<TAG_START>{
\/{identifier}+{wsnl}*\>	{
	ECHOC('}');
	BEGIN INITIAL;
}
{identifier}+	{
	ECHO;
	current_tag = yytext;
	BEGIN TAG_MAYBE;
}
}

<TAG_MAYBE>{
\>	{
	ECHOS(" {");
	if (do_ignore(current_tag)) {
		ignore_start = cursor_position;
		BEGIN IGNORE_SEEK;
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
	BEGIN STRING;
}
=	{
	ECHOS(": ");
}
\>	{
	ECHOS(") {");
	if (do_ignore(current_tag)) {
		ignore_start = cursor_position;
		BEGIN IGNORE_SEEK;
	} else {
		BEGIN INITIAL;
	}
}
\/\>	{
	ECHOC(';');
	BEGIN INITIAL;
}
.|\n	{
	ECHO;
}
}

<STRING>{
[^\\]\"|\'	{
	BEGIN TAG;
}
,	{
	ECHOS("\\,");
}
.|\n	{
	ECHO;
}
}

<IGNORE_SEEK>{
\<\/{identifier}+\>	{
	// XXX: if $identifier == yytext
	for (int i = 0; i < ignore_count; i++) {
		ECHOC('{');
	}
	fseek(yyin, ignore_start, SEEK_SET);
	YY_FLUSH_BUFFER;
	BEGIN IGNORE;
}
\{	{
	BEGIN IGNORE_COUNT_START;
}
\{	{
	BEGIN IGNORE_COUNT_END;
}
.|\n	{
}
}

<IGNORE_COUNT_START>{
\{	{
	++ignore_i;
}
}

<IGNORE_COUNT_END>{
\}	{
	++ignore_i;
}
}

<IGNORE_COUNT_START,IGNORE_COUNT_END>{
.|\n	{
	if (ignore_i > ignore_count) {
		ignore_count = ignore_i;
	}
	ignore_i = 0;
	BEGIN IGNORE_SEEK;
}
}

<IGNORE>{
\<\/{identifier}+\>	{
	// XXX: if $identifier == yytext
	for (int i = -1; i < ignore_count; i++) {
		ECHOC('}');
	}
	ignore_count = 1;
	BEGIN INITIAL;
}
	/*
[{|}]	{
	ECHOC('\\');
	ECHOC(yytext[0]);
}
	*/
.|\n	{
	ECHO;
}
}
%%
