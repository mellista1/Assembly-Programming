<!---
POR FAVOR LEER!

Antes de consultar, por favor buscar en el Discord de la materia si no se respondió una pregunta similar. 

Si la pregunta se puede abstraer del detalle del código, enviarla al servidor de Discord donde recibirán respuesta más rápido.
--->
# Solicitud de ayuda con bug
## Trabajo práctico y ejercicio
<!-- Indicar el trabajo práctico y número de ejercicio a consultar. -->
**Trabajo práctico:**

**Ejecicio:**

## Resumen del problema
<!-- Resumir el comportamiento inesperado que no están pudiendo resolver -->

## Código para reproducir
<!-- Linkear a archivo del proyecto con código para reproducir el error o proveer snippet de código para reproducir el error e indicar como utilizarlo. -->
<!-- Se puede linkear linas específicas de código abriendo el archivo relevante en la interfaz web del repositorio y haciendo click en el número de linea, luego copiando la URL de la página. -->

<!-- EJEMPLO DE SNIPPET DE CÓDIGO DE PRUEBA:
```c
// main.c
int main (void){
  list_t* list=listNew();
  listAddLast(list,2);
  listAddLast(list,3);
  listAddLast(list,4);
  listDelete(list);
}
```
-->


## Pasos para reproducir
<!-- Describir de manera clara y concisa los pasos necesarios para reproducir. -->

1. [Paso 1]
2. [Paso 2]
3. [Paso 3]
4. [Paso 4]
5. [Paso 5]

## Cuál es el comportamiento *incorrecto* actual?
<!-- Describir el comportamiento actual del sistema o función al seguir los pasos indicados anteriormente. -->

## Cuál es el comportamiento *correcto* esperado?
<!-- Describir el comportamiento esperado del sistema o función al seguir los pasos indicados anteriormente. -->

## Soluciones probadas
<!-- Describir pasos que hayan tomado para intentar solucionar el comportamiento y que efecto tuvieron. -->

## Logs y/o capturas de pantalla relevantes
<!-- De ser relevantes incluir screenshots para ilustrar el error.  -->
<!-- Pegar logs de error (de valgrind, nasm) o indicar la excepción que esté ocurriendo con detalle de los valores de registros --> 
<!-- En vez de pegar los logs también pueden crear un snippet usando el boton `+` de la barra superior de gitlab > submenú Gitlab > New snippet -->
<!-- Ejemplo (primera mitad de la materia) correr ejecutable de testeo y pegar o adjuntar un .txt con el output relevante. -->
<!-- Ejemplo (segunda mitad de la materia) en caso de un Page Fault indicar el valor del registro cr2. Consultar registros relevantes a cada excepción aquí https://wiki.osdev.org/Exceptions -->



## Entorno de ejecución
<!-- Listar información relevante de entorno de ejecución, especialmente sistema operativo (Ubuntu versión x, WSL, mac, etc) y versión de gcc y nasm (`gcc --version`, `nasm --version`). -->
```txt
Sistema operativo: 
gcc: 
NASM:

Otros:
```

## Salida de tests
<!-- De haber sido provistos, pegar o describir la salida de los tests de la cátedra para el trabajo actual. -->
<!-- Omitir si ya fue provisto en un punto anterior. -->
<!-- CORRER LOS TESTS CON VALGRIND. -->

## Posibles causantes
<!-- Si tienen una sospecha o certeza respecto a qué parte del código puede estar causando el comportamiento, linkearlo acá. Se puede linkear linas específicas de código abriendo el archivo relevante en la interfaz web del repositorio y haciendo click en el número de linea, luego copiando la URL de la página. -->

/label ~"type::ayuda con bug"