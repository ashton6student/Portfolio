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
ConfigStatus=dev.ConfigureFPGA("JTEG_Test_File.bit");

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
def twos_to_signed(value):
    if value >= 2**15: 
        value -= 2**16  
    return value

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
    time.sleep(0.01)    
    
    dev.UpdateWireOuts()
    data1 = dev.GetWireOutValue(0x20)
    data2 = dev.GetWireOutValue(0x21)
    
    if(sensor == 'ACC'):
        datax = data1 & 0x0000FFFF
        datax_h = (datax << 8) & 0x0000FF00
        datax_l = (datax & 0x0000FF00) >> 8
        datax = (datax_h | datax_l)
        datax = twos_to_signed(datax)
        datax = datax / 16000
        
        
        datay = (data2 & 0xFFFF0000) >> 16
        datay_h = (datay << 8) & 0x0000FF00
        datay_l = (datay & 0x0000FF00) >> 8
        datay = (datay_h | datay_l)
        datay = twos_to_signed(datay)
        datay = datay / 16000
        
        dataz = data2 & 0x0000FFFF
        dataz_h = (dataz << 8) & 0x0000FF00
        dataz_l = (dataz & 0x0000FF00) >> 8
        dataz = (dataz_h | dataz_l)
        dataz = twos_to_signed(dataz)
        dataz = dataz / 16000
        
    elif(sensor == 'MAG'):
        datax = data1 & 0x0000FFFF
        datax = twos_to_signed(datax)
        datax = datax / 1100
        
        dataz = (data2 & 0xFFFF0000) >> 16
        dataz = twos_to_signed(dataz)
        dataz = dataz / 980
        
        datay = data2 & 0x0000FFFF
        datay = twos_to_signed(datay)
        datay = datay / 1100

    
    WORD = WORD & 0x7FFF;
    
    dev.SetWireInValue(0x00, WORD) 
    dev.UpdateWireIns()
    time.sleep(0.01)
    
    return datax, datay, dataz

def turnMotor(DIR, CTR):
    PC_CONTROL = 0b1
    WORD = (PC_CONTROL << 31) | (DIR << 30) | CTR
    #print('start: ' + str(format(WORD, f'0{32}b')))
    dev.SetWireInValue(0x01, WORD) 
    dev.UpdateWireIns()
    
    time.sleep(0.01)    
    WORD = WORD & 0x7FFFFFFF;
    #print('stop:  ' + str(format(WORD, f'0{32}b')))
    dev.SetWireInValue(0x01, WORD) 
    dev.UpdateWireIns()
    time.sleep(0.01)

def newTurnData(DIR, CTR):
    PC_CONTROL = 0b1
    WORD = (PC_CONTROL << 31) | (DIR << 30) | CTR
    #print('stop:  ' + str(format(WORD, f'0{32}b')))
    dev.SetWireInValue(0x01, WORD) 
    dev.UpdateWireIns()
    dataxa = 0
    dataya = 0
    dataza = 0
    maxxa = 0
    maxya = 0
    maxza = 0
    num_meas = 20
    for i in range(num_meas):
        tempxa, tempya, tempza = read('ACC')
        if (maxxa < abs(tempxa)):
            maxxa = abs(tempxa)
        if (maxya < abs(tempya)):
            maxya = abs(tempya)
        if (maxza < abs(tempza)):
            maxza = abs(tempza)
        dataxa += tempxa
        dataya += tempya
        dataza += tempza
        
        #dataxm, dataym, datazm = read('MAG')
        #print('Acceleration (X, Y, Z) = (' + str(dataxa) + ', ' + str(dataya) + ', ' + str(dataza) + ')' +' g')
        #print('Magnetic Flux (X, Y, Z) = (' + str(dataxm) + ', ' + str(dataym) + ', ' + str(datazm) + ')' +' gauss')
        time.sleep(0.1 / num_meas )
    dataxAvg = dataxa/num_meas
    datayAvg = dataya/num_meas
    datazAvg = dataza/num_meas
    
    print('Acceleration Average (X, Y, Z) = (' + str(dataxAvg) + ', ' + str(datayAvg) + ', ' + str(datazAvg) + ')' +' g')
    print('Acceleration Max (X, Y, Z) = (' + str(maxxa) + ', ' + str(maxya) + ', ' + str(maxza) + ')' +' g')
    
    PC_CONTROL = 0b0
    WORD = (PC_CONTROL << 31) | (DIR << 30) | CTR
    #print('start: ' + str(format(WORD, f'0{32}b')))
    dev.SetWireInValue(0x01, WORD) 
    dev.UpdateWireIns()
    time.sleep(0.5)
    
#%%
turn_on('ACC')
turn_on('MAG')
dirc = 0
time.sleep(2)
newTurnData(1, 100)

# time.sleep(1)
#newTurnData(1, 100)
# while(1!=2):
#     turnMotor(dirc, 100)
#     # print('---------------------------------------------------------------')
#     # for i in range(20):
#     #     dataxa, dataya, dataza = read('ACC')
#     #     #dataxm, dataym, datazm = read('MAG')
#     #     print('Acceleration (X, Y, Z) = (' + str(dataxa) + ', ' + str(dataya) + ', ' + str(dataza) + ')' +' g')
#     #     #print('Magnetic Flux (X, Y, Z) = (' + str(dataxm) + ', ' + str(dataym) + ', ' + str(datazm) + ')' +' gauss')
#     #     time.sleep(0.02)
    
#     dirc = dirc ^ 1
#     time.sleep(1)
dev.Close
    
#%%