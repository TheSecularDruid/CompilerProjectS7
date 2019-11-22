%code requires{
#include "Table_des_symboles.h"
#include "Attribute.h"

 }

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>    
#include "perso_func.h"
    
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
%type <val> decl var_decl type typename aff exp vlist did vir
%left DIFF EQUAL SUP INF       // low priority on comparison
%left PLUS MOINS               // higher priority on + - 
%left STAR DIV                 // higher priority on * /
%left OR                       // higher priority on ||
%left AND                      // higher priority on &&
%left DOT ARR                  // higher priority on . and -> 
%nonassoc UNA                  // highest priority on unary operator
 
%start prog  
 


%%

prog : block                   {FILE* output_h = fopen("test.h","a+");
                                int i;
                                for(i=0;i++;i<get_int_register_nb()) 
				    fprintf(output_h, "int ri%d;\n", i);
				for(i=0;i++;i<get_float_register_nb())
				    fprintf(output_h, "float rf%d;\n");
				fclose(output_h);
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
var_decl : type vlist          {$$->type_val = $1->type_val; printf("type vlist\n");}
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
				$$->reg_number = 0; //On set la valeur reg_number à FALSE à la déclaration, puis à TRUE à l'affectation. De cette manière on peut détécter l'utilisation d'une variable non affectée et renvoyer une erreur le cas échéant
				set_symbol_value(string_to_sid($1->name), $$);
                                FILE * output_h = fopen("test.h", "a+");
                                fprintf(output_h, "\n%s %s;\n", enumPrint($$->type_val), $$->name);
                                fclose(output_h); 
            
                                printf("ID\n");

                                }
;

vir : VIR                      {$$->type_val = $<val>-1->type_val;  printf("VIR\n");}
;

fun_body : AO block AF         {}
;

// I.4. Types
type
: typename pointer             {}
| typename                     {$$->type_val = $1->type_val; printf("typename\n ");}
;

typename
: TINT                          {$$ = new_attribute(); $$->type_val = INT; printf("TINT\n");
                                }
| TFLOAT                        {$$ = new_attribute(); $$->type_val = FLOAT; printf("TFLOAT\n");}
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
                              FILE * output_c = fopen("test.c", "a+");
                              $$->type_val = get_symbol_value(string_to_sid($1->name))->type_val; 
			      
			      //on marque la variable comme "initialisée"
			      attribute x = get_symbol_value(string_to_sid($1->name));
			      x->reg_number = 1;
			      set_symbol_value(string_to_sid($1->name),x);
			      

                              if ($1->type_val == INT && $3->type_val==FLOAT){
                                  printf("WARNING : implicit cast of FLOAT exp in INT variable\n"); 
				  int cast_int_register = get_int_register_nb();
				  fprintf(output_c, "ri%d = (int) rf%d;\n",cast_int_register,$3->reg_number); 
				  fprintf(output_c, "%s = ri%d;\n", $1->name, cast_int_register);
			      }  else if ($1->type_val == FLOAT && $3->type_val==INT){
				  int cast_float_register = get_float_register_nb();
				  fprintf(output_c, "rf%d = (float) ri%d;\n", cast_float_register, $3->reg_number);
				  fprintf(output_c, "%s = rf%d;\n", $1->name, cast_float_register);
			      } else if ($1->type_val==INT &&$3->type_val == INT) {
				  fprintf(output_c, "%s = ri%d;\n", $1->name, $3->reg_number);
                              } else if ($1->type_val == FLOAT){
                                fprintf(output_c, "%s = rf%d;\n", $1->name, $3->reg_number);
                              } else{
                                  printf("Type error during affectation of variable %s\n", $1->name);
				  printf("%s",enumPrint($1->type_val));
				  printf("%s\n",enumPrint($3->type_val));
				  exit(-1);
                              }
                              
                              printf("Affectation\n"); 
			      fclose(output_c);
                              }
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
: MOINS exp %prec UNA         {FILE* output = fopen("test.c", "a+"); if($2->type_val==FLOAT) fprintf(output,"rf%d = -rf%d;\n", get_float_register_nb(),$2->reg_number);
                               if($2->type_val==INT) fprintf(output,"ri%d = -ri%d;\n", get_int_register_nb(),$2->reg_number);
			       fclose(output);}
| exp PLUS exp                {$$=printexp('+',$1,$3);}
| exp MOINS exp               {$$=printexp('-',$1,$3);}
| exp STAR exp                {$$=printexp('*',$1,$3);}
| exp DIV exp                 {$$=printexp('/',$1,$3);}
| PO exp PF                   {$$=$2;}
| ID                          {$$ = get_symbol_value(string_to_sid($1->name));
    
                               //Test pour savoir si la variable a déjà été affectée
                               if($$->reg_number) {
				   FILE* output=fopen("test.c","a+");
				   int ret_reg_nb;
				   if($$->type_val==FLOAT) {
				       ret_reg_nb = get_float_register_nb();
				       fprintf(output,"rf%d = %s;\n", ret_reg_nb, $$->name);}
				   if($$->type_val==INT) {
				       ret_reg_nb = get_int_register_nb();
				       fprintf(output,"ri%d = %s;\n", ret_reg_nb, $$->name);}
				   $$->reg_number=ret_reg_nb;
				   fclose(output);}
			       else {
				   printf("Error : variable %s used with no prior affectation\n", $1->name);
			       }
  }
| NUMI                        {FILE* output=fopen("test.c","a+");
                               $$->type_val=INT; $$->int_val = $1->int_val; $$->reg_number=get_int_register_nb(); printf("NUMI\n");
                               fprintf(output,"ri%d = %d;\n",$$->reg_number,$$->int_val);fclose(output);}
| NUMF                        {FILE* output=fopen("test.c","a+"); $$->type_val=FLOAT; $$->int_val = $1->float_val; $$->reg_number=get_float_register_nb(); printf("NUMF\n");
                               fprintf(output,"rf%d = %f;\n",$$->reg_number,$$->float_val);fclose(output);}

// II.3.1 Déréférencement

| STAR exp %prec UNA          {}

// II.3.2. Booléens

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
