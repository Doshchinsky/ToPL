#include "chaining_hash.h"

void hashtab_init(struct listnode **hashtab)
{
	int i;
	for (i = 0; i < HASHTAB_SIZE; i++) {
		hashtab[i] = NULL;
	}
}

unsigned int hashtab_hash(char *key)
{
	unsigned int h = 0;
	char *p;
	for (p = key; *p != '\0'; p++)
		h = h * HASHTAB_MUL + (unsigned int) * p;
	return h % HASHTAB_SIZE;
}

void hashtab_add(struct listnode **hashtab, char *key, int value)
{
	struct listnode *node;
	if (!hashtab_lookup(hashtab, key)) 
	{
		int index = hashtab_hash(key);
		node = malloc(sizeof(*node));
		if (node != NULL) 
		{
			node->key = strdup(key);
			node->value = value;
			node->coll = hashtab[index];
			hashtab[index] = node;
		}
		return;	
	}
	int index = hashtab_hash(key);
	
	// Вставка в начало списка
	node = malloc(sizeof(*node));
	if (node != NULL) {
		node->key = strdup(key);
		node->value = value;
		node->next = hashtab[index];
		hashtab[index] = node;
	}
}

/*struct listnode *hashtab_lookup(struct listnode **hashtab, char *key)
{
	int index;
	struct listnode *node;
	index = hashtab_hash(key);
	if (hashtab[index] == NULL)
		return NULL;

	if (strcmp(hashtab[index]->key, key) == 0)
		return hashtab[index];

	for (int i = (index + 1) % HASHTAB_SIZE; i != index; i = (i + 1) % HASHTAB_SIZE){
		if (hashtab[i] == NULL)
			continue;
		if (strcmp(hashtab[i]->key, key) == 0)
			return node;
	}
	return NULL;
}*/

struct listnode *hashtab_lookup(struct listnode **hashtab, char *key)
{
	int index;
	struct listnode *node;
	index = hashtab_hash(key);
	for (node = hashtab[index]; node != NULL; node = node->next)
		for (node = hashtab[index]; node != NULL ; node = node->coll)
			if (strcmp(node->key, key) == 0)
				return node;
	return NULL;
}

void hashtab_delete(struct listnode **hashtab)
{
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

void hashtab_print(struct listnode **hashtab)
{
	printf("\n\n\t\t\tHASH TABLE:\n\n");
	for (int i = 0; i < HASHTAB_SIZE; ++i)
		if (hashtab[i] != NULL) {
			printf("\tNode #%d:\t%s\t-\t%d\n", i + 1, hashtab[i]->key, hashtab[i]->value);
		
		if (hashtab[i]->coll != NULL) {
			printf("\tNote: This Node (#%d) has collision\n", i + 1);
			printf("\n");
		} else printf("\n");
	}
	printf("\n");
}