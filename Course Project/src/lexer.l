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

":="			{ return(ASSGNOP); }
do				{ return(DO); }
else			{ return(ELSE); }
end				{ return(END); }
fi				{ return(FI); }
if				{ return(IF); }
in				{ return(IN); }
integer			{ return(INT); }
let				{ return(LET); }
read 			{ return(READ); }
skip 			{ return(SKIP); }
then 			{ return(THEN); }
while 			{ return(WHILE); }
write 			{ return(WRITE); }
{ID} { yylval.id = (char *) strdup(yytext);return(IDENTIFIER); }
[-+]?({DIGIT}*\.{DIGIT}+|{DIGIT}+\.|{DIGIT}+)([eE][-+]?{DIGIT}+)?	return NUMBER;
[ \t\n]+ ;
. 				{ printf("[ERROR]\tUnknown character! Compilation terminated\n"); }
%%

int yywrap(void){ return 0;}
/************************** End Scanner File */
