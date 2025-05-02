#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_1A_HECHO = false;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - indice_a_inventario
 */
bool EJERCICIO_1B_HECHO = false;

/**
 * OPCIONAL: implementar en C
 */
bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador) {
 // a mi me gustaria chequear si la vista que me pasan por parámetro está correctamente ordenada segun el comparador
 //además debo chequear que la vista corresponda a un inventario posible
 //cada posicion de la vista es vista[i] = inventario [inidice[i]]. Si en algún momento no se cumple la igualdad con lo que indica el comparador, entonces, return false.
	uint16_t tam = 0;
	bool res = true;
	if (tamanio == 1 || tamanio == 0){
		return res;
	}else{
		item_t* actual = indice[tam];
		item_t* siguiente = indice[tam +1];
		while (tam != tamanio-1)
		{
			if (comparador(actual, siguiente) == true )
			{
				tam = tam + 1;
				actual = siguiente;
				siguiente = indice[tam + 1];
				
			}else{
				res = false;
				break;
			}
		
		}
	return res;
	}



}

/**
 * OPCIONAL: implementar en C
 */
item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio) {
	
	item_t** resultado = calloc(tamanio, sizeof(item_t));

	for (size_t i = 0; i < tamanio -1; i++)
	{
		item_t* nuevo_item = malloc(sizeof(item_t));
		nuevo_item->fuerza = inventario[indice[i]]->fuerza;
		nuevo_item->durabilidad = inventario[indice[i]]->durabilidad;
		for (size_t j = 0; j < 18; j++)
		{
			nuevo_item->nombre[j] = inventario[indice[i]]->nombre[j];
		}
		resultado[i] = nuevo_item;
	}

	return resultado;
}
