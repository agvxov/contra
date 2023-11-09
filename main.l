%{
#include <stdio.h>
#include <stack>

#define ECHOS(s) fwrite(s, strlen(s), 1, yyout)

std::stack<std::string> tag_stack;
std::string tag_candidate = "";

bool push_tag() {
	if (tag_candidate == "") {
		return false;
	}
	tag_stack.push(tag_candidate);
	ECHOS("<" + tag_stack.top() + ">");
	tag_candidate = "";
}

bool pop_tag() {
	ECHOS("</" + tag_stack.top() + ">");
	tag_stack.pop();
}

/*
	q0(.)  -> q1
	q0(\d) -> q2
	q1(\d) -> qe
	q2(\d) -> q2
	q2(.)  -> qe
	qe(\d) -> qe
*/
%}

%x HEAD STRING COMMENT COMMENT_MULTILINE
%s BODY

ws			[ \t\r\v\f]
wsnl		[ \t\r\v\f\n]

%%

<BODY>{
\/\/	{
	BEGIN COMMENT;
	ECHOS("<!--");
}
\/\*	{
	BEGIN COMMENT_MULTILINE;
	ECHOS("<!--");
}
w+	{
	tag_candidate = yytext;
}
\(	{
	push_tag();
	BEGIN HEAD;
}
\{	{
	push_tag();
}
\}	{
	pop_tag();
}
}

<COMMENT,COMMENT_MULTILINE>{
.*	{
	ECHO;
}
}

<COMMENT>{
\n	{
	ECHOS("-->");
	BEGIN BODY;
}
}

<COMMENT_MULTILINE>{
\n	{
	ECHO;
}
\*\/	{
	ECHOS("-->");
	BEGIN BODY;
}
}

<HEAD> {
.*	{
	ECHO;
}
)[wsnl]{	{
	BEGIN BODY;
}
}

%%
