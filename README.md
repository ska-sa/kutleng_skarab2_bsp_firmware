# kutleng_skarab2_bsp_firmware
===
The Vivado firmware for the skarab2 100G Ethernet and Partial Reconfiguration 

This is the work for the port of the 100G Ethernet to the VCU118+VCU1525 board.

The Vivado version being used is Vivado 2019.2.1_AR72614


# Building the Vivado Project
===

To run the code clone it first to a directory


```bash
git clone https://github.com/hectorkutleng/kutleng_skarab2_bsp_firmware.git

cd kutleng_skarab2_bsp_firmware/casperbsp/projects/vivado

mkdir project_flow

cd project_flow

vivado

```
Replace {vcu118|vcu1525} with whichever platform you intend to build for e.g. 
for vcu118 use vcu118.


On vivado prompt source the project file for the vcu118 or the vcu1525


```bash

source ../{vcu118|vcu1525}/ethmac{vcu118|vcu1525}pr.tcl

```

You need to launch vivado when you are on the ${kutleng_skarab2_bsp_firmware/casperbsp/projects/project_flow} folder

This will create a vivado project on a folder ${kutleng_skarab2_bsp_firmware/casperbsp/projects/project_flow/{vcu118|vcu1525}project/{vcu118|vcu1525}projectpr.xpr}


The design assumes a network at 192.168.100.10/15 for port 1 and port 2 of the QFSP28+ ports


After the design is finished building it is necessary to launch Vitis and export the design to Vitis.

===

# Version Description Document

The know working version of the build with the corresponding git hash are updated on the list as follows:

The Firmware Repository is: [https://github.com/hectorkutleng/kutleng_skarab2_bsp_firmware](https://github.com/hectorkutleng/kutleng_skarab2_bsp_firmware.git)
The Software Repository is: [https://github.com/hectorkutleng/kutleng_skarab2_control_software](https://github.com/hectorkutleng/kutleng_skarab2_control_software.git)


|           Firmware Version                |   Software Version                        | Date     |Revision log     |
|:-----------------------------------------:|:-----------------------------------------:|----------|-----------------|
|5f5712025d37814a3bdd7f34865f85a70fd92355   | af971507164f51cb484c50caff1c0ca9d5b2399f  |12/03/2020|Initial Release Build | 
|1c0bf0662bd48062868d314891425078cc116662   | 97fc01d8bad27c04a434e7ab72159103a98bde3f  |20/03/2020|Added HTML Doxygen Documentation |  
|**228339bcb88fd459f06655977baedb34692d9987**   | **7be16ccf864662586db49b18158ef5bd76c5cadc**  |30/03/2020|Fixed Issues with CPU TX and RX Interface|

The latest version is the version in **bold** as the per the hash and the date.

# Design Export to Vitis

To export the design,in Vivado select File->Export->Export Hardware

![alt text](./images/vivado3.png)

Make sure to tick Include bitstresm
![alt text](./images/vivado5.png)

Select the path you need to export to:

![alt text](./images/vivado6.png)

The design will be exported to the destination path folder.

# Creating a new hardware plaform in Vitis

On Vitis Create a new hardware platform

![alt text](./images/vitiscreate1.png)


Select create from XSA

![alt text](./images/vitiscreate2.png)

Browse to the export folder  where the design has been exported.

![alt text](./images/vitiscreate3.png)


Select the XSA file

![alt text](./images/vitiscreate4.png)

![alt text](./images/vitiscreate5.png)


A new platform vcu118platform project will be created and ready to build

![alt text](./images/vitiscreate6.png)


On the test_harness project select the newly created platform

![alt text](./images/vitiscreate7.png)

![alt text](./images/vitiscreate8.png)

Select yes when prompted.

![alt text](./images/vitiscreate9.png)


Build the testharness 
![alt text](./images/vitiscreate11.png)

Select the tesh harness elf executable to start debug

![alt text](./images/vitiscreate10.png)


Create a debug profile to start the executable

![alt text](./images/vitiscreate12.png)


Double Click on Single Application Debug (GDB)

![alt text](./images/vitiscreate13.png)


This will create Debugger_testharness-GDB

![alt text](./images/vitiscreate14.png)

![alt text](./images/vitiscreate15.png)

![alt text](./images/vitiscreate16.png)

Select Debug and start running the application.

![alt text](./images/vitiscreate17.png)

The FPGA bitstream load will start till it finshes loading the FPGA code.

![alt text](./images/vitiscreate18.png)

The debugger will start at stop on init_platform()

![alt text](./images/vitiscreate19.png)


Run the code untill the function cleanup_platform()

![alt text](./images/vitiscreate20.png)

![alt text](./images/vitiscreate21.png)



On Vivado Select the hw_vio_2

![alt text](./images/vivado7.png)

![alt text](./images/vivado8.png)

The design will now run and be ready for tests.

