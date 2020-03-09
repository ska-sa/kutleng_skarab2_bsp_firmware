# kutleng_skarab2_bsp_firmware
The vivado firmware for the skarab2

This is the work for the port of the 100G Ethernet to the VCU118+VCU1525 board.

The Vivado version being used is Vivado 2019.2.1_AR72614

Use code at Git tag v1.8

To run the code clone it first to a directory

git clone https://github.com/hectorkutleng/kutleng_skarab2_bsp_firmware.git


cd kutleng_skarab2_bsp_firmware/casperbsp/projects/

mkdir project_flow

cd project_flow

vivado

Replace {vcu118|vcu1525} with whichever platform you intend to build for e.g. 
for vcu118 use vcu118.


#on vivado prompt source the project file for the vcu118 or the vcu1525


source ../{vcu118|vcu1525}/ethmac{vcu118|vcu1525}pr.tcl


#You need to launch vivado when you are on the ${kutleng_skarab2_bsp_firmware/casperbsp/projects/project_flow} folder

#This will create a vivado project on a folder ${kutleng_skarab2_bsp_firmware/casperbsp/projects/project_flow/{vcu118|vcu1525}project/{vcu118|vcu1525}projectpr.xpr}


The design assumes a network at 192.168.100.10/15 for port 1 and port 2 of the QFSP28+ ports

The latest Git tag that contains the working fileset is:
tag 1.8


