#include "perso_func.h"
#include <stdio.h>
#include <stdlib.h>

int int_reg_nb = 0;
int get_int_register_nb() {
    return(int_reg_nb++);
}
 
int float_reg_nb = 0;
int get_float_register_nb() {
    return(float_reg_nb++);
} 
 
char * enumPrint(int t){
    if (t == 0) return "int" ;
    if (t == 1) return "float" ;
    else return "type error from enumPrint";
}
 
attribute printexp(char op, attribute g, attribute d) {
    FILE* output = fopen("test.c", "a+");
    attribute ret = new_attribute();
    ret->type_val = FLOAT;
    int f = -1;
    if(g->type_val==FLOAT&&d->type_val==FLOAT) {
	f = get_float_register_nb();
	fprintf(output,"rf%d = rf%d %c rf%d;\n", f, g->reg_number, op, d->reg_number);}
    if(g->type_val==FLOAT&&d->type_val==INT) {
	f = get_float_register_nb();
	int cast_reg_nb = get_float_register_nb();
	fprintf(output, "rf%d = (float) ri%d;\n", cast_reg_nb, d->reg_number);   //explicitation du cast
	fprintf(output,"rf%d = rf%d %c rf%d;\n", f, g->reg_number, op, cast_reg_nb);}
    if(g->type_val==INT&&d->type_val==FLOAT){
	f = get_float_register_nb();
	int cast_reg_nb = get_float_register_nb();
	fprintf(output,"rf%d = (float) ri%d;\n", cast_reg_nb, g->reg_number);
	fprintf(output,"rf%d = rf%d %c rf%d;\n", f, cast_reg_nb,op, d->reg_number);}
    if(g->type_val==INT&&d->type_val==INT) {
	f = get_int_register_nb();
	fprintf(output,"ri%d = ri%d %c ri%d;\n", f, g->reg_number, op, d->reg_number);
	ret->type_val = INT;}
    fclose(output);
    ret->reg_number = f;
    return ret;
}

 