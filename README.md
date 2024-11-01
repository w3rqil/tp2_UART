![fcefyn](  /home/leonel/Desktop/Arqui/tp2_UART/img/fcefyn_logo.png)

En este repositorio se desarrolla el trabajo práctico número 2 de la materia Arquitectura de Computadoras.
Este proyecto fue realizado por los alumnos: 
- [Mansilla, Josías Leonel](https://github.com/w3rqil)
    - leonel.mansilla@mi.unc.edu.ar
- [Schroder Ferrando, Florencia](https://github.com/FlorSchroder) 
    - florencia.schroder@mi.unc.edu.ar

# Consigna
Realizar un Receptor y Transmisor Asíncrono Universal del siguiente tipo:

![Receptor y transmisor](/home/leonel/Desktop/Arqui/tp2_UART/img/tp2.png)

# Desarrollo

Para el desarrollo del trabajo práctico se reutilizo el modulo alu del primer trabajo practico se implementaron los siguientos modulos:

- baudrate_generator
- top
- uart_interface
- uart_rx
- uart_tx

# jerarquia de Archivos

![jerarquia](/home/leonel/Desktop/Arqui/tp2_UART/img/jerarquia.png)

## Module Baudrate Generator

El módulo baudrate_generator es un generador de ticks diseñado para sincronizar la transmisión de datos a una tasa de baudios específica.

A continuación un diagrama del módulo donde se pueden ver sus entradas y salidas:

- **File**: baudrate_generator.v

### Diagram
![Diagram](/home/leonel/Desktop/Arqui/tp2_UART/img/baudrate_generator.svg "Diagram")
### Generics

| Generic name | Type | Value      | Description              |
| ------------ | ---- | ---------- | ------------------------ |
| BAUD_RATE    |      | 19200      | Velocidad de transmision |
| CLK_FREQ     |      | 100_000_000 | Frecuencia del reloj     |
| OVERSAMPLING |      | 16         | Oversampling             |

### Ports

| Port name | Direction | Type | Description                         |
| --------- | --------- | ---- | ----------------------------------- |
| clk       | input     | wire | Reloj                               |
| i_rst_n   | input     | wire | Reset                               |
| o_tick    | output    | wire | tick que se genera cada NC_PER_TICK |

### Signals

| Name    | Type                 | Description |
| ------- | -------------------- | ----------- |
| counter | reg [NB_COUNTER-1:0] | Contador    |

### Constants

| Name        | Type | Value                               | Description                 |
| ----------- | ---- | ----------------------------------- | --------------------------- |
| NC_PER_TICK |      | CLK_FREQ / BAUD_RATE / OVERSAMPLING | Numero de ciclos por tick   |
| NB_COUNTER  |      | (NC_PER_TICK - 1)                   | Numero de bits del contador |

## Uart Interface

Esta iterfáz está diseñada para recibir datos desde el receptor uart (UART_RX), parsearlos y enviarlos hacia la , y luego recibir el resultado desde la ALU y enviarselo hacia el transmisor uart (UART_TX). Funciona como una máquina de estados que en una primera instancia recibe un código que va a determinar el tipo del siguiente dato, sea datoA, datoB u operacion.\
En el único momento en el que se enviará un resultado hacia el uart_TX será después de que se reciba una operación. Es decir, el orden correcto de enviarle datos a la interfaz sería **dato_A** --> **dato_B** --> **operation**. \
Aún así, se puede mandar otra operación y conservar los datos A y B previos.

![interface](/home/leonel/Desktop/Arqui/tp2_UART/img/uart_interface.png)

# Python
Para enviar y recibir los datos por uart se utilizó una simple [interfáz de python](uartInterface.py) donde se le configura el puerto y el baudrate utilizado (éste último debe ser coincidente con el del módulo baudrate_generator).\
Una vez en el script de python, utilizando el método get_value_alu_test(operation, dato_A, dato_B) podemos enviar una operación, dato_A, dato_B y recibir el resultado de forma instantánea. (para visualizar el resultado debemos hacer un 'print' de lo que retorna el método).

## test
A continuación probamos una operación suma y una resta.
```
def test_all_operations():
    time.sleep(0.1)
    val = get_value_alu_test(ADD_OP, 0b00001010, 0b00001000)
    #ser.write(ALU_DATA_A_OP)
    #val = ser.read(1)clear
    print(f" ADD Result: {val}")

    val = get_value_alu_test(SUB_OP, 0b00001000, 0b00000001)
    print(f" SUB Result: {val}")
```
Podemos ver que en la consola se imprimen los resultados correctos:

![result](/home/leonel/Desktop/Arqui/tp2_UART/img/python_result.png)
# Schematic

A continuación el esquemático del proyecto final donde se pueden ver las conexiones entre módulos.

![schematic](/home/leonel/Desktop/Arqui/tp2_UART/img/schematic.png)