--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
--Date        : Sun Mar 31 07:22:06 2019
--Host        : benjamin-ubuntu-ws running 64-bit Ubuntu 16.04.5 LTS
--Command     : generate_target pciexdma_refbd_wrapper.bd
--Design      : pciexdma_refbd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity pciexdma_refbd_wrapper is
  port (
    GPIO2_0_tri_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    GPIO_0_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_0_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXIS_0_tlast : out STD_LOGIC;
    M_AXIS_0_tready : in STD_LOGIC;
    M_AXIS_0_tvalid : out STD_LOGIC;
    m_axis_aclk_0 : in STD_LOGIC;
    m_axis_aresetn_0 : in STD_LOGIC;
    pcie_mgt_0_rxn : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_rxp : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_txn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_txp : out STD_LOGIC_VECTOR ( 7 downto 0 );
    sys_clk_0 : in STD_LOGIC;
    sys_clk_gt_0 : in STD_LOGIC;
    sys_rst_n_0 : in STD_LOGIC;
    user_lnk_up_0 : out STD_LOGIC
  );
end pciexdma_refbd_wrapper;

architecture STRUCTURE of pciexdma_refbd_wrapper is
  component pciexdma_refbd is
  port (
    m_axis_aclk_0 : in STD_LOGIC;
    m_axis_aresetn_0 : in STD_LOGIC;
    sys_clk_0 : in STD_LOGIC;
    sys_clk_gt_0 : in STD_LOGIC;
    sys_rst_n_0 : in STD_LOGIC;
    user_lnk_up_0 : out STD_LOGIC;
    GPIO2_0_tri_i : in STD_LOGIC_VECTOR ( 31 downto 0 );
    GPIO_0_tri_o : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_0_tvalid : out STD_LOGIC;
    M_AXIS_0_tready : in STD_LOGIC;
    M_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_0_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXIS_0_tlast : out STD_LOGIC;
    pcie_mgt_0_rxn : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_rxp : in STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_txn : out STD_LOGIC_VECTOR ( 7 downto 0 );
    pcie_mgt_0_txp : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  end component pciexdma_refbd;
begin
pciexdma_refbd_i: component pciexdma_refbd
     port map (
      GPIO2_0_tri_i(31 downto 0) => GPIO2_0_tri_i(31 downto 0),
      GPIO_0_tri_o(31 downto 0) => GPIO_0_tri_o(31 downto 0),
      M_AXIS_0_tdata(31 downto 0) => M_AXIS_0_tdata(31 downto 0),
      M_AXIS_0_tkeep(3 downto 0) => M_AXIS_0_tkeep(3 downto 0),
      M_AXIS_0_tlast => M_AXIS_0_tlast,
      M_AXIS_0_tready => M_AXIS_0_tready,
      M_AXIS_0_tvalid => M_AXIS_0_tvalid,
      m_axis_aclk_0 => m_axis_aclk_0,
      m_axis_aresetn_0 => m_axis_aresetn_0,
      pcie_mgt_0_rxn(7 downto 0) => pcie_mgt_0_rxn(7 downto 0),
      pcie_mgt_0_rxp(7 downto 0) => pcie_mgt_0_rxp(7 downto 0),
      pcie_mgt_0_txn(7 downto 0) => pcie_mgt_0_txn(7 downto 0),
      pcie_mgt_0_txp(7 downto 0) => pcie_mgt_0_txp(7 downto 0),
      sys_clk_0 => sys_clk_0,
      sys_clk_gt_0 => sys_clk_gt_0,
      sys_rst_n_0 => sys_rst_n_0,
      user_lnk_up_0 => user_lnk_up_0
    );
end STRUCTURE;
