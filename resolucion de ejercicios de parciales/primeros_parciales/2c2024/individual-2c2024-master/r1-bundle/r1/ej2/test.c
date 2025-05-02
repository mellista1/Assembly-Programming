#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "ej2.h"

/**
 * Cuenta cuántos tests corrieron exitosamente.
 */
uint64_t successful_tests = 0;
/**
 * Cuenta cuántos tests test fallaron.
 */
uint64_t failed_tests = 0;

float pi = 6.283185307179586/2;
bool print_high_precision = false;
float EPSILON = 0.0001;

/**
 * El mensaje [DONE] escrito en verde.
 */
#define DONE "[\033[32;1mDONE\033[0m] "

/**
 * El mensaje [FAIL] escrito en rojo.
 */
#define FAIL "[\033[31;1mFAIL\033[0m] "

/**
 * El mensaje [INFO] escrito en amarillo.
 */
#define INFO "[\033[33;1mINFO\033[0m] "

/**
 * El mensaje [SKIP] escrito en magenta.
 */
#define SKIP "[\033[95;1mSKIP\033[0m] "


// Convierte el array a string.
void printString(float* A, float size) {
	printf("{");
	uint32_t i = 1;
	for (i=0; i<size-1; i++) {
		if (print_high_precision)
			printf("%.4f, ", A[i]);
		else
			printf("%.1f, ", A[i]);
	}
	printf("%.1f}", A[i]);
}

void testResults(float* A, float* B, float* expected, float size, char* testName) {
	bool iguales = true;
	uint32_t i;
	for (i=0; iguales && i<size; i++) {
		iguales = iguales && fabs(B[i] - expected[i]) <= EPSILON;
	}

	if (iguales) {
		successful_tests++;
		printf(DONE "%s: para ",testName);
		printString(A, size);
		printf(" se logró ");
		printString(expected, size);
		printf("\n");
	} else {
		failed_tests++;
		printf(FAIL "%s: para ", testName);
		printString(A, size);
		printf(" se esperaba ");
		printString(expected, size);
		printf(", se obtuvo ");
		printString(B, size);
		printf("\nDiferencia en posición %d\n", i);
	}
}

void test_2a_grados_sin_cambios() {
	float A[5] = {0, 90, 180, 270, 360};
	float B[5] = {999, 999, 999, 999, 999};
	unwrap(A, B, 5, 360.0);
	testResults(A, B, A, 5, "test_2a_grados_sin_cambios");
}

void test_2a_grados_con_cambios() {
	float A[21] = {-180.0, -140.0, -100.0,  -60.0,  -20.0,   20.0,   60.0,  100.0,  140.0,
	-180.0, -140.0, -100.0,  -60.0,  -20.0,   20.0,   60.0,  100.0,  140.0,
	-180.0, -140.0, -90.0};
	float B[21] = {999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999, 999};
	float expected[21] = {-180.0, -140.0, -100.0,  -60.0,  -20.0,   20.0,   60.0,  100.0,  140.0,
	180.0,  220.0,  260.0,  300.0,  340.0,  380.0,  420.0,  460.0,  500.0,
	540.0, 580.0, 630.0};
	unwrap(A, B, 21, 360);
	testResults(A, B, expected, 21, "test_2a_grados_con_cambios");
}	

void test_2a_periodo_4() {
	float A[5] = {0, 1, 2, -1, 0};
	float B[5] = {999, 999, 999, 999, 999};
	float expected[5] = {0, 1, 2, 3, 4};
	unwrap(A, B, 5, 4);
	testResults(A, B, expected, 5, "test_2a_periodo_4");
}

void test_2a_periodo_6() {
	float A[9] = {1, 2, 3, 4, 5, 6, 1, 2, 3};
	float B[9] = {999, 999, 999, 999, 999, 999, 999, 999, 999};
	float expected[9] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
	unwrap(A, B, 9, 6);
	testResults(A, B, expected, 9, "test_2a_periodo_6");
}

void test_2a_radianes() {
	print_high_precision = true;
	float A[5] = {0.0,  0.78539816,  1.57079633,  5.49778714,  6.28318531};
	float B[5] = {999, 999, 999, 999, 999};
	float expected[5] = {0.        ,  0.78539816,  1.57079633, -0.78539816,  0.};
	unwrap(A, B, 5, 2*pi);
	testResults(A, B, expected, 5, "test_2a_radianes");
	print_high_precision = false;
}

void test_2a_limite_ambiguo() {
	float A[5] = {0.0, 1.0, 2.0, 4.5, 6.0};
	float B[5] = {999, 999, 999, 999, 999};
	float expected[5] = {0.0, 1.0, 2.0, 0.5, 2.0};
	unwrap(A, B, 5, 4);
	testResults(A, B, expected, 5, "test_2a_limite_ambiguo");
}

/**
 * Evalúa los tests del ejercicio 2A. Este ejercicio requiere implementar
 * `es_indice_ordenado`.
 *
 * En caso de que se quieran skipear los tests alcanza con asignarle `false`
 * a `EJERCICIO_2A_HECHO`.
 */
void test_ej2a(void) {
	uint64_t failed_at_start = failed_tests;
	if (!EJERCICIO_2A_HECHO) {
		printf(SKIP "El ejercicio 2A no está hecho aún.\n");
		return;
	}
	test_2a_grados_sin_cambios();
	test_2a_limite_ambiguo();
	test_2a_periodo_4();
	test_2a_radianes();
	test_2a_periodo_6();
	test_2a_grados_con_cambios();

	if (failed_at_start < failed_tests) {
		printf(FAIL "El ejercicio 2A tuvo tests que fallaron.\n");
	}
}

/**
 * Corre los tests de este ejercicio.
 *
 * Las variables `EJERCICIO_2A_HECHO` y `EJERCICIO_2B_HECHO` controlan qué
 * testsuites se van a correr. Ponerlas como `false` indica que el ejercicio no
 * está implementado y por lo tanto no querés que se corran los tests asociados
 * a él.
 *
 * Recordá que los dos ejercicios pueden implementarse independientemente uno
 * del otro.
 *
 * Si algún test falla el programa va a terminar con un código de error.
 */
int main(int argc, char* argv[]) {
	// 2A
	test_ej2a();

	printf(
		"\nSe corrieron %ld tests. %ld corrieron exitosamente. %ld fallaron.\n",
		failed_tests + successful_tests, successful_tests, failed_tests
	);

	if (failed_tests) {
		return 1;
	} else {
		return 0;
	}
}
