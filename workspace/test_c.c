/* Test file en C para el analizador léxico
   Este archivo prueba que el lexer también funciona con código C
*/

#include <stdio.h>
#include <stdlib.h>

// Función principal
int main() {
    // Prueba de identificadores
    int counter;
    float _temperature;
    double averageScore;
    int max_value_2024;
    
    /* 
     * Prueba de literales numéricos
     * Enteros, flotantes, hexadecimales y notación científica
     */
    int decimal = 42;
    int zero = 0;
    int large = 1000000;
    
    // Hexadecimales
    int color = 0xFF00AA;
    int address = 0x8000;
    
    // Flotantes
    float pi = 3.14159;
    double e = 2.71828;
    float half = 0.5;
    
    // Notación científica
    double avogadro = 6.022e23;
    double planck = 6.626e-34;
    double speed_light = 3.0e8;
    
    // Operadores aritméticos
    int sum = 10 + 20;
    int diff = 50 - 15;
    int product = 6 * 7;
    int quotient = 100 / 4;
    
    // Operadores relacionales y lógicos
    if (sum > 0 && diff < 100) {
        printf("Condition 1: true\n");
    }
    
    if (product == 42 || quotient != 25) {
        printf("Condition 2: true\n");
    }
    
    if (!(zero >= 1)) {
        printf("Condition 3: true\n");
    }
    
    // Prueba de cadenas con secuencias de escape
    char *greeting = "Hello, World!";
    char *newline = "First line\nSecond line";
    char *tab = "Column1\tColumn2\tColumn3";
    char *quote = "He said: \"Hello\"";
    char *backslash = "Windows path: C:\\Program Files\\App";
    char *complex = "Special chars: \n\t\"\\";
    
    // Expresiones complejas
    double result = (3.14 * 2.0) + 1e-5 - 0x10;
    
    // Bucles y control de flujo
    for (int i = 0; i < 10; i++) {
        if (i <= 5) {
            continue;
        }
        // Hacer algo
    }
    
    while (counter > 0) {
        counter--;
    }
    
    return 0;
}

// Función auxiliar
void processData(int x, float y) {
    // Operaciones con parámetros
    int result1 = x * 2;
    float result2 = y / 3.0;
    
    if (result1 >= 100 && result2 <= 50.0) {
        printf("Processing complete\n");
    }
}
