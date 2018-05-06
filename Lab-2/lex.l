%option noyywrap yylineno
%{
#include <stdio.h>
#include <string.h>
#include "chaining_hash.h"

int ch;
int value = 10;
%}

digit[0-9]
letter[a-zA-HJ-UW-Z]
delim[();]
oper[<>=]
ws[ \t\n]

%%

do {
	printf("KEYWORD (%d, %d): %s\n", yylineno, ch, yytext);
 	ch += yyleng;
}
while {
	printf("KEYWORD (%d, %d): %s\n", yylineno, ch, yytext);
 	ch += yyleng;
}

("_"|{letter})("_"|{letter}|{digit})* {
	printf("IDENTIFIER (%d, %d): %s\n", yylineno, ch, yytext);
	hashtab_add(hashtab, yytext, value*ch);
	ch += yyleng;
}

(I{1,3}|I?V{1}|VI{1,3}?|I?X{1,3}I?V?I{0,3}?) {
	printf("RomeNUMBER (%d, %d): %s\n", yylineno, ch, yytext);
	ch += yyleng;
}

{oper} {
	printf("OPERATION (%d, %d): %s\n", yylineno, ch, yytext);
 	ch += yyleng;
}

":=" {
	printf("OPERATION (%d, %d): %s\n", yylineno, ch, yytext);
 	ch += yyleng;
}

{delim} {
	printf("DELIMITER (%d, %d): %s\n", yylineno, ch, yytext);
 	ch += yyleng;

}

{ws}+ {
	ch += yyleng;
}
. {
	printf("Unknown character (%d, %d): %s\n", yylineno, ch, yytext);
 	ch += yyleng;
}

%%
int main(int argc, char **argv)
{
	if(argc < 2)
	{
		printf("\nNot enough arguments. Please specify filename.\n");
		return -1;
	}
	if((yyin = fopen(argv[1], "r")) == NULL)
	{
		printf("\nCannot open file %s.\n", argv[1]);
		return -1;
	}
	ch = 1;
	yylineno = 1;
	
	struct listnode *node;
	hashtab_init(hashtab);
	
	yylex();
	node = hashtab_lookup(hashtab, "b");
	printf("Found node: %s, %d\n", node->key, node->value);
	fclose(yyin);
	
	return 0;
}
