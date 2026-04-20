# Flex Docker Environment

Docker environment for [flex](https://github.com/westes/flex) (Fast Lexical Analyzer) built from source.

## Getting Started

### 1. Build and start the container

```bash
docker compose up -d --build
```

### 2. Enter the container

```bash
docker compose exec flex bash
```

### 3. Run the example

```bash
cd /workspace/examples
flex example.l
gcc lex.yy.c -o scanner
echo "Hello World from flex!" | ./scanner
```

Output:

```
Lines: 1, Words: 4, Characters: 23
```

### 4. Stop the container

```bash
docker compose down
```

Inside the container, navigate to your folder:

```bash
cd /workspace/examples/tu-carpeta
flex tu-archivo.l
gcc lex.yy.c -o scanner
./scanner < input.txt
```

## Useful flex Commands

| Command                   | Description                                 |
| ------------------------- | ------------------------------------------- |
| `flex file.l`             | Generate lex.yy.c                           |
| `flex -d file.l`          | Enable debug mode (prints each token match) |
| `flex -v file.l`          | Verbose output (shows DFA stats)            |
| `flex -o output.c file.l` | Custom output filename                      |

## File Structure

```
flex-docker/
├── Dockerfile
├── docker-compose.yml
├── README.md
├── .gitignore
└── workspace/
    └── examples/
        └── example.l
```

# Python Function Scanner

A Flex-based lexical analyzer for scanning Python function syntax.

### python.l

The Flex specification file consists of three sections:

**Section 1: Declarations** (between `%{` and `%}`)

- C includes and global variables
- Example: `int codeLine = 1;`

**Section 2: Rules** (between `%%` markers)

- Pattern-action pairs
- Example: `"def" { print_token("DEF", yytext); }`

**Section 3: User Code** (after second `%%`)

- Helper functions
- `yywrap()` function (required)
- `main()` function

## How to Build

```bash
# Generate C code from Flex specification
flex python.l

# Compile the generated code
gcc lex.yy.c -o scanner -lfl

# Run the scanner
./scanner test.py
```

## Input

Text file containing Python code:

```python
def add(x, y):
    return x + y
```

## Output

```
Token(DEF, 'def', line=1, pos=1)
Token(IDENTIFIER, 'add', line=1, pos=5)
Token(LPAREN, '(', line=1, pos=8)
...
```

## Key Variables

- `yytext` - Matched string
- `yyleng` - Length of matched string
- `codeLine` - Current line number
- `position` - Current character position

## Notes

- Generated files (`lex.yy.c`, `scanner`) are excluded from git
- Only commit your `.l` source files
- The container includes `gcc` for compiling the generated C code

---

# Python Parser — Flex + YACC

Extends the Python scanner with a **YACC grammar** that validates syntax and reports errors with line numbers.

## Files

| File               | Role                                                              |
| ------------------ | ----------------------------------------------------------------- |
| `python_parser.l`  | Flex lexer — prints tokens **and** returns codes to YACC          |
| `python_parser.y`  | YACC grammar — defines valid syntax, calls `yyerror` on bad input |
| `test_valid.input` | Valid input (parses cleanly)                                      |
| `test_error.input` | Input with a syntax error on line 2                               |

## How to Build

```bash
# 1. Enter the container
docker compose exec flex bash
cd /workspace/examples

# 2. Generate C files
yacc -d python_parser.y    # produces y.tab.c and y.tab.h
flex python_parser.l       # produces lex.yy.c

# 3. Compile
gcc y.tab.c lex.yy.c -o parser
```

## Running — valid input

```bash
./parser < test_valid.input
```

Expected output:

```
=== Python Parser (Flex + YACC) ===

  [TOKEN] ID         -> 'x'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '5'
  [PARSE] Assignment
  ...
  [TOKEN] DEF        -> 'def'
  [TOKEN] ID         -> 'add'
  ...
  [PARSE] Function definition

[OK] Input parsed successfully — no syntax errors.
```

## Running — input with a syntax error

```bash
./parser < test_error.input
```

`test_error.input` contains `y = * 3` on line 2 — a `*` where an expression is expected.

Expected output:

```
=== Python Parser (Flex + YACC) ===

  [TOKEN] ID         -> 'x'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] NUMBER     -> '5'
  [PARSE] Assignment
  [TOKEN] ID         -> 'y'
  [TOKEN] ASSIGN     -> '='
  [TOKEN] TIMES      -> '*'

  [SYNTAX ERROR] syntax error at line 2

[FAIL] Parsing stopped due to syntax error(s).
```

## Grammar summary

```
program       → statement+
statement     → ID = expr NEWLINE
              | expr NEWLINE
              | def ID ( params ) : NEWLINE
              | NEWLINE
expr          → expr + term | expr - term | term
term          → term * factor | term / factor | factor
factor        → ID | NUMBER | ( expr )
```

## Key YACC variables / functions

| Item           | Description                                             |
| -------------- | ------------------------------------------------------- |
| `yyparse()`    | Starts parsing; returns 0 on success                    |
| `yylex()`      | Called by YACC to get the next token (provided by Flex) |
| `yyerror(msg)` | Called on syntax error; receives the error message      |
| `%token`       | Declares terminal symbols shared between `.y` and `.l`  |
| `%left`        | Declares left-associative operators (sets precedence)   |
| `yacc -d`      | Generates `y.tab.h` so the lexer knows the token codes  |
