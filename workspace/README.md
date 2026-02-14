# Lab 1: Análisis Léxico con Flex

## Archivos

- **java_lexer.l** - Analizador léxico principal
- **test_java.java** - Casos de prueba en Java
- **test_c.c** - Casos de prueba en C (Requisito 6)
- **SYNTAX_HIGHLIGHTING.md** - Respuesta a pregunta 7
- **ANTLR_ALTERNATIVE.md** - Respuesta a pregunta 8

## Características Implementadas

✅ **Requisito 1:** Identificadores válidos (letra/_ + alfanuméricos)  
✅ **Requisito 2:** Literales numéricos (enteros, flotantes, hex, científicos)  
✅ **Requisito 3:** Operadores (aritméticos, relacionales, lógicos)  
✅ **Requisito 4:** Comentarios (// y /* */)  
✅ **Requisito 5:** Strings con escapes (\n, \t, \", \\)  
✅ **Requisito 6:** Lenguaje C (ver test_c.c)  
✅ **Requisito 7:** Syntax highlighting (ver SYNTAX_HIGHLIGHTING.md)  
✅ **Requisito 8:** ANTLR (ver ANTLR_ALTERNATIVE.md)

## Compilación y Ejecución

### Con Docker:
```bash
cd ..
docker-compose up -d
docker exec -it flex_container bash
cd /workspace
make
make test
```

### Con PowerShell (Windows):
```powershell
.\run.ps1 compile
.\run.ps1 test-all
```

### Manual (Linux/Mac):
```bash
flex java_lexer.l
gcc lex.yy.c -o java_lexer -lfl
./java_lexer test_java.java
```

## Ejemplos

**Entrada:**
```java
int x = 42;
float y = 3.14;
```

**Salida:**
```
KEYWORD: int (línea 1)
IDENTIFIER: x (línea 1)
ASSIGNMENT: = (línea 1)
INTEGER: 42 (línea 1)
SEMICOLON: ; (línea 1)
KEYWORD: float (línea 2)
IDENTIFIER: y (línea 2)
ASSIGNMENT: = (línea 2)
FLOAT: 3.14 (línea 2)
SEMICOLON: ; (línea 2)
```
