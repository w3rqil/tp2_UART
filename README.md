# Arquitectura de Computadoras

En este repositorio se desarrolla el trabajo práctico 1 de la materia Arquitectura de Computadoras.
Este proyecto fue realizado por los alumnos: 
- [Mansilla, Josías Leonel](https://github.com/w3rqil)

- [Schroder Ferrando, Florencia](https://github.com/FlorSchroder) 

# Consigna
Realizar un Receptor y Transmisor Asíncrono Universal del siguiente tipo:

![Receptor y transmisor](/img/tp2.png)

# Desarrollo

Para el desarrollo del trabajo práctico se reutilizo el modulo alu del primer trabajo practico se implementaron los siguientos modulos:

- baudrate_generator
- top
- uart_interface
- uart_rx
- uart_tx

# jerarquia de Archivos

## Module Baudrate Generator

El módulo baudrate_generator es un generador de ticks diseñado para sincronizar la transmisión de datos a una tasa de baudios específica.

A continuación un diagrama del módulo donde se pueden ver sus entradas y salidas:

- **File**: baudrate_generator.v

### Diagram
![Diagram](baudrate_generator.svg "Diagram")
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