#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct ast {
  int type;
  char *key;
  struct ast* left;
  struct ast* middle;
  struct ast* right;
};

#define SIZE_BUFFER 256
#define DEBUG 0

#define P_NODE_T 255
#define P_RET_T 254
#define P_PROG_T 0
#define P_WHILE_T 1
#define P_COND_T 2
#define P_CONST_T 3
#define P_ID_T 4
#define P_DEF_T 5
#define P_DEF1_T 6
#define P_VAR_T 7
#define P_OP_T 9
#define P_OUT_T 10
#define P_DEF2_T 11
#define P_IN_T 12
#define P_IF_T 13

struct ast* ast_createNode(int type, char* key, struct ast* l, struct ast* m, struct ast* r);
void print_ast(struct ast* t, int l);
void free_ast(struct ast* t);
int codeGen(struct ast* t);

#endif
