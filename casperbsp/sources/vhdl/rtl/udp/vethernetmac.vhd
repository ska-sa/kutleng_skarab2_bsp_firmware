--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : vethernetmac - rtl                                       -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module instantiates two QSFP28+ ports with CMACs.   -
--                    The udpipinterfacepr module is instantiated to connect   -
--                    UDP functionality on QSFP28+[1].                         -
--                    To test bandwidth the testcomms module is instantiated on-
--                    QSFP28+[2].                                              -
-- Dependencies     : 														   -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity vethernetmac is
    generic(
        C_VMAC_ADDRESS : STD_LOGIC_VECTOR(47 downto 0)
    );
    port(
        ------------------------------------------------------------------------
        -- These signals/busses run at 322.265625MHz clock domain              -
        ------------------------------------------------------------------------
        -- Global System Enable
        Enable                       : in  STD_LOGIC;
        Reset                        : in  STD_LOGIC;
        vmac_register_data_out       : in  STD_LOGIC_VECTOR(31 downto 0);
        vmac_register_data_in        : out STD_LOGIC_VECTOR(31 downto 0);
        vmac_register_address        : out STD_LOGIC_VECTOR(3 downto 0);
        vmac_register_control        : out STD_LOGIC_VECTOR(1 downto 0);
        -- Statistics interface
        gmac_reg_core_type           : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_status_h        : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_status_l        : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_control_h       : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_control_l       : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_packet_rate      : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_packet_count     : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_valid_rate       : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_valid_count      : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_packet_rate      : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_packet_count     : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_valid_rate       : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_valid_count      : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_bad_packet_count : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_counters_reset      : in  STD_LOGIC;
        pcie_axis_rx_tdata           : in  STD_LOGIC_VECTOR(511 downto 0);
        pcie_axis_rx_tvalid          : in  STD_LOGIC;
        pcie_axis_rx_tready          : out STD_LOGIC;
        pcie_axis_rx_tkeep           : in  STD_LOGIC_VECTOR(63 downto 0);
        pcie_axis_rx_tlast           : in  STD_LOGIC;
        pcie_axis_tx_tdata           : out STD_LOGIC_VECTOR(511 downto 0);
        pcie_axis_tx_tvalid          : out STD_LOGIC;
        pcie_axis_tx_tready          : in  STD_LOGIC;
        pcie_axis_tx_tkeep           : out STD_LOGIC_VECTOR(63 downto 0);
        pcie_axis_tx_tlast           : out STD_LOGIC;
        -- AXIS Bus
        -- RX Bus
        ethernet_axis_rx_tdata       : in  STD_LOGIC_VECTOR(511 downto 0);
        ethernet_axis_rx_tvalid      : in  STD_LOGIC;
        ethernet_axis_rx_tready      : out STD_LOGIC;
        ethernet_axis_rx_tkeep       : in  STD_LOGIC_VECTOR(63 downto 0);
        ethernet_axis_rx_tlast       : in  STD_LOGIC;
        ethernet_axis_rx_tuser       : in  STD_LOGIC;
        -- TX Bus
        ethernet_axis_tx_tdata       : out STD_LOGIC_VECTOR(511 downto 0);
        ethernet_axis_tx_tvalid      : out STD_LOGIC;
        ethernet_axis_tx_tkeep       : out STD_LOGIC_VECTOR(63 downto 0);
        ethernet_axis_tx_tlast       : out STD_LOGIC;
        -- User signal for errors and dropping of packets
        ethernet_axis_tx_tuser       : out STD_LOGIC
    );

end entity vethernetmac;

architecture rtl of vethernetmac is
begin
end architecture rtl;

