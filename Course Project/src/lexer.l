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

"LET"	{	hashtab_add(hashtab, "main", 256);	SAVE_STRING;	return LET;}
"IN"	{	SAVE_STRING;	return INN;		}
"FIN"	{	SAVE_STRING;	return T_FIN;}

";"		{	SAVE_STRING;	return T_SEMCOL;	}
"+"		{	SAVE_STRING;	return T_PLUS;		}
"-"		{	SAVE_STRING;	return T_MINUS;		}
"*"		{	SAVE_STRING;	return T_MUL;		}
"/"		{	SAVE_STRING;	return T_DIV;		}
"%"		{	SAVE_STRING;	return T_MOD;		}
"&"		{	SAVE_STRING;	return T_AND;		}
"|"		{	SAVE_STRING;	return T_OR;		}
"^"		{	SAVE_STRING;	return T_XOR;		}
"!"		{	SAVE_STRING;	return T_NO;		}
"~"		{	SAVE_STRING;	return T_NOT;		}
"("		{	SAVE_STRING;	return T_LB;		}
")"		{	SAVE_STRING;	return T_RB;		}
"{"		{	SAVE_STRING;	return T_LF;		}
"}"		{	SAVE_STRING;	return T_RF;		}
"<"		{	SAVE_STRING;	return T_LT;		}
">"		{	SAVE_STRING;	return T_GT;		}
"<="	{	SAVE_STRING;	return T_LE;		}
"=>"	{	SAVE_STRING;	return T_GE;		}
"=="	{	SAVE_STRING;	return T_EQ;		}

{SIGN}?{DIGIT}+	{	TOKEN_LENGTH;	SAVE_STRING;	return T_INUM;}
{SIGN}?({DIGIT}+\.{DIGIT}+|{DIGIT}+\.|{DIGIT}+)([eE]{SIGN}?{DIGIT}+)? {	TOKEN_LENGTH;	SAVE_STRING;	return T_DNUM;}

"int"|"float"	{	TOKEN_LENGTH;	SAVE_STRING;	return T_TYPEVAR;	}
"do"			{	TOKEN_LENGTH;	SAVE_STRING;	return T_DO;		}
"while"			{	TOKEN_LENGTH;	SAVE_STRING;	return T_WHILE;		}
"if"			{	TOKEN_LENGTH;	SAVE_STRING;	return T_IF;		}
"then"			{	TOKEN_LENGTH;	SAVE_STRING;	return T_THEN;		}
"else"			{	TOKEN_LENGTH;	SAVE_STRING;	return T_ELSE;		}
"return"		{	TOKEN_LENGTH;	SAVE_STRING;	return T_RETURN;	}
"write"			{	TOKEN_LENGTH;	SAVE_STRING;	return T_PRINT;		}
"read"			{	TOKEN_LENGTH;	SAVE_STRING;	return T_SCAN;		}
":="			{	TOKEN_LENGTH;					return T_ASSIGN;	}
{OPER}			{	TOKEN_LENGTH;	SAVE_STRING;	return T_CMP;		}

("_"|{LETTER})("_"|{LETTER}|{DIGIT})* {	SAVE_STRING;	TOKEN_LENGTH;	return ID;}
{DELIM}	{	TOKEN_LENGTH;}
{WS}+	{	TOKEN_LENGTH;}
.		{	TOKEN_LENGTH; printf("Unknown character (%d, %d): %s\n", yylineno, ch, yytext);}

%%