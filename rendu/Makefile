PATH_FILE = ./src/

all		:	lang

$(PATH_FILE)y.tab.h $(PATH_FILE)y.tab.c :	$(PATH_FILE)lang.y
			bison -v -y  -d $(PATH_FILE)lang.y
lex.yy.c	:	$(PATH_FILE)lang.l y.tab.h
			flex $(PATH_FILE)lang.l 
lang		:	lex.yy.c y.tab.c $(PATH_FILE)Table_des_symboles.c $(PATH_FILE)Table_des_chaines.c $(PATH_FILE)Attribute.c $(PATH_FILE)perso_func.c
			gcc -o myc lex.yy.c y.tab.c $(PATH_FILE)Attribute.c $(PATH_FILE)Table_des_symboles.c $(PATH_FILE)Table_des_chaines.c $(PATH_FILE)perso_func.c
clean		:	
			rm -f lex.yy.c $(PATH_FILE)*.o y.tab.h y.tab.c myc $(PATH_FILE)*~ y.output
