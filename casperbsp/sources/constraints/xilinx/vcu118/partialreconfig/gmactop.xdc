#############################################################################################################
#
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
#
#############################################################################################################
#

# Base Reference Clock
set_property PACKAGE_PIN G31 [get_ports sysclk1_300_p]
set_property PACKAGE_PIN F31 [get_ports sysclk1_300_n]
set_property IOSTANDARD LVDS [get_ports sysclk1_300_p]
set_property IOSTANDARD LVDS [get_ports sysclk1_300_n]

create_clock -period 3.333 [get_ports sysclk1_300_n]
set_input_jitter [get_clocks -of_objects [get_ports sysclk1_300_n]] 0.033

# UART (USB Based)
set_property PACKAGE_PIN BB21 [get_ports rs232_uart_txd]
set_property PACKAGE_PIN AW25 [get_ports rs232_uart_rxd]

# QSFP2
set_property PACKAGE_PIN W8 [get_ports mgt_qsfp1_clock_n]
set_property PACKAGE_PIN W9 [get_ports mgt_qsfp1_clock_p]


create_clock -period 6.400 [get_ports mgt_qsfp1_clock_p]

set_property LOC CMACE4_X0Y8 [get_cells -hierarchical -filter {NAME =~ *inst/i_EthMACPHY100GQSFP24x_top/* && REF_NAME==CMACE4}]

# QSFP1
set_property PACKAGE_PIN R8 [get_ports mgt_qsfp2_clock_n]
set_property PACKAGE_PIN R9 [get_ports mgt_qsfp2_clock_p]

create_clock -period 6.400 [get_ports mgt_qsfp2_clock_p]

set_property LOC CMACE4_X0Y7 [get_cells -hierarchical -filter {NAME =~ *inst/i_EthMACPHY100GQSFP14x_top/* && REF_NAME==CMACE4}]

# Debug LEDs
set_property PACKAGE_PIN AT32 [get_ports {blink_led[0]}]
set_property PACKAGE_PIN AV34 [get_ports {blink_led[1]}]
set_property PACKAGE_PIN AY30 [get_ports {blink_led[2]}]
set_property PACKAGE_PIN BB32 [get_ports {blink_led[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {blink_led[*]}]
set_property DRIVE 8 [get_ports {blink_led[*]}]
set_false_path -to [get_ports -filter NAME=~blink_led*]


#QSFP2





#QSFP1

set_property PACKAGE_PIN T2 [get_ports {qsfp2_mgt_rx_p[0]}]
set_property PACKAGE_PIN T1 [get_ports {qsfp2_mgt_rx_n[0]}]
set_property PACKAGE_PIN L5 [get_ports {qsfp2_mgt_tx_p[0]}]
set_property PACKAGE_PIN L4 [get_ports {qsfp2_mgt_tx_n[0]}]

set_property PACKAGE_PIN R4 [get_ports {qsfp2_mgt_rx_p[1]}]
set_property PACKAGE_PIN R3 [get_ports {qsfp2_mgt_rx_n[1]}]
set_property PACKAGE_PIN K7 [get_ports {qsfp2_mgt_tx_p[1]}]
set_property PACKAGE_PIN K6 [get_ports {qsfp2_mgt_tx_n[1]}]

set_property PACKAGE_PIN P2 [get_ports {qsfp2_mgt_rx_p[2]}]
set_property PACKAGE_PIN P1 [get_ports {qsfp2_mgt_rx_n[2]}]
set_property PACKAGE_PIN J5 [get_ports {qsfp2_mgt_tx_p[2]}]
set_property PACKAGE_PIN J4 [get_ports {qsfp2_mgt_tx_n[2]}]

set_property PACKAGE_PIN M2 [get_ports {qsfp2_mgt_rx_p[3]}]
set_property PACKAGE_PIN M1 [get_ports {qsfp2_mgt_rx_n[3]}]
set_property PACKAGE_PIN H7 [get_ports {qsfp2_mgt_tx_p[3]}]
set_property PACKAGE_PIN H6 [get_ports {qsfp2_mgt_tx_n[3]}]

# QSFP1 Settings

set_property PACKAGE_PIN AT21 [get_ports qsfp2_intl_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp2_intl_ls]
set_property PACKAGE_PIN AT24 [get_ports qsfp2_lpmode_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp2_lpmode_ls]
set_property PACKAGE_PIN AN24 [get_ports qsfp2_modprsl_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp2_modprsl_ls]
set_property PACKAGE_PIN AN23 [get_ports qsfp2_modsell_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp2_modsell_ls]
set_property PACKAGE_PIN AY22 [get_ports qsfp2_resetl_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp2_resetl_ls]


# QSFP2 Settings

set_property PACKAGE_PIN AP21 [get_ports qsfp1_intl_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp1_intl_ls]
set_property PACKAGE_PIN AN21 [get_ports qsfp1_lpmode_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp1_lpmode_ls]
set_property PACKAGE_PIN AL21 [get_ports qsfp1_modprsl_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp1_modprsl_ls]
set_property PACKAGE_PIN AM21 [get_ports qsfp1_modsell_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp1_modsell_ls]
set_property PACKAGE_PIN BA22 [get_ports qsfp1_resetl_ls]
set_property IOSTANDARD LVCMOS18 [get_ports qsfp1_resetl_ls]

# Exceptions
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets GMAC1_i/MACPHY_QSFP1_i/inst/gt_ref_clk]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets GMAC2_i/MACPHY_QSFP2_i/inst/gt_ref_clk]

# Timing exceptions

set_false_path -from [get_cells *ClockGen100MHz_i/inst/seq_reg* -filter is_sequential]
set_false_path -to [get_pins -hier {*sync_reg[0]/D}]

#This is the partial loaded pins

set_property PACKAGE_PIN BF32 [get_ports {partial_bit_leds[0]}]
set_property PACKAGE_PIN AU37 [get_ports {partial_bit_leds[1]}]
set_property PACKAGE_PIN AV36 [get_ports {partial_bit_leds[2]}]
set_property PACKAGE_PIN BA37 [get_ports {partial_bit_leds[3]}]
set_property IOSTANDARD LVCMOS12 [get_ports {partial_bit_leds[*]}]

set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_n}] -to [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}] -to [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_n}]


set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_n}] -to [get_clocks -of_objects [get_pins {GMAC2_i/MAC1i.CMAC1_i/MACPHY_QSFP2_i/inst/EthMACPHY100GQSFP24x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP24x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}] -to [get_clocks -of_objects [get_pins {GMAC2_i/MAC1i.CMAC1_i/MACPHY_QSFP2_i/inst/EthMACPHY100GQSFP24x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP24x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}] -to [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_n}]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}] -to [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}] -to [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT0] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}]
set_false_path -from [get_clocks MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_E2.BSCAN_I/Use_E2.BSCANE2_I/DRCK] -to [get_clocks MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_E2.BSCAN_I/Use_E2.BSCANE2_I/DRCK]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}] -to [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_n}]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_n}] -to [get_clocks -of_objects [get_pins {GMAC2_i/MAC1i.CMAC1_i/MACPHY_QSFP2_i/inst/EthMACPHY100GQSFP24x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP24x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}] -to [get_clocks -of_objects [get_pins {GMAC2_i/MAC1i.CMAC1_i/MACPHY_QSFP2_i/inst/EthMACPHY100GQSFP24x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP24x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]


#MicroblazeSys_i After removing debug hub put back Microblaze on the static region PBlock
create_pblock pblock_static_region_slr2
add_cells_to_pblock [get_pblocks pblock_static_region_slr2] [get_cells -quiet [list BANDWIDTHTEST_i ECHOAXIS_i GMAC1_i GMAC2_i MAINAXIS_i MicroblazeSys_i/microblaze_axi_us_plus_i/GND MicroblazeSys_i/microblaze_axi_us_plus_i/axi_timebase_wdt_0 MicroblazeSys_i/microblaze_axi_us_plus_i/axi_timer_0 MicroblazeSys_i/microblaze_axi_us_plus_i/axi_uartlite_0 MicroblazeSys_i/microblaze_axi_us_plus_i/ethernetcore_mm_0 MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/GND MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/MDM_Core_I1 MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_AXI_IPIF.AXI_LITE_IPIF_I MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Bus_MASTER.bus_master_I MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.BUFGCTRL_DRCK MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.BUFGCTRL_UPDATE MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.No_BSCANID.jtag_busy_reg MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.No_BSCANID.update_reset_reg MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_Dbg_Reg_Access.update_set_reg MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/VCC MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0 MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0_axi_intc MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0_axi_periph MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0_local_memory MicroblazeSys_i/microblaze_axi_us_plus_i/microblaze_0_xlconcat MicroblazeSys_i/microblaze_axi_us_plus_i/proc_sys_reset_0 RESET_VIO_i UDPIPIFFi/ARPCACHE_i UDPIPIFFi/CPUIFi UDPIPIFFi/PRCFGi.PRDATAApp_i UDPIPIFFi/STREAMAPPSi]]
resize_pblock [get_pblocks pblock_static_region_slr2] -add {CLOCKREGION_X0Y10:CLOCKREGION_X5Y14}



create_pblock pblock_master_slr1
add_cells_to_pblock [get_pblocks pblock_master_slr1] [get_cells -quiet [list MicroblazeSys_i/microblaze_axi_us_plus_i/mdm_0/U0/Use_E2.BSCAN_I UDPIPIFFi/PRCFGi.ICAPE3_i]]
resize_pblock [get_pblocks pblock_master_slr1] -add {CLOCKREGION_X0Y5:CLOCKREGION_X5Y9}



set_false_path -from [get_clocks -of_objects [get_pins {GMAC2_i/MAC1i.CMAC1_i/MACPHY_QSFP2_i/inst/EthMACPHY100GQSFP24x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP24x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins {GMAC2_i/MAC1i.CMAC1_i/MACPHY_QSFP2_i/inst/EthMACPHY100GQSFP24x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP24x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]]

set_false_path -from [get_clocks -of_objects [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/EthMACPHY100GQSFP14x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP14x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_n}]
set_false_path -from [get_clocks -of_objects [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/EthMACPHY100GQSFP14x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP14x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/EthMACPHY100GQSFP14x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP14x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/EthMACPHY100GQSFP14x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP14x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_n}] -to [get_clocks -of_objects [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/EthMACPHY100GQSFP14x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP14x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins ClockGen100MHz_i/inst/mmcme4_adv_inst/CLKOUT1] -filter {IS_GENERATED && MASTER_CLOCK == sysclk1_300_p}] -to [get_clocks -of_objects [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/EthMACPHY100GQSFP14x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP14x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_false_path -from [get_clocks -of_objects [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/EthMACPHY100GQSFP14x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP14x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins {GMAC2_i/MAC1i.CMAC1_i/MACPHY_QSFP2_i/inst/EthMACPHY100GQSFP24x_gt_i/inst/gen_gtwizard_gtye4_top.EthMACPHY100GQSFP24x_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[36].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_false_path -from [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/i_EthMACPHY100GQSFP14x_lbus2axis/i_EthMACPHY100GQSFP14x_lbus2axis_segmented_corelogic/axis_tdata_reg[37]/C}] -to *
set_false_path -from [get_pins {GMAC1_i/MAC0i.CMAC0_i/MACPHY_QSFP1_i/inst/i_EthMACPHY100GQSFP14x_lbus2axis/i_EthMACPHY100GQSFP14x_lbus2axis_segmented_corelogic/axis_tdata_reg[*]/C}] -to *
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets ClkQSFP1]
