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
#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communication with the OK board
#ConfigStatus=dev.ConfigureFPGA("JTEG_Test_File.bit");

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()

#%%
def turn_on(sensor):
    PC_CONTROL = 0b1
    RW = 0b0
    if(sensor == 'ACC'):
        SAD = 0b0011001
        SUB = 0b00100000
        DATA = 0b01110111
    elif(sensor == 'MAG'):
        SAD = 0b0011110
        SUB = 0b00000010
        DATA = 0b00000000
    WORD = (PC_CONTROL << 31) | (RW << 30) | (SAD << 23) | (SUB << 15) | (DATA << 7)

    dev.SetWireInValue(0x00, WORD) 
    dev.UpdateWireIns()
    time.sleep(0.05)    

    WORD = WORD & 0x7FFF;
    
    dev.SetWireInValue(0x00, WORD) 
    dev.UpdateWireIns()
    time.sleep(0.05)

def read(sensor):
    PC_CONTROL = 0b1
    RW = 0b1
    SIZE = 6
    if(sensor == 'ACC'):
        SAD = 0b0011001
        SUB = 0b10101000
        
    elif(sensor == 'MAG'):
        SAD = 0b0011110
        SUB = 0b00000011
        
    WORD = (PC_CONTROL << 31) | (RW << 30) | (SAD << 23) | (SUB << 15) | SIZE

    dev.SetWireInValue(0x00, WORD) 
    dev.UpdateWireIns()
    time.sleep(0.05)    
    
    dev.UpdateWireOuts()
    data1 = dev.GetWireOutValue(0x20)
    data2 = dev.GetWireOutValue(0x21)
    
    if(sensor == 'ACC'):
        datax = data2 & 0x0000FFFF
        datax_h = (datax << 8) & 0x0000FF00
        datax_l = (datax & 0x0000FF00) >> 8
        datax = (datax_h | datax_l) / 16000
        
        datay = (data2 & 0xFFFF0000) >> 16
        datay_h = (datay << 8) & 0x0000FF00
        datay_l = (datay & 0x0000FF00) >> 8
        datay = (datay_h | datay_l) / 16000
        
        dataz = data1 & 0x0000FFFF
        dataz_h = (dataz << 8) & 0x0000FF00
        dataz_l = (dataz & 0x0000FF00) >> 8
        dataz = (dataz_h | dataz_l) / 16000
        
    elif(sensor == 'MAG'):
        datax = data2 & 0x0000FFFF
        datax = datax / 16000
        
        datay = (data2 & 0xFFFF0000) >> 16
        datay = datay / 16000
        
        dataz = data1 & 0x0000FFFF
        dataz = dataz / 16000

    
    WORD = WORD & 0x7FFF;
    
    dev.SetWireInValue(0x00, WORD) 
    dev.UpdateWireIns()
    time.sleep(0.05)
    
    return datax, datay, dataz

#%%
turn_on('ACC')
turn_on('MAG')

while(1!=2):
    datax, datay, dataz = read('ACC')
    print("Acceleration X = " + str(datax));
    print("Acceleration Y = " + str(datay));
    print("Acceleration Z = " + str(dataz));
    
    datax, datay, dataz = read('MAG')
    print("Magnetic Flux X = " + str(datax));
    print("Magnetic Flux Y = " + str(datay));
    print("Magnetic Flux Z = " + str(dataz));

dev.Close
    
#%%