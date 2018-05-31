%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <strings.h>
	#include "lex.yy.h"
	#include "parser.tab.h"
	#include "translation.h"

	extern FILE *yyin;
	extern int yylineno;
	extern int ch;
	extern char *yytext;

	void yyerror (char *);
	char err[] = "error";
	char stype[] = "int";
	struct listnode *hashtab[HASH_SIZE];
	int errc = 0;
	int value;
	FILE *fd;
%}

%union {
	char *str;
	struct treeode *tree;
}
/*=========== TKN'n'TYPE declarations ==============*/
%token	<str>	NUMBER
%token	<str>	ID
%token	<str>	IF
%token	<str>	ELSE
%token	<str>	FOR
%token	<str>	DO
%token	<str>	WHILE
%token	<str>	TYPE
%token	<str>	READ
%token	<str>	WRITE

%right	<str>	ASSIGN
%left	<str>	LOWOPER
%left	<str>	HIGHOPER
%left	<str>	CMP

%type	<tree>	program
%type	<tree>	statement
%type	<tree>	status
%type	<tree>	lstatement
%type	<tree>	prime
%type	<tree>	expr
%type	<tree>	defvar
%type	<tree>	defexpr
%type	<tree>	definit
%type	<tree>	init
%type	<tree>	loop
%type	<tree>	cond
%type	<tree>	iffi
%type	<tree>	ifelse
%type	<tree>	ios
/*======== End of TKN'n'TYPE declarations ========*/

%%

/*=================================================
			FUNCTIONS DECLARATIONS
==================================================*/

compale:	program { if (errc > 0) return 1; init_asm(hashtab); dfs($1); end_asm();  free_tree($1); free_hash(hashtab);}

program:	statement { $$ = $1; }
		|	statement program { add_atr($1, $2); }

statement:	defvar';' { $$ = $1; }
		|	init';' { $$ = $1; }
		|	loop  { $$ = $1; }
		|	iffi { $$ = $1; }
		|	ios';' { $$ = $1; }

statement:	error';' { errc++; $$ = create_node(err, typeErr, NULL, NULL, NULL, NULL, NULL); }

defvar:		TYPE defexpr { if (strcmp($1, stype) == 0) value = 1; else value = 0; add_hashtab(hashtab, value); $$ = create_node($1, typeDef, $2, NULL, NULL, NULL, NULL); }

defexpr:	defexpr',' defexpr { $$ = add_atr($1, $3); }
		|	definit { $$ = $1; }
		|	ID { if (lookup_hash(hashtab, $1) != NULL) { printf("Line %d: Перезаявление переменной: %s\n", yylineno, $1); errc++; } push_hash(hashtab, $1, 3); $$ = create_node($1, typeId, NULL, NULL, NULL, NULL, NULL); }

definit:	ID ASSIGN expr { if (lookup_hash(hashtab, $1) != NULL) { printf("Line %d: Перезаявление переменной: %s\n", yylineno, $1); errc++; } push_hash(hashtab, $1, 3); $$ = create_node($2, typeOpr, create_node($1, typeId, NULL, NULL, NULL, NULL, NULL), $3, NULL, NULL, NULL); }
		|	ID ASSIGN '('expr')' { if (lookup_hash(hashtab, $1) != NULL) { printf("Line %d: Перезаявление переменной: %s\n", yylineno, $1); errc++; } push_hash(hashtab, $1, 3); $$ = create_node($2, typeOpr, create_node($1, typeId, NULL, NULL, NULL, NULL, NULL), $4, NULL, NULL, NULL); }

init:		ID ASSIGN expr { if (lookup_hash(hashtab, $1) == NULL) { printf("Line %d: Не заявленная переменная: %s\n", yylineno, $1); errc++; } $$ = create_node($2, typeOpr, create_node($1, typeId, NULL, NULL, NULL, NULL, NULL), $3, NULL, NULL, NULL); }
		|	ID ASSIGN '('expr')' { if (lookup_hash(hashtab, $1) == NULL) { printf("Line %d : Не заявленная переменная: %s\n", yylineno, $1); errc++; } $$ = create_node($2, typeOpr, create_node($1, typeId, NULL, NULL, NULL, NULL, NULL), $4, NULL, NULL, NULL); }

loop:		FOR '('init';' cond';' init')' '{' status '}' { $$ = create_node($1, typeOpr, $3, $5, $7, $10, NULL); }
		|	FOR '('init';' cond';' init')' lstatement { $$ = create_node($1, typeOpr, $3, $5, $7, $9, NULL); }
		|	FOR '('init';' cond';' init')' '{''}' { $$ = create_node($1, typeOpr, $3, $5, $7, NULL, NULL); }
		|	FOR '('init';' cond';' init')'';' { $$ = create_node($1, typeOpr, $3, $5, $7, NULL, NULL); }
		|	WHILE '('cond')' '{' status '}' { $$ = create_node($1, typeOpr, NULL, $3, NULL, $6, NULL); }
		|	WHILE '('cond')' lstatement { $$ = create_node($1, typeOpr, NULL, $3, NULL, $5, NULL); }

iffi:		IF '('cond')' '{' status '}' { $$ = create_node($1, typeOpr, NULL, $3, NULL, $6, NULL); }
		|	IF '('cond')' '{' status '}' ifelse { $$ = create_node($1, typeOpr, NULL, $3, NULL, $6, $8); }
		|	IF '('cond')' lstatement { $$ = create_node($1, typeOpr, NULL, $3, NULL, $5, NULL); }
		|	IF '('cond')' lstatement ifelse { $$ = create_node($1, typeOpr, NULL, $3, NULL, $5, $6); }

ifelse:		ELSE '{' status '}' { $$ = create_node($1, typeOpr, NULL, NULL, NULL, $3, NULL); }
		|	ELSE lstatement {  $$ = create_node($1, typeOpr, NULL, NULL, NULL, $2, NULL); }

ios:		WRITE prime { $$ = create_node($1, typeOpr, $2, NULL, NULL, NULL, NULL); }
		|	READ ID { if (lookup_hash(hashtab, $2) == NULL) { printf("Line %d: Не заявленная переменная: %s\n", yylineno, $1); errc++; } $$ = create_node($1, typeOpr, create_node($2, typeId, NULL, NULL, NULL, NULL, NULL), NULL, NULL, NULL, NULL); }

expr:		expr LOWOPER expr { $$ = create_node($2, typeOpr, $1, $3, NULL, NULL, NULL); }
		|	'('expr')' LOWOPER '('expr')' { $$ = create_node($4, typeOpr, $2, $6, NULL, NULL, NULL); }
		|	'('expr')' LOWOPER expr { $$ = create_node($4, typeOpr, $2, $5, NULL, NULL, NULL); }
		|	expr LOWOPER '('expr')' { $$ = create_node($2, typeOpr, $1, $4, NULL, NULL, NULL); }
		|	expr HIGHOPER expr { $$ = create_node($2, typeOpr, $1, $3, NULL, NULL, NULL);}
		|	'('expr')' HIGHOPER '('expr')' { $$ = create_node($4, typeOpr, $2, $6, NULL, NULL, NULL); }
		|	'('expr')' HIGHOPER expr { $$ = create_node($4, typeOpr, $2, $5, NULL, NULL, NULL); }
		|	expr HIGHOPER '('expr')' { $$ = create_node($2, typeOpr, $1, $4, NULL, NULL, NULL); }
		|	prime { $$ = $1; }

cond:		prime CMP prime { $$ = create_node($2, typeOpr, $1, $3, NULL, NULL, NULL);}
		|	'('expr')' CMP '('expr')' { $$ = create_node($4, typeOpr, $2, $6, NULL, NULL, NULL); }
		|	'('expr')' CMP prime { $$ = create_node($4, typeOpr, $2, $5, NULL, NULL, NULL); }
		|	prime CMP '('expr')' { $$ = create_node($2, typeOpr, $1, $4, NULL, NULL, NULL); }

status:		lstatement status { $$ = add_atr($1, $2); }
		|	lstatement { $$ = $1; }

lstatement:	init';' { $$ = $1; }
		|	loop { $$ = $1; }
		|	iffi { $$ = $1; }
		|	ios';' { $$ = $1; }

lstatement:	error';' { errc++; $$ = create_node(err, typeErr, NULL, NULL, NULL, NULL, NULL); }

prime:		NUMBER { $$ = create_node($1, typeCon, NULL, NULL, NULL, NULL, NULL); }
		|	ID { if (lookup_hash(hashtab, $1) == NULL) { printf("Line %d: Не заявленная переменная: %s\n", yylineno, $1); errc++; } $$ = create_node($1, typeId, NULL, NULL, NULL, NULL, NULL); }

/*==================================================
			End of function's declarations
==================================================*/

%%

void yyerror(char *errmsg) {
	fprintf(stderr, "[ERROR] Line %d: %s\n", yylineno, errmsg);
}

int main(int argc, char **argv) {
	if (argc < 3) {
		printf("[ERROR] Not enough arguments!\n");
		return -1;
	}
	if ((yyin = fopen(argv[1], "r")) == NULL) {
		printf("[ERROR] Can't open one of the files!\n");
		return -1;
	}
	if ((fd = fopen(argv[2], "w")) == NULL) {
		printf("[ERROR] Can't open any file\n");
		return -1;
	}

	ch = 1;
	yylineno = 1;
	yyparse();
	fclose(fd);

	if (errc == 0) {
	} else {
		remove(argv[2]);
	}

	return EXIT_SUCCESS;
}