%{
	#include <stdio.h>
	#include <string.h>
	#include "./../include/hash.h"
	#include "./../include/parser.tab.h"

	#define SAVE_STRING yylval.str = strdup(yytext)
	#define TOKEN_LENGTH ch += yyleng

	extern struct listnode* hashtab[];
	extern void yyerror (char *);

	int ch;
	int value = 10;
%}

%option noyywrap yylineno
%option header-file="./include/lexer.h"

DIGIT[0-9]
LETTER[a-zA-Z]
DELIM[();{},:]
WS[ \n\t]
OPER [-+*/<>|?!%=~]
SIGN [-+]
%x COMM
%%

"/*"			{	TOKEN_LENGTH; BEGIN COMM;		}
<COMM>.			{	TOKEN_LENGTH; continue;			}
<COMM>\n		{	TOKEN_LENGTH; continue;			}
<COMM>"*/"		{	TOKEN_LENGTH; BEGIN INITIAL;	}
<COMM><<EOF>>	{	TOKEN_LENGTH; yyerror("Unterminated comment"); BEGIN INITIAL; }
\/\/(.)*(\n|$)	{	TOKEN_LENGTH;}

"main"	{	hashtab_add(hashtab, "main", 256);	SAVE_STRING;	return MAIN;}

";"		{	SAVE_STRING;	return SEMCOL;	}
"+"		{	SAVE_STRING;	return PLUS;	}
"-"		{	SAVE_STRING;	return MINUS;	}
"*"		{	SAVE_STRING;	return MUL;		}
"/"		{	SAVE_STRING;	return DIV;		}
"%"		{	SAVE_STRING;	return MOD;		}
"&"		{	SAVE_STRING;	return AND;		}
"|"		{	SAVE_STRING;	return OR;		}
"^"		{	SAVE_STRING;	return XOR;		}
"!"		{	SAVE_STRING;	return NO;		}
"~"		{	SAVE_STRING;	return NOT;		}
"("		{	SAVE_STRING;	return LB;		}
")"		{	SAVE_STRING;	return RB;		}
"{"		{	SAVE_STRING;	return LF;		}
"}"		{	SAVE_STRING;	return RF;		}
"<"		{	SAVE_STRING;	return LOW;		}
">"		{	SAVE_STRING;	return BIG;		}
"=="	{	SAVE_STRING;	return EQ;		}

{SIGN}?{DIGIT}+	{	TOKEN_LENGTH;	SAVE_STRING;	return INUM;}
{SIGN}?({DIGIT}+\.{DIGIT}+|{DIGIT}+\.|{DIGIT}+)([eE]{SIGN}?{DIGIT}+)? {	TOKEN_LENGTH;	SAVE_STRING;	return DNUM;}

"int"|"float"	{	TOKEN_LENGTH;	SAVE_STRING;	return TYPEVAR;	}
"do"			{	TOKEN_LENGTH;	SAVE_STRING;	return DO;		}
"while"			{	TOKEN_LENGTH;	SAVE_STRING;	return WHILE;	}
"if"			{	TOKEN_LENGTH;	SAVE_STRING;	return IF;		}
"then"			{	TOKEN_LENGTH;	SAVE_STRING;	return THEN;	}
"else"			{	TOKEN_LENGTH;	SAVE_STRING;	return ELSE;	}
"return"		{	TOKEN_LENGTH;	SAVE_STRING;	return RETURN;	}
"write"			{	TOKEN_LENGTH;	SAVE_STRING;	return PRINT;	}
"read"			{	TOKEN_LENGTH;	SAVE_STRING;	return SCAN;	}
":="			{	TOKEN_LENGTH;					return ASSIGN;	}
{OPER}			{	TOKEN_LENGTH;	SAVE_STRING;		return CMP;	}

("_"|{LETTER})("_"|{LETTER}|{DIGIT})* {	SAVE_STRING;		TOKEN_LENGTH;	return ID;}
{DELIM}	{		TOKEN_LENGTH;}
{WS}+	{		TOKEN_LENGTH;}
.		{		printf("Unknown character (%d, %d): %s\n", yylineno, ch, yytext);		TOKEN_LENGTH;}

%%