#include "./../include/ast.h"

struct ast* ast_createNode(int type, char* key, struct ast* l, struct ast* m, struct ast* r) {
  struct ast* p = NULL;
  p = (struct ast*)malloc(sizeof(struct ast));
  if (p != NULL) {
    p->type = type;
    p->key = key;
    p->left = l;
    p->middle = m;
    p->right = r;
    #if DEBUG==1
    printf("Node (%p) | (%d %s %p %p %p) create!\n",p, type, key, l, m, r);
    #endif
  }

  return p;
}

void print_ast(struct ast* t, int l) {
  int i;
  for (i = 0; i < l; ++i) printf("|  ");
  if (t != NULL) {
    printf("%d | %s\n", t->type, t->key);
    print_ast(t->left, l + 1);
    print_ast(t->middle, l + 1);
    print_ast(t->right, l + 1);
    printf("\n");
  } else printf("NULL\n");
}

void free_ast(struct ast* t) {
  if (t != NULL){
    free_ast(t->left);
    free_ast(t->middle);
    free_ast(t->right);
    free(t);
  }
}
