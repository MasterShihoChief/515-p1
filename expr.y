/*
  This file contains the input to the bison compiler generator.
  bison will use this file to generate a C/C++ parser.

  The default output file for bison is: y.tab.c

  This grammar describes a simple expression language with:
  
    +,-,(,), and integers

  In other words, the parser generated when bison processes this
  file will evaluate any legal expression that contains the above
  symbols.  For example, the following are all legal expressions:

    5
    5 + 5
    5 - 5
    5 + (6 - 3)
    (5)
    (42 - 42)
    (3) + (2)


  NOTE: this grammar does not handle binary -, so the following are
  NOT legal:

    5 + -2
    5 - -2
    -2
*/

%{  // bison syntax to indicate the start of the header
  // the header is copied directly into y.tab.c

extern int yylex();
extern int yyerror(char *);
extern int line_count;  // from expr.l, used for statement blocks

#include "error.h"    // class for printing errors
#include "gpl_assert.h" // function version of standard assert.h
#include <iostream>
#include <string>
using namespace std;

%} // bison syntax to indicate the end of the header

// The union is used to declare the variable yylval which is used to
// pass data between the flex generated lexer and the bison generated parser
// A union is kind of like a structure or class, but only one field can be
// used at a time.  Each line describes one item in the union.  The left hand
// side is the type, the right hand side it out name for the type (the union_
// is used to indicate that this is a member of the union).

// the "%union" is bison syntax

%union {
 int            union_int;
 double 		union_double;
 string         *union_string;  // MUST be a pointer to a string (this sucks!)
}

// each token in the language is defined here
// if a token has a type associated with it, put that type (as named in the
// union) inside of <> (such as T_INT_CONSTANT).

%token T_LPAREN
%token T_RPAREN
%token T_PLUS
%token T_MINUS
%token T_PRODUCT
%token T_QUOTIENT

%token <union_int> T_INT_CONSTANT // this token has a int value associated w/it
/*%token <union_string> T_ERROR // this token has a string value associated w/it*/
%token <union_double> T_DOUBLE_CONSTANT //this token has a double value associated w/it

// grammar symbols that have values associated with them need to be
// declared here.  The above union is used for the "ruturning" the value.
// NOTE: values are not really returned as in function calls, but actions
// associated with rules sort of look like functions and the values associated
// with a bison symbol look like return values
%type <union_int> expression
%type <union_double> myDouble

// The following specifies that the operators T_PLUS and T_MINUS are
// left associative, and have the same precedence.
//
// NOTE: you will have to add a "%left" line for each level of precedence
//       The lower precedence operators must be first
//
%left T_PLUS T_MINUS
%left T_PRODUCT T_QUOTIENT

%% // indicates the start of the rules

//---------------------------------------------------------------------
program:
  expression
  {
    cout << "expression = " << $1 << endl;
  }
  ;
//---------------------------------------------------------------------
expression:
  expression T_PLUS expression
  {
    $$ = $1 + $3;
  }
  |
  expression T_MINUS expression
  {
    $$ = $1 - $3;
  }
  |
  T_LPAREN expression T_RPAREN
  {
    $$ = $2;
  }
  |
  T_INT_CONSTANT
  {
    $$ = $1;
  }
  |
  expression T_PRODUCT expression
  {
	$$ = $1 * $3;
  }
  |
  expression T_QUOTIENT expression
  {
	$$ = $1 / $3;
  }
  ;
//-----------------------------------------------------------------------
//---------------------------------------------------------------------
program:
  myDouble
  {
    cout << "expression = " << $1 << endl;
  }
  ;
//---------------------------------------------------------------------
myDouble:
  T_DOUBLE_CONSTANT
  {
    $$ = $1;
  }
  |
  myDouble T_PLUS myDouble
  {
    $$ = $1 + $3;
  }
  |
  myDouble T_MINUS myDouble
  {
    $$ = $1 - $3;
  }
  |
  T_LPAREN myDouble T_RPAREN
  {
    $$ = $2;
  }
  |
  myDouble T_PRODUCT myDouble
  {
	$$ = $1 * $3;
  }
  |
  myDouble T_QUOTIENT myDouble
  {
	$$ = $1 / $3;
  }
  ;