# kutleng_skarab2_bsp_firmware

Table of Contents
=================

   * [kutleng_skarab2_bsp_firmware](#kutleng_skarab2_bsp_firmware)
   * [Table of Contents](#table-of-contents)
      * [Introduction](#introduction)
      * [Building the Vivado Project](#building-the-vivado-project)
      * [Version Description Document](#version-description-document)
      * [Design Export to Vitis](#design-export-to-vitis)
         * [Creating a new hardware plaform in Vitis](#creating-a-new-hardware-plaform-in-vitis)
      * [Test setup](#test-setup)
         * [Bandwidth test](#bandwidth-test)
         * [Partial reconfiguration test](#partial-reconfiguration-test)
      * [Firmware Module Layout](#firmware-module-layout)
         * [Yellow block interface](#yellow-block-interface)
         * [Partial Reconfiguration Module](#partial-reconfiguration-module)

## Introduction

In this document the Vivado firmware for the 100G Ethernet and Partial Reconfiguration is describe together with the different modes of operation and testing.

This is the work for the port of the 100G Ethernet to the VCU118+VCU1525 board.

The Vivado version being used is Vivado 2019.2.1_AR72614


## Building the Vivado Project

To run the code clone it first to a directory


```bash
git clone https://github.com/ska-sa/kutleng_skarab2_bsp_firmware.git

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

---

## Version Description Document

The know working version of the build with the corresponding git hash are updated on the list as follows:

The Firmware Repository is: [https://github.com/ska-sa/kutleng_skarab2_bsp_firmware](https://github.com/ska-sa/kutleng_skarab2_bsp_firmware.git)

The Software Repository is: [https://github.com/ska-sa/kutleng_skarab2_control_software](https://github.com/ska-sa/kutleng_skarab2_control_software.git)


|           Firmware Version                |   Software Version                        | Date     |Revision log     |
|:-----------------------------------------:|:-----------------------------------------:|----------|-----------------|
|5f5712025d37814a3bdd7f34865f85a70fd92355   | af971507164f51cb484c50caff1c0ca9d5b2399f  |12/03/2020|Initial Release Build | 
|1c0bf0662bd48062868d314891425078cc116662   | 97fc01d8bad27c04a434e7ab72159103a98bde3f  |20/03/2020|Added HTML Doxygen Documentation |  
|**228339bcb88fd459f06655977baedb34692d9987**   | **7be16ccf864662586db49b18158ef5bd76c5cadc**  |30/03/2020|Fixed Issues with CPU TX and RX Interface|

The latest version is the version in **bold** as the per the hash and the date.

---

## Design Export to Vitis

To export the design,in Vivado select File->Export->Export Hardware

![alt text](./images/vivado3.png)

Make sure to tick Include bitstream

![alt text](./images/vivado5.png)

Select the path you need to export to:

![alt text](./images/vivado6.png)

The design will be exported to the destination path folder.

### Creating a new hardware plaform in Vitis

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

## Test setup

The standard test setup for the design needs the following equipment:

* VCU118/VCU1525 - The FPGA board with 100G links

* 100G Ethernet Switch - With a minimum of 3 ports

* Workstation running Linux - With a 100G Netowrk Interface Card

* Xilinx JTAG Cable - For initial configuration and ILA/VIO setup

* 3 100G Cables - The cables must not be > 3m if they are copper else there will be errors

The test setup is shown on the figure below:

![alt text](./images/devsetup.png)



### Bandwidth test

To start the bandwidth test it is important to have the test setup as shown below:

![alt text](./images/bandwidthtest.png)

First make sure to ping both ports so that the switch can have the ARP tables populated.

```bash
ping 192.168.100.10

ping 192.168.100.15
 
```

After pinging the ports you should be able to observe the ARP packets on WireShark.

The standard test for bandwidth test requires data to be sent to port 2.
Port 2 has the IP address 192.168.100.15

Every packet sent to port 2 will be **echoed** back to the sender IP.

Port one with IP address 192.168.100.10 has a UDP packet sender that first receives packets from the Workstation,
buffer the packets and then send them untill the ring buffers are filled in both the transmit and receive path.

First stop Wireshark before starting the bandwidth test.
 
To start the bandwidth test run the following commands to generate packets on the Workstation:

```bash

cd /kutleng_skarab2_control_software/casperbsp/ethernettests/bandwidth

make

./ethbwtest

```

After the packet are filled the Signal StripperClearEnable on the VIO can be switched on since the test has reached line rate.

The expected line rate is 98.6 Gbps on the FPGA ports both TX and RX.

![alt text](./images/vivado8.png)


### Partial reconfiguration test

The partial reconfiguration test requires the same setup as the bandwith test.
The only difference is that patial reconfiguration data is programmed to the FPGA.

![alt text](./images/partialreconfigtest.png)

To run the partial reconfig make sure that all bit streams have been produced.

Copy all the bitsreams to the /kutleng_skarab2_control_software/casperbsp/partialreconfigapp/bitfiles folder.
Inside this folder there is VCU118 and VCU1525 copy the correct bitstreams.bin to the board you are using.

There is a Python script to load the partial reconfiguration bitstreams.

The script will:
 
* first clear the RM module (all LEDs will be off)

* wait for 5 seconds

* load the blinker RM (4 leds will run like a Johnson counter)

* wait for 5 seconds

* clear the RM module (all LEDs will be off)

* wait 5 seconds

* load the flasher module (4 LEDs will all flash at the same time)

* exit

Run the partial reconfiguration Python script as follows:

```bash

cd /kutleng_skarab2_control_software/casperbsp/partialreconfigapp/

make

python xilinxbitstream.py

```

This will begin the partial reconfiguration process.

---

## Firmware Module Layout

The Firmware is made up of a top module called casper100gethernetblock.vhd

This module has two modules

* udpipinterfacepr.vhd

* mac100gphy.vhd

![alt text](./images/udpipprblock.png)

This module has a generic (C_INCLUDE_ICAP) to enable/disable partial reconfiguration.

 * C_INCLUDE_ICAP := TRUE enables partial reconfiguration

 * C_INCLUDE_ICAP := FALSE disables partial reconfiguration
 
![alt text](./images/udpipnoprblock.png)


The module uses DataRateBackOff signal for rate control to throttle data and prevent overflows.

![alt text](./images/udpipprblockratecontrol.png)


### Yellow block interface

The interface to Yellowblock streaming data is done using the AXIS streaming interface on the casper100gethernetblock.vhd

The interface ports have both receive and transmit interface and follows the AXIS protocol.

The interface will leave all the addressing information on the first 512-bit word i.e the first 336 bits wil be discarded.

Addressing information must come from the udpdatapacker module.


### Partial Reconfiguration Module

The partial reconfiguration module is documented on the link below.

[https://github.com/ska-sa/kutleng_skarab2_bsp_firmware/PartialReconfigDoc.md](https://github.com/ska-sa/kutleng_skarab2_bsp_firmware/blob/master/PartialReconfigDoc.md)








