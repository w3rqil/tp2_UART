import time
import serial
import random

BAUDRATE = 19200
PORT = '/dev/ttyUSB1'

ser = serial.Serial(
    port=PORT, 
    baudrate=BAUDRATE,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS,
)

# ALU commands
ALU_DATA_A_OP = bytes([0b001000])
ALU_DATA_B_OP = bytes([0b010000])
ALU_OPERATOR_OP = bytes([0b100000])

# ALU operations
ADD_OP = bytes([0b00100000])
SUB_OP = bytes([0b00100010])
AND_OP = bytes([0b00100100])
OR_OP = bytes([0b00100101])
XOR_OP = bytes([0b00100110])
SRA_OP = bytes([0b00000011])
SRL_OP = bytes([0b00000010])
NOR_OP = bytes([0b00100111])

random.seed(0)

# Function to send data to ALU
def send_data_to_alu(operator, a_value, b_value):
    ser.write(ALU_OPERATOR_OP)
    ser.write(operator)
    ser.write(ALU_DATA_A_OP)
    ser.write(bytes([a_value]))
    ser.write(ALU_DATA_B_OP)
    ser.write(bytes([b_value]))

# Infinite loop to continuously get results from ALU
try:
    while True:
        operator = random.choice([ADD_OP, SUB_OP, AND_OP, OR_OP, XOR_OP, SRA_OP, SRL_OP, NOR_OP])
        a_value = random.randint(0, 255)
        b_value = random.randint(0, 255)

        send_data_to_alu(operator, a_value, b_value)
        
        # Receive result directly from ALU
        recv = ser.read(1)  # Read the result sent by the ALU
        print(f'ALU Operation Result: {recv.hex()} (A: {a_value}, B: {b_value})')
        
        time.sleep(0.5)  # Adjust the delay as necessary

except KeyboardInterrupt:
    print("Process interrupted by user.")

finally:
    # Ensure the serial connection is closed when the script exits
    if ser.is_open:
        ser.close()
    print("Serial connection closed.")
