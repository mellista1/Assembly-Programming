#pragma once
#include <stdbool.h>
#include <stdint.h>

extern uint32_t catalogo[32];

extern char *productos[256];


// Se pide implementar las siguientes funciones:

// Imprime un producto en el archivo pfile con el siguiente formato:
// Nombre del producto, Precio, Moneda, Stock
// Donde Nombre de producto se obtiene a partir del array productos, usando el parámetro id como índice
// Moneda debe ser "ARG" si moneda es 0 y "USD" si moneda es 1
// Pueden asumir que el archivo pfile ya está abierto y no hace falta cerrarlo y que id es un índice válido en el array productos
void imprimir_producto(FILE *pfile, uint32_t id, uint32_t precio, uint32_t moneda, uint32_t stock);

// Procesa el catálogo almacenado en el array catalogo obteniendo los componentes de cada producto y lo imprime en el archivo pfile
// Pueden asumir que el archivo pfile ya está abierto y no hace falta cerrarlo
void procesar_e_imprimir_catalogo(FILE *pfile);
