%{
	#include <stdio.h>
	#include "./../include/lexer.h"
	#include "./../include/hash.h"
	#include "./../include/ast.h"

	extern FILE *yyin;
	extern int yylineno;
	extern int ch;
	extern char *yytext;
	extern struct listnode* hashtab[];
	extern int yylex();
	extern int debuginfo;
	extern int optimization;
	
	void optimize(struct ast* t);
	int swriteInt(char* buff, int num, int radix, int znac);

	void yyerror(char *);
	int errcount = 0;
	int var_counter = 0;
%}

%union {
	char *str;
	struct ast* ast_tree;
}

%token <str> T_IF
%token <str> T_THEN
%token <str> T_ELSE
%token <str> T_WHILE
%token <str> T_DO
%token <str> ID
%token <str> T_RETURN
%token <str> T_PRINT
%token <str> T_SCAN
%token <str> LET
%token <str> INN
%token <str> T_FIN
%token <str> T_TYPEVAR
%token <str> T_INUM T_DNUM CNUM
%token <str> T_ASSIGN
%token <str> T_CMP
%token <str> T_SEMCOL
%token <str> T_SPACE
%token <str> T_LT
%token <str> T_GT
%token <str> T_LE
%token <str> T_GE
%token <str> T_EQ
%token <str> T_PLUS
%token <str> T_MINUS
%token <str> T_MUL
%token <str> T_DIV
%token <str> T_MOD
%token <str> T_AND
%token <str> T_OR
%token <str> T_XOR
%token <str> T_LB
%token <str> T_RB
%token <str> T_NOT
%token <str> T_NO
%token <str> T_LF
%token <str> T_RF

%type <str> CONST

%type <ast_tree> EXPR1 
%type <ast_tree> EXPR2
%type <ast_tree> VAR
%type <ast_tree> COND
%type <ast_tree> WHILELOOP
%type <ast_tree> BODY
%type <ast_tree> STATE
%type <ast_tree> START
%type <ast_tree> STATELIST
%type <ast_tree> ID_TOK
%type <ast_tree> IFF
%type <ast_tree> IN
%type <ast_tree> OUT
%type <ast_tree> ID_TOK1
%type <ast_tree> RET
%type <ast_tree> PROG
%type <ast_tree> DEFVAR
%type <ast_tree> DEFVAR1
%type <ast_tree> DEFVAR2
%type <ast_tree> EXPR
%type <ast_tree> EXPR0
%type <ast_tree> FUNC
%type <ast_tree> DEFIN
%type <ast_tree> INIT

%%

PROG: FUNC {
	if (errcount > 0)
		yyerror("Err~");
	else {
		print_ast($1, 0);
		codeGen($1);
		free_ast($1);
		hashtab_print(hashtab);
	}
};

FUNC:	LET DEFIN INIT {$$ = ast_createNode(P_NODE_T, NULL, $2, $3, NULL);}

DEFIN:	DEFIN DEFVAR2 | DEFVAR2

INIT:	INN START {$$ = $2;}

START:	START STATE {$$ = ast_createNode(P_NODE_T, NULL, $1, $2, NULL);}
		| STATE {$$ = $1;};

STATE:	error T_SEMCOL {errcount = errcount + 1; yyerror("Some error deteceted~");};

STATE:	DEFVAR { $$ = $1;}
		| DEFVAR1 { $$ = $1;}
		| WHILELOOP	{ $$ = $1;}
		| RET { $$ = $1;}
		| OUT { $$ = $1;}
		| IN { $$ = $1;}
		| IFF { $$ = $1;}

IFF:	T_IF T_LB COND T_RB T_LF BODY T_RF {
		$$ = ast_createNode(P_IF_T, $1, $3, $6, NULL);
	}
		| T_IF T_LB COND T_RB T_LF BODY T_RF T_ELSE T_LF BODY T_RF {
		$$ = ast_createNode(P_IF_T, $1, $3, $6, $10);
	}
		| T_IF T_LB COND T_RB T_LF BODY T_RF T_ELSE STATE {
		$$ = ast_createNode(P_IF_T, $1, $3, $6, $9);
	}
		| T_IF T_LB COND T_RB STATE {
		$$ = ast_createNode(P_IF_T, $1, $3, $5, NULL);
	}
		| T_IF T_LB COND T_RB STATE T_ELSE STATE {
		$$ = ast_createNode(P_IF_T, $1, $3, $5, $7);
	}
		| T_IF T_LB COND T_RB STATE T_ELSE T_LF BODY T_RF {
		$$ = ast_createNode(P_IF_T, $1, $3, $5, $8);
	}

OUT:	T_PRINT T_LB VAR T_RB T_SEMCOL {
	$$ = ast_createNode(P_OUT_T, $1, $3, NULL, NULL);
};

IN:		T_SCAN T_LB ID_TOK1 T_RB T_SEMCOL {
	struct ast* tmpast = $3;
	struct listnode* tmphash = hashtab_lookup(hashtab, tmpast->key);
	tmphash->scan = 1;
	$$ = ast_createNode(P_IN_T, $1, $3, NULL, NULL);
};

/*int v = 5 + b;*/
DEFVAR:	T_TYPEVAR ID_TOK T_ASSIGN EXPR T_SEMCOL {
	struct ast* tmpast = $2;
	struct listnode* tmphash = hashtab_lookup(hashtab, tmpast->key);
	tmphash->type = !strcmp($1, "int") ? 0 : 1;
	tmpast = $4;
  if (tmpast->type == P_CONST_T || tmpast->type == P_CONSTC_T) {
    tmphash->num = atoi(tmpast->key);
  }
  if (optimization == 1) {
    optimize(tmpast);
  }
	$$ = ast_createNode(P_DEF_T, $1, $4, $2, NULL);
};

/*v = 5 + b;*/
DEFVAR1:	ID_TOK1 T_ASSIGN EXPR T_SEMCOL {
	struct ast* tmpast = $1;
	struct listnode* tmphash = hashtab_lookup(hashtab, tmpast->key);
	tmpast = $3;
    tmphash->scan = 1;
    if (tmpast->type == P_CONST_T || tmpast->type == P_CONSTC_T) {
      tmphash->num = atoi(tmpast->key);
    }
    if (optimization == 1) {
      optimize(tmpast);
    }
	$$ = ast_createNode(P_DEF1_T, $2, $3, $1, NULL);
};

EXPR:	EXPR0 {$$ = $1;}
		| EXPR0 T_AND EXPR {$$ = ast_createNode(P_OP_T, $2, $3, $1, NULL);}
		| EXPR0 T_XOR EXPR {$$ = ast_createNode(P_OP_T, $2, $3, $1, NULL);}
		| EXPR0 T_OR EXPR {$$ = ast_createNode(P_OP_T, $2, $3, $1, NULL);};

EXPR0:	EXPR1 {$$ = $1;}
		| EXPR1 T_PLUS EXPR0 {$$ = ast_createNode(P_OP_T, $2, $3, $1, NULL);}
		| EXPR1 T_MINUS EXPR0 {$$ = ast_createNode(P_OP_T, $2, $3, $1, NULL);};

EXPR1:	EXPR2 {$$ = $1;}
		| EXPR2 T_MUL EXPR1 {$$ = ast_createNode(P_OP_T, $2, $3, $1, NULL);}
		| EXPR2 T_DIV EXPR1 {$$ = ast_createNode(P_OP_T, $2, $3, $1, NULL);}
		| EXPR2 T_MOD EXPR1 {$$ = ast_createNode(P_OP_T, $2, $3, $1, NULL);};

EXPR2:	VAR {$$ = $1;}
		| T_LB EXPR T_RB {$$ = $2;}
		| T_NOT EXPR {$$ = ast_createNode(P_OP_T, $1, $2, NULL, NULL);}
		| T_NO EXPR {$$ = ast_createNode(P_OP_T, $1, $2, NULL, NULL);};

/*int v;*/
DEFVAR2:	T_TYPEVAR ID_TOK T_SEMCOL {
	struct ast* tmpast = $2;
	struct listnode* tmphash = hashtab_lookup(hashtab, tmpast->key);
	tmphash->type = !strcmp($1, "int") ? 0 : 1;
	$$ = ast_createNode(P_DEF2_T, $1, $2, NULL, NULL);
};

RET:	T_RETURN CONST T_SEMCOL T_FIN {$$ = ast_createNode(P_RET_T, $2, NULL, NULL, NULL);}

BODY:	STATE {$$ = $1;}
		| STATELIST {$$ = $1;};

STATELIST:	STATE BODY {$$ = ast_createNode(P_NODE_T, NULL, $1, $2, NULL);};

WHILELOOP: T_WHILE T_LB COND T_RB T_LF BODY T_RF {
	$$ = ast_createNode(P_WHILE_T, $1, $3, $6, NULL);
}
		| T_WHILE T_LB COND T_RB STATE {
	$$ = ast_createNode(P_WHILE_T, $1, $3, $5, NULL);
};

COND:	VAR {
		struct ast* tmpast = ast_createNode(P_CONST_T, strdup("1"), NULL, NULL, NULL);
		$$ = ast_createNode(P_COND_T, strdup("=="), $1, tmpast, NULL);}
		| VAR T_LT VAR {
	$$ = ast_createNode(P_COND_T, $2, $1, $3, NULL);
}
		| VAR T_GT VAR {
	$$ = ast_createNode(P_COND_T, $2, $1, $3, NULL);
}
		| VAR T_EQ VAR {
	$$ = ast_createNode(P_COND_T, $2, $1, $3, NULL);
}
		| VAR T_LE VAR {
	$$ = ast_createNode(P_COND_T, $2, $1, $3, NULL);
}
		| VAR T_GE VAR {
	$$ = ast_createNode(P_COND_T, $2, $1, $3, NULL);
}
;

ID_TOK: ID {
	if (hashtab_lookup(hashtab, $1) != NULL){
		++errcount;
		yyerror("Redefinition var~");
	}
	hashtab_add(hashtab, $1, var_counter++);
	$$ = ast_createNode(P_ID_T, $1, NULL, NULL, NULL);
};

ID_TOK1: ID {
	if (hashtab_lookup(hashtab, $1) == NULL){
		++errcount;
		yyerror("Undefined var~");
	}
	$$ = ast_createNode(P_ID_T, $1, NULL, NULL, NULL);
};

VAR:	CONST {
  char *tmp = $1;
  if (tmp[0] == '\''){
    int n;
    char buf[256];
    if (tmp[1] == '\\'){
      if (tmp[2] == '0') {
        n = 0;
      } else if (tmp[2] == 'n') {
        n = 10;
      } else if (tmp[2] == 'r') {
        n = 13;
      } else if (tmp[2] == 'a') {
        n = 7;
      } else if (tmp[2] == 't') {
        n = 9;
      } else n = 0;
    } else {
      n = tmp[1] - '\0';
    }
    swriteInt(buf, n, 10, -1);
    $$ = ast_createNode(P_CONSTC_T, strdup(buf), NULL, NULL, NULL);
  }
  else
  $$ = ast_createNode(P_CONST_T, $1, NULL, NULL, NULL);
}
		| ID_TOK1 {
	$$ = $1;
};

CONST:	T_INUM
		| T_DNUM
        | CNUM;;

%%
void yyerror(char *errmsg)
{
	fprintf(stderr, "[ERROR]\t%s (%d, %d): %s\n", errmsg, yylineno, ch, yytext);
}