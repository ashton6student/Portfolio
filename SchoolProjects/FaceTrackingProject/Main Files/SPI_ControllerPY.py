# -*- coding: utf-8 -*-

#%%
# import various libraries necessary to run your Python code
import time   # time related library
import sys,os    # system related library
ok_sdk_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\x64"
ok_dll_loc = "C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\lib\\x64"

sys.path.append(ok_sdk_loc)   # add the path of the OK library
os.add_dll_directory(ok_dll_loc)

import ok     # OpalKelly library
import numpy as np
#%%
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communication with the OK board
#ConfigStatus=dev.ConfigureFPGA("Top_Level.bit");

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()


def turn_on(sensor):
    if(sensor == 'CAM'):
        WORD = 0b1 << 31
    dev.SetWireInValue(0x00, WORD)
    dev.UpdateWireIns()
   

def turn_off(sensor, WORD):
    if(sensor == 'CAM'):
        WORD = 0
    return WORD

def write(sensor, ADDRESS, DATA):
    if(sensor == 'CAM'):
        POWER_ON = 0b1
        SPI_START = 0b1
        C = 0b1
        WORD = POWER_ON << 31 | SPI_START << 30 | C << 29 | ADDRESS << 22 | DATA << 14
   
    dev.SetWireInValue(0x00, WORD)
    dev.UpdateWireIns()
   
    WORD = WORD & 0xBFFFFFFF;
    dev.SetWireInValue(0x00, WORD)
    dev.UpdateWireIns()
   
def read(sensor, ADDRESS):
    if(sensor == 'CAM'):
        POWER_ON = 0b1
        SPI_START = 0b1
        C = 0b0
        WORD = POWER_ON << 31 | SPI_START << 30 | C << 29 | ADDRESS << 22
   
    dev.SetWireInValue(0x00, WORD)
    dev.UpdateWireIns()
   
    dev.UpdateWireOuts()
    data1 = dev.GetWireOutValue(0x20)

   
    WORD = WORD & 0xBFFFFFFF;
    dev.SetWireInValue(0x00, WORD)
    dev.UpdateWireIns()

    return data1

def frame_request():
    POWER_ON = 0b1
    FRAME_REQ = 0b1
    WORD = POWER_ON << 31 | FRAME_REQ
       
    dev.SetWireInValue(0x00, WORD)
    dev.UpdateWireIns()
   
    WORD = WORD & 0xBFFFFFFF;
    dev.SetWireInValue(0x00, WORD)
    dev.UpdateWireIns()
    
addresses = np.array([57, 58,  59, 60, 68, 69, 80,  83,  97, 98, 100, 101, 102, 103, 106, 107, 108, 109, 110, 117])
data =      np.array([ 3, 44, 240, 10,  1,  9,  9, 187, 240, 10, 112,  98,  34,  64,  94, 110,  91,  82,  80,  91])

turn_on('CAM')
time.sleep(0.5)

for n in range(len(data)):
    print('------------------------------------------------')
    print('Initial Value of Register: ' + str(addresses[n]) + ' is: ' + str(read('CAM', int(addresses[n]))))
    time.sleep(.1)
    write('CAM', int(addresses[n]), int(data[n]))
    print('New Value of Register: ' + str(addresses[n]) + ' is: ' + str(read('CAM', int(addresses[n]))))

buf = bytearray(688*488);
dev.ReadFromBlockPipeOut(0xa0, 1024, buf);

time.sleep(1)

frame_request()

# for i in range (0, 1024, 1):    
#    result = buf[i];
#    time.sleep(0.1)
#    print (result)

print(buf[100000:100100])
# print('Initial Value of Register: ' + str(83) + ' is: ' + str(read('CAM', 83)))
# time.sleep(0.5)
# write('CAM', 97, 187)
# print('New Value of Register: ' + str(83) + ' is: ' + str(read('CAM', 83)))
# while(1!=2):
   
#     # time.sleep(0.5)
#     #write('CAM', 57, 3)
#     time.sleep(0.5)
#     print(read('CAM', 57))
#     time.sleep(0.5)
dev.Close
