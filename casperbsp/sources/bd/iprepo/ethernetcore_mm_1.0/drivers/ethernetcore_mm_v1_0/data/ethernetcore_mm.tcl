

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "ethernetcore_mm" "NUM_INSTANCES" "DEVICE_ID"  "C_S00_AXI_BASEADDR" "C_S00_AXI_HIGHADDR" "C_S01_AXI_BASEADDR" "C_S01_AXI_HIGHADDR" "C_S02_AXI_BASEADDR" "C_S02_AXI_HIGHADDR" "C_S03_AXI_BASEADDR" "C_S03_AXI_HIGHADDR"
}
