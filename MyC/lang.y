%code requires{
#include "Table_des_symboles.h"
#include "Attribute.h"
 }

%{

#include <stdio.h>
  
extern int yylex();
extern int yyparse();
 
void yyerror (char* s) {
  printf ("%s\n",s);
  
}

int reg_nb = 0;
int get_register_nb() {
  return(reg_nb++);
}

void init(char* filename) {
  FILE* output;
  output = fopen(filename,w);
}
%}

%union { 
	attribute val;
}
%token <val> NUMI NUMF
%token TINT TFLOAT STRUCT
%token <val> ID
%token AO AF PO PF PV VIR
%token RETURN VOID EQ
%token <val> IF ELSE WHILE

%token <val> AND OR NOT DIFF EQUAL SUP INF
%token PLUS MOINS STAR DIV
%token DOT ARR
%type <val> decl var_decl type typename aff exp
%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
 
%start prog  
 


%%

prog : block                   {}
;

block:
decl_list inst_list            {}
;

// I. Declarations

decl_list : decl decl_list     {}
|                              {}
;

decl: var_decl PV              {$$->name = $1->name;}
| struct_decl PV               {}
| fun_decl                     {}
;

// I.1. Variables
var_decl : type vlist          {$$->type_val = $1->type_val;}
;

// I.2. Structures
struct_decl : STRUCT ID struct {}
;

struct : AO attr AF            {}
;

attr : type ID                 {}
| type ID PV attr              {}

// I.3. Functions

fun_decl : type fun            {}
;

fun : fun_head fun_body        {}
;

fun_head : ID PO PF            {}
| ID PO params PF              {}
;

params: type ID vir params     {}
| type ID                      {}

vlist: ID vir vlist            {}
| ID                           {set_symbol_value(string_to_sid($1->name),get_register_nb());//ajouter une condition pour les redÈfinitions, en gros cette ligne dÈfinis ID comme une variable ‡ retenir et lui associe un numÈro (unique) de registre
                                $$->val = $1->val;}//Áa j'suis pas s˚r mais on sait jamais
  
;

vir : VIR                      {}
;

fun_body : AO block AF         {}
;

// I.4. Types
type
: typename pointer             {}
| typename                     {$$->type_val = $1->type_val; }
;

typename
: TINT                          {$$->type_val = INT; }
| TFLOAT                        {$$->type_val = FLOAT; }
| VOID                          {}
| STRUCT ID                     {}
;

pointer
: pointer STAR                 {}
| STAR                         {}
;


// II. Intructions

inst_list: inst PV inst_list   {}
| inst                         {}
;

inst:
exp                           {}
| AO block AF                 {}
| aff                         {}
| ret                         {}
| cond                        {}
| loop                        {}
| PV                          {}
;


// II.1 Affectations

aff : ID EQ exp               {$$->name = $1->name; $$->int_val = $3->int_val; set_symbol_value($1->name, $3);}
| exp STAR EQ exp
;


// II.2 Return
ret : RETURN exp              {}
| RETURN PO PF                {}
;

// II.3. Conditionelles
cond :
if bool_cond inst             {}
|  else inst                  {}
;


bool_cond : PO exp PF         {}
;

if : IF                       {}
;

else : ELSE                   {}
;

// II.4. Iterations

loop : while while_cond inst  {}
;

while_cond : PO exp PF        {}

while : WHILE                 {}
;


// II.3 Expressions
exp
// II.3.0 Exp. arithmetiques
: MOINS exp %prec UNA         {}
//on va supposer que le fichier marche
| exp PLUS exp                {fprintf(output, "r%d=%s+%s",get_register_nb(),$1->val,$3->val); }
| exp MOINS exp               {fprintf(output, "r%d=%s-%s", get_register_nb(),$1->val, $3->val);}
| exp STAR exp                {fprintf(output, "r%d=%s*%s", get_register_nb(),$1->val, $3->val);}
| exp DIV exp                  {fprintf(output, "r%d=%s/%s", get_register_nb(),$1->val, $3->val);}
| PO exp PF                   {}
| ID                          {$$ = get_symbol_value($1->name);}
| NUMI                        {}
| NUMF                        {$$ = $1;}

// II.3.1 D√©r√©f√©rencement

| STAR exp %prec UNA          {}

// II.3.2. Bool√©ens

| NOT exp %prec UNA           {}
| exp INF exp                 {}
| exp SUP exp                 {}
| exp EQUAL exp               {}
| exp DIFF exp                {}
| exp AND exp                 {}
| exp OR exp                  {}

// II.3.3. Structures

| exp ARR ID                  {}
| exp DOT ID                  {}

| app                         {}
;
       
// II.4 Applications de fonctions

app : ID PO args PF;

args :  arglist               {}
|                             {}
;

arglist : exp VIR arglist     {}
| exp                         {}
;



%% 
int main () {
printf ("? "); return yyparse ();
} 

