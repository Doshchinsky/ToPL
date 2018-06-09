CC = gcc
LEX = flex
PARSE = bison
CFLAGS = -g3 -O0 -Wall
LIB = -lm

all: COMPILE TEST

restruct: clean all

COMPILE: PARSER LEXER AST GEN MAIN

MAIN: ./obj/main.o
	$(CC) ./obj/main.o ./obj/lexer.yy.o ./obj/parser.tab.o  ./obj/hash.o ./obj/ast.o ./obj/codegen.o -o ./bin/tlpcc  $(CFLAGS)

./obj/main.o: ./src/main.c
	$(CC) -c ./src/main.c -o ./obj/main.o $(CFLAGS)

LEXER: HASH ./src/lexer.l
	$(LEX) -o ./src/lexer.yy.c ./src/lexer.l
	$(CC) -c ./src/lexer.yy.c -o ./obj/lexer.yy.o  $(CFLAGS)

HASH: ./src/hash.c
	$(CC) -c ./src/hash.c -o ./obj/hash.o $(CFLAGS)

AST: ./src/ast.c
	$(CC) -c ./src/ast.c -o ./obj/ast.o $(CFLAGS)

GEN: ./src/codegen.c
	$(CC) -c ./src/codegen.c -o ./obj/codegen.o $(CFLAGS)

PARSER: ./src/parser.y
	$(PARSE) -o ./src/parser.tab.c ./src/parser.y -dy
	$(CC) -c ./src/parser.tab.c -o ./obj/parser.tab.o $(CFLAGS)
	mv ./src/parser.tab.h ./include/parser.tab.h

TEST:

.PHONY: clean
clean:
	rm -f ./obj/*.o
	rm -f ./src/lexer.yy.c
	rm -f ./src/parser.tab.c
	rm -f ./include/parser.tab.h