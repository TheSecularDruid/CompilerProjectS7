PATH = ./src/

all		:	lang

$(PATH)y.tab.h $(PATH)y.tab.c :	$(PATH)lang.y
			bison -v -y  -d $(PATH)lang.y
$(PATH)lex.yy.c	:	$(PATH)lang.l $(PATH)y.tab.h
			flex $(PATH)lang.l 
lang		:	$(PATH)lex.yy.c $(PATH)y.tab.c $(PATH)Table_des_symboles.c $(PATH)Table_des_chaines.c $(PATH)Attribute.c $(PATH)perso_func.c
			gcc -o myc $(PATH)lex.yy.c $(PATH)y.tab.c $(PATH)Attribute.c $(PATH)Table_des_symboles.c $(PATH)Table_des_chaines.c $(PATH)perso_func.c
clean		:	
			rm -f 	$(PATH)lex.yy.c $(PATH)*.o $(PATH)y.tab.h $(PATH)y.tab.c myc $(PATH)*~ y.output
