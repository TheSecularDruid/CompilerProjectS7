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
 
type printexp(char op, attribute g, attribute d) {
    FILE* output = fopen("test.c", "a+");
    if(g->type_val==FLOAT&&d->type_val==FLOAT)
	fprintf(output,"rf%d=rf%d%crf%d;\n", get_float_register_nb(), g->reg_number, op, d->reg_number);
    if(g->type_val==FLOAT&&d->type_val==INT)
	fprintf(output,"rf%d=rf%d%cri%d;\n", get_float_register_nb(), g->reg_number, op, d->reg_number);
    if(g->type_val==INT&&d->type_val==FLOAT)
	fprintf(output,"rf%d=ri%d%crf%d;\n", get_float_register_nb(), g->reg_number,op, d->reg_number);
    if(g->type_val==INT&&d->type_val==INT) {
	fprintf(output,"ri%d=ri%d%cri%d;\n", get_int_register_nb(), g->reg_number, op, d->reg_number);
	fclose(output);
	return INT;}
    fclose(output);
    return FLOAT;
}

 
