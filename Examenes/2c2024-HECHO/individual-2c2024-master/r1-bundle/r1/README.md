# Recuperatorio primer parcial - Arquitectura y Organización de Computadoras
#### Segundo cuatrimestre 2024

## Normas generales y modalidad de entrega

- El parcial es **INDIVIDUAL**
- Una vez terminada la evaluación se deberá crear un issue con el *hash* del
  *commit* de entrega.

## Régimen de Aprobación

- Para aprobar el examen es necesario obtener como mínimo **un ejercicio aprobado y un ejercicio regular**, demostrando conocimiento suficiente de todos los temas abarcados por el parcial.

## Actualización del fork individual

Es importante que, para esta instancia de parcial y próximas, **no creen un nuevo fork de este repositorio** si no que actualicen el mismo fork individual que estaban utilizando para el tp0.

Los pasos para actualizar el repositorio son los mismos que siguieron para el TP1-b y TP1-c, pero ante cualquier duda pueden consultarlos en el archivo [como_actualizar.md (link)](https://git.exactas.uba.ar/ayoc-doc/individual-2c2024/-/blob/master/p1/como_actualizar.md) de esta carpeta.

## Compilación y Testeo

Para compilar y ejecutar los tests cada ejercicio dispone de un archivo
`Makefile` con los siguientes *targets*:

| Comando             | Descripción                                                         |
| ------------------- | ------------------------------------------------------------------- |
| `make test_c`       | Genera el ejecutable usando la implementación en C del ejercicio.   |
| `make test_asm`     | Genera el ejecutable usando la implementación en ASM del ejercicio. |
| `make run_c`        | Corre los tests usando la implementación en C.                      |
| `make run_asm`      | Corre los tests usando la implementación en ASM.                    |
| `make valgrind_c`   | Corre los tests en valgrind usando la implementación en C.          |
| `make valgrind_asm` | Corre los tests en valgrind usando la implementación en ASM.        |
| `make clean`        | Borra todo archivo generado por el `Makefile`.                      |

El sistema de tests de este parcial **sólo correrá los tests que hayan marcado
como hechos**. Para esto deben modificar la variable `EJERCICIO_xx_HECHO`
correspondiente asignándole `true` (en C) ó `TRUE` (en ASM). `xx` es el inciso
en cuestión: `1A`, `1B`, `1C`, `2A`.

# Ejercicio 1

Luego del éxito de nuestro último juego "AyOC - la venganza de los punteros" hemos decidido incursionar al mundo de los juegos de estrategia por turnos para nuestro próximo juego, "Organized Wars".

En su turno, el jugador podrá colocar en un mapa de juego cuadriculado varias unidades de ataque de distintas clases. Cada clase tiene un valor inicial de combustible cargado, el cuál utilizarán en una etapa posterior para realizar acciones como moverse, disparar bombas, etc. Además del combustible precargado, el jugador cuenta con una reserva extra de combustible que puede repartir entre las unidades que desee, potenciando ciertas unidades puntuales.

Dado que es común que los jugadores reposicionen y modifiquen los niveles de combustible de las unidades constantemente durante su turno, el sistema de nuestro juego funciona del siguiente modo:

- Durante el transcurso del turno, cada unidad de ataque agregada se instancia independientemente. 
- Al momento de finalizar el turno, se revisa que el jugador no haya asignado más combustible extra del que tenía disponible en su reserva. De haber asignado combustible correctamente, se efectiviza el final del turno.
- Una vez finalizado el turno, se corre una optimización que reemplaza todas las instancias independientes de unidades equivalentes por una única instancia "compartida"" (donde dos unidades son equivalentes si el resultado de aplicar una función de hash dada sobre cada una es el mismo).

![alt text](img/optimizacion.png)

**a)** Programar en lenguaje assembler una función que, dado el puntero a un personaje, "optimice" todas las unidades del mapa que sean
equivalentes utilizando en su lugar la versión pasada por parámetro. La solución debe hacer un uso apropiado
de la memoria, teniendo en cuenta que las referencias a unidades solo son guardadas en el mapa.

`void optimizar(mapa_t mapa, personaje_t* compartida, uint32_t *fun_hash)`

**b)** Programar en lenguaje assembler una función

`uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*))`

que se utilizará para calcular, antes de finalizar el turno del jugador, la cantidad de combustible **de la reserva** que fue asignado por el jugador. La funcion fun_combustible pasada por parametro, toma una clase de unidad y devuelve la cantidad de combustible base que le corresponde.

---

Luego de la optimización cominenza la fase de batalla, en la que las unidades realizarán acciones y sus niveles de combustible se modificarán de manera acorde. Si se modifica una unidad que está compartiendo instancia por una optimización, se debe crear una nueva instancia individual para esta en lugar de modificar la instancia compartida (lo cual resultaría en modificaciones indebidas en otras unidades).

**c)** Programar en lenguaje assembler una función
    
`void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void *fun_modificar)`

que dada una posición en el mapa permita aplicar la función modificadora a la unidad en esa posición **únicamente**. 
La solución propuesta debe tener en cuenta el caso en que se quiera modificar una unidad que previamente había sido optimizada, sin hacer uso excesivo o innecesario de recursos del sistema.

De no haber una unidad en la posición especificada, no se debe hacer nada.

---
**Observaciones:**

- La instancia compartida podría ser una **nueva instancia** o **alguna de las instancias individuales preexistentes**.
- En los tests se utiliza un area del mapa de 5x5 lugares para simplificar la visualización, pero se evaluará que se resuelva correctamente para el mapa completo.
- Para cada función se incluye un último test que sí trabaja sobre un mapa de tamaño máximo. Este test no correrá hasta que los anteriores pasen exitosamente.
- A fin de debuggear puede ser útil revisar la función de hash utilizada en los tests, la cual está definida al principio de `test.c`.

# Ejercicio 2 - SIMD

Este ejercicio consiste en implementar una función de procesamiento de señales utilizando el modelo de procesamiento SIMD.

Se **deben** procesar al menos **4 elementos del arreglo en simultáneo, en el mismo registro XMM**, aprovechando instrucciones de procesamiento paralelo. 

:warning: El uso innecesario de registros de propósito general será penalizado.

## La función `unwrap`

`void unwrap(float* A, float* B, uint32_t size, float period);`

es una función utilizada en de procesamiento de señales o análisis de datos cíclicos, como el análisis de fases en señales periódicas. A menudo, estas señales contienen discontinuidades artificiales debido a la forma en que son medidas. Mediante la función `unwrap` podemos eliminar estos saltos, obteniendo una representación contínua de los datos sin saltos bruscos.

A grandes rasgos, `unwrap` busca discontinuidades mayores a `periodo/2` en la señal de entrada y las suaviza **sumando/restando** un ajuste `k*periodo` 
donde k refleja el shift necesario para que no haya diferencias mayores a `periodo/2` entre una muestra y la anterior.

Por ejemplo, si partimos de un círculo unitario y movemos un punto para que de la vuelta contínuamente sobre su circumferencia, el ángulo formado por el radio a ese punto y el eje x crecerá de manera constance de 0° a 360°, pero al alcanzar el punto de partida volverá abruptamente a 0°.

Al aplicar unwrap, dejaremos de tener estos saltos bruscos y nuestra medición adicionalmente reflejará la cantidad de vueltas que dimos al círculo.
![alt text](img/unitario.png)

Observando el gráfico se ve que **los ajustes son acumulativos**: cuando sumamos un período a uno de los puntos, debemos sumarselo a los siguientes también para que la señal continue de manera suave.

## Detalle del algoritmo

El algoritmo de `unwrap` en su versión paralelizable consiste de los siguientes pasos:
- El primer elemento se mantiene igual.
- Para el i-ésimo elemento, sea A el arreglo de entrada y B el de salida:
    1. Se calcula la diferencia `dd = A[i]-A[i-1]`
    2. Se calcula además `ddmod ∈ [-periodo/2, periodo/2)`, que usaremos más adelante para conocer cuánto debemos sumar o restar para suavizar los saltos. Para calcularlo: 
        
        **a.** Sumar `periodo/2` a `dd`

        **b.** Aplicarle `mod periodo` a ese resultado. Este resultado parcial `ddmod_part ∈ [0, periodo)` 
        
        **c.** Finalmente restarle `periodo/2` a `ddmod_part` para lograr `ddmod ∈ [-periodo/2, periodo/2)`.
    3. Se calcula la corrección de fase para el arreglo de entrada `ph_correct = ddmod - dd`. 
    4. Se corrige `ph_correct` de forma que solo sea distinto de cero cuando `dd ∉ [-periodo/2, periodo/2)`.
    5. Sumamos la corrección de fase que se realizó para el elemento anterior A[i-1]
        - Si estamos calculando más de una corrección en paralelo, realizaremos la suma acumulada de las correcciones - por ejemplo, si `ph_correct = [0, 1, 1, 1]` las correcciones finales deben ser `ph_cumsum = [0, 1, 2, 3]`.
        - Si trabajamos en "lotes", debemos además sumar el ajuste del lote anterior.
    6. Finalmente guardamos `B[i] = A[i] + ph_cumsum[i]`

## Ejercicio
Programar la función `unwrap`. 

Se provee una función auxiliar interna `modps` que recibe en XMM0 y XMM1 4 elementos de punto flotante y devuelve en XMM0 `XMM0[i] = XMM0[i] mod XMM1[i]`, resultando `XMM0[i] ∈ [0, XMM1[i])`. 

:warning: La función `modps` **rompe xmm2**.

---

**Observaciones:**
- Investigar la instrucción `CMPPS`. Prestar especial atención a la tabla de pseudo-operaciones.
- Se puede asumir que el tamaño del arreglo cumple 
  
  ```math
  tamaño = (4*k) +1 \,/\, k >= 1 \land k \in \mathbb{N}
  ```
- El periodo siempre es positivo
