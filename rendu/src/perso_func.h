#ifndef PERSO_FUNC_H
#define PERSO_FUNC_H

#include "Attribute.h"

int get_int_register_nb();
int get_float_register_nb();
int get_label_nb(); 
char* enumPrint(int t);
attribute printexp(char* op, attribute g, attribute d);

#endif
