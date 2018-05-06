#ifndef CHAINING
#define CHAINING

#define HASHTAB_MUL 31
#define HASHTAB_SIZE 50

struct listnode
{
	char *key;
	int value;
	struct listnode *next;
};

struct listnode* hashtab[HASHTAB_SIZE];

void hashtab_init(struct listnode **hashtab);
unsigned int hashing_hash(char *s);

#endif