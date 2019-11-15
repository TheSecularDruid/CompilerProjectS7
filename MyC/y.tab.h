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

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 1 "lang.y" /* yacc.c:1909  */

#include "Table_des_symboles.h"
#include "Attribute.h"
 

#line 50 "y.tab.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    NUMI = 258,
    NUMF = 259,
    TINT = 260,
    TFLOAT = 261,
    STRUCT = 262,
    ID = 263,
    AO = 264,
    AF = 265,
    PO = 266,
    PF = 267,
    PV = 268,
    VIR = 269,
    RETURN = 270,
    VOID = 271,
    EQ = 272,
    IF = 273,
    ELSE = 274,
    WHILE = 275,
    AND = 276,
    OR = 277,
    NOT = 278,
    DIFF = 279,
    EQUAL = 280,
    SUP = 281,
    INF = 282,
    PLUS = 283,
    MOINS = 284,
    STAR = 285,
    DIV = 286,
    DOT = 287,
    ARR = 288,
    UNA = 289
  };
#endif
/* Tokens.  */
#define NUMI 258
#define NUMF 259
#define TINT 260
#define TFLOAT 261
#define STRUCT 262
#define ID 263
#define AO 264
#define AF 265
#define PO 266
#define PF 267
#define PV 268
#define VIR 269
#define RETURN 270
#define VOID 271
#define EQ 272
#define IF 273
#define ELSE 274
#define WHILE 275
#define AND 276
#define OR 277
#define NOT 278
#define DIFF 279
#define EQUAL 280
#define SUP 281
#define INF 282
#define PLUS 283
#define MOINS 284
#define STAR 285
#define DIV 286
#define DOT 287
#define ARR 288
#define UNA 289

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 35 "lang.y" /* yacc.c:1909  */
 
	attribute val;

#line 134 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
