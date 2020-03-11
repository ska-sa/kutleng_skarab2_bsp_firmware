#############################################################################################################
#set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
#
#############################################################################################################
#
# Base Reference Clock
set_property PACKAGE_PIN G31 [get_ports sysclk1_300_p]
set_property PACKAGE_PIN F31 [get_ports sysclk1_300_n]
set_property IOSTANDARD LVDS [get_ports sysclk1_300_p]
set_property IOSTANDARD LVDS [get_ports sysclk1_300_n]


# UART (USB Based)
set_property PACKAGE_PIN BB21 [get_ports rs232_uart_txd]
set_property PACKAGE_PIN AW25 [get_ports rs232_uart_rxd]

# QSFP1
set_property PACKAGE_PIN   W9  [get_ports mgt_qsfp1_clock_p]
set_property PACKAGE_PIN   W8  [get_ports mgt_qsfp1_clock_n]
set_property LOC CMACE4_X0Y7 [get_cells -hierarchical -filter {NAME =~ *inst/i_EthMACPHY100GQSFP14x_top/* && REF_NAME==CMACE4}]

#Place this one at the top of the chip


# QSFP2
set_property PACKAGE_PIN   R9  [get_ports mgt_qsfp2_clock_p]
set_property PACKAGE_PIN   R8  [get_ports mgt_qsfp2_clock_n]
set_property LOC CMACE4_X0Y8 [get_cells -hierarchical -filter {NAME =~ *inst/i_EthMACPHY100GQSFP24x_top/* && REF_NAME==CMACE4}]


# Debug LEDs
set_property PACKAGE_PIN   AT32  [get_ports {blink_led[0]}]
set_property PACKAGE_PIN   AV34  [get_ports {blink_led[1]}]
set_property PACKAGE_PIN   AY30  [get_ports {blink_led[2]}]
set_property PACKAGE_PIN   BB32  [get_ports {blink_led[3]}]
set_property IOSTANDARD   LVCMOS12  [get_ports {blink_led[*]}]



#QSFP1

set_property PACKAGE_PIN   Y2  [get_ports {qsfp1_mgt_rx_p[0]}]
set_property PACKAGE_PIN   Y1  [get_ports {qsfp1_mgt_rx_n[0]}]
set_property PACKAGE_PIN   V7  [get_ports {qsfp1_mgt_tx_p[0]}]
set_property PACKAGE_PIN   V6  [get_ports {qsfp1_mgt_tx_n[0]}]

set_property PACKAGE_PIN   W4  [get_ports {qsfp1_mgt_rx_p[1]}]
set_property PACKAGE_PIN   W3  [get_ports {qsfp1_mgt_rx_n[1]}]
set_property PACKAGE_PIN   T7  [get_ports {qsfp1_mgt_tx_p[1]}]
set_property PACKAGE_PIN   T6  [get_ports {qsfp1_mgt_tx_n[1]}]

set_property PACKAGE_PIN   V2  [get_ports {qsfp1_mgt_rx_p[2]}]
set_property PACKAGE_PIN   V1  [get_ports {qsfp1_mgt_rx_n[2]}]
set_property PACKAGE_PIN   P7  [get_ports {qsfp1_mgt_tx_p[2]}]
set_property PACKAGE_PIN   P6  [get_ports {qsfp1_mgt_tx_n[2]}]

set_property PACKAGE_PIN   U4  [get_ports {qsfp1_mgt_rx_p[3]}]
set_property PACKAGE_PIN   U3  [get_ports {qsfp1_mgt_rx_n[3]}]
set_property PACKAGE_PIN   M7  [get_ports {qsfp1_mgt_tx_p[3]}]
set_property PACKAGE_PIN   M6  [get_ports {qsfp1_mgt_tx_n[3]}]

#QSFP2

set_property PACKAGE_PIN   T2  [get_ports {qsfp2_mgt_rx_p[0]}]
set_property PACKAGE_PIN   T1  [get_ports {qsfp2_mgt_rx_n[0]}]
set_property PACKAGE_PIN   L5  [get_ports {qsfp2_mgt_tx_p[0]}]
set_property PACKAGE_PIN   L4  [get_ports {qsfp2_mgt_tx_n[0]}]

set_property PACKAGE_PIN   R4  [get_ports {qsfp2_mgt_rx_p[1]}]
set_property PACKAGE_PIN   R3  [get_ports {qsfp2_mgt_rx_n[1]}]
set_property PACKAGE_PIN   K7  [get_ports {qsfp2_mgt_tx_p[1]}]
set_property PACKAGE_PIN   K6  [get_ports {qsfp2_mgt_tx_n[1]}]

set_property PACKAGE_PIN   P2  [get_ports {qsfp2_mgt_rx_p[2]}]
set_property PACKAGE_PIN   P1  [get_ports {qsfp2_mgt_rx_n[2]}]
set_property PACKAGE_PIN   J5  [get_ports {qsfp2_mgt_tx_p[2]}]
set_property PACKAGE_PIN   J4  [get_ports {qsfp2_mgt_tx_n[2]}]

set_property PACKAGE_PIN   M2  [get_ports {qsfp2_mgt_rx_p[3]}]
set_property PACKAGE_PIN   M1  [get_ports {qsfp2_mgt_rx_n[3]}]
set_property PACKAGE_PIN   H7  [get_ports {qsfp2_mgt_tx_p[3]}]
set_property PACKAGE_PIN   H6  [get_ports {qsfp2_mgt_tx_n[3]}]

# QSFP1 Settings

set_property PACKAGE_PIN    AT21      [get_ports "qsfp1_intl_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp1_intl_ls"];
set_property PACKAGE_PIN    AT24      [get_ports "qsfp1_lpmode_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp1_lpmode_ls"];
set_property PACKAGE_PIN    AN24      [get_ports "qsfp1_modprsl_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp1_modprsl_ls"];
set_property PACKAGE_PIN    AN23      [get_ports "qsfp1_modsell_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp1_modsell_ls"];
set_property PACKAGE_PIN    AY22      [get_ports "qsfp1_resetl_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp1_resetl_ls"];


# QSFP2 Settings

set_property PACKAGE_PIN    AP21      [get_ports "qsfp2_intl_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp2_intl_ls"];
set_property PACKAGE_PIN    AN21      [get_ports "qsfp2_lpmode_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp2_lpmode_ls"];
set_property PACKAGE_PIN    AL21      [get_ports "qsfp2_modprsl_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp2_modprsl_ls"];
set_property PACKAGE_PIN    AM21      [get_ports "qsfp2_modsell_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp2_modsell_ls"];
set_property PACKAGE_PIN    BA22      [get_ports "qsfp2_resetl_ls"];
set_property IOSTANDARD     LVCMOS18  [get_ports "qsfp2_resetl_ls"];

#This is the partial loaded pins

set_property PACKAGE_PIN BF32 [get_ports {partial_bit_leds[0]}]
set_property PACKAGE_PIN AU37 [get_ports {partial_bit_leds[1]}]
set_property PACKAGE_PIN AV36 [get_ports {partial_bit_leds[2]}]
set_property PACKAGE_PIN BA37 [get_ports {partial_bit_leds[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {partial_bit_leds[*]}]
#set_false_path -from [get_clocks MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_E2.BSCAN_I/Use_E2.BSCANE2_I/DRCK] -to [get_clocks MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_E2.BSCAN_I/Use_E2.BSCANE2_I/DRCK]


#MicroblazeSys_i After removing debug hub put back Microblaze on the static region PBlock
#create_pblock pblock_static_region_slr2
#add_cells_to_pblock [get_pblocks pblock_static_region_slr2] [get_cells -quiet [list BANDWIDTHTEST_i ECHOAXIS_i GMAC1_i GMAC2_i MAINAXIS_i MicroblazeSys_i/microblaze_axi_us_plus_i/GND MicroblazeSys_i/microblaze_axi_us_plus_i/axi_timebase_wdt_0 MicroblazeSys_i/microblaze_axi_us_plus_i/axi_timer_0 MicroblazeSys_i/microblaze_axi_us_plus_i/axi_uartlite_0 MicroblazeSys_i/microblaze_axi_us_plus_i/ethernetcore_mm_0 MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/GND MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/MDM_Core_I1 MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_AXI_IPIF.AXI_LITE_IPIF_I MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Bus_MASTER.bus_master_I MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.BUFGCTRL_DRCK MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.BUFGCTRL_UPDATE MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.No_BSCANID.jtag_busy_reg MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.No_BSCANID.update_reset_reg MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.update_set_reg MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/VCC MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0 MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0_axi_intc MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0_axi_periph MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0_local_memory MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0_xlconcat MicroblazeSys_i/microblaze_axi_us_plus_i/proc_sys_reset_0 RESET_VIO_i UDPIPIFFi/ARPCACHE_i UDPIPIFFi/CPUIFi UDPIPIFFi/PRCFGi.PRDATAApp_i UDPIPIFFi/STREAMAPPSi]]
#resize_pblock [get_pblocks pblock_static_region_slr2] -add {CLOCKREGION_X0Y10:CLOCKREGION_X5Y14}



#create_pblock pblock_master_slr1
#add_cells_to_pblock [get_pblocks pblock_master_slr1] [get_cells -quiet [list MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_E2.BSCAN_I UDPIPIFFi/PRCFGi.ICAPE3_i]]
#resize_pblock [get_pblocks pblock_master_slr1] -add {CLOCKREGION_X0Y5:CLOCKREGION_X5Y9}


# Timing exceptions
create_clock -period 3.333 [get_ports sysclk1_300_p]
set_input_jitter [get_clocks -of_objects [get_ports sysclk1_300_p]] 0.010


create_clock -period 6.400 [get_ports mgt_qsfp2_clock_p]
create_clock -period 6.400 [get_ports mgt_qsfp1_clock_p]

#For both the ethernet MACs txclock and the 100MHz clock are independant and asynchronous
set_clock_groups -asynchronous -group [get_clocks {txoutclk_out[0]}] -group [get_clocks clk_out2_clockgen100mhz]
#For both the ethernet MACs derived txclock and the 100MHz clock are independant and asynchronous
set_clock_groups -asynchronous -group [get_clocks {txoutclk_out[0]_1}] -group [get_clocks clk_out2_clockgen100mhz]
#For both the ethernet MACs txclock and derived txclock are independant and asynchronous
set_clock_groups -asynchronous -group [get_clocks {txoutclk_out[0]}] -group [get_clocks {txoutclk_out[0]_1}]
#For both the ethernet MACs tx and RX clocks are independant and asynchronous 
set_clock_groups -asynchronous -group [get_clocks {txoutclk_out[0]}] -group [get_clocks {rxoutclk_out[0]}]
#For both the ethernet MACs rxclock and derived txclock are independant and asynchronous
set_clock_groups -asynchronous -group [get_clocks {rxoutclk_out[0]_1}] -group [get_clocks {txoutclk_out[0]_1}]

set_property CONFIG_MODE S_SELECTMAP32 [current_design]

#Remove these for non debug designs
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets ClkQSFP1]
