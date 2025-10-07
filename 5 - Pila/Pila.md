En una máquina de uno de los labos de la facultad, nos encontramos un _pendrive_ con un programa ejecutable de linux adentro.
Investigando un poco vimos que se trata de un programa de prueba interno de una importante compañía de software, que sirve para probar la validez de claves para su sistema operativo.
Si logramos descubrir la clave... bueno, sería interesante...
Para ello llamamos por teléfono a la división de desarrollo en USA, haciéndonos pasar por Susan, la amiga de John (quien averiguamos estuvo en la ECI dando una charla sobre seguridad).
De esa llamada averiguamos:

- El programador que compiló el programa olvidó sacar los símbolos de *debug* en la función que imprime el mensaje de autenticación exitosa/fallida.
  Esta función toma un único parámetro de tipo `int` llamado `miss` que utiliza para definir y imprimir un mensaje de éxito o de falla de autenticación.
- La clave está guardada en una variable local (de tipo `char*`) de alguna función en la cadena de llamados de la función de autenticación.

Se pide:

1. Investigar como ver los símbolos de debug con GDB e identificar funciones que podrían ser las que imprimanel mensaje de autenticación exitosa/fallida.
2. Correr el programa con `gdb` y poner breakpoints en la o las funciones identificadas.
3. Para cada función, imprimir una porción del stack, con un formato adecuado para ver si podemos encontrar la clave.
4. ¿En que función se encuentra la clave? Explicar el mecanismo de como se llega a encontrar la función en la que se calcula la clave.

### Tips de GDB:
- :exclamation: El comando `backtrace` de gdb permite ver el stack de llamados hasta el momento actual de la ejecución del programa, y el comando `frame` permite cambiar al frame determinado. 
  `info frame` permite ver información del frame activo actualmente.
- Los parámetros pasados al comando `run` dentro de gdb se pasan al binario como argumentos, por ejemplo `run clave` iniciará la ejecución del binario cargado en gdb, pasándole un argumento con valor "clave".
- El comando `p {tipo} dirección` permite pasar a `print` cómo se debe interpretar el contenido de la dirección.  
Por ejemplo: `p {char*} 0x12345678` es equivalente a `p *(char**) 0x12345678`.  
  - En el ejemplo mostrado, sabemos que en la dirección `0x12345678` hay un puntero a `char`, por lo que le decimos a `gdb` que interprete el contenido de esa dirección como un puntero a `char`.
- El comando `p ({tipo} dirección)@cantidad` permite imprimir una cantidad de elementos de un tipo determinado a partir de una dirección.
Esto es sumamente práctico cuando conocemos la dirección y el tipo de una variable y queremos ver su contenido.





SOLUCION: 
Corro gdb. Luego uso "run hola". Esto me imprime un mensaje que dice que va a denunciarme con el fbi jaja.

Primero busqué info functions en gdb. Eso me imprimió muchísimas funciones, así que para filtrar busqué info funtions authentic (porque el punto 1 dice que busquemos autenticaciones). 
En ese paso encontré la función que nombra el ejercicio: void print_authentication_message(int);

Para saber qué hace esa función use: disassemble print_authentication_message. Esto me imprimió su código. 
Lo que vi fue: (ahre usé chat gpt)x/
   0x000055555555550f <+12>:    mov    %edi,-0x4(%rbp)        ; guarda parámetro (int)
   0x0000555555555512 <+15>:    cmpl   $0x0,-0x4(%rbp)        ; compara con 0
   0x0000555555555516 <+19>:    jne    0x555555555529         ; si es distinto de cero, va a offset +38

No me sirvió de nada xd . 

Así que pasé al punto 2. Puse el breakpoint en la funcion print_authentication_message. Usando next observé que la función llama a otra función "do_some_stuff". Así que le puse un breakpoint. Vuelvo a correr el programa y empecé a mirar qué hace do_some_stuff. No encontré nada. Pero me acordé que abajo del enunciado hay guiños como el "backtrace". Llamando al backtrace veo que antes de do_some_stuff, se hizo un llamado a otra función do_some_more_stuff (ya recibida en hacker), por ende, le puse un breakpoint. Haciendo una vez "next" noto que la función llama a strcmp (OSEA STRING CMP!!!!). A strcmp le pasa dos parámetros por rdi y rsi. Así que imprimí lo que había en esos registros usando x/s $rdi y x/s $rsi. En uno de ellos esta "hola" que es la clave que pasé al correrlo, y en el otro registro tengo la clave:
x/s $rdi
0x555555559300: "clave_10.46.29.119". Hacker total atr. 
