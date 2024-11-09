THIS IS CURRENTLY A WORK IN PROGRESS, AS THE CLASS THIS IS BEING DONE FOR IS YET TO COMPLETE.

Introduction:
This is the final project for ECE437 Sensors and Instrumentation, in which we use a camera, stepper motor, and IMU to create a face tracking camera system.
In order to do this we created firmware in verilog running on an Opal Kelly FPGA and python code running on a windows desktop. 
This FPGA board is attached to a custom PCB containing the camera, IMU, stepper motor, amongst other sensors in which we interface with via various communcation protocols.
Note: the PCB Schematic, related images, and relevant sensor data sheets are provided in the same folder this README is contained in.

Firmware:
To configure the camera, we interface with said camera via the SPI communcation protocol. In return, we recieve 10-bit monochrome pixel data with resolution 640x480.
To read from the IMU, we interface with the IMU via the I2C communcation protocol.
To control the stepper motor, we follow the PMOD standard as specificed in the PMOD motor controller data sheet.
The state machine controlling the SPI signals, I2C signals, and PMOD controller is contained in the SPI_Transmit.v, I2C_Transmit.v, and PMOD_Controller.v files, respectively, contained in the main files folder.
To interface amongst these modules, a top level needed to be made. This is also included in the main files folder named Top_Level.v.
Other utility modules and files, such as a clock generator and Opal Kelly modules(to be discussed later), for example, needed to be used in our project. These are included in the Other Files folder.

Software:
The firmware is mainly tasked with sending and recieving data between the sensors and the PC for further processing. To do this, we used Python, mainly using the Opal Kelly library.
The Opal Kelly library through USB 3.0 and the aformentioned Opal Kelly verilog files is what allows us to send and recieve data to and from the FPGA, and hence the sensors.

WORK IN PROGRESS NOTES:
As stated, this project is a work in progress as the class has yet to complete, however it will be done by the end of the fall session December 19th 2025.
As such, the provided python software files is not the final project code, but the python code used in previous labs to control the specific components that will be used in the final project.
The python code provided is as follows: PMOD_ControllerPY.py, I2C_ControllerPY.py, SPI_ControllerPY.py.
These files are self explanatory, as these are the files that are tasked with communcating with the FPGA to control the PMOD, I2C, and SPI state machines verilog files.
Note: they may contain specific usage meant for the labs, so don't attempt to interpret this code with reference to this project goal. 