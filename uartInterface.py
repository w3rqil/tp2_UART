import tkinter as tk
from tkinter import messagebox

class UartReceiver:
    def __init__(self):
        self.state = "IDLE"
        self.tick_counter = 0
        self.rec_bits = 0
        self.rec_byte = 0
        self.done_bit = 0

    def reset(self):
        self.state = "IDLE"
        self.tick_counter = 0
        self.rec_bits = 0
        self.rec_byte = 0
        self.done_bit = 0

    def tick(self, i_data):
        if self.state == "IDLE":
            if i_data == 0:  # Esperar el bit de inicio
                self.state = "START"
                self.tick_counter = 0

        elif self.state == "START":
            if self.tick_counter == 7:  # Mitad del bit de inicio
                self.state = "RECEIVE"
                self.tick_counter = 0
                self.rec_bits = 0
                self.rec_byte = 0
            else:
                self.tick_counter += 1

        elif self.state == "RECEIVE":
            if self.tick_counter == 15:  # Mitad del primer bit de datos
                self.rec_byte = (i_data << (self.rec_bits)) | self.rec_byte  # Shift register
                self.tick_counter = 0
                if self.rec_bits == 7:  # Todos los bits de datos recibidos
                    self.state = "STOP"
                else:
                    self.rec_bits += 1
            else:
                self.tick_counter += 1

        elif self.state == "STOP":
            if self.tick_counter == 15:  # Mitad del bit de parada
                self.state = "IDLE"
                if i_data == 1:  # Verificar el bit de parada
                    self.done_bit = 1

    def get_data(self):
        return self.rec_byte

    def is_done(self):
        return self.done_bit

class UartInterface:
    def __init__(self, master):
        self.master = master
        self.master.title("UART Receiver Interface")

        self.receiver = UartReceiver()

        self.label = tk.Label(master, text="Ingrese un byte (0-255):")
        self.label.pack()

        self.entry = tk.Entry(master)
        self.entry.pack()

        self.send_button = tk.Button(master, text="Enviar", command=self.send_data)
        self.send_button.pack()

        self.datoa_button = tk.Button(master, text="DATOA", command=self.send_datoa)
        self.datoa_button.pack()

        self.datob_button = tk.Button(master, text="DATOB", command=self.send_datob)
        self.datob_button.pack()

        self.op_button = tk.Button(master, text="OP", command=self.send_op)
        self.op_button.pack()

        self.result_label = tk.Label(master, text="")
        self.result_label.pack()

    def send_data(self):
        try:
            byte_input = int(self.entry.get())
            if byte_input < 0 or byte_input > 255:
                raise ValueError("El byte debe estar entre 0 y 255.")
            self.send_byte(byte_input)

        except ValueError as e:
            messagebox.showerror("Error", str(e))

    def send_datoa(self):
        self.send_byte(0b10101010)  # Valor predefinido para DATOA

    def send_datob(self):
        self.send_byte(0b11001100)  # Valor predefinido para DATOB

    def send_op(self):
        self.send_byte(0b11110000)  # Valor predefinido para OP

    def send_byte(self, byte_input):
        # Reiniciar el receptor antes de enviar
        self.receiver.reset()

        # Simular el envío del byte bit a bit
        for bit_index in range(8):  # Transmitir los 8 bits
            self.receiver.tick((byte_input >> bit_index) & 1)  # Enviar cada bit
            # Simular el reloj (tick)
            self.receiver.tick(0)  # Enviar el bit de inicio
            for _ in range(15):  # Esperar para el tiempo del bit
                self.receiver.tick(0)

        self.receiver.tick(1)  # Enviar el bit de parada
        for _ in range(15):  # Esperar para el tiempo del bit
            self.receiver.tick(1)

        # Verificar si la recepción fue exitosa
        if self.receiver.is_done():
            self.result_label.config(text=f"Byte recibido: {self.receiver.get_data()}")
        else:
            self.result_label.config(text="Error en la recepción.")

if __name__ == "__main__":
    root = tk.Tk()
    app = UartInterface(root)
    root.mainloop()
