%{
	#include <stdio.h>
	extern FILE *yyin;
	extern int yylineno;
	extern int ch;
	extern char *yytext;

	void yyerror(char *);
%}

%token DO WHILE ID NUMBER
%right ASSIGN
%left CMP

%%

program:	statement | program statement {
	printf("\nprogram\n");
}

statement:	statement statement | dowhile | oper {
	printf("\nstatement\n");
}

statement:	error';'
dowhile:	DO statement WHILE '(' cmp ')' {	
	printf("\nDo-While\n");
}

oper:		ID ASSIGN exp';'	{ printf("\noper\n"); }
cmp:		exp CMP exp			{ printf("\ncomparison\n"); }
exp:		ID					{ printf("\nexp\n"); } |
			NUMBER				{ printf("\nexp\n"); }

%%

void yyerror(char *errmsg)
{
	fprintf(stderr, "%s (%d, %d): %s\n", errmsg, yylineno, ch, yytext);
}

int main(int argc, char **argv)
{
	if(argc < 2) {
		printf("\nNot enough arguments. Please specify filename. \n");
		return -1;
	}

	if((yyin = fopen(argv[1], "r")) == NULL) {
		printf("\nCannot open file %s.\n", argv[1]);
		return -1;
	}

	ch = 1;
	yylineno = 1;

	yyparse();

	return 0;
}