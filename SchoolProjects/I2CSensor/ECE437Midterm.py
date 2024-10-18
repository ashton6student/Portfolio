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


while(1!=2):
    # Define the two variables that will send data to the FPGA
    # We will use WireIn instructions to send data to the FPGA
    PC_Control = 0b1; # send a "go" signal to the FSM
    SAD = 0b0011001;
    SUB = 0b10101000;
    SIZE = 6;
    DATA = (PC_Control << 31) | (SAD << 24) | (SUB << 16) | SIZE;
    
    dev.SetWireInValue(0x00, DATA) 
    dev.UpdateWireIns()  # Update the WireIns
  
    time.sleep(0.3)
    
    dev.UpdateWireOuts()
    data1 = dev.GetWireOutValue(0x20)
    data2 = dev.GetWireOutValue(0x21)
    
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
    
    print("Acceleration X = " + str(datax));
    print("Acceleration Y = " + str(datay));
    print("Acceleration Z = " + str(dataz));
    
    PC_Control = 0b0; # send a "stop" signal to the FSM
    SAD = 0b0011001;
    SUB = 0b0101000;
    SIZE = 6;
    DATA = (PC_Control << 31) | (SAD << 24) | (SUB << 17) | SIZE;
    
    dev.SetWireInValue(0x00, DATA) 
    dev.UpdateWireIns()  # Update the WireIns

dev.Close
    
#%%