# Proc to create BD pciexdma_refbd
proc cr_bd_pciexdma_refbd { parentCell } {

  # CHANGE DESIGN NAME HERE
  set design_name pciexdma_refbd

  common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

  create_bd_design $design_name

  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\ 
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:axis_data_fifo:*\
xilinx.com:ip:axis_dwidth_converter:*\
xilinx.com:ip:system_ila:*\
xilinx.com:ip:xdma:*\
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

  variable script_folder

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
  set GPIO2_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 GPIO2_0 ]
  set GPIO_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 GPIO_0 ]
  set M_AXIS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_0 ]
  set pcie_mgt_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt_0 ]

  # Create ports
  set m_axis_aclk_0 [ create_bd_port -dir I -type clk m_axis_aclk_0 ]
  set m_axis_aresetn_0 [ create_bd_port -dir I -type rst m_axis_aresetn_0 ]
  set sys_clk_0 [ create_bd_port -dir I -type clk sys_clk_0 ]
  set sys_clk_gt_0 [ create_bd_port -dir I -type clk sys_clk_gt_0 ]
  set sys_rst_n_0 [ create_bd_port -dir I -type rst sys_rst_n_0 ]
  set user_lnk_up_0 [ create_bd_port -dir O user_lnk_up_0 ]

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {0} \
   CONFIG.C_ALL_INPUTS_2 {1} \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_DOUT_DEFAULT {0x00000001} \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.NUM_MI {1} \
 ] $axi_interconnect_0

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_0 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {16} \
   CONFIG.IS_ACLK_ASYNC {1} \
 ] $axis_data_fifo_0

  # Create instance: axis_dwidth_converter_0, and set properties
  set axis_dwidth_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_dwidth_converter axis_dwidth_converter_0 ]
  set_property -dict [ list \
   CONFIG.M_TDATA_NUM_BYTES {4} \
   CONFIG.S_TDATA_NUM_BYTES {32} \
 ] $axis_dwidth_converter_0

  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila system_ila_0 ]
  set_property -dict [ list \
   CONFIG.C_MON_TYPE {INTERFACE} \
   CONFIG.C_NUM_MONITOR_SLOTS {1} \
   CONFIG.C_SLOT_0_APC_EN {0} \
   CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
   CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
   CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
 ] $system_ila_0

  # Create instance: system_ila_1, and set properties
  set system_ila_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila system_ila_1 ]
  set_property -dict [ list \
   CONFIG.C_MON_TYPE {INTERFACE} \
   CONFIG.C_NUM_MONITOR_SLOTS {1} \
   CONFIG.C_SLOT_0_APC_EN {0} \
   CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
   CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
   CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
 ] $system_ila_1

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma xdma_0 ]
  set_property -dict [ list \
   CONFIG.PCIE_BOARD_INTERFACE {pci_express_x8} \
   CONFIG.PF0_DEVICE_ID_mqdma {9038} \
   CONFIG.PF2_DEVICE_ID_mqdma {9038} \
   CONFIG.PF3_DEVICE_ID_mqdma {9038} \
   CONFIG.axi_data_width {256_bit} \
   CONFIG.axilite_master_en {true} \
   CONFIG.mode_selection {Advanced} \
   CONFIG.pf0_Use_Class_Code_Lookup_Assistant {true} \
   CONFIG.pf0_base_class_menu {Memory_controller} \
   CONFIG.pf0_device_id {9038} \
   CONFIG.pf0_sub_class_interface_menu {Other_memory_controller} \
   CONFIG.pl_link_cap_max_link_speed {8.0_GT/s} \
   CONFIG.plltype {QPLL1} \
   CONFIG.xdma_axi_intf_mm {AXI_Stream} \
   CONFIG.xdma_rnum_chnl {2} \
 ] $xdma_0

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins xdma_0/M_AXI_LITE]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports GPIO_0] [get_bd_intf_pins axi_gpio_0/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO2 [get_bd_intf_ports GPIO2_0] [get_bd_intf_pins axi_gpio_0/GPIO2]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins axis_dwidth_converter_0/S_AXIS]
connect_bd_intf_net -intf_net [get_bd_intf_nets axis_data_fifo_0_M_AXIS] [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins system_ila_1/SLOT_0_AXIS]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_intf_nets axis_data_fifo_0_M_AXIS]
  connect_bd_intf_net -intf_net axis_dwidth_converter_0_M_AXIS [get_bd_intf_ports M_AXIS_0] [get_bd_intf_pins axis_dwidth_converter_0/M_AXIS]
  connect_bd_intf_net -intf_net xdma_0_M_AXIS_H2C_1 [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins xdma_0/M_AXIS_H2C_1]
connect_bd_intf_net -intf_net [get_bd_intf_nets xdma_0_M_AXIS_H2C_1] [get_bd_intf_pins system_ila_0/SLOT_0_AXIS] [get_bd_intf_pins xdma_0/M_AXIS_H2C_1]
  set_property -dict [ list \
HDL_ATTRIBUTE.DEBUG {true} \
 ] [get_bd_intf_nets xdma_0_M_AXIS_H2C_1]
  connect_bd_intf_net -intf_net xdma_0_M_AXIS_H2C_2 [get_bd_intf_pins xdma_0/M_AXIS_H2C_0] [get_bd_intf_pins xdma_0/S_AXIS_C2H_0]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_mgt_0] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins system_ila_0/resetn] [get_bd_pins xdma_0/axi_aresetn]
  connect_bd_net -net m_axis_aclk_0_1 [get_bd_ports m_axis_aclk_0] [get_bd_pins axis_data_fifo_0/m_axis_aclk] [get_bd_pins axis_dwidth_converter_0/aclk] [get_bd_pins system_ila_1/clk]
  connect_bd_net -net m_axis_aresetn_0_1 [get_bd_ports m_axis_aresetn_0] [get_bd_pins axis_data_fifo_0/m_axis_aresetn] [get_bd_pins axis_dwidth_converter_0/aresetn] [get_bd_pins system_ila_1/resetn]
  connect_bd_net -net sys_clk_0_1 [get_bd_ports sys_clk_0] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net sys_clk_gt_0_1 [get_bd_ports sys_clk_gt_0] [get_bd_pins xdma_0/sys_clk_gt]
  connect_bd_net -net sys_rst_n_0_1 [get_bd_ports sys_rst_n_0] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins system_ila_0/clk] [get_bd_pins xdma_0/axi_aclk]
  connect_bd_net -net xdma_0_user_lnk_up [get_bd_ports user_lnk_up_0] [get_bd_pins xdma_0/user_lnk_up]

  # Create address segments
  create_bd_addr_seg -range 0x00010000 -offset 0x00000000 [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

  close_bd_design $design_name 
}
# End of cr_bd_pciexdma_refbd()
cr_bd_pciexdma_refbd ""
set_property SYNTH_CHECKPOINT_MODE "Hierarchical" [get_files pciexdma_refbd.bd ] 
