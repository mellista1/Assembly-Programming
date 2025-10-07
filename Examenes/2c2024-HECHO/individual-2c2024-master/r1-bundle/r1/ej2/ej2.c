#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "ej2.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_2A_HECHO = false;

float modps(float valor, float periodo) {
	return valor-(floor(valor/periodo) * periodo);
}

/**
 * OPCIONAL: implementar en C
 */
void unwrap(float* A, float* B, uint32_t size, float periodo) {
}