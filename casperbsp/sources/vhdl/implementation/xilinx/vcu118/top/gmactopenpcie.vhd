--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : gmactop - rtl                                            -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module instantiates two QSFP28+ ports with CMACs.   -
--                    The udpipinterfacepr module is instantiated to connect   -
--                    UDP functionality on QSFP28+[1].                         -
--                    To test bandwidth the testcomms module is instantiated on-
--                    QSFP28+[2].                                              -
-- Dependencies     : mac100gphy,microblaze_axi_us_plus_wrapper,clockgen100mhz,-
--                    testcomms,udpipinterfacepr,pciexdma_refbd_wrapper.       -
--                    partialblinker,ledflasher,ICAP3E                         -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity gmactop is
    port(
        -- Reference clock to generate 100MHz from
        sysclk1_300_p     : in  STD_LOGIC;
        sysclk1_300_n     : in  STD_LOGIC;
        -- Ethernet reference clock for 156.25MHz
        -- QSFP+ 1
        mgt_qsfp1_clock_p : in  STD_LOGIC;
        mgt_qsfp1_clock_n : in  STD_LOGIC;
        -- QSFP+ 2
        mgt_qsfp2_clock_p : in  STD_LOGIC;
        mgt_qsfp2_clock_n : in  STD_LOGIC;
        --RX     
        qsfp1_mgt_rx_p    : in  STD_LOGIC_VECTOR(3 downto 0);
        qsfp1_mgt_rx_n    : in  STD_LOGIC_VECTOR(3 downto 0);
        -- TX
        qsfp1_mgt_tx_p    : out STD_LOGIC_VECTOR(3 downto 0);
        qsfp1_mgt_tx_n    : out STD_LOGIC_VECTOR(3 downto 0);
        -- Settings
        qsfp1_modsell_ls  : out STD_LOGIC;
        qsfp1_resetl_ls   : out STD_LOGIC;
        qsfp1_modprsl_ls  : in  STD_LOGIC;
        qsfp1_intl_ls     : in  STD_LOGIC;
        qsfp1_lpmode_ls   : out STD_LOGIC;
        -- QSFP+ 2
        --RX     
        qsfp2_mgt_rx_p    : in  STD_LOGIC_VECTOR(3 downto 0);
        qsfp2_mgt_rx_n    : in  STD_LOGIC_VECTOR(3 downto 0);
        -- TX
        qsfp2_mgt_tx_p    : out STD_LOGIC_VECTOR(3 downto 0);
        qsfp2_mgt_tx_n    : out STD_LOGIC_VECTOR(3 downto 0);
        -- Settings
        qsfp2_modsell_ls  : out STD_LOGIC;
        qsfp2_resetl_ls   : out STD_LOGIC;
        qsfp2_modprsl_ls  : in  STD_LOGIC;
        qsfp2_intl_ls     : in  STD_LOGIC;
        qsfp2_lpmode_ls   : out STD_LOGIC;
        -- PCIe Clocks        
        sys_clk_p         : in  STD_LOGIC;
        sys_clk_n         : in  STD_LOGIC;
        sys_rst_n         : in  STD_LOGIC;
        -- PCIe Data signals
        pci_exp_txp       : out STD_LOGIC_VECTOR(7 downto 0);
        pci_exp_txn       : out STD_LOGIC_VECTOR(7 downto 0);
        pci_exp_rxp       : in  STD_LOGIC_VECTOR(7 downto 0);
        pci_exp_rxn       : in  STD_LOGIC_VECTOR(7 downto 0);
        -- UART I/O
        rs232_uart_rxd    : in  STD_LOGIC;
        rs232_uart_txd    : out STD_LOGIC;
        --        
        partial_bit_leds  : out STD_LOGIC_VECTOR(3 downto 0);
        -- LEDs for debug     
        blink_led         : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity gmactop;

architecture rtl of gmactop is
    -- If partial reconfiguration is not desired set this variable to false.
    constant C_INCLUDE_ICAP               : boolean                          := true;
    --    constant C_EMAC_ADDR_1                : std_logic_vector(47 downto 0)    := X"000A_3502_4192";
    constant C_EMAC_ADDR_2                : std_logic_vector(47 downto 0)    := X"000A_3502_4194";
    --    constant C_IP_ADDR_1                  : std_logic_vector(31 downto 0)    := X"C0A8_640A"; --192.168.100.10
    constant C_IP_ADDR_2                  : std_logic_vector(31 downto 0)    := X"C0A8_640F"; --192.168.100.15
    constant C_UDP_SERVER_PORT            : natural range 0 to ((2**16) - 1) := 10000;
    constant C_PR_SERVER_PORT             : natural range 0 to ((2**16) - 1) := 20000;
    constant C_ARP_CACHE_ASIZE            : natural                          := 10;
    constant C_CPU_TX_DATA_BUFFER_ASIZE   : natural                          := 11;
    constant C_CPU_RX_DATA_BUFFER_ASIZE   : natural                          := 11;
    constant C_SLOT_WIDTH                 : natural                          := 4;
    constant C_NUM_STREAMING_DATA_SERVERS : natural range 1 to 4             := 1;
    constant C_ARP_DATA_WIDTH             : natural                          := 32;
    constant C_AXIS_DATA_WIDTH            : natural                          := 512;

    component pciexdma_refbd_wrapper is
        port(
            GPIO2_0_tri_i    : in  STD_LOGIC_VECTOR(31 downto 0);
            GPIO_0_tri_o     : out STD_LOGIC_VECTOR(31 downto 0);
            M_AXIS_0_tdata   : out STD_LOGIC_VECTOR(31 downto 0);
            M_AXIS_0_tkeep   : out STD_LOGIC_VECTOR(3 downto 0);
            M_AXIS_0_tlast   : out STD_LOGIC;
            M_AXIS_0_tready  : in  STD_LOGIC;
            M_AXIS_0_tvalid  : out STD_LOGIC;
            m_axis_aclk_0    : in  STD_LOGIC;
            m_axis_aresetn_0 : in  STD_LOGIC;
            pcie_mgt_0_rxn   : in  STD_LOGIC_VECTOR(7 downto 0);
            pcie_mgt_0_rxp   : in  STD_LOGIC_VECTOR(7 downto 0);
            pcie_mgt_0_txn   : out STD_LOGIC_VECTOR(7 downto 0);
            pcie_mgt_0_txp   : out STD_LOGIC_VECTOR(7 downto 0);
            sys_clk_0        : in  STD_LOGIC;
            sys_clk_gt_0     : in  STD_LOGIC;
            sys_rst_n_0      : in  STD_LOGIC;
            user_lnk_up_0    : out STD_LOGIC
        );
    end component pciexdma_refbd_wrapper;

    component udpipinterfacepr is
        generic(
            G_INCLUDE_ICAP               : boolean                          := false;
            G_AXIS_DATA_WIDTH            : natural                          := 512;
            G_SLOT_WIDTH                 : natural                          := 4;
            -- Number of UDP Streaming Data Server Modules 
            G_NUM_STREAMING_DATA_SERVERS : natural range 1 to 4             := 1;
            G_ARP_CACHE_ASIZE            : natural                          := 13;
            G_ARP_DATA_WIDTH             : natural                          := 32;
            G_CPU_TX_DATA_BUFFER_ASIZE   : natural                          := 13;
            G_CPU_RX_DATA_BUFFER_ASIZE   : natural                          := 13;
            G_PR_SERVER_PORT             : natural range 0 to ((2**16) - 1) := 5
        );
        port(
            -- Axis clock is the Ethernet module clock running at 322.625MHz
            axis_clk                                     : in  STD_LOGIC;
            -- Aximm clock is the AXI Lite MM clock for the gmac register interface
            -- Usually 50MHz 
            aximm_clk                                    : in  STD_LOGIC;
            -- ICAP is the 125MHz ICAP clock used for PR
            icap_clk                                     : in  STD_LOGIC;
            -- Axis reset is the global synchronous reset to the highest clock
            axis_reset                                   : in  STD_LOGIC;
            ------------------------------------------------------------------------
            -- AXILite slave Interface                                            --
            -- This interface is for register access as per CASPER Ethernet Core  --
            -- memory map, this core has mac & phy registers, arp cache and also  --
            -- cpu transmit and receive buffers                                   --
            ------------------------------------------------------------------------
            aximm_gmac_reg_phy_control_h                 : in  STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_phy_control_l                 : in  STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_mac_address                   : in  STD_LOGIC_VECTOR(47 downto 0);
            aximm_gmac_reg_local_ip_address              : in  STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_gateway_ip_address            : in  STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_multicast_ip_address          : in  STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_multicast_ip_mask             : in  STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_udp_port                      : in  STD_LOGIC_VECTOR(15 downto 0);
            aximm_gmac_reg_udp_port_mask                 : in  STD_LOGIC_VECTOR(15 downto 0);
            aximm_gmac_reg_mac_enable                    : in  STD_LOGIC;
            aximm_gmac_reg_mac_promiscous_mode           : in  STD_LOGIC;
            aximm_gmac_reg_counters_reset                : in  STD_LOGIC;
            aximm_gmac_reg_core_type                     : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_phy_status_h                  : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_phy_status_l                  : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_tx_packet_rate                : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_tx_packet_count               : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_tx_valid_rate                 : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_tx_valid_count                : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_tx_overflow_count             : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_tx_afull_count                : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_rx_packet_rate                : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_rx_packet_count               : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_rx_valid_rate                 : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_rx_valid_count                : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_rx_overflow_count             : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_rx_almost_full_count          : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_rx_bad_packet_count           : out STD_LOGIC_VECTOR(31 downto 0);
            --
            aximm_gmac_reg_arp_size                      : out STD_LOGIC_VECTOR(31 downto 0);
            aximm_gmac_reg_tx_word_size                  : out STD_LOGIC_VECTOR(15 downto 0);
            aximm_gmac_reg_rx_word_size                  : out STD_LOGIC_VECTOR(15 downto 0);
            aximm_gmac_reg_tx_buffer_max_size            : out STD_LOGIC_VECTOR(15 downto 0);
            aximm_gmac_reg_rx_buffer_max_size            : out STD_LOGIC_VECTOR(15 downto 0);
            ------------------------------------------------------------------------
            -- ARP Cache Write Interface according to EthernetCore Memory MAP     --
            ------------------------------------------------------------------------ 
            aximm_gmac_arp_cache_write_enable            : in  STD_LOGIC;
            aximm_gmac_arp_cache_read_enable             : in  STD_LOGIC;
            aximm_gmac_arp_cache_write_data              : in  STD_LOGIC_VECTOR(G_ARP_DATA_WIDTH - 1 downto 0);
            aximm_gmac_arp_cache_read_data               : out STD_LOGIC_VECTOR(G_ARP_DATA_WIDTH - 1 downto 0);
            aximm_gmac_arp_cache_write_address           : in  STD_LOGIC_VECTOR(G_ARP_CACHE_ASIZE - 1 downto 0);
            aximm_gmac_arp_cache_read_address            : in  STD_LOGIC_VECTOR(G_ARP_CACHE_ASIZE - 1 downto 0);
            ------------------------------------------------------------------------
            -- Transmit Ring Buffer Interface according to EthernetCore Memory MAP--
            ------------------------------------------------------------------------ 
            aximm_gmac_tx_data_write_enable              : in  STD_LOGIC;
            aximm_gmac_tx_data_read_enable               : in  STD_LOGIC;
            aximm_gmac_tx_data_write_data                : in  STD_LOGIC_VECTOR(7 downto 0);
            -- The Byte Enable is as follows
            -- Bit (0-1) Byte Enables
            -- Bit (2) Maps to TLAST (To terminate the data stream).
            aximm_gmac_tx_data_write_byte_enable         : in  STD_LOGIC_VECTOR(1 downto 0);
            aximm_gmac_tx_data_read_data                 : out STD_LOGIC_VECTOR(7 downto 0);
            -- The Byte Enable is as follows
            -- Bit (0-1) Byte Enables
            -- Bit (2) Maps to TLAST (To terminate the data stream).
            aximm_gmac_tx_data_read_byte_enable          : out STD_LOGIC_VECTOR(1 downto 0);
            aximm_gmac_tx_data_write_address             : in  STD_LOGIC_VECTOR(G_CPU_TX_DATA_BUFFER_ASIZE - 1 downto 0);
            aximm_gmac_tx_data_read_address              : in  STD_LOGIC_VECTOR(G_CPU_TX_DATA_BUFFER_ASIZE - 1 downto 0);
            aximm_gmac_tx_ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            aximm_gmac_tx_ringbuffer_slot_set            : in  STD_LOGIC;
            aximm_gmac_tx_ringbuffer_slot_status         : out STD_LOGIC;
            aximm_gmac_tx_ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            ------------------------------------------------------------------------
            -- Receive Ring Buffer Interface according to EthernetCore Memory MAP --
            ------------------------------------------------------------------------ 
            aximm_gmac_rx_data_read_enable               : in  STD_LOGIC;
            aximm_gmac_rx_data_read_data                 : out STD_LOGIC_VECTOR(7 downto 0);
            -- The Byte Enable is as follows
            -- Bit (0-1) Byte Enables
            -- Bit (2) Maps to TLAST (To terminate the data stream).        
            aximm_gmac_rx_data_read_byte_enable          : out STD_LOGIC_VECTOR(1 downto 0);
            aximm_gmac_rx_data_read_address              : in  STD_LOGIC_VECTOR(G_CPU_RX_DATA_BUFFER_ASIZE - 1 downto 0);
            aximm_gmac_rx_ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            aximm_gmac_rx_ringbuffer_slot_clear          : in  STD_LOGIC;
            aximm_gmac_rx_ringbuffer_slot_status         : out STD_LOGIC;
            aximm_gmac_rx_ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            ------------------------------------------------------------------------
            -- Yellow Block Data Interface                                        --
            -- These can be many AXIS interfaces denoted by axis_data{n}_tx/rx    --
            -- where {n} = G_NUM_STREAMING_DATA_SERVERS.                          --
            -- Each of them run on their own clock.                               --
            -- Aggregate data rate for all modules combined must be less than 100G--                                --
            -- Each module in a PR configuration makes a PR boundary.             --
            ------------------------------------------------------------------------
            -- Streaming data clocks 
            axis_streaming_data_clk                      : in  STD_LOGIC_VECTOR(G_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
            axis_streaming_data_rx_packet_length         : out STD_LOGIC_VECTOR((16 * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);         
            
            -- Streaming data outputs to AXIS of the Yellow Blocks
            axis_streaming_data_rx_tdata                 : out STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_rx_tvalid                : out STD_LOGIC_VECTOR(G_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
            axis_streaming_data_rx_tready                : in  STD_LOGIC_VECTOR(G_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
            axis_streaming_data_rx_tkeep                 : out STD_LOGIC_VECTOR(((G_AXIS_DATA_WIDTH / 8) * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_rx_tlast                 : out STD_LOGIC_VECTOR(G_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
            axis_streaming_data_rx_tuser                 : out STD_LOGIC_VECTOR(G_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
            --Data inputs from AXIS bus of the Yellow Blocks
            axis_streaming_data_tx_destination_ip        : in  STD_LOGIC_VECTOR((32 * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_tx_destination_udp_port  : in  STD_LOGIC_VECTOR((16 * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_tx_source_udp_port       : in  STD_LOGIC_VECTOR((16 * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_tx_packet_length         : in  STD_LOGIC_VECTOR((16 * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);                                 
            axis_streaming_data_tx_tdata                 : in  STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_tx_tvalid                : in  STD_LOGIC_VECTOR((G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_tx_tuser                 : in  STD_LOGIC_VECTOR((G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_tx_tkeep                 : in  STD_LOGIC_VECTOR(((G_AXIS_DATA_WIDTH / 8) * G_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
            axis_streaming_data_tx_tlast                 : in  STD_LOGIC_VECTOR(G_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
            axis_streaming_data_tx_tready                : out STD_LOGIC_VECTOR(G_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
            ------------------------------------------------------------------------
            -- Ethernet MAC/PHY Control and Statistics Interface                  --
            ------------------------------------------------------------------------
            gmac_reg_core_type                           : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_status_h                        : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_status_l                        : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_control_h                       : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_control_l                       : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_packet_rate                      : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_packet_count                     : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_valid_rate                       : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_valid_count                      : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_packet_rate                      : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_packet_count                     : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_valid_rate                       : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_valid_count                      : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_bad_packet_count                 : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_counters_reset                      : out STD_LOGIC;
            gmac_reg_mac_enable                          : out STD_LOGIC;
            ------------------------------------------------------------------------
            -- Ethernet MAC Streaming Interface                                   --
            ------------------------------------------------------------------------
            -- Outputs to AXIS bus MAC side 
            axis_tx_tdata                                : out STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
            axis_tx_tvalid                               : out STD_LOGIC;
            axis_tx_tready                               : in  STD_LOGIC;
            axis_tx_tkeep                                : out STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
            axis_tx_tlast                                : out STD_LOGIC;
            axis_tx_tuser                                : out STD_LOGIC;
            --Inputs from AXIS bus of the MAC side
            axis_rx_tdata                                : in  STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
            axis_rx_tvalid                               : in  STD_LOGIC;
            axis_rx_tuser                                : in  STD_LOGIC;
            axis_rx_tkeep                                : in  STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
            axis_rx_tlast                                : in  STD_LOGIC
        );
    end component udpipinterfacepr;

    component testcomms is
        generic(
            G_DATA_WIDTH      : natural                          := 512;
            G_EMAC_ADDR       : std_logic_vector(47 downto 0)    := X"000A_3502_4194";
            G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
            G_IP_ADDR         : std_logic_vector(31 downto 0)    := X"C0A8_0A0A" --192.168.10.10

        );
        port(
            axis_clk       : in  STD_LOGIC;
            axis_reset     : in  STD_LOGIC;
            --Outputs to AXIS bus MAC side 
            axis_tx_tdata  : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
            axis_tx_tvalid : out STD_LOGIC;
            axis_tx_tready : in  STD_LOGIC;
            axis_tx_tkeep  : out STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
            axis_tx_tlast  : out STD_LOGIC;
            axis_tx_tuser  : out STD_LOGIC;
            --Inputs from AXIS bus of the MAC side
            axis_rx_tdata  : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
            axis_rx_tvalid : in  STD_LOGIC;
            axis_rx_tuser  : in  STD_LOGIC;
            axis_rx_tkeep  : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
            axis_rx_tlast  : in  STD_LOGIC
        );
    end component testcomms;

    component mac100gphy is
        generic(
            C_MAC_INSTANCE : natural range 0 to 1 := 0
        );
        port(
            -- Ethernet reference clock for 156.25MHz
            -- QSFP+ 
            mgt_qsfp_clock_p             : in  STD_LOGIC;
            mgt_qsfp_clock_n             : in  STD_LOGIC;
            --RX     
            qsfp_mgt_rx_p                : in  STD_LOGIC_VECTOR(3 downto 0);
            qsfp_mgt_rx_n                : in  STD_LOGIC_VECTOR(3 downto 0);
            -- TX
            qsfp_mgt_tx_p                : out STD_LOGIC_VECTOR(3 downto 0);
            qsfp_mgt_tx_n                : out STD_LOGIC_VECTOR(3 downto 0);
            -- Reference clock to generate 100MHz from
            Clk100MHz                    : in  STD_LOGIC;
            ------------------------------------------------------------------------
            -- These signals/busses run at 322.265625MHz clock domain              -
            ------------------------------------------------------------------------
            -- Global System Enable
            Enable                       : in  STD_LOGIC;
            Reset                        : in  STD_LOGIC;
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
            -- Lbus and AXIS
            lbus_reset                   : in  STD_LOGIC;
            -- Overflow signal
            lbus_tx_ovfout               : out STD_LOGIC;
            -- Underflow signal
            lbus_tx_unfout               : out STD_LOGIC;
            -- AXIS Bus
            -- RX Bus
            axis_rx_clkin                : in  STD_LOGIC;
            axis_rx_tdata                : in  STD_LOGIC_VECTOR(511 downto 0);
            axis_rx_tvalid               : in  STD_LOGIC;
            axis_rx_tready               : out STD_LOGIC;
            axis_rx_tkeep                : in  STD_LOGIC_VECTOR(63 downto 0);
            axis_rx_tlast                : in  STD_LOGIC;
            axis_rx_tuser                : in  STD_LOGIC;
            -- TX Bus
            axis_tx_clkout               : out STD_LOGIC;
            axis_tx_tdata                : out STD_LOGIC_VECTOR(511 downto 0);
            axis_tx_tvalid               : out STD_LOGIC;
            axis_tx_tkeep                : out STD_LOGIC_VECTOR(63 downto 0);
            axis_tx_tlast                : out STD_LOGIC;
            -- User signal for errors and dropping of packets
            axis_tx_tuser                : out STD_LOGIC
        );
    end component mac100gphy;

    component microblaze_axi_us_plus_wrapper is
        generic(
            -- Users to add parameters here
            C_ARP_CACHE_ASIZE          : natural := 13;
            C_CPU_TX_DATA_BUFFER_ASIZE : natural := 13;
            C_CPU_RX_DATA_BUFFER_ASIZE : natural := 13;
            C_SLOT_WIDTH               : natural := 4
        );
        port(
            ------------------------------------------------------------------------
            -- MAC PHY Register Interface according to EthernetCore Memory MAP    --
            ------------------------------------------------------------------------ 
            gmac_reg_phy_control_h                 : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_control_l                 : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_mac_address                   : out STD_LOGIC_VECTOR(47 downto 0);
            gmac_reg_local_ip_address              : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_gateway_ip_address            : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_multicast_ip_address          : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_multicast_ip_mask             : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_udp_port                      : out STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_udp_port_mask                 : out STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_mac_enable                    : out STD_LOGIC;
            gmac_reg_mac_promiscous_mode           : out STD_LOGIC;
            gmac_reg_counters_reset                : out STD_LOGIC;
            gmac_reg_core_type                     : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_status_h                  : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_status_l                  : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_packet_rate                : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_packet_count               : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_valid_rate                 : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_valid_count                : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_overflow_count             : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_afull_count                : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_packet_rate                : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_packet_count               : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_valid_rate                 : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_valid_count                : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_overflow_count             : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_almost_full_count          : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_bad_packet_count           : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_arp_size                      : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_word_size                  : in  STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_rx_word_size                  : in  STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_tx_buffer_max_size            : in  STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_rx_buffer_max_size            : in  STD_LOGIC_VECTOR(15 downto 0);
            gmac_arp_cache_write_enable            : out STD_LOGIC;
            gmac_arp_cache_read_enable             : out STD_LOGIC;
            gmac_arp_cache_write_data              : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_arp_cache_read_data               : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_arp_cache_write_address           : out STD_LOGIC_VECTOR(C_ARP_CACHE_ASIZE - 1 downto 0);
            gmac_arp_cache_read_address            : out STD_LOGIC_VECTOR(C_ARP_CACHE_ASIZE - 1 downto 0);
            gmac_tx_data_write_enable              : out STD_LOGIC;
            gmac_tx_data_read_enable               : out STD_LOGIC;
            gmac_tx_data_write_data                : out STD_LOGIC_VECTOR(7 downto 0);
            gmac_tx_data_write_byte_enable         : out STD_LOGIC_VECTOR(1 downto 0);
            gmac_tx_data_read_data                 : in  STD_LOGIC_VECTOR(7 downto 0);
            gmac_tx_data_read_byte_enable          : in  STD_LOGIC_VECTOR(1 downto 0);
            gmac_tx_data_write_address             : out STD_LOGIC_VECTOR(C_CPU_TX_DATA_BUFFER_ASIZE - 1 downto 0);
            gmac_tx_data_read_address              : out STD_LOGIC_VECTOR(C_CPU_TX_DATA_BUFFER_ASIZE - 1 downto 0);
            gmac_tx_ringbuffer_slot_id             : out STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
            gmac_tx_ringbuffer_slot_set            : out STD_LOGIC;
            gmac_tx_ringbuffer_slot_status         : in  STD_LOGIC;
            gmac_tx_ringbuffer_number_slots_filled : in  STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
            gmac_rx_data_read_enable               : out STD_LOGIC;
            gmac_rx_data_read_data                 : in  STD_LOGIC_VECTOR(7 downto 0);
            gmac_rx_data_read_byte_enable          : in  STD_LOGIC_VECTOR(1 downto 0);
            gmac_rx_data_read_address              : out STD_LOGIC_VECTOR(C_CPU_RX_DATA_BUFFER_ASIZE - 1 downto 0);
            gmac_rx_ringbuffer_slot_id             : out STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
            gmac_rx_ringbuffer_slot_clear          : out STD_LOGIC;
            gmac_rx_ringbuffer_slot_status         : in  STD_LOGIC;
            gmac_rx_ringbuffer_number_slots_filled : in  STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
            ClockStable                            : in  STD_LOGIC;
            PSClock                                : in  STD_LOGIC;
            PSReset                                : in  STD_LOGIC;
            rs232_uart_rxd                         : in  STD_LOGIC;
            rs232_uart_txd                         : out STD_LOGIC
        );
    end component microblaze_axi_us_plus_wrapper;

    component clockgen100mhz is
        port(
            clk_out1  : out STD_LOGIC;
            clk_out2  : out STD_LOGIC;
            locked    : out STD_LOGIC;
            clk_in1_p : in  STD_LOGIC;
            clk_in1_n : in  STD_LOGIC
        );
    end component clockgen100mhz;

    ----------------------------------------------------------------------------
    --                 Vivado logic analyser test modules                     --
    -- TODO                                                                   --
    -- Remove these for production designs                                    --
    -- They are only here for debug purposes                                  --
    ----------------------------------------------------------------------------
    component axisila is
        port(
            clk     : IN STD_LOGIC;
            probe0  : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
            probe1  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe2  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe3  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            probe4  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe5  : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
            probe6  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe7  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
            probe8  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe9  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe11 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe12 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe13 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe14 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe15 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
        );
    end component axisila;

    component resetvio is
        port(
            clk        : IN  STD_LOGIC;
            probe_in0  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe_in1  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe_in2  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe_in3  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
            probe_out2 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
        );
    end component resetvio;

    ----------------------------------------------------------------------------
    --                       LED blinker test modules                         --
    -- TODO                                                                   --
    -- Remove these for production designs                                    --
    -- They are only here for debug purposes                                  --
    ----------------------------------------------------------------------------
    component partialblinker is
        port(
            clk_100MHz       : IN  STD_LOGIC;
            partial_bit_leds : out STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    end component partialblinker;
    component ledflasher is
        generic(
            -- Clock frequency in Hz
            G_CLOCK_FREQUENCY : NATURAL := 50_000_000;
            -- LED flashrate in Hz
            G_LED_FLASH_RATE  : NATURAL := 1
        );
        port(
            Clk : in  STD_LOGIC;
            LED : out STD_LOGIC
        );
    end component ledflasher;

    signal RefClk100MHz    : std_logic;
    signal ICAPClk125MHz   : std_logic;
    signal RefClkLocked    : std_logic;
    signal Reset           : std_logic;
    signal lReset          : std_logic;
    signal lbus_reset      : std_logic;
    signal lbus1_tx_ovfout : std_logic;
    signal lbus2_tx_ovfout : std_logic;
    signal lbus1_tx_unfout : std_logic;
    signal lbus2_tx_unfout : std_logic;

    signal ClkQSFP1 : std_logic;
    signal ClkQSFP2 : std_logic;

    signal axis_rx_tdata_1  : STD_LOGIC_VECTOR(511 downto 0);
    signal axis_rx_tvalid_1 : STD_LOGIC;
    signal axis_rx_tkeep_1  : STD_LOGIC_VECTOR(63 downto 0);
    signal axis_rx_tlast_1  : STD_LOGIC;
    signal axis_rx_tuser_1  : STD_LOGIC;

    signal axis_tx_tdata_1  : STD_LOGIC_VECTOR(511 downto 0);
    signal axis_tx_tvalid_1 : STD_LOGIC;
    signal axis_tx_tkeep_1  : STD_LOGIC_VECTOR(63 downto 0);
    signal axis_tx_tlast_1  : STD_LOGIC;
    signal axis_tx_tready_1 : STD_LOGIC;
    signal axis_tx_tuser_1  : STD_LOGIC;

    signal axis_rx_tdata_2  : STD_LOGIC_VECTOR(511 downto 0);
    signal axis_rx_tvalid_2 : STD_LOGIC;
    signal axis_rx_tkeep_2  : STD_LOGIC_VECTOR(63 downto 0);
    signal axis_rx_tlast_2  : STD_LOGIC;
    signal axis_rx_tuser_2  : STD_LOGIC;

    signal axis_tx_tdata_2  : STD_LOGIC_VECTOR(511 downto 0);
    signal axis_tx_tvalid_2 : STD_LOGIC;
    signal axis_tx_tkeep_2  : STD_LOGIC_VECTOR(63 downto 0);
    signal axis_tx_tlast_2  : STD_LOGIC;
    signal axis_tx_tready_2 : STD_LOGIC;
    signal axis_tx_tuser_2  : STD_LOGIC;

    signal Enable : STD_LOGIC;

    --    signal ICAP_PRDONE  : std_logic;
    --    signal ICAP_PRERROR : std_logic;
    --    signal ICAP_AVAIL   : std_logic;
    --    signal ICAP_CSIB    : std_logic;
    --    signal ICAP_RDWRB   : std_logic;
    --    signal ICAP_DataOut : std_logic_vector(31 downto 0);
    --    signal ICAP_DataIn  : std_logic_vector(31 downto 0);
    --    signal ICAP_CSI                                     : std_logic;

    --    signal ZERO_30_vector : std_logic_vector(29 downto 0);
    signal Sig_Vcc                                      : std_logic;
    signal Sig_Gnd                                      : std_logic;
    signal sys_rst_n_c                                  : std_logic;
    signal sys_clk_gt                                   : std_logic;
    signal sys_clk                                      : std_logic;
    signal ICAP_DataIn_Dummy                            : std_logic_vector(31 downto 0);
    signal port1_gmac_reg_phy_control_h                 : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_phy_control_l                 : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_mac_address                   : STD_LOGIC_VECTOR(47 downto 0);
    signal port1_gmac_reg_local_ip_address              : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_gateway_ip_address            : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_multicast_ip_address          : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_multicast_ip_mask             : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_udp_port                      : STD_LOGIC_VECTOR(15 downto 0);
    signal port1_gmac_reg_udp_port_mask                 : STD_LOGIC_VECTOR(15 downto 0);
    signal port1_gmac_reg_mac_enable                    : STD_LOGIC;
    signal port1_gmac_reg_mac_promiscous_mode           : STD_LOGIC;
    signal port1_gmac_reg_counters_reset                : STD_LOGIC;
    signal port1_gmac_reg_core_type                     : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_phy_status_h                  : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_phy_status_l                  : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_tx_packet_rate                : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_tx_packet_count               : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_tx_valid_rate                 : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_tx_valid_count                : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_tx_overflow_count             : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_tx_afull_count                : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_rx_packet_rate                : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_rx_packet_count               : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_rx_valid_rate                 : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_rx_valid_count                : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_rx_overflow_count             : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_rx_almost_full_count          : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_rx_bad_packet_count           : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_arp_size                      : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_reg_tx_word_size                  : STD_LOGIC_VECTOR(15 downto 0);
    signal port1_gmac_reg_rx_word_size                  : STD_LOGIC_VECTOR(15 downto 0);
    signal port1_gmac_reg_tx_buffer_max_size            : STD_LOGIC_VECTOR(15 downto 0);
    signal port1_gmac_reg_rx_buffer_max_size            : STD_LOGIC_VECTOR(15 downto 0);
    signal port1_gmac_arp_cache_write_enable            : STD_LOGIC;
    signal port1_gmac_arp_cache_read_enable             : STD_LOGIC;
    signal port1_gmac_arp_cache_write_data              : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_arp_cache_read_data               : STD_LOGIC_VECTOR(31 downto 0);
    signal port1_gmac_arp_cache_write_address           : STD_LOGIC_VECTOR(C_ARP_CACHE_ASIZE - 1 downto 0);
    signal port1_gmac_arp_cache_read_address            : STD_LOGIC_VECTOR(C_ARP_CACHE_ASIZE - 1 downto 0);
    signal port1_gmac_tx_data_write_enable              : STD_LOGIC;
    signal port1_gmac_tx_data_read_enable               : STD_LOGIC;
    signal port1_gmac_tx_data_write_data                : STD_LOGIC_VECTOR(7 downto 0);
    signal port1_gmac_tx_data_write_byte_enable         : STD_LOGIC_VECTOR(1 downto 0);
    signal port1_gmac_tx_data_read_data                 : STD_LOGIC_VECTOR(7 downto 0);
    signal port1_gmac_tx_data_read_byte_enable          : STD_LOGIC_VECTOR(1 downto 0);
    signal port1_gmac_tx_data_write_address             : STD_LOGIC_VECTOR(C_CPU_TX_DATA_BUFFER_ASIZE - 1 downto 0);
    signal port1_gmac_tx_data_read_address              : STD_LOGIC_VECTOR(C_CPU_TX_DATA_BUFFER_ASIZE - 1 downto 0);
    signal port1_gmac_tx_ringbuffer_slot_id             : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
    signal port1_gmac_tx_ringbuffer_slot_set            : STD_LOGIC;
    signal port1_gmac_tx_ringbuffer_slot_status         : STD_LOGIC;
    signal port1_gmac_tx_ringbuffer_number_slots_filled : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
    signal port1_gmac_rx_data_read_enable               : STD_LOGIC;
    signal port1_gmac_rx_data_read_data                 : STD_LOGIC_VECTOR(7 downto 0);
    signal port1_gmac_rx_data_read_byte_enable          : STD_LOGIC_VECTOR(1 downto 0);
    signal port1_gmac_rx_data_read_address              : STD_LOGIC_VECTOR(C_CPU_RX_DATA_BUFFER_ASIZE - 1 downto 0);
    signal port1_gmac_rx_ringbuffer_slot_id             : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
    signal port1_gmac_rx_ringbuffer_slot_clear          : STD_LOGIC;
    signal port1_gmac_rx_ringbuffer_slot_status         : STD_LOGIC;
    signal port1_gmac_rx_ringbuffer_number_slots_filled : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);

    signal udp1_gmac_reg_core_type           : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_phy_status_h        : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_phy_status_l        : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_phy_control_h       : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_phy_control_l       : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_tx_packet_rate      : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_tx_packet_count     : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_tx_valid_rate       : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_tx_valid_count      : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_rx_packet_rate      : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_rx_packet_count     : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_rx_valid_rate       : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_rx_valid_count      : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_rx_bad_packet_count : STD_LOGIC_VECTOR(31 downto 0);
    signal udp1_gmac_reg_counters_reset      : STD_LOGIC;
    signal udp1_gmac_reg_mac_enable          : STD_LOGIC;

    signal axis_streaming_data_clk                     : STD_LOGIC_VECTOR(C_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
    signal axis_streaming_data_rx_packet_length        : STD_LOGIC_VECTOR((16 * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);         
    signal axis_streaming_data_rx_tdata                : STD_LOGIC_VECTOR((C_AXIS_DATA_WIDTH * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_rx_tvalid               : STD_LOGIC_VECTOR(C_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
    signal axis_streaming_data_rx_tready               : STD_LOGIC_VECTOR(C_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
    signal axis_streaming_data_rx_tkeep                : STD_LOGIC_VECTOR(((C_AXIS_DATA_WIDTH / 8) * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_rx_tlast                : STD_LOGIC_VECTOR(C_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
    signal axis_streaming_data_rx_tuser                : STD_LOGIC_VECTOR(C_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
    signal axis_streaming_data_tx_destination_ip       : STD_LOGIC_VECTOR((32 * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_tx_destination_udp_port : STD_LOGIC_VECTOR((16 * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_tx_source_udp_port      : STD_LOGIC_VECTOR((16 * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_tx_packet_length        : STD_LOGIC_VECTOR((16 * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);         
    signal axis_streaming_data_tx_tdata                : STD_LOGIC_VECTOR((C_AXIS_DATA_WIDTH * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_tx_tvalid               : STD_LOGIC_VECTOR((C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_tx_tuser                : STD_LOGIC_VECTOR((C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_tx_tkeep                : STD_LOGIC_VECTOR(((C_AXIS_DATA_WIDTH / 8) * C_NUM_STREAMING_DATA_SERVERS) - 1 downto 0);
    signal axis_streaming_data_tx_tlast                : STD_LOGIC_VECTOR(C_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
    signal axis_streaming_data_tx_tready               : STD_LOGIC_VECTOR(C_NUM_STREAMING_DATA_SERVERS - 1 downto 0);
begin






     axis_streaming_data_clk(0)   <= ClkQSFP1;
     axis_streaming_data_tx_packet_length <= axis_streaming_data_rx_packet_length;         
     axis_streaming_data_tx_tdata <= axis_streaming_data_rx_tdata;
     axis_streaming_data_tx_tvalid <= axis_streaming_data_rx_tvalid;
     
     axis_streaming_data_rx_tready <= axis_streaming_data_tx_tready;
     
     axis_streaming_data_tx_tkeep <= axis_streaming_data_rx_tkeep;
     axis_streaming_data_tx_tlast <= axis_streaming_data_rx_tlast;
     axis_streaming_data_tx_tuser <= axis_streaming_data_rx_tuser;
     axis_streaming_data_tx_destination_ip       <= C_IP_ADDR_2;
     axis_streaming_data_tx_destination_udp_port <= std_logic_vector(to_unsigned(C_UDP_SERVER_PORT, 16));
     axis_streaming_data_tx_source_udp_port      <= std_logic_vector(to_unsigned(C_UDP_SERVER_PORT, 16));

    --ZERO_30_vector   <= (others => '0');
    Sig_Vcc <= '1';
    Sig_Gnd <= '0';
    --ICAP_CSIB        <= not ICAP_CSI;
    Reset   <= (not RefClkLocked) or lReset;

    ----------------------------------------------------------------------------
    --             Generic QSFP28+ port configuration settings.               --
    ----------------------------------------------------------------------------
    --                             QSFP28+ port 1                             --       
    -- This port is used for all Ethernet communications and is the main port.--       
    ----------------------------------------------------------------------------    
    -- Dont set module to low power mode
    qsfp1_lpmode_ls  <= '0';
    -- Dont select the module
    qsfp1_modsell_ls <= '1';
    -- Keep the module out of reset    
    qsfp1_resetl_ls  <= (not Reset);
    ----------------------------------------------------------------------------
    --                             QSFP28+ port 2                             --       
    -- This port is used for Ethernet bandwidth testing only.                 --       
    ----------------------------------------------------------------------------   
    -- Dont set module to low power mode
    qsfp2_lpmode_ls  <= '0';
    -- Dont select the module
    qsfp2_modsell_ls <= '1';
    -- Keep the module out of reset    
    qsfp2_resetl_ls  <= (not Reset);

    ----------------------------------------------------------------------------
    --                      System Clocks Generator                           --       
    -- This module resides on the static portion of the design.               --
    -- The module generates two clocks i.e.                                   --
    -- RefClk100MHz with a frequency of 100MHz                                --
    --    This clock is used to drive the MGT calibration for the 100G PHY.   --
    -- ICAPClk125MHz with a frequency of 125MHz                               --
    --    This clock is used to clock the ICAPE for partial reconfiguration.  --
    --    This clock also is used to clock the Microblaze sub system.         --       
    ---------------------------------------------------------------------------- 
    ClockGen100MHz_i : clockgen100mhz
        port map(
            clk_out1  => RefClk100MHz,
            clk_out2  => ICAPClk125MHz,
            locked    => RefClkLocked,
            clk_in1_p => sysclk1_300_p,
            clk_in1_n => sysclk1_300_n
        );
    ----------------------------------------------------------------------------
    --                      Led flasher module                                --       
    -- This module resides on the static portion of the design.               --
    -- This module flashes leds on a Johnson counter pattern. .               --
    -- TODO                                                                   --
    --   Please remove this on your design it is just here to show the code is--
    --   running for testing purposes only.                                   --
    ----------------------------------------------------------------------------
    LED2_i : ledflasher
        generic map(
            G_CLOCK_FREQUENCY => 322_265_625,
            G_LED_FLASH_RATE  => 2
        )
        port map(
            Clk => ClkQSFP1,
            LED => blink_led(1)
        );
    LED3_i : ledflasher
        generic map(
            G_CLOCK_FREQUENCY => 322_265_625,
            G_LED_FLASH_RATE  => 1
        )
        port map(
            Clk => ClkQSFP2,
            LED => blink_led(2)
        );
    LED4_i : ledflasher
        generic map(
            G_CLOCK_FREQUENCY => 322_265_625,
            G_LED_FLASH_RATE  => 2
        )
        port map(
            Clk => ClkQSFP2,
            LED => blink_led(3)
        );

    ----------------------------------------------------------------------------
    --          QSFP28+ CMAC0 100G MAC Instance (port 1)                      --
    -- The CMAC resides in the static partition of the design.                --
    -- This is the main data port on the design.                              --
    -- On the VCU118 this is mapped to the top port on the board.             -- 
    ----------------------------------------------------------------------------
    GMAC1_i : mac100gphy
        generic map(
            C_MAC_INSTANCE => 0         -- Instantiate CMAC0 QSFP1
        )
        port map(
            Clk100MHz                    => RefClk100MHz,
            Enable                       => udp1_gmac_reg_mac_enable,
            Reset                        => Reset,
            gmac_reg_core_type           => udp1_gmac_reg_core_type,
            gmac_reg_phy_status_h        => udp1_gmac_reg_phy_status_h,
            gmac_reg_phy_status_l        => udp1_gmac_reg_phy_status_l,
            gmac_reg_phy_control_h       => udp1_gmac_reg_phy_control_h,
            gmac_reg_phy_control_l       => udp1_gmac_reg_phy_control_l,
            gmac_reg_tx_packet_rate      => udp1_gmac_reg_tx_packet_rate,
            gmac_reg_tx_packet_count     => udp1_gmac_reg_tx_packet_count,
            gmac_reg_tx_valid_rate       => udp1_gmac_reg_tx_valid_rate,
            gmac_reg_tx_valid_count      => udp1_gmac_reg_tx_valid_count,
            gmac_reg_rx_packet_rate      => udp1_gmac_reg_rx_packet_rate,
            gmac_reg_rx_packet_count     => udp1_gmac_reg_rx_packet_count,
            gmac_reg_rx_valid_rate       => udp1_gmac_reg_rx_valid_rate,
            gmac_reg_rx_valid_count      => udp1_gmac_reg_rx_valid_count,
            gmac_reg_rx_bad_packet_count => udp1_gmac_reg_rx_bad_packet_count,
            gmac_reg_counters_reset      => udp1_gmac_reg_counters_reset,
            mgt_qsfp_clock_p             => mgt_qsfp1_clock_p,
            mgt_qsfp_clock_n             => mgt_qsfp1_clock_n,
            qsfp_mgt_rx_p                => qsfp1_mgt_rx_p,
            qsfp_mgt_rx_n                => qsfp1_mgt_rx_n,
            qsfp_mgt_tx_p                => qsfp1_mgt_tx_p,
            qsfp_mgt_tx_n                => qsfp1_mgt_tx_n,
            axis_tx_clkout               => ClkQSFP1,
            axis_rx_clkin                => ClkQSFP1,
            lbus_tx_ovfout               => lbus1_tx_ovfout,
            lbus_tx_unfout               => lbus1_tx_unfout,
            lbus_reset                   => lbus_reset,
            axis_rx_tdata                => axis_tx_tdata_1,
            axis_rx_tvalid               => axis_tx_tvalid_1,
            axis_rx_tready               => axis_tx_tready_1,
            axis_rx_tkeep                => axis_tx_tkeep_1,
            axis_rx_tlast                => axis_tx_tlast_1,
            axis_rx_tuser                => axis_tx_tuser_1,
            axis_tx_tdata                => axis_rx_tdata_1,
            axis_tx_tvalid               => axis_rx_tvalid_1,
            axis_tx_tkeep                => axis_rx_tkeep_1,
            axis_tx_tlast                => axis_rx_tlast_1,
            axis_tx_tuser                => axis_rx_tuser_1
        );

    ----------------------------------------------------------------------------
    --                 Ethernet UDP/IP Communications module                  --
    -- The UDP/IP module resides in the static partition of the design.       --
    -- This module implements all UDP/IP  communications.                     --
    -- This module supports 9600 jumbo frame packets.                         --
    -- The  module depends on CPU for configuration settings and 100gmac      --    
    -- When C_INCLUDE_ICAP = true partial reconfiguration over UDP is enabled.--
    -- The module gets and sends streaming data using the module apps.        --
    -- All DSP high speed streaming data is connected to this module.         --
    -- To facilitate reaching maximum bandwidth several streaming apps can be --
    -- connected to the module as data sources/sinks.                         --     
    ----------------------------------------------------------------------------
    UDPIPIFFi : udpipinterfacepr
        generic map(
            G_INCLUDE_ICAP               => C_INCLUDE_ICAP,
            G_AXIS_DATA_WIDTH            => C_AXIS_DATA_WIDTH,
            G_SLOT_WIDTH                 => C_SLOT_WIDTH,
            -- Number of UDP Streaming Data Server Modules 
            G_NUM_STREAMING_DATA_SERVERS => C_NUM_STREAMING_DATA_SERVERS,
            G_ARP_CACHE_ASIZE            => C_ARP_CACHE_ASIZE,
            G_ARP_DATA_WIDTH             => C_ARP_DATA_WIDTH,
            G_CPU_TX_DATA_BUFFER_ASIZE   => C_CPU_TX_DATA_BUFFER_ASIZE,
            G_CPU_RX_DATA_BUFFER_ASIZE   => C_CPU_RX_DATA_BUFFER_ASIZE,
            G_PR_SERVER_PORT             => C_PR_SERVER_PORT
        )
        port map(
            axis_clk                                     => ClkQSFP1,
            -- Running Microblaze at 125MHz used for ICAP Clocking
            aximm_clk                                    => ICAPClk125MHz,
            icap_clk                                     => ICAPClk125MHz,
            axis_reset                                   => Reset,
            aximm_gmac_reg_phy_control_h                 => port1_gmac_reg_phy_control_h,
            aximm_gmac_reg_phy_control_l                 => port1_gmac_reg_phy_control_l,
            aximm_gmac_reg_mac_address                   => port1_gmac_reg_mac_address,
            aximm_gmac_reg_local_ip_address              => port1_gmac_reg_local_ip_address,
            aximm_gmac_reg_gateway_ip_address            => port1_gmac_reg_gateway_ip_address,
            aximm_gmac_reg_multicast_ip_address          => port1_gmac_reg_multicast_ip_address,
            aximm_gmac_reg_multicast_ip_mask             => port1_gmac_reg_multicast_ip_mask,
            aximm_gmac_reg_udp_port                      => port1_gmac_reg_udp_port,
            aximm_gmac_reg_udp_port_mask                 => port1_gmac_reg_udp_port_mask,
            aximm_gmac_reg_mac_enable                    => port1_gmac_reg_mac_enable,
            aximm_gmac_reg_mac_promiscous_mode           => port1_gmac_reg_mac_promiscous_mode,
            aximm_gmac_reg_counters_reset                => port1_gmac_reg_counters_reset,
            aximm_gmac_reg_core_type                     => port1_gmac_reg_core_type,
            aximm_gmac_reg_phy_status_h                  => port1_gmac_reg_phy_status_h,
            aximm_gmac_reg_phy_status_l                  => port1_gmac_reg_phy_status_l,
            aximm_gmac_reg_tx_packet_rate                => port1_gmac_reg_tx_packet_rate,
            aximm_gmac_reg_tx_packet_count               => port1_gmac_reg_tx_packet_count,
            aximm_gmac_reg_tx_valid_rate                 => port1_gmac_reg_tx_valid_rate,
            aximm_gmac_reg_tx_valid_count                => port1_gmac_reg_tx_valid_count,
            aximm_gmac_reg_tx_overflow_count             => port1_gmac_reg_tx_overflow_count,
            aximm_gmac_reg_tx_afull_count                => port1_gmac_reg_tx_afull_count,
            aximm_gmac_reg_rx_packet_rate                => port1_gmac_reg_rx_packet_rate,
            aximm_gmac_reg_rx_packet_count               => port1_gmac_reg_rx_packet_count,
            aximm_gmac_reg_rx_valid_rate                 => port1_gmac_reg_rx_valid_rate,
            aximm_gmac_reg_rx_valid_count                => port1_gmac_reg_rx_valid_count,
            aximm_gmac_reg_rx_overflow_count             => port1_gmac_reg_rx_overflow_count,
            aximm_gmac_reg_rx_almost_full_count          => port1_gmac_reg_rx_almost_full_count,
            aximm_gmac_reg_rx_bad_packet_count           => port1_gmac_reg_rx_bad_packet_count,
            aximm_gmac_reg_arp_size                      => port1_gmac_reg_arp_size,
            aximm_gmac_reg_tx_word_size                  => port1_gmac_reg_tx_word_size,
            aximm_gmac_reg_rx_word_size                  => port1_gmac_reg_rx_word_size,
            aximm_gmac_reg_tx_buffer_max_size            => port1_gmac_reg_tx_buffer_max_size,
            aximm_gmac_reg_rx_buffer_max_size            => port1_gmac_reg_rx_buffer_max_size,
            aximm_gmac_arp_cache_write_enable            => port1_gmac_arp_cache_write_enable,
            aximm_gmac_arp_cache_read_enable             => port1_gmac_arp_cache_read_enable,
            aximm_gmac_arp_cache_write_data              => port1_gmac_arp_cache_write_data,
            aximm_gmac_arp_cache_read_data               => port1_gmac_arp_cache_read_data,
            aximm_gmac_arp_cache_write_address           => port1_gmac_arp_cache_write_address,
            aximm_gmac_arp_cache_read_address            => port1_gmac_arp_cache_read_address,
            aximm_gmac_tx_data_write_enable              => port1_gmac_tx_data_write_enable,
            aximm_gmac_tx_data_read_enable               => port1_gmac_tx_data_read_enable,
            aximm_gmac_tx_data_write_data                => port1_gmac_tx_data_write_data,
            aximm_gmac_tx_data_write_byte_enable         => port1_gmac_tx_data_write_byte_enable,
            aximm_gmac_tx_data_read_data                 => port1_gmac_tx_data_read_data,
            aximm_gmac_tx_data_read_byte_enable          => port1_gmac_tx_data_read_byte_enable,
            aximm_gmac_tx_data_write_address             => port1_gmac_tx_data_write_address,
            aximm_gmac_tx_data_read_address              => port1_gmac_tx_data_read_address,
            aximm_gmac_tx_ringbuffer_slot_id             => port1_gmac_tx_ringbuffer_slot_id,
            aximm_gmac_tx_ringbuffer_slot_set            => port1_gmac_tx_ringbuffer_slot_set,
            aximm_gmac_tx_ringbuffer_slot_status         => port1_gmac_tx_ringbuffer_slot_status,
            aximm_gmac_tx_ringbuffer_number_slots_filled => port1_gmac_tx_ringbuffer_number_slots_filled,
            aximm_gmac_rx_data_read_enable               => port1_gmac_rx_data_read_enable,
            aximm_gmac_rx_data_read_data                 => port1_gmac_rx_data_read_data,
            aximm_gmac_rx_data_read_byte_enable          => port1_gmac_rx_data_read_byte_enable,
            aximm_gmac_rx_data_read_address              => port1_gmac_rx_data_read_address,
            aximm_gmac_rx_ringbuffer_slot_id             => port1_gmac_rx_ringbuffer_slot_id,
            aximm_gmac_rx_ringbuffer_slot_clear          => port1_gmac_rx_ringbuffer_slot_clear,
            aximm_gmac_rx_ringbuffer_slot_status         => port1_gmac_rx_ringbuffer_slot_status,
            aximm_gmac_rx_ringbuffer_number_slots_filled => port1_gmac_rx_ringbuffer_number_slots_filled,
            axis_streaming_data_clk                      => axis_streaming_data_clk,
            axis_streaming_data_rx_packet_length         => axis_streaming_data_rx_packet_length,
            axis_streaming_data_rx_tdata                 => axis_streaming_data_rx_tdata,
            axis_streaming_data_rx_tvalid                => axis_streaming_data_rx_tvalid,
            axis_streaming_data_rx_tready                => axis_streaming_data_rx_tready,
            axis_streaming_data_rx_tkeep                 => axis_streaming_data_rx_tkeep,
            axis_streaming_data_rx_tlast                 => axis_streaming_data_rx_tlast,
            axis_streaming_data_rx_tuser                 => axis_streaming_data_rx_tuser,
            axis_streaming_data_tx_destination_ip        => axis_streaming_data_tx_destination_ip,
            axis_streaming_data_tx_destination_udp_port  => axis_streaming_data_tx_destination_udp_port,
            axis_streaming_data_tx_source_udp_port       => axis_streaming_data_tx_source_udp_port,
            axis_streaming_data_tx_packet_length         => axis_streaming_data_tx_packet_length,
            axis_streaming_data_tx_tdata                 => axis_streaming_data_tx_tdata,
            axis_streaming_data_tx_tvalid                => axis_streaming_data_tx_tvalid,
            axis_streaming_data_tx_tuser                 => axis_streaming_data_tx_tuser,
            axis_streaming_data_tx_tkeep                 => axis_streaming_data_tx_tkeep,
            axis_streaming_data_tx_tlast                 => axis_streaming_data_tx_tlast,
            axis_streaming_data_tx_tready                => axis_streaming_data_tx_tready,
            gmac_reg_core_type                           => udp1_gmac_reg_core_type,
            gmac_reg_phy_status_h                        => udp1_gmac_reg_phy_status_h,
            gmac_reg_phy_status_l                        => udp1_gmac_reg_phy_status_l,
            gmac_reg_phy_control_h                       => udp1_gmac_reg_phy_control_h,
            gmac_reg_phy_control_l                       => udp1_gmac_reg_phy_control_l,
            gmac_reg_tx_packet_rate                      => udp1_gmac_reg_tx_packet_rate,
            gmac_reg_tx_packet_count                     => udp1_gmac_reg_tx_packet_count,
            gmac_reg_tx_valid_rate                       => udp1_gmac_reg_tx_valid_rate,
            gmac_reg_tx_valid_count                      => udp1_gmac_reg_tx_valid_count,
            gmac_reg_rx_packet_rate                      => udp1_gmac_reg_rx_packet_rate,
            gmac_reg_rx_packet_count                     => udp1_gmac_reg_rx_packet_count,
            gmac_reg_rx_valid_rate                       => udp1_gmac_reg_rx_valid_rate,
            gmac_reg_rx_valid_count                      => udp1_gmac_reg_rx_valid_count,
            gmac_reg_rx_bad_packet_count                 => udp1_gmac_reg_rx_bad_packet_count,
            gmac_reg_counters_reset                      => udp1_gmac_reg_counters_reset,
            gmac_reg_mac_enable                          => udp1_gmac_reg_mac_enable,
            axis_tx_tdata                                => axis_tx_tdata_1,
            axis_tx_tvalid                               => axis_tx_tvalid_1,
            axis_tx_tready                               => axis_tx_tready_1,
            axis_tx_tkeep                                => axis_tx_tkeep_1,
            axis_tx_tlast                                => axis_tx_tlast_1,
            axis_tx_tuser                                => axis_tx_tuser_1,
            axis_rx_tdata                                => axis_rx_tdata_1,
            axis_rx_tvalid                               => axis_rx_tvalid_1,
            axis_rx_tuser                                => axis_rx_tuser_1,
            axis_rx_tkeep                                => axis_rx_tkeep_1,
            axis_rx_tlast                                => axis_rx_tlast_1
        );

    ----------------------------------------------------------------------------
    --                   Microblaze CPU Instance                              --
    -- The CPU resides in the static partition of the design.                 --
    -- The CPU implements CASPER FPGA communication functions over the CMAC.  --
    -- The CPU can only send and receive 1520 MTU Ethernet packets.           --
    -- The CPU runs at 125MHz clock                                           --
    -- Inside the CPU BD {n} ethernet memory map core(s) is/are instantiated. --
    ----------------------------------------------------------------------------
    MicroblazeSys_i : microblaze_axi_us_plus_wrapper
        generic map(
            C_ARP_CACHE_ASIZE          => C_ARP_CACHE_ASIZE,
            C_CPU_TX_DATA_BUFFER_ASIZE => C_CPU_TX_DATA_BUFFER_ASIZE,
            C_CPU_RX_DATA_BUFFER_ASIZE => C_CPU_RX_DATA_BUFFER_ASIZE,
            C_SLOT_WIDTH               => C_SLOT_WIDTH
        )
        port map(
            gmac_reg_phy_control_h                 => port1_gmac_reg_phy_control_h,
            gmac_reg_phy_control_l                 => port1_gmac_reg_phy_control_l,
            gmac_reg_mac_address                   => port1_gmac_reg_mac_address,
            gmac_reg_local_ip_address              => port1_gmac_reg_local_ip_address,
            gmac_reg_gateway_ip_address            => port1_gmac_reg_gateway_ip_address,
            gmac_reg_multicast_ip_address          => port1_gmac_reg_multicast_ip_address,
            gmac_reg_multicast_ip_mask             => port1_gmac_reg_multicast_ip_mask,
            gmac_reg_udp_port                      => port1_gmac_reg_udp_port,
            gmac_reg_udp_port_mask                 => port1_gmac_reg_udp_port_mask,
            gmac_reg_mac_enable                    => port1_gmac_reg_mac_enable,
            gmac_reg_mac_promiscous_mode           => port1_gmac_reg_mac_promiscous_mode,
            gmac_reg_counters_reset                => port1_gmac_reg_counters_reset,
            gmac_reg_core_type                     => port1_gmac_reg_core_type,
            gmac_reg_phy_status_h                  => port1_gmac_reg_phy_status_h,
            gmac_reg_phy_status_l                  => port1_gmac_reg_phy_status_l,
            gmac_reg_tx_packet_rate                => port1_gmac_reg_tx_packet_rate,
            gmac_reg_tx_packet_count               => port1_gmac_reg_tx_packet_count,
            gmac_reg_tx_valid_rate                 => port1_gmac_reg_tx_valid_rate,
            gmac_reg_tx_valid_count                => port1_gmac_reg_tx_valid_count,
            gmac_reg_tx_overflow_count             => port1_gmac_reg_tx_overflow_count,
            gmac_reg_tx_afull_count                => port1_gmac_reg_tx_afull_count,
            gmac_reg_rx_packet_rate                => port1_gmac_reg_rx_packet_rate,
            gmac_reg_rx_packet_count               => port1_gmac_reg_rx_packet_count,
            gmac_reg_rx_valid_rate                 => port1_gmac_reg_rx_valid_rate,
            gmac_reg_rx_valid_count                => port1_gmac_reg_rx_valid_count,
            gmac_reg_rx_overflow_count             => port1_gmac_reg_rx_overflow_count,
            gmac_reg_rx_almost_full_count          => port1_gmac_reg_rx_almost_full_count,
            gmac_reg_rx_bad_packet_count           => port1_gmac_reg_rx_bad_packet_count,
            gmac_reg_arp_size                      => port1_gmac_reg_arp_size,
            gmac_reg_tx_word_size                  => port1_gmac_reg_tx_word_size,
            gmac_reg_rx_word_size                  => port1_gmac_reg_rx_word_size,
            gmac_reg_tx_buffer_max_size            => port1_gmac_reg_tx_buffer_max_size,
            gmac_reg_rx_buffer_max_size            => port1_gmac_reg_rx_buffer_max_size,
            gmac_arp_cache_write_enable            => port1_gmac_arp_cache_write_enable,
            gmac_arp_cache_read_enable             => port1_gmac_arp_cache_read_enable,
            gmac_arp_cache_write_data              => port1_gmac_arp_cache_write_data,
            gmac_arp_cache_read_data               => port1_gmac_arp_cache_read_data,
            gmac_arp_cache_write_address           => port1_gmac_arp_cache_write_address,
            gmac_arp_cache_read_address            => port1_gmac_arp_cache_read_address,
            gmac_tx_data_write_enable              => port1_gmac_tx_data_write_enable,
            gmac_tx_data_read_enable               => port1_gmac_tx_data_read_enable,
            gmac_tx_data_write_data                => port1_gmac_tx_data_write_data,
            gmac_tx_data_write_byte_enable         => port1_gmac_tx_data_write_byte_enable,
            gmac_tx_data_read_data                 => port1_gmac_tx_data_read_data,
            gmac_tx_data_read_byte_enable          => port1_gmac_tx_data_read_byte_enable,
            gmac_tx_data_write_address             => port1_gmac_tx_data_write_address,
            gmac_tx_data_read_address              => port1_gmac_tx_data_read_address,
            gmac_tx_ringbuffer_slot_id             => port1_gmac_tx_ringbuffer_slot_id,
            gmac_tx_ringbuffer_slot_set            => port1_gmac_tx_ringbuffer_slot_set,
            gmac_tx_ringbuffer_slot_status         => port1_gmac_tx_ringbuffer_slot_status,
            gmac_tx_ringbuffer_number_slots_filled => port1_gmac_tx_ringbuffer_number_slots_filled,
            gmac_rx_data_read_enable               => port1_gmac_rx_data_read_enable,
            gmac_rx_data_read_data                 => port1_gmac_rx_data_read_data,
            gmac_rx_data_read_byte_enable          => port1_gmac_rx_data_read_byte_enable,
            gmac_rx_data_read_address              => port1_gmac_rx_data_read_address,
            gmac_rx_ringbuffer_slot_id             => port1_gmac_rx_ringbuffer_slot_id,
            gmac_rx_ringbuffer_slot_clear          => port1_gmac_rx_ringbuffer_slot_clear,
            gmac_rx_ringbuffer_slot_status         => port1_gmac_rx_ringbuffer_slot_status,
            gmac_rx_ringbuffer_number_slots_filled => port1_gmac_rx_ringbuffer_number_slots_filled,
            ClockStable                            => RefClkLocked,
            PSClock                                => ICAPClk125MHz,
            PSReset                                => Reset,
            rs232_uart_rxd                         => rs232_uart_rxd,
            rs232_uart_txd                         => rs232_uart_txd
        );

    ----------------------------------------------------------------------------
    --          QSFP28+ CMAC1 100G MAC Instance (port 2)                      --
    -- The CMAC resides in the static partition of the design.                --
    -- This is the Ethernet bandwidth test data port on the design.           --
    -- On the VCU118 this is mapped to the bottom port on the board.          -- 
    ----------------------------------------------------------------------------
    GMAC2_i : mac100gphy
        generic map(
            C_MAC_INSTANCE => 1         -- Instantiate CMAC1 QSFP2
        )
        port map(
            Clk100MHz                    => RefClk100MHz,
            Reset                        => Reset,
            Enable                       => udp1_gmac_reg_mac_enable,
            gmac_reg_core_type           => open,
            gmac_reg_phy_status_h        => open,
            gmac_reg_phy_status_l        => open,
            gmac_reg_phy_control_h       => udp1_gmac_reg_phy_control_h,
            gmac_reg_phy_control_l       => udp1_gmac_reg_phy_control_l,
            gmac_reg_tx_packet_rate      => open,
            gmac_reg_tx_packet_count     => open,
            gmac_reg_tx_valid_rate       => open,
            gmac_reg_tx_valid_count      => open,
            gmac_reg_rx_packet_rate      => open,
            gmac_reg_rx_packet_count     => open,
            gmac_reg_rx_valid_rate       => open,
            gmac_reg_rx_valid_count      => open,
            gmac_reg_rx_bad_packet_count => open,
            gmac_reg_counters_reset      => udp1_gmac_reg_counters_reset,
            mgt_qsfp_clock_p             => mgt_qsfp2_clock_p,
            mgt_qsfp_clock_n             => mgt_qsfp2_clock_n,
            qsfp_mgt_rx_p                => qsfp2_mgt_rx_p,
            qsfp_mgt_rx_n                => qsfp2_mgt_rx_n,
            qsfp_mgt_tx_p                => qsfp2_mgt_tx_p,
            qsfp_mgt_tx_n                => qsfp2_mgt_tx_n,
            axis_tx_clkout               => ClkQSFP2,
            axis_rx_clkin                => ClkQSFP2,
            lbus_tx_ovfout               => lbus2_tx_ovfout,
            lbus_tx_unfout               => lbus2_tx_unfout,
            lbus_reset                   => lbus_reset,
            --
            axis_rx_tdata                => axis_tx_tdata_2,
            axis_rx_tvalid               => axis_tx_tvalid_2,
            axis_rx_tready               => axis_tx_tready_2,
            axis_rx_tkeep                => axis_tx_tkeep_2,
            axis_rx_tlast                => axis_tx_tlast_2,
            axis_rx_tuser                => axis_tx_tuser_2,
            --
            axis_tx_tdata                => axis_rx_tdata_2,
            axis_tx_tvalid               => axis_rx_tvalid_2,
            axis_tx_tkeep                => axis_rx_tkeep_2,
            axis_tx_tlast                => axis_rx_tlast_2,
            axis_tx_tuser                => axis_rx_tuser_2
        );

    ----------------------------------------------------------------------------
    --                 Ethernet Bandwidth test Interface                      --
    -- This module is used only for Ethernet bandwidth testing nothing more.  --
    -- It has an internal ARP module and a UDP echo server at UDP port        --
    -- G_UDP_SERVER_PORT. It will return data sent over UDP on this port at   --
    -- Ethernet line rate. It support 9600 jumbo frames.                      --
    ----------------------------------------------------------------------------
    BANDWIDTHTEST_i : testcomms
        generic map(
            G_DATA_WIDTH      => C_AXIS_DATA_WIDTH,
            G_EMAC_ADDR       => C_EMAC_ADDR_2,
            G_IP_ADDR         => C_IP_ADDR_2,
            G_UDP_SERVER_PORT => C_UDP_SERVER_PORT
        )
        port map(
            axis_clk       => ClkQSFP2,
            axis_reset     => Reset,
            axis_tx_tdata  => axis_tx_tdata_2,
            axis_tx_tvalid => axis_tx_tvalid_2,
            axis_tx_tready => axis_tx_tready_2,
            axis_tx_tkeep  => axis_tx_tkeep_2,
            axis_tx_tlast  => axis_tx_tlast_2,
            --
            axis_rx_tdata  => axis_rx_tdata_2,
            axis_rx_tvalid => axis_rx_tvalid_2,
            axis_rx_tuser  => axis_rx_tuser_2,
            axis_rx_tkeep  => axis_rx_tkeep_2,
            axis_rx_tlast  => axis_rx_tlast_2
        );

    MAINAXIS_i : axisila
        port map(
            clk        => ClkQSFP1,
            probe0     => axis_rx_tdata_1,
            probe1(0)  => axis_rx_tvalid_1,
            probe2(0)  => axis_rx_tuser_1,
            probe3     => axis_rx_tkeep_1,
            probe4(0)  => axis_rx_tlast_1,
            probe5     => axis_tx_tdata_1,
            probe6(0)  => axis_tx_tvalid_1,
            probe7     => axis_tx_tkeep_1,
            probe8(0)  => axis_tx_tlast_1,
            probe9(0)  => axis_tx_tready_1,
            probe10(0) => lbus_reset,
            probe11(0) => lbus1_tx_ovfout,
            probe12(0) => lbus1_tx_unfout,
            probe13(0) => RefClkLocked,
            probe14(0) => Reset,
            probe15(0) => qsfp1_intl_ls
        );

    ECHOAXIS_i : axisila
        port map(
            clk        => ClkQSFP2,
            probe0     => axis_rx_tdata_2,
            probe1(0)  => axis_rx_tvalid_2,
            probe2(0)  => axis_rx_tuser_2,
            probe3     => axis_rx_tkeep_2,
            probe4(0)  => axis_rx_tlast_2,
            probe5     => axis_tx_tdata_2,
            probe6(0)  => axis_tx_tvalid_2,
            probe7     => axis_tx_tkeep_2,
            probe8(0)  => axis_tx_tlast_2,
            probe9(0)  => axis_tx_tready_2,
            probe10(0) => lbus_reset,
            probe11(0) => lbus2_tx_ovfout,
            probe12(0) => lbus2_tx_unfout,
            probe13(0) => RefClkLocked,
            probe14(0) => Reset,
            probe15(0) => qsfp2_intl_ls
        );

    RESET_VIO_i : resetvio
        port map(
            clk           => ClkQSFP1,
            probe_in0(0)  => qsfp1_modprsl_ls,
            probe_in1(0)  => qsfp1_intl_ls,
            probe_in2(0)  => qsfp2_modprsl_ls,
            probe_in3(0)  => qsfp2_intl_ls,
            probe_out0(0) => lbus_reset,
            probe_out1(0) => lReset,
            probe_out2(0) => Enable
        );

    ----------------------------------------------------------------------------
    --                    PCIe sub system instantiation                       --
    -- The PCIe sub system with its QDMA engine is instantiated here.         --
    -- This module resides on the static portion of the design.               --
    -- This code must boot first on a minimal tandem bitstream to meet PCIe   --
    -- system bus enumeration and meet the full line sync of less than 10ms   --
    -- for successful device enumeration,else the FPGA wont be recognized on  --
    -- the system PCIe bus.                                                   --
    -- TODO                                                                   --
    -- Add the PCIe vEthernet MAC controller.                                 --
    ----------------------------------------------------------------------------   

    -- PCIe Refference clock buffer for PCI Express clocking
    refclk_ibuf : IBUFDS_GTE4
        generic map(
            REFCLK_HROW_CK_SEL => "00"
        )
        port map(
            O     => sys_clk_gt,
            ODIV2 => sys_clk,
            CEB   => '0',
            I     => sys_clk_p,
            IB    => sys_clk_n
        );

    -- PCIe reset buffer for PCI Express card reset
    sys_reset_n_ibuf : IBUF
        port map(
            O => sys_rst_n_c,
            I => sys_rst_n
        );

    PCIE_i : pciexdma_refbd_wrapper
        port map(
            GPIO2_0_tri_i(31 downto 0) => ICAP_DataIn_Dummy(31 downto 0),
            --GPIO2_0_tri_i(31 downto 2) => ZERO_30_vector,
            --GPIO2_0_tri_i(1)           => ICAP_PRERROR,
            --GPIO2_0_tri_i(0)           => ICAP_PRDONE,
            GPIO_0_tri_o               => open,
            --M_AXIS_0_tdata             => ICAP_DataIn,
            M_AXIS_0_tdata             => ICAP_DataIn_Dummy,
            M_AXIS_0_tkeep             => open,
            M_AXIS_0_tlast             => open,
            M_AXIS_0_tready            => Enable, --ICAP_AVAIL,
            --            M_AXIS_0_tvalid            => ICAP_CSI,
            M_AXIS_0_tvalid            => open,
            m_axis_aclk_0              => ICAPClk125MHz,
            m_axis_aresetn_0           => Sig_Vcc,
            pcie_mgt_0_rxn             => pci_exp_rxn,
            pcie_mgt_0_rxp             => pci_exp_rxp,
            pcie_mgt_0_txn             => pci_exp_txn,
            pcie_mgt_0_txp             => pci_exp_txp,
            sys_clk_0                  => sys_clk,
            sys_clk_gt_0               => sys_clk_gt,
            sys_rst_n_0                => sys_rst_n_c,
            user_lnk_up_0              => blink_led(0)
        );

    ----------------------------------------------------------------------------
    -- End of static portion of the design.                                   --       
    -- All modules after this portion must be fixed on partial reconfigurable --
    -- partition (PRM).                                                       --
    ----------------------------------------------------------------------------

    --                Transition to partial reconfigurable region             --   

    ----------------------------------------------------------------------------
    --                      Partial Reconfiguration Module                    --       
    -- This module is a very simple partial reconfiguration module to test and--
    -- show partial reconfiguration functionality by blinking leds.           --
    -- Two partial reconfiguration modules exist for showing the led patterns --
    -- partialblinker (RM)                                                    --
    --   This RM blinks the LEDs in a Johnson counter pattern.                --
    -- partialflasher (RM)                                                    --
    --   This RM flashes all the LEDs in a simultaneous on off pattern.       --
    -- TODO                                                                   --
    --    Add your partial reconfiguration module code here.                  --       
    --    Hint:                                                               --       
    --        For the initial bitstream put a very tiny placeholder RM and    --
    --        use bitstream compression for loading the bitstream to flash.   --
    --        In that way you can have a very tiny bitstream that will enable --
    --        the FPGA to be initially configured within 5ms needed for PCIe  --
    --        bus enumeration. Then you will have the entire PCIe and 100G    --
    --        infrastructure running and ready to receive bigger PR RMs over  --
    --        100G Ethernet or PCIe depending on the bus interface.           --         
    ---------------------------------------------------------------------------- 
    PartialBlinker_i : partialblinker
        port map(
            clk_100MHz       => RefClk100MHz,
            partial_bit_leds => partial_bit_leds
        );

end architecture rtl;

