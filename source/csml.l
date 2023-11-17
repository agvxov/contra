%{
#include "scanner.hpp"

#include <stdio.h>
#include <stack>
#include <string>

#include "global.hpp"

std::stack<std::string> tag_stack;
std::string tag_candidate = "";

static
void _ECHO_CANDIDATE(){
	if (tag_candidate != "") {
		ECHOS(tag_candidate.c_str());
	}
}

#define ECHO_CANDIDATE _ECHO_CANDIDATE()

static const char COMMENT_START[] = "<!--";
static const char COMMENT_END[]   = "-->";

static const char ATTRIBUTE_VALUE_START[] = "'";
static const char ATTRIBUTE_VALUE_END[]   = "'";

bool push_tag() {
	if (tag_candidate == "") {
		exit(3);
		return false;
	}

	trim(tag_candidate);
	tag_stack.push(tag_candidate);
	tag_candidate = "";

	return true;
}

bool pop_tag() {
	if (tag_stack.empty()) {
		exit(3);
		return false;

	}
	tag_stack.pop();
	tag_candidate = "";

	return true;
}

%}

%option noyywrap
%option nodefault
%option noyylineno

%x BODY HEAD HEAD_VALUE
%x COMMENT COMMENT_MULTILINE
%x IGNORE IGNORE_COUNT_START IGNORE_COUNT_END
%x STRING

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]
identifier	[A-z][A-z0-9]*

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
;	{
	ECHOS(("<" + tag_candidate + "/>").c_str());
	tag_candidate = "";
}
\{	{
	push_tag();
	ECHOS(("<" + tag_stack.top() + ">").c_str());
	if (do_ignore(tag_stack.top())) {
		BEGIN IGNORE_COUNT_START;
	}
}
\}	{
	ECHO_CANDIDATE;
	ECHOS(("</" + tag_stack.top() + ">").c_str());
	pop_tag();
}
.|{wsnl}	{
	ECHO;
}
}

<COMMENT,COMMENT_MULTILINE>{
.*	{
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
.|\n	{
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
	ECHOS(ATTRIBUTE_VALUE_START);
	BEGIN HEAD_VALUE;
}
.|\n	{
	ECHO;
}
}

<HEAD_VALUE>{
,	{
	ECHOS(ATTRIBUTE_VALUE_END);
	BEGIN HEAD;
}
\)	{
	ECHOS(ATTRIBUTE_VALUE_END);
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
	ECHO;
	BEGIN IGNORE;
}
}

<IGNORE_COUNT_END>{
\}	{
	if (++ignore_i >= ignore_count) {
		ignore_i = 0;
		ignore_count = 1;

		ECHOS(("</" + tag_stack.top() + ">").c_str());
		pop_tag();
		BEGIN BODY;
	}
}
.|\n	{
	while (ignore_i--) {
		ECHOC('}');
	}
	ignore_i = 1;
	ECHO;
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
		ECHOS(("</" + tag_stack.top() + ">").c_str());
		pop_tag();
		BEGIN BODY;
	}
}
.|\n	{
	ECHO;
}
}

<*>{
\\[(){},:;]	{
	ECHOC(yytext[0]);
}
\\<	{
	ECHOS("&lt;");
}
\\>	{
	ECHOS("&gt;");
}
}

%%
