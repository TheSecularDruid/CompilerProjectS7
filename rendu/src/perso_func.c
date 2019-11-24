#include "perso_func.h"
#include <stdio.h>
#include <stdlib.h>

//Incrémente les registres entiers
int int_reg_nb = 0;
int get_int_register_nb() {
    return(int_reg_nb++);
}
 
//Incrémente les registres pour float
int float_reg_nb = 0;
int get_float_register_nb() {
    return(float_reg_nb++);
} 

//Incrémente les lebels
int label_nb = 0;
int get_label_nb() {
    return(label_nb++);
} 


char * enumPrint(int t){
    if (t == 0) return "int" ;
    if (t == 1) return "float" ;
    else return "type error from enumPrint";
}
 
attribute printexp(char* op, attribute g, attribute d) {
    attribute ret = new_attribute();
    ret->type_val = FLOAT;
    int f = -1;
    if(g->type_val==FLOAT&&d->type_val==FLOAT) {
	f = get_float_register_nb();
	fprintf(STDOUT,"rf%d = rf%d %s rf%d;\n", f, g->reg_number, op, d->reg_number);}
    if(g->type_val==FLOAT&&d->type_val==INT) {
	f = get_float_register_nb();
	int cast_reg_nb = get_float_register_nb();
	fprintf(STDOUT, "rf%d = (float) ri%d;\n", cast_reg_nb, d->reg_number);   //explicitation du cast
	fprintf(STDOUT,"rf%d = rf%d %s rf%d;\n", f, g->reg_number, op, cast_reg_nb);}
    if(g->type_val==INT&&d->type_val==FLOAT){
	f = get_float_register_nb();
	int cast_reg_nb = get_float_register_nb();
	fprintf(STDOUT,"rf%d = (float) ri%d;\n", cast_reg_nb, g->reg_number);
	fprintf(STDOUT,"rf%d = rf%d %s rf%d;\n", f, cast_reg_nb,op, d->reg_number);}
    if(g->type_val==INT&&d->type_val==INT) {
	f = get_int_register_nb();
	fprintf(STDOUT,"ri%d = ri%d %s ri%d;\n", f, g->reg_number, op, d->reg_number);
	ret->type_val = INT;}
    ret->reg_number = f;
    return ret;
}

 
