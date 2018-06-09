/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_SRC_PARSER_TAB_H_INCLUDED
# define YY_YY_SRC_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_IF = 258,
    T_THEN = 259,
    T_ELSE = 260,
    T_WHILE = 261,
    T_DO = 262,
    ID = 263,
    T_RETURN = 264,
    T_PRINT = 265,
    T_SCAN = 266,
    LET = 267,
    INN = 268,
    T_TYPEVAR = 269,
    T_INUM = 270,
    T_DNUM = 271,
    T_ASSIGN = 272,
    T_CMP = 273,
    T_SEMCOL = 274,
    T_SPACE = 275,
    T_LT = 276,
    T_GT = 277,
    T_LE = 278,
    T_GE = 279,
    T_EQ = 280,
    T_PLUS = 281,
    T_MINUS = 282,
    T_MUL = 283,
    T_DIV = 284,
    T_MOD = 285,
    T_AND = 286,
    T_OR = 287,
    T_XOR = 288,
    T_LB = 289,
    T_RB = 290,
    T_NOT = 291,
    T_NO = 292,
    T_LF = 293,
    T_RF = 294
  };
#endif
/* Tokens.  */
#define T_IF 258
#define T_THEN 259
#define T_ELSE 260
#define T_WHILE 261
#define T_DO 262
#define ID 263
#define T_RETURN 264
#define T_PRINT 265
#define T_SCAN 266
#define LET 267
#define INN 268
#define T_TYPEVAR 269
#define T_INUM 270
#define T_DNUM 271
#define T_ASSIGN 272
#define T_CMP 273
#define T_SEMCOL 274
#define T_SPACE 275
#define T_LT 276
#define T_GT 277
#define T_LE 278
#define T_GE 279
#define T_EQ 280
#define T_PLUS 281
#define T_MINUS 282
#define T_MUL 283
#define T_DIV 284
#define T_MOD 285
#define T_AND 286
#define T_OR 287
#define T_XOR 288
#define T_LB 289
#define T_RB 290
#define T_NOT 291
#define T_NO 292
#define T_LF 293
#define T_RF 294

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 19 "./src/parser.y" /* yacc.c:1909  */

	char *str;
	struct ast* ast_tree;

#line 137 "./src/parser.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_SRC_PARSER_TAB_H_INCLUDED  */
