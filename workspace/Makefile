# Makefile - Lab 1 Análisis Léxico

CC = gcc
FLEX = flex
CFLAGS = -Wall
LDFLAGS = -lfl

LEXER_SOURCE = java_lexer.l
LEXER_OUTPUT = lex.yy.c
EXECUTABLE = java_lexer
TEST_JAVA = test_java.java
TEST_C = test_c.c

all: $(EXECUTABLE)

$(LEXER_OUTPUT): $(LEXER_SOURCE)
	$(FLEX) $(LEXER_SOURCE)

$(EXECUTABLE): $(LEXER_OUTPUT)
	$(CC) $(CFLAGS) $(LEXER_OUTPUT) -o $(EXECUTABLE) $(LDFLAGS)

test-java: $(EXECUTABLE)
	./$(EXECUTABLE) $(TEST_JAVA)

test-c: $(EXECUTABLE)
	./$(EXECUTABLE) $(TEST_C)

test: test-java test-c

clean:
	rm -f $(LEXER_OUTPUT) $(EXECUTABLE)

rebuild: clean all

.PHONY: all test test-java test-c clean rebuild
