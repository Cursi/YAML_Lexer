# Cursaru Razvan-Mihai 331CC

CC=gcc
FLEX=flex
RM=rm

tema: flex_tema.l
	$(FLEX) flex_tema.l
	$(CC) -Wall lex.yy.c -o tema

.PHONY: run
run: tema
	./tema $(TEST)

.PHONY: clean
clean: lex.yy.c tema
	$(RM) lex.yy.c
	$(RM) tema
