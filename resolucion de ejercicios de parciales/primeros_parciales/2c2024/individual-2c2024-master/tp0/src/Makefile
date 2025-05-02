LDFLAGS = -lm
CFLAGS= -Wall -Wextra -pedantic -O0 -g -Wno-unused-variable -Wno-unused-parameter -no-pie -z noexecstack
CC=c99

# Crea los binarios en cuestión
all: main test

# Corre los tests 
run: test
	./test


# Corre los tests en valgrind
valgrind: test
	valgrind  --show-reachable=yes --leak-check=full --error-exitcode=1 ./test \
	&& echo "No se detectaron errores de memoria"


# Borra todos los archivos generados
clean:
	rm -f *.o
	rm -f main test
	rm -f salida.propios.*

test: test.c ej1.c
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

main: main.c ej1.c
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

.PHONY: clean run valgrind

