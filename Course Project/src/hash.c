#include "./../include/hash.h"

void hashtab_init(struct listnode **hashtab) {
  int i;
  for (i = 0; i < HASHTAB_SIZE; i++) {
    hashtab[i] = NULL;
  }
}

unsigned int hashtab_hash(char *key) {
  unsigned int h = 0;
  char *p = key;
  int len = strlen(key);
  int hash, i;

  for (p = key; *p != '\0'; p++)
    h = h * HASHTAB_MUL + (unsigned int)(*p);

  for(hash = i = 0; i < len; ++i) {
      hash += p[i];
      hash += (hash << 10);
      hash ^= (hash >> 6);
  }
  hash += (hash << 3);
  hash ^= (hash >> 11);
  hash += (hash << 15);
  return (hash % HASHTAB_SIZE + h % HASHTAB_SIZE) % HASHTAB_SIZE;
}

void hashtab_add(struct listnode **hashtab, char *key, int value) {
  struct listnode *node;
	struct listnode *look;
	look = hashtab_lookup(hashtab, key);
  int index = hashtab_hash(key);
  if (look == NULL) {
    node = malloc(sizeof(*node));
    if (node != NULL) {
      node->key = strdup(key);
      node->value = value;
      node->type = -1;
      node->scan = 0;
      node->num = 0;
      node->next = NULL;
      hashtab[index] = node;
    }
  } else {
    // Вставка в начало списка
    node = malloc(sizeof(*node));
    if (node != NULL) {
      node->key = strdup(key);
      node->value = value;
      node->type = -1;
      node->scan = 0;
      node->num = 0;
      node->next = look;
      hashtab[index] = node;
	  }
  }
}

struct listnode *hashtab_lookup(struct listnode **hashtab, char *key) {
  int index;
  struct listnode *node;
  index = hashtab_hash(key);
  for (node = hashtab[index]; node != NULL; node = node->next)
    if (strcmp(node->key, key) == 0)
      return node;
  return NULL;
}

void hashtab_delete(struct listnode **hashtab) {
  struct listnode *p, *prev;
  for (int i = 0; i < HASHTAB_SIZE ; ++i) {
    for (p = hashtab[i]; p != NULL;) {
      if (p->key) free(p->key);
      prev = p;
      p = p->next;
      free(prev);
    }
  }
}

void hashtab_print(struct listnode **hashtab) {
  int i;
  struct listnode *node;
  printf("\n\n\t\t\tHASH TABLE:\n\n");
  for (i = 0; i < HASHTAB_SIZE; ++i){
    if (hashtab[i] != NULL) {
      printf("\tNode #%d:\t%s\t-\t%d\t=%d ,scan = %d , num = %d\n", i + 1, hashtab[i]->key, hashtab[i]->value, hashtab[i]->type, hashtab[i]->scan,  hashtab[i]->num);

      if (hashtab[i]->next != NULL) {
        printf("\tNote: This Node (#%d) has collision\n", i + 1);
			  for (node = hashtab[i]; node != NULL; node = node->next)
				  printf("\t\tNode #%d:\t%s\t-\t%d\t=%d\n", i + 1, node->key, node->value, node->type);

        printf("\n");
      } else printf("\n");
    }
  }
  printf("\n");
}
