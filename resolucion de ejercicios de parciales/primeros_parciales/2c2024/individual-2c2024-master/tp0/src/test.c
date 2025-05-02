#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <assert.h>
#include <errno.h>
#include "ej1.h"

char *filename_salida = "salida.propios.txt";
void test(char *filename);

int main(void)
{
    srand(0);
    remove(filename_salida);
    test(filename_salida);
    return 0;
}

void test(char *filename)
{
    // Abrimos un archivo para escribir
    FILE *pfile = fopen(filename, "a");

    // Generamos el catalogo con valores aleatorios
    for (int i = 0; i < 32; i++)
    {
        catalogo[i] = (uint32_t)(rand() % (4294967296));
    }

    procesar_e_imprimir_catalogo(pfile);

    // Cerramos el archivo
    fclose(pfile);
}
