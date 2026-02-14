# Entorno Docker para Flex

Entorno Docker para [Flex](https://github.com/westes/flex) (Fast Lexical Analyzer).

## Inicio Rápido

### 1. Construir e iniciar el contenedor
```bash
docker-compose up -d
```

### 2. Entrar al contenedor
```bash
docker exec -it flex_container bash
```

### 3. Compilar y probar
```bash
cd /workspace
make
make test
```

### 4. Detener el contenedor
```bash
docker-compose down
```

## Comandos Útiles de Flex

| Comando                   | Descripción                                 |
| ------------------------- | ------------------------------------------- |
| `flex archivo.l`          | Generar lex.yy.c                           |
| `flex -d archivo.l`       | Modo debug (imprime cada token encontrado) |
| `flex -v archivo.l`       | Salida verbosa (muestra estadísticas DFA)  |
| `flex -o salida.c archivo.l` | Nombre personalizado para archivo de salida |

## Archivos del Lab

Ver `workspace/README.md` para documentación completa del Lab 1.

## Estructura

```
Flex_Setup/
├── Dockerfile
├── docker-compose.yml
├── README.md
└── workspace/
    ├── java_lexer.l
    ├── test_java.java
    ├── test_c.c
    ├── SYNTAX_HIGHLIGHTING.md
    ├── ANTLR_ALTERNATIVE.md
    ├── Makefile
    ├── run.ps1
    └── README.md
```
