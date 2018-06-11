#include <stdio.h>
#include "./../include/hash.h"
#include "./../include/ast.h"

extern struct listnode* hashtab[];
extern int var_counter;
extern int optimization;
extern FILE* fileout;

static int labelcount = 0;
static int exprLoad = 0;
static int stackOffset = 0;

static void optimize(struct ast* t);

static void gen(struct ast* t);
static void genExpr(struct ast* t);
static void genCond(struct ast* t, int inv, int els, int label);
static int swriteInt(char* buff, int num, int radix, int znac);

int codeGen(struct ast* t) {
  stackOffset = var_counter * 4 + 8;
  /*strings print*/
//-------------GENERATE ASM-------------
  fprintf(fileout, "\t.data\n");
  fprintf(fileout, "INT:\n\t.string \"%%d\"\n");
  fprintf(fileout, "INTN:\n\t.string \"%%d\\n\"\n");
  fprintf(fileout, "\t.text\n");
  fprintf(fileout, "\t.globl main\n");
  fprintf(fileout, "\t.type main, @function\n\n");
  fprintf(fileout, "main:\n\t");
  fprintf(fileout, "pushq %%rbp\n\t");
  fprintf(fileout, "movq %%rsp, %%rbp\n\t");
  fprintf(fileout, "subq $%d, %%rsp\n\t", stackOffset);
//------------------------------
  /*generate*/
  if (optimization == 1) {
    optimize(t);
  }
  print_ast(t, 0);
  gen(t);
//------------------------------
  fprintf(fileout, "\n");
//--------------------------------------
  return 0;
}

static void gen(struct ast* t) {
  if (t != NULL) {
    struct listnode* tmp;
    switch (t->type) {
      case P_NODE_T:
      case P_DEF_T:
        gen(t->left);
        gen(t->middle);
        fprintf(fileout, "\n\t");
      break;
      case P_DEF1_T:
        genExpr(t->left);
        exprLoad = 0;
        gen(t->middle);
        fprintf(fileout, "\n\t");
      break;
      case P_WHILE_T:
        fprintf(fileout, "jmp .L%03d\n", labelcount + 2);
        fprintf(fileout, "\r.L%03d:\n\t", ++labelcount);
        gen(t->middle);
        fprintf(fileout, "\r.L%03d:\n\t", ++labelcount);
        genCond(t->left, 1, 0, labelcount - 1);
        fprintf(fileout, "\n\t");
      break;
      case P_IF_T:
        genCond(t->left, 0, 0, labelcount + 1);
        gen(t->middle);
        fprintf(fileout, "\r.L%03d:\n\t", ++labelcount);
        if (t->right != NULL) {
          genCond(t->left, 0, 1, labelcount + 1);
          gen(t->right);
          fprintf(fileout, "\r.L%03d:\n\t", ++labelcount);
        }
        fprintf(fileout, "\n\t");
      break;
      case P_ID_T:
        tmp = hashtab_lookup(hashtab, t->key);
        if (tmp != NULL){
          fprintf(fileout, "movl %%eax, %d(%%rbp)\n\t", -4*(tmp->value) - 4);
        }
        tmp = NULL;
      break;
      case P_CONST_T:
        fprintf(fileout, "movl $%s, %%eax\n\t", t->key);
      break;
      case P_DEF2_T:
        tmp = hashtab_lookup(hashtab, t->left->key);
        if (tmp != NULL){
          fprintf(fileout, "movl $0, %d(%%rbp)\n\t", -4*(tmp->value) - 4);
        }
      break;
      case P_OP_T:
        genExpr(t);
        exprLoad = 0;
      break;
      case P_RET_T:
          fprintf(fileout, "addq $%d, %%rsp\n\t", stackOffset);
          if (t->left == NULL)
          fprintf(fileout, "movl $1, %%eax\n\t");
          fprintf(fileout, "movl $%s, %%ebx\n\t", t->key);
          fprintf(fileout, "popq %%rbp\n\t");
          fprintf(fileout, "int $0x80\n\t");
      break;
      case P_OUT_T:
          tmp = hashtab_lookup(hashtab, t->left->key);
          if (tmp != NULL) {
            if (tmp->type == 0)
            fprintf(fileout, "movl $INTN, %%edi\n\t");
            fprintf(fileout, "xorq %%rsi, %%rsi\n\t");
            fprintf(fileout, "movl %d(%%rbp), %%eax\n\t", -4*(tmp->value) - 4);
            fprintf(fileout, "movl %%eax, %%esi\n\t");
            fprintf(fileout, "movl $0, %%eax\n\t");
            fprintf(fileout, "call printf\n\t");
            fprintf(fileout, "\n\t");
          }
      break;
      case P_IN_T:
          tmp = hashtab_lookup(hashtab, t->left->key);
          if (tmp != NULL) {
            if (tmp->type == 0)
            fprintf(fileout, "leaq %d(%%rbp), %%rax\n\t", -4*(tmp->value) - 4);
            fprintf(fileout, "movq %%rax, %%rsi\n\t");
            fprintf(fileout, "movl $INT, %%edi\n\t");
            fprintf(fileout, "movl $0, %%eax\n\t");
            fprintf(fileout, "call __isoc99_scanf\n\t");
            fprintf(fileout, "\n\t");
          }
      break;
      default: break;
    }
  }
}

static void genCond(struct ast* t, int inv, int els, int label) {
  struct listnode* tmp1 = NULL;
  struct listnode* tmp2 = NULL;
  if (t != NULL) {
    tmp1 = hashtab_lookup(hashtab, t->left->key);
    tmp2 = hashtab_lookup(hashtab, t->middle->key);
    if (tmp1 != NULL && tmp2 == NULL) {
      fprintf(fileout, "cmpl $%s, %d(%%rbp)\n\t", t->middle->key,-4*(tmp1->value) - 4);
    } else if (tmp1 == NULL && tmp2 != NULL) {
      fprintf(fileout, "xorl %%edx, %%edx\n\t");
      fprintf(fileout, "movl $%s, %%edx\n\t", t->left->key);
      fprintf(fileout, "cmpl %d(%%rbp), %%edx\n\t", -4*(tmp2->value) - 4);
    } else if (tmp1 != NULL && tmp2 != NULL) {
      fprintf(fileout, "xorl %%edx, %%edx\n\t");
      fprintf(fileout, "movl %%edx, %d(%%rbp)\n\t", -4*(tmp2->value) - 4);
      fprintf(fileout, "cmpl %%edx, %d(%%rbp)\n\t", -4*(tmp1->value) - 4);
    } else if (tmp1 == NULL && tmp2 == NULL) {
      fprintf(fileout, "xorl %%edx, %%edx\n\t");
      fprintf(fileout, "movl $%s, %%edx\n\t", t->left->key);
      fprintf(fileout, "cmpl $%s, %%edx\n\t", t->middle->key);
    }
    switch (t->key[0]) {
      case '>':
        if (inv == 0)
          if (els == 0)
            fprintf(fileout, "jle .L%03d\n\t", label);
          else {
            fprintf(fileout, "jg .L%03d\n\t", label);
          }
        else {
          fprintf(fileout, "jg .L%03d\n\t", label);
        }
      break;
      case '<':
        if (inv == 0) {
          if (els == 0)
            fprintf(fileout, "jns .L%03d\n\t", label);
          else {
            fprintf(fileout, "js .L%03d\n\t", label);
          }
        } else {
          fprintf(fileout, "js .L%03d\n\t", label);
        }
        break;
      case '=':
        if (inv == 0)
          if (els == 0)
            fprintf(fileout, "jne .L%03d\n\t", label);
          else {
            fprintf(fileout, "je .L%03d\n\t", label);
          }
        else {
          fprintf(fileout, "je .L%03d\n\t", label);
        }
      break;
    }
    fprintf(fileout, "xorl %%edx, %%edx\n\t");
  }
}

static void genExpr(struct ast* t) {
  struct listnode* tmp = NULL;
  if (t != NULL) {
    genExpr(t->left);
    tmp = hashtab_lookup(hashtab, t->key);
    switch (t->type) {
      case P_ID_T:
      case P_CONST_T:
          if (exprLoad == 0) {
            fprintf(fileout, "xorl %%eax, %%eax\n\t");
            if (tmp != NULL)
              fprintf(fileout, "movl %d(%%rbp), %%eax\n\t", -4*(tmp->value) - 4);
            else
              fprintf(fileout, "movl $%s, %%eax\n\t", t->key);
            exprLoad = 1;
          }
      break;
      case P_OP_T:
        tmp = hashtab_lookup(hashtab, t->middle->key);
        switch (t->key[0]) {
          case '+':
            if (tmp != NULL && tmp->type == 0)
              fprintf(fileout, "addl %d(%%rbp), %%eax\n\t", -4*(tmp->value) - 4);
            else if (t->middle->type == P_CONST_T)
              fprintf(fileout, "addl $%s, %%eax\n\t", t->middle->key);
            else if (t->left->type == P_OP_T && t->middle->type == P_OP_T) {
              fprintf(fileout, "movl %%eax, %%ecx\n\t");
              exprLoad = 0;
              genExpr(t->middle);
              fprintf(fileout, "addl %%ecx, %%eax\n\t");
            }
          break;
          case '-':
            if (tmp != NULL && tmp->type == 0)
              fprintf(fileout, "subl %d(%%rbp), %%eax\n\t", -4*(tmp->value) - 4);
            else if (t->middle->type == P_CONST_T)
              fprintf(fileout, "subl $%s, %%eax\n\t", t->middle->key);
            else if (t->left->type == P_OP_T && t->middle->type == P_OP_T) {
              fprintf(fileout, "movl %%eax, %%ecx\n\t");
              exprLoad = 0;
              genExpr(t->middle);
              fprintf(fileout, "subl %%ecx, %%eax\n\t");
            }
          break;
          case '*':
            if (tmp != NULL && tmp->type == 0)
              fprintf(fileout, "mull %d(%%rbp)\n\t", -4*(tmp->value) - 4);
            else if (t->middle->type == P_CONST_T) {
              fprintf(fileout, "movl $%s, %%ebx\n\t", t->middle->key);
              fprintf(fileout, "mull %%ebx\n\t");
            } else if (t->left->type == P_OP_T && t->middle->type == P_OP_T) {
              fprintf(fileout, "movl %%eax, %%ecx\n\t");
              exprLoad = 0;
              genExpr(t->middle);
              fprintf(fileout, "mull %%ecx\n\t");
            } else if ((t->left->type == P_CONST_T || t->left->type == P_ID_T) && t->middle->type == P_OP_T) {
              fprintf(fileout, "movl %%eax, %%ecx\n\t");
              exprLoad = 0;
              genExpr(t->middle);
              fprintf(fileout, "mull %%ecx\n\t");
            }
          break;
          case '/':
          case '%':
            if (tmp != NULL && tmp->type == 0)
              fprintf(fileout, "divl %d(%%rbp), %%eax\n\t", -4*(tmp->value) - 4);
            else if (t->middle->type == P_CONST_T)
              fprintf(fileout, "divl $%s, %%eax\n\t", t->middle->key);
          break;
          case '&':
            if (tmp != NULL && tmp->type == 0)
              fprintf(fileout, "andl %d(%%rbp), %%eax\n\t", -4*(tmp->value) - 4);
            else if (t->middle->type == P_CONST_T)
              fprintf(fileout, "andl $%s, %%eax\n\t", t->middle->key);
          break;
          case '|':
            if (tmp != NULL && tmp->type == 0)
              fprintf(fileout, "orl %d(%%rbp), %%eax\n\t", -4*(tmp->value) - 4);
            else if (t->middle->type == P_CONST_T)
              fprintf(fileout, "orl $%s, %%eax\n\t", t->middle->key);
          break;
          case '^':
            if (tmp != NULL && tmp->type == 0)
              fprintf(fileout, "xorl %d(%%rbp), %%eax\n\t", -4*(tmp->value) - 4);
            else if (t->middle->type == P_CONST_T)
              fprintf(fileout, "xorl $%s, %%eax\n\t", t->middle->key);
          break;
          case '!':
          case '~':
            tmp = hashtab_lookup(hashtab, t->left->key);
            if (tmp != NULL && tmp->type == 0)
              fprintf(fileout, "notl %d(%%rbp)\n\t", -4*(tmp->value) - 4);
            else if (t->middle->type == P_CONST_T)
              fprintf(fileout, "notl %%eax\n\t");
          break;
        }
      break;
      default: break;
    }

  }
}

static void optimize(struct ast* t) {
  int tmp1, tmp2, res;
  struct listnode* tmph1 = NULL;
  struct listnode* tmph2 = NULL;
  char buffer[256];
  if (t != NULL) {
    optimize(t->left);
    optimize(t->middle);
    //print_ast(t, 0);
    if (t->type == P_OP_T) {
      if (t->middle != NULL) {
        if (t->left->type == P_CONST_T && t->middle->type == P_CONST_T) {
          tmp1 = atoi(t->left->key);
          tmp2 = atoi(t->middle->key);

          switch(t->key[0]) {
            case '+':
              res = tmp1 + tmp2;
            break;
            case '-':
              res = tmp1 - tmp2;
            break;
            case '*':
              res = tmp1 * tmp2;
            break;
            case '/':
            case '%':
              res = tmp1 / tmp2;
            break;
            case '&':
              res = tmp1 & tmp2;
            break;
            case '|':
              res = tmp1 | tmp2;
            break;
            case '^':
              res = tmp1 ^ tmp2;
            break;
          }
        } else if ((t->left->type == P_ID_T && t->middle->type == P_CONST_T) ||
                   (t->left->type == P_CONST_T && t->middle->type == P_ID_T)) {
          tmph1 = hashtab_lookup(hashtab, t->left->type == P_ID_T ? t->left->key : t->middle->key);
          if (tmph1->scan == 1) return;
          tmp1 = tmph1->num;
          tmp2 = atoi(t->left->type == P_ID_T ? t->middle->key : t->left->key);

          switch(t->key[0]) {
            case '+':
              res = tmp1 + tmp2;
            break;
            case '-':
              res = tmp1 - tmp2;
            break;
            case '*':
              res = tmp1 * tmp2;
            break;
            case '/':
            case '%':
              res = tmp1 / tmp2;
            break;
            case '&':
              res = tmp1 & tmp2;
            break;
            case '|':
              res = tmp1 | tmp2;
            break;
            case '^':
              res = tmp1 ^ tmp2;
            break;
          }
        } else if (t->left->type == P_ID_T && t->middle->type == P_ID_T) {
          tmph1 = hashtab_lookup(hashtab, t->left->key);
          if (tmph1->scan == 1) return;
          tmph2 = hashtab_lookup(hashtab, t->middle->key);
          if (tmph2->scan == 1) return;
          tmp1 = tmph1->num;
          tmp2 = tmph2->num;
          switch(t->key[0]) {
            case '+':
              res = tmp1 + tmp2;
            break;
            case '-':
              res = tmp1 - tmp2;
            break;
            case '*':
              res = tmp1 * tmp2;
            break;
            case '/':
            case '%':
              res = tmp1 / tmp2;
            break;
            case '&':
              res = tmp1 & tmp2;
            break;
            case '|':
              res = tmp1 | tmp2;
            break;
            case '^':
              res = tmp1 ^ tmp2;
            break;
          }
        }
        swriteInt(buffer, res, 10, -1);
        free(t->key);
        t->key = strdup(buffer);
        t->type = P_CONST_T;
        free(t->left);
        free(t->middle);
        t->left = NULL;
        t->middle = NULL;
      }
    }
  }
}

static int swriteInt(char* buff, int num, int radix, int znac)
{
  char sign                = '-';
  int i                    = 0;
  int j                    = 0;
  int k                    = 0;
  char buffer[SIZE_BUFFER] = {0};
  int counter              = SIZE_BUFFER;


  if (num == 0) {
    if (znac == -1)
      buff[i] = '0';
    for (i = 0; i < znac; i++)
      buff[i] = '0';
    return i;
  }

  if (radix == 10) {
    if (num < 0) {
      buff[0] = sign;
      num = -num;
    }
  }

  while (num) {
    if (num % radix > 9) {
      buffer[--counter] = 'A' + num % radix - 10;
      num /= radix;
    } else {
      buffer[--counter] = '0' + (num % radix);
      num /= radix;
    }
  }
  if (znac > -1) {
    if ((SIZE_BUFFER - counter) < znac) {
      znac = znac - SIZE_BUFFER + counter;
      while (znac) {
        buff[i] = '0';
        i++;
        j++;
        znac--;
      }
    }
  }

  while(i < SIZE_BUFFER - counter + j) {
    buff[i] = buffer[counter + k++];
    i++;
  }
  buff[i] = '\0';
  return counter;
}
