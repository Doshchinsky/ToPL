%option noyywrap yylineno
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"

	int ch;

	extern void yyerror (char *);
%}

digit[0-9]
letter[a-zA-HJ-UW-Z]
delim[();]
oper[<>=]
ws[ \t\n]

%%

do {
	/*printf("KEYWORD (%d, %d): %s\n", yylineno, ch, yytext);*/
	ch += yyleng;
	return DO;
}
while {
	/*printf("KEYWORD (%d, %d): %s\n", yylineno, ch, yytext);*/
	ch += yyleng;
	return WHILE;
}

("_"|{letter})("_"|{letter}|{digit})* {
	/*printf("IDENTIFIER (%d, %d): %s\n", yylineno, ch, yytext);*/
	/*hashtab_add(hashtab, yytext, value*ch);*/
	ch += yyleng;
	return ID;
}

(I{1,3}|I?V{1}|VI{1,3}?|I?X{1,3}I?V?I{0,3}?) {
	/*printf("RomeNUMBER (%d, %d): %s\n", yylineno, ch, yytext);*/
	ch += yyleng;
	return NUMBER;
}

{oper} {
	/*printf("OPERATION (%d, %d): %s\n", yylineno, ch, yytext);*/
	ch += yyleng;
	return CMP;
}

":=" {
	/*printf("OPERATION (%d, %d): %s\n", yylineno, ch, yytext);*/
	ch += yyleng;
	return ASSIGN;
}

{delim} {
	/*printf("DELIMITER (%d, %d): %s\n", yylineno, ch, yytext);*/
	ch += yyleng;
	return *yytext;
}

{ws}+ {
	ch += yyleng;
}

. {
	/*printf("Unknown character (%d, %d): %s\n", yylineno, ch, yytext);*/
	yyerror("Unknown character");
	ch += yyleng;
}

%%