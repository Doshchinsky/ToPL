%{
	#include <stdio.h>
	#include <strings.h>
	#include "lex.yy.h"
	#include "parser.tab.h"

	int ch;
	#define SAVE_STRING yylval->str = strdup(yytext);
	extern void yyerror (char *);
%}

%option noyywrap yylineno
%option header-file="lex.yy.h"

DLM[(){};,]
LETTER[a-zA-Z]
DIGIT[0-9]
WS[ \t\n]

%%

int|float					{ ch += yyleng; SAVE_STRING; return TYPE;		}

if							{ ch += yyleng; SAVE_STRING; return IF;			}
else						{ ch += yyleng; SAVE_STRING; return ELSE;		}
for							{ ch += yyleng; SAVE_STRING; return FOR;		}
do							{ ch += yyleng; SAVE_STRING; return DO;			}
while						{ ch += yyleng; SAVE_STRING; return WHILE;		}

write						{ ch += yyleng; SAVE_STRING; return WRITE;		}
read						{ ch += yyleng; SAVE_STRING; return READ;		}
"+"|"-"						{ ch += yyleng; SAVE_STRING; return LOWOPER;	}
"*"|"/"						{ ch += yyleng; SAVE_STRING; return HIGHOPER;	}
"="							{ ch += yyleng; SAVE_STRING; return ASSIGN;		}
">"|">="|"=="|"<="|"<"|"!="	{ ch += yyleng; SAVE_STRING; return CMP;		}

("_"|{LETTER})("_"|{LETTER}|{DIGIT})* { ch += yyleng; SAVE_STRING; return ID; }
[+-]?({DIGIT}*\.{DIGIT}+|{DIGIT}+\.|{DIGIT}+)([eE][+-]?{DIGIT}+)? { ch += yyleng; SAVE_STRING; return NUMBER; }

{DLM}						{ ch += yyleng; return *yytext; }
{WS}+						{ ch += yyleng; }
. 							{ yyerror("[ERROR] Unknown character! Compilation terminated!"); ch += yyleng; }

%%