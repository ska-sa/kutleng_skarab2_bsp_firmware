
################################################################
# This is a generated script based on design: microblaze_axi_us_plus
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source microblaze_axi_us_plus_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu9p-flga2104-2L-e
   set_property BOARD_PART xilinx.com:vcu118:part0:2.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name microblaze_axi_us_plus

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir .

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_msg_id "BD_TCL-110" "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_msg_id "BD_TCL-008" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_msg_id "BD_TCL-009" "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-111" "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-010" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-112" "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_msg_id "BD_TCL-113" "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-011" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_msg_id "BD_TCL-012" "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_timebase_wdt:3.0\
xilinx.com:ip:axi_timer:2.0\
xilinx.com:ip:axi_uartlite:2.0\
kutleng.co.za:kutleng:ethernetcore_mm:1.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:microblaze:11.0\
xilinx.com:ip:axi_intc:4.1\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
xilinx.com:ip:lmb_v10:3.0\
xilinx.com:ip:blk_mem_gen:8.4\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [ list \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set rs232_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 rs232_uart ]

  # Create ports
  set ClockStable [ create_bd_port -dir I ClockStable ]
  set PSClock [ create_bd_port -dir I -type clk PSClock ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
 ] $PSClock
  set PSReset [ create_bd_port -dir I -type rst PSReset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $PSReset
  set gmac_arp_cache_read_address [ create_bd_port -dir O -from 12 -to 0 gmac_arp_cache_read_address ]
  set gmac_arp_cache_read_data [ create_bd_port -dir I -from 31 -to 0 gmac_arp_cache_read_data ]
  set gmac_arp_cache_read_enable [ create_bd_port -dir O gmac_arp_cache_read_enable ]
  set gmac_arp_cache_write_address [ create_bd_port -dir O -from 12 -to 0 gmac_arp_cache_write_address ]
  set gmac_arp_cache_write_data [ create_bd_port -dir O -from 31 -to 0 gmac_arp_cache_write_data ]
  set gmac_arp_cache_write_enable [ create_bd_port -dir O gmac_arp_cache_write_enable ]
  set gmac_reg_arp_size [ create_bd_port -dir I -from 31 -to 0 gmac_reg_arp_size ]
  set gmac_reg_core_type [ create_bd_port -dir I -from 31 -to 0 gmac_reg_core_type ]
  set gmac_reg_counters_reset [ create_bd_port -dir O -type rst gmac_reg_counters_reset ]
  set gmac_reg_gateway_ip_address [ create_bd_port -dir O -from 31 -to 0 gmac_reg_gateway_ip_address ]
  set gmac_reg_local_ip_address [ create_bd_port -dir O -from 31 -to 0 gmac_reg_local_ip_address ]
  set gmac_reg_mac_address [ create_bd_port -dir O -from 47 -to 0 gmac_reg_mac_address ]
  set gmac_reg_mac_enable [ create_bd_port -dir O gmac_reg_mac_enable ]
  set gmac_reg_mac_promiscous_mode [ create_bd_port -dir O gmac_reg_mac_promiscous_mode ]
  set gmac_reg_multicast_ip_address [ create_bd_port -dir O -from 31 -to 0 gmac_reg_multicast_ip_address ]
  set gmac_reg_multicast_ip_mask [ create_bd_port -dir O -from 31 -to 0 gmac_reg_multicast_ip_mask ]
  set gmac_reg_phy_control_h [ create_bd_port -dir O -from 31 -to 0 -type data gmac_reg_phy_control_h ]
  set gmac_reg_phy_control_l [ create_bd_port -dir O -from 31 -to 0 -type data gmac_reg_phy_control_l ]
  set gmac_reg_phy_status_h [ create_bd_port -dir I -from 31 -to 0 gmac_reg_phy_status_h ]
  set gmac_reg_phy_status_l [ create_bd_port -dir I -from 31 -to 0 gmac_reg_phy_status_l ]
  set gmac_reg_rx_almost_full_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_rx_almost_full_count ]
  set gmac_reg_rx_bad_packet_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_rx_bad_packet_count ]
  set gmac_reg_rx_buffer_max_size [ create_bd_port -dir I -from 15 -to 0 gmac_reg_rx_buffer_max_size ]
  set gmac_reg_rx_overflow_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_rx_overflow_count ]
  set gmac_reg_rx_packet_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_rx_packet_count ]
  set gmac_reg_rx_packet_rate [ create_bd_port -dir I -from 31 -to 0 gmac_reg_rx_packet_rate ]
  set gmac_reg_rx_valid_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_rx_valid_count ]
  set gmac_reg_rx_valid_rate [ create_bd_port -dir I -from 31 -to 0 gmac_reg_rx_valid_rate ]
  set gmac_reg_rx_word_size [ create_bd_port -dir I -from 15 -to 0 gmac_reg_rx_word_size ]
  set gmac_reg_tx_afull_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_tx_afull_count ]
  set gmac_reg_tx_buffer_max_size [ create_bd_port -dir I -from 15 -to 0 gmac_reg_tx_buffer_max_size ]
  set gmac_reg_tx_overflow_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_tx_overflow_count ]
  set gmac_reg_tx_packet_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_tx_packet_count ]
  set gmac_reg_tx_packet_rate [ create_bd_port -dir I -from 31 -to 0 gmac_reg_tx_packet_rate ]
  set gmac_reg_tx_valid_count [ create_bd_port -dir I -from 31 -to 0 gmac_reg_tx_valid_count ]
  set gmac_reg_tx_valid_rate [ create_bd_port -dir I -from 31 -to 0 gmac_reg_tx_valid_rate ]
  set gmac_reg_tx_word_size [ create_bd_port -dir I -from 15 -to 0 gmac_reg_tx_word_size ]
  set gmac_reg_udp_port [ create_bd_port -dir O -from 15 -to 0 gmac_reg_udp_port ]
  set gmac_reg_udp_port_mask [ create_bd_port -dir O -from 15 -to 0 gmac_reg_udp_port_mask ]
  set gmac_rx_data_read_address [ create_bd_port -dir O -from 12 -to 0 gmac_rx_data_read_address ]
  set gmac_rx_data_read_byte_enable [ create_bd_port -dir I -from 1 -to 0 gmac_rx_data_read_byte_enable ]
  set gmac_rx_data_read_data [ create_bd_port -dir I -from 7 -to 0 gmac_rx_data_read_data ]
  set gmac_rx_data_read_enable [ create_bd_port -dir O gmac_rx_data_read_enable ]
  set gmac_rx_data_write_address [ create_bd_port -dir O -from 12 -to 0 gmac_rx_data_write_address ]
  set gmac_rx_data_write_byte_enable_0 [ create_bd_port -dir O -from 1 -to 0 gmac_rx_data_write_byte_enable_0 ]
  set gmac_rx_data_write_data [ create_bd_port -dir O -from 7 -to 0 gmac_rx_data_write_data ]
  set gmac_rx_data_write_enable [ create_bd_port -dir O gmac_rx_data_write_enable ]
  set gmac_rx_ringbuffer_number_slots_filled [ create_bd_port -dir I -from 3 -to 0 gmac_rx_ringbuffer_number_slots_filled ]
  set gmac_rx_ringbuffer_slot_clear [ create_bd_port -dir O gmac_rx_ringbuffer_slot_clear ]
  set gmac_rx_ringbuffer_slot_id [ create_bd_port -dir O -from 3 -to 0 gmac_rx_ringbuffer_slot_id ]
  set gmac_rx_ringbuffer_slot_status [ create_bd_port -dir I gmac_rx_ringbuffer_slot_status ]
  set gmac_tx_data_read_address [ create_bd_port -dir O -from 12 -to 0 gmac_tx_data_read_address ]
  set gmac_tx_data_read_byte_enable [ create_bd_port -dir I -from 1 -to 0 gmac_tx_data_read_byte_enable ]
  set gmac_tx_data_read_data [ create_bd_port -dir I -from 7 -to 0 gmac_tx_data_read_data ]
  set gmac_tx_data_read_enable [ create_bd_port -dir O gmac_tx_data_read_enable ]
  set gmac_tx_data_write_address [ create_bd_port -dir O -from 12 -to 0 gmac_tx_data_write_address ]
  set gmac_tx_data_write_byte_enable [ create_bd_port -dir O -from 1 -to 0 gmac_tx_data_write_byte_enable ]
  set gmac_tx_data_write_data [ create_bd_port -dir O -from 7 -to 0 gmac_tx_data_write_data ]
  set gmac_tx_data_write_enable [ create_bd_port -dir O gmac_tx_data_write_enable ]
  set gmac_tx_ringbuffer_number_slots_filled [ create_bd_port -dir I -from 3 -to 0 gmac_tx_ringbuffer_number_slots_filled ]
  set gmac_tx_ringbuffer_slot_id [ create_bd_port -dir O -from 3 -to 0 gmac_tx_ringbuffer_slot_id ]
  set gmac_tx_ringbuffer_slot_set [ create_bd_port -dir O gmac_tx_ringbuffer_slot_set ]
  set gmac_tx_ringbuffer_slot_status [ create_bd_port -dir I gmac_tx_ringbuffer_slot_status ]

  # Create instance: axi_timebase_wdt_0, and set properties
  set axi_timebase_wdt_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timebase_wdt:3.0 axi_timebase_wdt_0 ]

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
   CONFIG.C_S_AXI_ACLK_FREQ_HZ {125000000} \
   CONFIG.UARTLITE_BOARD_INTERFACE {rs232_uart} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uartlite_0

  # Create instance: ethernetcore_mm_0, and set properties
  set ethernetcore_mm_0 [ create_bd_cell -type ip -vlnv kutleng.co.za:kutleng:ethernetcore_mm:1.0 ethernetcore_mm_0 ]
  set_property -dict [ list \
   CONFIG.C_S01_AXI_ADDR_WIDTH {15} \
   CONFIG.C_S02_AXI_ADDR_WIDTH {15} \
   CONFIG.C_S03_AXI_ADDR_WIDTH {15} \
 ] $ethernetcore_mm_0

  # Create instance: mdm_0, and set properties
  set mdm_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_0 ]
  set_property -dict [ list \
   CONFIG.C_DBG_MEM_ACCESS {1} \
   CONFIG.C_DBG_REG_ACCESS {1} \
   CONFIG.C_S_AXI_ADDR_WIDTH {5} \
   CONFIG.C_USE_UART {1} \
 ] $mdm_0

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0 ]
  set_property -dict [ list \
   CONFIG.C_ADDR_TAG_BITS {0} \
   CONFIG.C_AREA_OPTIMIZED {1} \
   CONFIG.C_CACHE_BYTE_SIZE {8192} \
   CONFIG.C_DCACHE_ADDR_TAG {0} \
   CONFIG.C_DCACHE_BYTE_SIZE {8192} \
   CONFIG.C_DCACHE_USE_WRITEBACK {0} \
   CONFIG.C_DEBUG_ENABLED {2} \
   CONFIG.C_DIV_ZERO_EXCEPTION {0} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_FPU_EXCEPTION {0} \
   CONFIG.C_ICACHE_LINE_LEN {8} \
   CONFIG.C_ICACHE_STREAMS {0} \
   CONFIG.C_ICACHE_VICTIMS {0} \
   CONFIG.C_ILL_OPCODE_EXCEPTION {0} \
   CONFIG.C_I_LMB {1} \
   CONFIG.C_MMU_DTLB_SIZE {4} \
   CONFIG.C_MMU_ITLB_SIZE {2} \
   CONFIG.C_MMU_ZONES {2} \
   CONFIG.C_M_AXI_D_BUS_EXCEPTION {1} \
   CONFIG.C_M_AXI_I_BUS_EXCEPTION {0} \
   CONFIG.C_NUMBER_OF_PC_BRK {2} \
   CONFIG.C_NUMBER_OF_RD_ADDR_BRK {2} \
   CONFIG.C_NUMBER_OF_WR_ADDR_BRK {2} \
   CONFIG.C_OPCODE_0x0_ILLEGAL {0} \
   CONFIG.C_PVR {0} \
   CONFIG.C_UNALIGNED_EXCEPTIONS {0} \
   CONFIG.C_USE_BARREL {1} \
   CONFIG.C_USE_DCACHE {0} \
   CONFIG.C_USE_DIV {0} \
   CONFIG.C_USE_FPU {0} \
   CONFIG.C_USE_HW_MUL {1} \
   CONFIG.C_USE_ICACHE {0} \
   CONFIG.C_USE_MMU {0} \
   CONFIG.C_USE_MSR_INSTR {1} \
   CONFIG.C_USE_PCMP_INSTR {1} \
   CONFIG.C_USE_REORDER_INSTR {1} \
   CONFIG.C_USE_STACK_PROTECTION {1} \
   CONFIG.G_TEMPLATE_LIST {6} \
   CONFIG.G_USE_EXCEPTIONS {1} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_intc, and set properties
  set microblaze_0_axi_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 microblaze_0_axi_intc ]
  set_property -dict [ list \
   CONFIG.C_HAS_FAST {1} \
 ] $microblaze_0_axi_intc

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {10} \
   CONFIG.NUM_SI {2} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: microblaze_0_xlconcat, and set properties
  set microblaze_0_xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 microblaze_0_xlconcat ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {6} \
 ] $microblaze_0_xlconcat

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports rs232_uart] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net mdm_0_M_AXI [get_bd_intf_pins mdm_0/M_AXI] [get_bd_intf_pins microblaze_0_axi_periph/S01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins axi_timebase_wdt_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins axi_timer_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins ethernetcore_mm_0/S00_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M06_AXI [get_bd_intf_pins ethernetcore_mm_0/S01_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins ethernetcore_mm_0/S_AXI_INTR] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M08_AXI [get_bd_intf_pins ethernetcore_mm_0/S02_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M09_AXI [get_bd_intf_pins ethernetcore_mm_0/S03_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_0/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net microblaze_0_intc_axi [get_bd_intf_pins microblaze_0_axi_intc/s_axi] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_interrupt [get_bd_intf_pins microblaze_0/INTERRUPT] [get_bd_intf_pins microblaze_0_axi_intc/interrupt]
  connect_bd_intf_net -intf_net microblaze_0_mdm_axi [get_bd_intf_pins mdm_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]

  # Create port connections
  connect_bd_net -net ClockStable_1 [get_bd_ports ClockStable] [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net PSReset_1 [get_bd_ports PSReset] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net axi_timebase_wdt_0_timebase_interrupt [get_bd_pins axi_timebase_wdt_0/timebase_interrupt] [get_bd_pins microblaze_0_xlconcat/In1]
  connect_bd_net -net axi_timebase_wdt_0_wdt_interrupt [get_bd_pins axi_timebase_wdt_0/wdt_interrupt] [get_bd_pins microblaze_0_xlconcat/In2]
  connect_bd_net -net axi_timer_0_interrupt [get_bd_pins axi_timer_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In3]
  connect_bd_net -net axi_uartlite_0_interrupt [get_bd_pins axi_uartlite_0/interrupt] [get_bd_pins microblaze_0_xlconcat/In0]
  connect_bd_net -net ethernetcore_mm_0_gmac_arp_cache_read_address [get_bd_ports gmac_arp_cache_read_address] [get_bd_pins ethernetcore_mm_0/gmac_arp_cache_read_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_arp_cache_read_enable [get_bd_ports gmac_arp_cache_read_enable] [get_bd_pins ethernetcore_mm_0/gmac_arp_cache_read_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_arp_cache_write_address [get_bd_ports gmac_arp_cache_write_address] [get_bd_pins ethernetcore_mm_0/gmac_arp_cache_write_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_arp_cache_write_data [get_bd_ports gmac_arp_cache_write_data] [get_bd_pins ethernetcore_mm_0/gmac_arp_cache_write_data]
  connect_bd_net -net ethernetcore_mm_0_gmac_arp_cache_write_enable [get_bd_ports gmac_arp_cache_write_enable] [get_bd_pins ethernetcore_mm_0/gmac_arp_cache_write_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_counters_reset [get_bd_ports gmac_reg_counters_reset] [get_bd_pins ethernetcore_mm_0/gmac_reg_counters_reset]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_gateway_ip_address [get_bd_ports gmac_reg_gateway_ip_address] [get_bd_pins ethernetcore_mm_0/gmac_reg_gateway_ip_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_local_ip_address [get_bd_ports gmac_reg_local_ip_address] [get_bd_pins ethernetcore_mm_0/gmac_reg_local_ip_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_mac_address [get_bd_ports gmac_reg_mac_address] [get_bd_pins ethernetcore_mm_0/gmac_reg_mac_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_mac_enable [get_bd_ports gmac_reg_mac_enable] [get_bd_pins ethernetcore_mm_0/gmac_reg_mac_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_mac_promiscous_mode [get_bd_ports gmac_reg_mac_promiscous_mode] [get_bd_pins ethernetcore_mm_0/gmac_reg_mac_promiscous_mode]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_multicast_ip_address [get_bd_ports gmac_reg_multicast_ip_address] [get_bd_pins ethernetcore_mm_0/gmac_reg_multicast_ip_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_multicast_ip_mask [get_bd_ports gmac_reg_multicast_ip_mask] [get_bd_pins ethernetcore_mm_0/gmac_reg_multicast_ip_mask]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_phy_control_h [get_bd_ports gmac_reg_phy_control_h] [get_bd_pins ethernetcore_mm_0/gmac_reg_phy_control_h]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_phy_control_l [get_bd_ports gmac_reg_phy_control_l] [get_bd_pins ethernetcore_mm_0/gmac_reg_phy_control_l]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_udp_port [get_bd_ports gmac_reg_udp_port] [get_bd_pins ethernetcore_mm_0/gmac_reg_udp_port]
  connect_bd_net -net ethernetcore_mm_0_gmac_reg_udp_port_mask [get_bd_ports gmac_reg_udp_port_mask] [get_bd_pins ethernetcore_mm_0/gmac_reg_udp_port_mask]
  connect_bd_net -net ethernetcore_mm_0_gmac_rx_data_read_address [get_bd_ports gmac_rx_data_read_address] [get_bd_pins ethernetcore_mm_0/gmac_rx_data_read_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_rx_data_read_enable [get_bd_ports gmac_rx_data_read_enable] [get_bd_pins ethernetcore_mm_0/gmac_rx_data_read_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_rx_data_write_address [get_bd_ports gmac_rx_data_write_address] [get_bd_pins ethernetcore_mm_0/gmac_rx_data_write_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_rx_data_write_byte_enable [get_bd_ports gmac_rx_data_write_byte_enable_0] [get_bd_pins ethernetcore_mm_0/gmac_rx_data_write_byte_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_rx_data_write_data [get_bd_ports gmac_rx_data_write_data] [get_bd_pins ethernetcore_mm_0/gmac_rx_data_write_data]
  connect_bd_net -net ethernetcore_mm_0_gmac_rx_data_write_enable [get_bd_ports gmac_rx_data_write_enable] [get_bd_pins ethernetcore_mm_0/gmac_rx_data_write_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_rx_ringbuffer_slot_clear [get_bd_ports gmac_rx_ringbuffer_slot_clear] [get_bd_pins ethernetcore_mm_0/gmac_rx_ringbuffer_slot_clear]
  connect_bd_net -net ethernetcore_mm_0_gmac_rx_ringbuffer_slot_id [get_bd_ports gmac_rx_ringbuffer_slot_id] [get_bd_pins ethernetcore_mm_0/gmac_rx_ringbuffer_slot_id]
  connect_bd_net -net ethernetcore_mm_0_gmac_tx_data_read_address [get_bd_ports gmac_tx_data_read_address] [get_bd_pins ethernetcore_mm_0/gmac_tx_data_read_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_tx_data_read_enable [get_bd_ports gmac_tx_data_read_enable] [get_bd_pins ethernetcore_mm_0/gmac_tx_data_read_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_tx_data_write_address [get_bd_ports gmac_tx_data_write_address] [get_bd_pins ethernetcore_mm_0/gmac_tx_data_write_address]
  connect_bd_net -net ethernetcore_mm_0_gmac_tx_data_write_byte_enable [get_bd_ports gmac_tx_data_write_byte_enable] [get_bd_pins ethernetcore_mm_0/gmac_tx_data_write_byte_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_tx_data_write_data [get_bd_ports gmac_tx_data_write_data] [get_bd_pins ethernetcore_mm_0/gmac_tx_data_write_data]
  connect_bd_net -net ethernetcore_mm_0_gmac_tx_data_write_enable [get_bd_ports gmac_tx_data_write_enable] [get_bd_pins ethernetcore_mm_0/gmac_tx_data_write_enable]
  connect_bd_net -net ethernetcore_mm_0_gmac_tx_ringbuffer_slot_id [get_bd_ports gmac_tx_ringbuffer_slot_id] [get_bd_pins ethernetcore_mm_0/gmac_tx_ringbuffer_slot_id]
  connect_bd_net -net ethernetcore_mm_0_gmac_tx_ringbuffer_slot_set [get_bd_ports gmac_tx_ringbuffer_slot_set] [get_bd_pins ethernetcore_mm_0/gmac_tx_ringbuffer_slot_set]
  connect_bd_net -net ethernetcore_mm_0_irq [get_bd_pins ethernetcore_mm_0/irq] [get_bd_pins microblaze_0_xlconcat/In5]
  connect_bd_net -net gmac_arp_cache_read_data_0_1 [get_bd_ports gmac_arp_cache_read_data] [get_bd_pins ethernetcore_mm_0/gmac_arp_cache_read_data]
  connect_bd_net -net gmac_reg_arp_size_0_1 [get_bd_ports gmac_reg_arp_size] [get_bd_pins ethernetcore_mm_0/gmac_reg_arp_size]
  connect_bd_net -net gmac_reg_core_type_0_1 [get_bd_ports gmac_reg_core_type] [get_bd_pins ethernetcore_mm_0/gmac_reg_core_type]
  connect_bd_net -net gmac_reg_phy_status_h_0_1 [get_bd_ports gmac_reg_phy_status_h] [get_bd_pins ethernetcore_mm_0/gmac_reg_phy_status_h]
  connect_bd_net -net gmac_reg_phy_status_l_0_1 [get_bd_ports gmac_reg_phy_status_l] [get_bd_pins ethernetcore_mm_0/gmac_reg_phy_status_l]
  connect_bd_net -net gmac_reg_rx_almost_full_count_0_1 [get_bd_ports gmac_reg_rx_almost_full_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_almost_full_count]
  connect_bd_net -net gmac_reg_rx_bad_packet_count_0_1 [get_bd_ports gmac_reg_rx_bad_packet_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_bad_packet_count]
  connect_bd_net -net gmac_reg_rx_buffer_max_size_0_1 [get_bd_ports gmac_reg_rx_buffer_max_size] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_buffer_max_size]
  connect_bd_net -net gmac_reg_rx_overflow_count_0_1 [get_bd_ports gmac_reg_rx_overflow_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_overflow_count]
  connect_bd_net -net gmac_reg_rx_packet_count_0_1 [get_bd_ports gmac_reg_rx_packet_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_packet_count]
  connect_bd_net -net gmac_reg_rx_packet_rate_0_1 [get_bd_ports gmac_reg_rx_packet_rate] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_packet_rate]
  connect_bd_net -net gmac_reg_rx_valid_count_0_1 [get_bd_ports gmac_reg_rx_valid_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_valid_count]
  connect_bd_net -net gmac_reg_rx_valid_rate_0_1 [get_bd_ports gmac_reg_rx_valid_rate] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_valid_rate]
  connect_bd_net -net gmac_reg_rx_word_size_0_1 [get_bd_ports gmac_reg_rx_word_size] [get_bd_pins ethernetcore_mm_0/gmac_reg_rx_word_size]
  connect_bd_net -net gmac_reg_tx_afull_count_0_1 [get_bd_ports gmac_reg_tx_afull_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_tx_afull_count]
  connect_bd_net -net gmac_reg_tx_buffer_max_size_0_1 [get_bd_ports gmac_reg_tx_buffer_max_size] [get_bd_pins ethernetcore_mm_0/gmac_reg_tx_buffer_max_size]
  connect_bd_net -net gmac_reg_tx_overflow_count_0_1 [get_bd_ports gmac_reg_tx_overflow_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_tx_overflow_count]
  connect_bd_net -net gmac_reg_tx_packet_count_0_1 [get_bd_ports gmac_reg_tx_packet_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_tx_packet_count]
  connect_bd_net -net gmac_reg_tx_packet_rate_0_1 [get_bd_ports gmac_reg_tx_packet_rate] [get_bd_pins ethernetcore_mm_0/gmac_reg_tx_packet_rate]
  connect_bd_net -net gmac_reg_tx_valid_count_0_1 [get_bd_ports gmac_reg_tx_valid_count] [get_bd_pins ethernetcore_mm_0/gmac_reg_tx_valid_count]
  connect_bd_net -net gmac_reg_tx_valid_rate_0_1 [get_bd_ports gmac_reg_tx_valid_rate] [get_bd_pins ethernetcore_mm_0/gmac_reg_tx_valid_rate]
  connect_bd_net -net gmac_reg_tx_word_size_0_1 [get_bd_ports gmac_reg_tx_word_size] [get_bd_pins ethernetcore_mm_0/gmac_reg_tx_word_size]
  connect_bd_net -net gmac_rx_data_read_byte_enable_0_1 [get_bd_ports gmac_rx_data_read_byte_enable] [get_bd_pins ethernetcore_mm_0/gmac_rx_data_read_byte_enable]
  connect_bd_net -net gmac_rx_data_read_data_0_1 [get_bd_ports gmac_rx_data_read_data] [get_bd_pins ethernetcore_mm_0/gmac_rx_data_read_data]
  connect_bd_net -net gmac_rx_ringbuffer_number_slots_filled_0_1 [get_bd_ports gmac_rx_ringbuffer_number_slots_filled] [get_bd_pins ethernetcore_mm_0/gmac_rx_ringbuffer_number_slots_filled]
  connect_bd_net -net gmac_rx_ringbuffer_slot_status_0_1 [get_bd_ports gmac_rx_ringbuffer_slot_status] [get_bd_pins ethernetcore_mm_0/gmac_rx_ringbuffer_slot_status]
  connect_bd_net -net gmac_tx_data_read_byte_enable_0_1 [get_bd_ports gmac_tx_data_read_byte_enable] [get_bd_pins ethernetcore_mm_0/gmac_tx_data_read_byte_enable]
  connect_bd_net -net gmac_tx_data_read_data_0_1 [get_bd_ports gmac_tx_data_read_data] [get_bd_pins ethernetcore_mm_0/gmac_tx_data_read_data]
  connect_bd_net -net gmac_tx_ringbuffer_number_slots_filled_0_1 [get_bd_ports gmac_tx_ringbuffer_number_slots_filled] [get_bd_pins ethernetcore_mm_0/gmac_tx_ringbuffer_number_slots_filled]
  connect_bd_net -net gmac_tx_ringbuffer_slot_status_0_1 [get_bd_ports gmac_tx_ringbuffer_slot_status] [get_bd_pins ethernetcore_mm_0/gmac_tx_ringbuffer_slot_status]
  connect_bd_net -net mdm_0_Interrupt [get_bd_pins mdm_0/Interrupt] [get_bd_pins microblaze_0_xlconcat/In4]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_0/Debug_SYS_Rst] [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_ports PSClock] [get_bd_pins axi_timebase_wdt_0/s_axi_aclk] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins ethernetcore_mm_0/s00_axi_aclk] [get_bd_pins ethernetcore_mm_0/s01_axi_aclk] [get_bd_pins ethernetcore_mm_0/s02_axi_aclk] [get_bd_pins ethernetcore_mm_0/s03_axi_aclk] [get_bd_pins ethernetcore_mm_0/s_axi_intr_aclk] [get_bd_pins mdm_0/M_AXI_ACLK] [get_bd_pins mdm_0/S_AXI_ACLK] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_intc/processor_clk] [get_bd_pins microblaze_0_axi_intc/s_axi_aclk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/M08_ACLK] [get_bd_pins microblaze_0_axi_periph/M09_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_axi_periph/S01_ACLK] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net microblaze_0_intr [get_bd_pins microblaze_0_axi_intc/intr] [get_bd_pins microblaze_0_xlconcat/dout]
  connect_bd_net -net proc_sys_reset_0_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins proc_sys_reset_0/bus_struct_reset]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net proc_sys_reset_0_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins microblaze_0_axi_intc/processor_rst] [get_bd_pins proc_sys_reset_0/mb_reset]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins axi_timebase_wdt_0/s_axi_aresetn] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins ethernetcore_mm_0/s00_axi_aresetn] [get_bd_pins ethernetcore_mm_0/s01_axi_aresetn] [get_bd_pins ethernetcore_mm_0/s02_axi_aresetn] [get_bd_pins ethernetcore_mm_0/s03_axi_aresetn] [get_bd_pins ethernetcore_mm_0/s_axi_intr_aresetn] [get_bd_pins mdm_0/M_AXI_ARESETN] [get_bd_pins mdm_0/S_AXI_ARESETN] [get_bd_pins microblaze_0_axi_intc/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/M08_ARESETN] [get_bd_pins microblaze_0_axi_periph/M09_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins microblaze_0_axi_periph/S01_ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x41A00000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_timebase_wdt_0/S_AXI/Reg] SEG_axi_timebase_wdt_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C00000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S00_AXI/S00_AXI_reg] SEG_ethernetcore_mm_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x76000000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S01_AXI/S01_AXI_mem] SEG_ethernetcore_mm_0_S01_AXI_mem
  create_bd_addr_seg -range 0x00010000 -offset 0x76010000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S02_AXI/S02_AXI_mem] SEG_ethernetcore_mm_0_S02_AXI_mem
  create_bd_addr_seg -range 0x00010000 -offset 0x76020000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S03_AXI/S03_AXI_mem] SEG_ethernetcore_mm_0_S03_AXI_mem
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S_AXI_INTR/S_AXI_INTR_reg] SEG_ethernetcore_mm_0_S_AXI_INTR_reg
  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs mdm_0/S_AXI/Reg] SEG_mdm_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces mdm_0/Data] [get_bd_addr_segs microblaze_0_axi_intc/S_AXI/Reg] SEG_microblaze_0_axi_intc_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timebase_wdt_0/S_AXI/Reg] SEG_axi_timebase_wdt_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41C00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] SEG_axi_timer_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40600000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] SEG_axi_uartlite_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S00_AXI/S00_AXI_reg] SEG_ethernetcore_mm_0_S00_AXI_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x76000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S01_AXI/S01_AXI_mem] SEG_ethernetcore_mm_0_S01_AXI_mem
  create_bd_addr_seg -range 0x00010000 -offset 0x76010000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S02_AXI/S02_AXI_mem] SEG_ethernetcore_mm_0_S02_AXI_mem
  create_bd_addr_seg -range 0x00010000 -offset 0x76020000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S03_AXI/S03_AXI_mem] SEG_ethernetcore_mm_0_S03_AXI_mem
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs ethernetcore_mm_0/S_AXI_INTR/S_AXI_INTR_reg] SEG_ethernetcore_mm_0_S_AXI_INTR_reg
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mdm_0/S_AXI/Reg] SEG_mdm_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x41200000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_axi_intc/S_AXI/Reg] SEG_microblaze_0_axi_intc_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


