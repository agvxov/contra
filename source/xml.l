%{
#include "scanner.h"

#include <stdio.h>

bool is_comment_multiline = false;
unsigned long long comment_begining;

%}

%option noyywrap
%option nodefault

%x TAG_START TAG_MAYBE TAG COMMENT STRING

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]
identifier	[A-z][A-z0-9]*

%%
<INITIAL>{
\<	{
	BEGIN TAG_START;
}
\<\!--	{
	comment_begining = ftell(yyin);
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
	ECHOS("}");
	BEGIN INITIAL;
}
{identifier}+	{
	ECHO;
	BEGIN TAG_MAYBE;
}
}

<TAG_MAYBE>{
\>	{
	ECHOS(" {");
	BEGIN INITIAL;
}
\/\>	{
	ECHOS(";");
	BEGIN INITIAL;
}
{wsnl}	{
	ECHO;
}
.	{
	yyless(0);
	ECHOS("(");
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
	BEGIN INITIAL;
}
\/\>	{
	ECHOS(";");
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

%%
