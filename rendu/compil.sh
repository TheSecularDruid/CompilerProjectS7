#!/bin/bash

    
cat $1 | ./myc > $1.c 2> $1.h
gcc $1.c -include $1.h -o $1

     
