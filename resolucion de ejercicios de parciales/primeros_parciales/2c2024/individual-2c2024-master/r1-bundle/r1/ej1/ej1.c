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
bool EJERCICIO_1A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_1B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_1C_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {
    //IDEA: Tengo que recorrer el mapa de forma completa. Debo encontrar todas aquellas unidades independientes que son equivalentes (comparten el mismo hash CON LA QUE ME PASAN POR PARAMETRO)
    // y reemplazarlas por la instancia compartida.

    uint32_t hash_en_comun = fun_hash(compartida);
    
    for (int i = 0; i< 255; i++)
    {
        for (int j = 0; j< 255; j++)
        {
            if (mapa[i][j] != NULL)
            {
                uint32_t h = fun_hash(mapa[i][j]);
                if (h == hash_en_comun)
                {
                    if (mapa[i][j] != compartida)
                    {
                    mapa[i][j] = compartida;
                    compartida->references++;
                    }
                
                }
            }   
            
        }
        
    }

}

/**
 * OPCIONAL: implementar en C
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
    //IDEA: Necesito recorrer el mapa en su totalidad. Debo sumar el extra que agregue de combustible a cada personaje. La función me retorna la base que tenía el personjae antes de que el usuario le agregue (si es que agrego)
//mas combustible

    uint32_t res = 0;
    for (int i = 0; i< 255; i++)
    {
        for (int j = 0; j< 255; j++)
        {
            if (mapa[i][j] != NULL)
            {
                uint16_t base = fun_combustible(mapa[i][j]->clase);
                if (mapa[i][j]->combustible > base)
                {   
                    res = res + (mapa[i][j]->combustible - base);
                }
            }
            
        }
        
    }
    return res;
}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {
    //IDEA: Voy a considerar que una unidad fue previamente optimizada si la cantidad de referencias es mayor a 1. 
    //Entonces si en la posición (x,y) hay una unidad y además tiene cantidad de referencias mayor a 1, tengo que crear una nueva unidad, modificar el puntero de la posición (x,y) 
    //y luego llamar a la fun_modificar

    if (mapa[x][y] != NULL)
    {
        if (mapa[x][y]->references > 1)
        {
            attackunit_t* nueva_unidad = malloc(sizeof(attackunit_t));

            for (size_t i = 0; mapa[x][y]->clase[i] != 0; i++)
            {
                nueva_unidad->clase[i] = mapa[x][y]->clase[i];
            }
            
            nueva_unidad->references = 1;
            nueva_unidad->combustible = mapa[x][y]->combustible;
            fun_modificar(nueva_unidad);
            mapa[x][y]->references = mapa[x][y]->references - 1 ;
            mapa[x][y] = nueva_unidad;

        }else{
            fun_modificar(mapa[x][y]);
        }
        
        
    }

}
