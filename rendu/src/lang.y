%code requires{
#include "../rendu/src/perso_func.h"
#include "../rendu/src/Attribute.h"
#include "./src/Table_des_symboles.h"
 }

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>    


extern int yylex();
extern int yyparse();
    
void yyerror (char* s) {
    printf ("%s\n",s);}
 
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
%type <val> decl var_decl type typename aff exp vlist did vir if else cond bool_cond stat block inst
%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
 
%start prog  
 


%%

prog : block                   {
                                int i = 0; 
                                int reg_int = get_int_register_nb(); 
                                int reg_float = get_float_register_nb(); 
                                for(i=0;i<reg_int; i++){
				                          fprintf(stderr, "int ri%d;\n", i);
                                }
                                for(i=0; i<reg_float; i++){
                                  fprintf(stderr, "float rf%d;\n", i);
                                }
                                fprintf(stdout, "}"); 
                                }
;

block:
decl_list inst_list            {}
;

// I. Declarations

decl_list : decl decl_list     {}
|                              {}
;

decl: var_decl PV              {}
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

vlist: did vir vlist            {}
| did                           {}
  
;

did : ID                       {
                                $$ =  new_attribute(); 
                                $$->name = $1->name; $$->type_val = $<val>0->type_val;
				$$->reg_number = 0; //On set la valeur reg_number � FALSE � la d�claration, puis � TRUE � l'affectation. De cette mani�re on peut d�t�cter l'utilisation d'une variable non affect�e et renvoyer une erreur le cas �ch�ant
				set_symbol_value(string_to_sid($1->name), $$);
                                fprintf(stderr, "\n%s %s;\n", enumPrint($$->type_val), $$->name);
           

                                }
;

vir : VIR                      {$$->type_val = $<val>-1->type_val;}
;

fun_body : AO block AF         {}
;

// I.4. Types
type
: typename pointer             {}
| typename                     {$$->type_val = $1->type_val;}
;

typename
: TINT                          {$$ = new_attribute(); $$->type_val = INT;
                                }
| TFLOAT                        {$$ = new_attribute(); $$->type_val = FLOAT;}
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
|                              {}
;

inst:
AO block AF                 {}
| aff                         {}
| ret                         {}
| cond                        {}
| loop                        {}
| PV                          {}
;


// II.1 Affectations

aff : ID EQ exp               {
                              $$->type_val = get_symbol_value(string_to_sid($1->name))->type_val; 
			      
                            //on marque la variable comme "initialis�e"
                            attribute x = get_symbol_value(string_to_sid($1->name));
                            x->reg_number = 1;
                            set_symbol_value(string_to_sid($1->name),x);
			      

                            if ($1->type_val == INT && $3->type_val==FLOAT){ //Membres de l'aff de types différents
                                printf("WARNING : implicit cast of FLOAT exp in INT variable\n"); 
                                int cast_int_register = get_int_register_nb();
                                fprintf(stdout, "ri%d = (int) rf%d;\n",cast_int_register,$3->reg_number); 
                                fprintf(stdout, "%s = ri%d;\n", $1->name, cast_int_register);

			                }  else if ($1->type_val == FLOAT && $3->type_val==INT){ //Membres de l'aff de types différents
                            int cast_float_register = get_float_register_nb();
                            fprintf(stdout, "rf%d = (float) ri%d;\n", cast_float_register, $3->reg_number);
                            fprintf(stdout, "%s = rf%d;\n", $1->name, cast_float_register);

			                } else if ($1->type_val==INT && $3->type_val == INT) { //Les deux membres de l'aff sont de memes types
				                      fprintf(stdout, "%s = ri%d;\n", $1->name, $3->reg_number);
                              } else if ($1->type_val == FLOAT){
                                fprintf(stdout, "%s = rf%d;\n", $1->name, $3->reg_number);
                              } else{
                                printf("Type error during affectation of variable %s\n", $1->name);
                                printf("%s",enumPrint($1->type_val));
                                printf("%s\n",enumPrint($3->type_val));
                                exit(-1);
                              }
                               }
| exp STAR EQ exp
;


// II.2 Return
ret : RETURN exp              {}
| RETURN PO PF                {}
;

// II.3. Conditionelles
cond :
if bool_cond stat else stat   { }
|  if bool_cond stat          {}
;

stat:
AO block AF                   {}
; 

bool_cond : PO exp PF         {}
;



if : IF                       {}
;


else : ELSE                   {}
;


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
: MOINS exp %prec UNA         {
                               if($2->type_val==FLOAT) fprintf(stdout,"rf%d = -rf%d;\n", $2->reg_number,$2->reg_number);
			       if($2->type_val==INT) fprintf(stdout,"ri%d = -ri%d;\n", $2->reg_number,$2->reg_number);
                               $$->reg_number = $2->reg_number;}
| exp PLUS exp                {$$=printexp("+",$1,$3);}
| exp MOINS exp               {$$=printexp("-",$1,$3);}
| exp STAR exp                {$$=printexp("*",$1,$3);}
| exp DIV exp                 {$$=printexp("/",$1,$3);}
| PO exp PF                   {$$=$2;}
| ID                          {$$ = get_symbol_value(string_to_sid($1->name));
    
                               //Test pour savoir si la variable a d�j� �t� affect�e
                               if($$->reg_number) {
			
				   int ret_reg_nb;
				   if($$->type_val==FLOAT) {
				       ret_reg_nb = get_float_register_nb();
				       fprintf(stdout,"rf%d = %s;\n", ret_reg_nb, $$->name);}
				   if($$->type_val==INT) {
				       ret_reg_nb = get_int_register_nb();
				       fprintf(stdout,"ri%d = %s;\n", ret_reg_nb, $$->name);}
				   $$->reg_number=ret_reg_nb;
				 }
			       else {
				 FILE* err = fopen("error_log.txt","a+");fprintf(err,"Error : variable %s used with no prior affectation\n", $1->name);fclose(err);exit(-1);
			       }
  }
| NUMI                        {
                               $$->type_val=INT; $$->int_val = $1->int_val; $$->reg_number=get_int_register_nb(); 
                               fprintf(stdout,"ri%d = %d;\n",$$->reg_number,$$->int_val);}
| NUMF                        {$$->type_val=FLOAT; $$->int_val = $1->float_val; $$->reg_number=get_float_register_nb(); 
                               fprintf(stdout,"rf%d = %f;\n",$$->reg_number,$$->float_val);}

// II.3.1 D�r�f�rencement

| STAR exp %prec UNA          {}

// II.3.2. Bool�ens

| NOT exp %prec UNA           {fprintf(stdout,"ri%d = !ri%d;\n",$2->reg_number,$2->reg_number);$$->reg_number=$2->reg_number;$$->type_val=INT;}
| exp INF exp                 {if($1->type_val!=INT||$3->type_val!=INT) {
    FILE* err = fopen("error_log.txt","a+");fprintf(err,"Type error : boolean operation with non-int variable\n");fclose(err); exit(-1);}
                               $$=printexp("<",$1,$3);}
| exp SUP exp                 {if($1->type_val!=INT||$3->type_val!=INT) {
    FILE* err = fopen("error_log.txt","a+");fprintf(err,"Type error : boolean operation with non-int variable\n");fclose(err); exit(-1);}
                               $$=printexp(">",$1,$3);}
| exp EQUAL exp               {if($1->type_val!=INT||$3->type_val!=INT) {
    FILE* err = fopen("error_log.txt","a+");fprintf(err,"Type error : boolean operation with non-int variable\n");fclose(err); exit(-1); }
  $$=printexp("==",$1,$3);}
| exp DIFF exp                {if($1->type_val!=INT||$3->type_val!=INT) {
    FILE* err = fopen("error_log.txt","a+");fprintf(err,"Type error : boolean operation on non-int variable\n");fclose(err); exit(-1);}
                               $$=printexp("<>",$1,$3);}
| exp AND exp                 {if($1->type_val!=INT||$3->type_val!=INT) {
    FILE* err = fopen("error_log.txt","a+");fprintf(err,"Type error : boolean operation on non-int variable\n"); fclose(err); exit(-1);}
                               $$=printexp("&&",$1,$3);}
| exp OR exp                  {if($1->type_val!=INT||$3->type_val!=INT) {
    FILE* err = fopen("error_log.txt","a+");fprintf(err,"Type error : boolean operation on non-int variable\n"); fclose(err);exit(-1);}
                               $$=printexp("||",$1,$3);}

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
    fprintf(stdout, "int main() {"); return yyparse ();
}
