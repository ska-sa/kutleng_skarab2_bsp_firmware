# kutleng_skarab2_bsp_firmware
The vivado firmware for the skarab2

This is the initial work for the port of the 100G Ethernet to the VCU118 board.

The Vivado version being used is Vivado 2018.1

Added Git tag v1.0

Updated code with VCU1525


To run the code clone it first to a directory

git clone https://github.com/hectorkutleng/kutleng_skarab2_bsp_firmware.git

cd kutleng_skarab2_bsp_firmware/casperbsp/projects/vivado/vcu118

vivado

#on vivado prompt source the project file for the vcu118

#on my machine it is as follows

source /home/hectorh/Documents/projects/sarao/skarab2/kutlengrepo/kutleng_skarab2_bsp_firmware/casperbsp/projects/vivado/vcu118/ethmacvcu118pr.tcl

#Yours maybe source ethmacvcu118pr.tcl

#You need to launch vivado when you are on the ${kutleng_skarab2_bsp_firmware/casperbsp/projects/vivado/vcu118/} folder

#This will create a vivado project on a folder ${kutleng_skarab2_bsp_firmware/casperbsp/projects/project_flow/vcu118project/vcu118project.xpr}




cd kutleng_skarab2_bsp_firmware/casperbsp/projects/vivado/vcu1525

vivado

#on vivado prompt source the project file for the vcu1525

#on my machine it is as follows

source /home/hectorh/Documents/projects/sarao/skarab2/kutlengrepo/kutleng_skarab2_bsp_firmware/casperbsp/projects/vivado/vcu1525/ethmacvcu1525.tcl

#Yours maybe source ethmacvcu1525.tcl

#You need to launch vivado when you are on the ${kutleng_skarab2_bsp_firmware/casperbsp/projects/vivado/vcu1525/} folder

#This will create a vivado project on a folder ${kutleng_skarab2_bsp_firmware/casperbsp/projects/project_flow/vcu1525project/vcu1525project.xpr}


Fixed 100G links on VCU1525 Using IP Address 192.168.100.10/15

Tagging this to V1.1

Updated code on this branch to work with partial reconfiguration.

ICAP based PR still being tested.
JTAG based PR working on VCU1525 (to be confirmed on VCU118 but it should work).

