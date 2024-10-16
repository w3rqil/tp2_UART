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
ALU_DATA_A_OP = bytes([0b00111111])
ALU_DATA_B_OP = bytes([0b00010000])
ALU_OPERATOR_OP = bytes([0b00100000])

# ALU operations
ADD_OP = bytes([0b00100000])
SUB_OP = bytes([0b00100010])
AND_OP = bytes([0b00100100])
OR_OP = bytes([0b00100101])
XOR_OP = bytes([0b00100110])
SRA_OP = bytes([0b00000011])
SRL_OP = bytes([0b00000010])
NOR_OP = bytes([0b00100111])

# Error Codes
ALU_OPERATOR_ERROR = bytes([0xa1])
INVALID_OPCODE = bytes([0xff])

random.seed(0)

# Function to send data to ALU and get the result
def get_value_alu_test(operator, a_value, b_value):
    
    
    # Send first operand (A)
    #time.sleep(0.1)
    ser.write(ALU_DATA_A_OP)
#    ser.write(bytes([a_value]))
#    # time.sleep(0.1)
#    
#    # Send second operand (B)
#    ser.write(ALU_DATA_B_OP)
#    # time.sleep(0.1)
#    ser.write(bytes([b_value]))
#    # time.sleep(0.1)
#    
#    # Set operator
#    ser.write(ALU_OPERATOR_OP)
#    # time.sleep(0.1)
#    ser.write(operator)
#    # time.sleep(0.1)
#
#    # Request result
#    # ser.write(GET_RESULT_OP)
#    time.sleep(0.1)
    
    # Receive result
    recv = ser.read(1)
    return recv

# Test all operations
def test_all_operations():
    time.sleep(0.1)
    val = get_value_alu_test(ADD_OP, 0b00000001, 0b00000001)
    #ser.write(ALU_DATA_A_OP)
    #val = ser.read(1)
    print(f" Result: {val}")

##    ser.write(ADD_OP)
##    val = ser.read(1)
##    print(f" Result: {val}")
##    ser.write(SUB_OP)
##    val = ser.read(1)
##    print(f" Result: {val}")
    
# Run all tests
test_all_operations()

ser.close()