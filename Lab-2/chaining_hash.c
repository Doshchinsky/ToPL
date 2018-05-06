#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "chaining_hash.h"

void hashtab_init(struct listnode **hashtab)
{
	int i;
	for (i = 0; i < HASHTAB_SIZE; i++) {
		hashtab[i] = NULL;
	}
}

unsigned int hashing_hash(char *key)
{
	unsigned int h = 0;
	char *p;
	for (p = key; *p != '\0'; p++)
		h = h * HASHTAB_MUL + (unsigned int) * p;
	return h % HASHTAB_SIZE;
}