%{
#include "scanner.h"

#include <stdio.h>
#include <stack>
#include <string>
#include <boost/algorithm/string/trim.hpp>

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

	boost::trim(tag_candidate);
	tag_stack.push(tag_candidate);
	tag_candidate = "";

	return true;
}

bool pop_tag() {
	tag_stack.pop();
	tag_candidate = "";

	return true;
}

%}

%option noyywrap
%option nodefault
%option noyylineno

%x BODY HEAD HEAD_VALUE SWALLOW STRING COMMENT COMMENT_MULTILINE

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
	//BEGIN SWALLOW;
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

<SWALLOW>{
{wsnl}	{
	;
}
. {
	yyless(0);
	BEGIN BODY;
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
	ECHOS(">");
	BEGIN BODY;
}
:{wsnl}*	{
	ECHOS("=");
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

%%
