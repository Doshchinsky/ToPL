%{
	#include <stdlib.h>
	#include <string.h>
	#include "parser.tab.h"

	int ch;
	extern void yyerror(char*);
%}

%option yylineno noyywrap reentrant bison-bridge
%option header-file="lex.yy.h"

DIGIT [0-9]
ID [a-z][a-z0-9]*

%%

let				{ return(LET); }
in				{ return(IN); }
end				{ return(END); }
do				{ return(DO); }
while			{ return(WHILE); }
if				{ return(IF); }
then			{ return(THEN); }
else			{ return(ELSE); }
skip			{ return(SKIP); }
integer			{ return(INT); }
float			{ return(FLOAT); }
read			{ return(READ); }
write			{ return(WRITE); }
":="			{ return(ASSIGN); }

{ID} { yylval.id = (char *) strdup(yytext);return(IDENTIFIER); }
[-+]?({DIGIT}*\.{DIGIT}+|{DIGIT}+\.|{DIGIT}+)([eE][-+]?{DIGIT}+)?	return NUMBER;

[ \t\n]+ ;
.				{ printf("[ERROR]\tUnknown character! Compilation terminated\n"); }

%%