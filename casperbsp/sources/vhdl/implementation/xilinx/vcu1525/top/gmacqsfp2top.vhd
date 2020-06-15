--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : gmacqsfp2top - rtl                                       -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module instantiates one QSFP28+ ports with CMACs.   -
--                    TODO                                                     -
--                    Enable AXI Lite bus for statistics collection.           - 
-- Dependencies     : EthMACPHY100GQSFP24x                                     -
-- Revision History : V1.0 - Initial design                                    -
--                  : V1.1 - changed to Vivado 2019.2 and used AXI-S           -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gmacqsfp2top is
    port(
        -- Reference clock to generate 100MHz from
        Clk100MHz                    : in  STD_LOGIC;
        -- Global System Enable
        Enable                       : in  STD_LOGIC;
        Reset                        : in  STD_LOGIC;
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
        -- This bus runs at 322.265625MHz
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
end entity gmacqsfp2top;

architecture rtl of gmacqsfp2top is

    component EthMACPHY100GQSFP24x is
        port(
            gt_rxp_in                      : in  STD_LOGIC_VECTOR(3 downto 0);
            gt_rxn_in                      : in  STD_LOGIC_VECTOR(3 downto 0);
            gt_txp_out                     : out STD_LOGIC_VECTOR(3 downto 0);
            gt_txn_out                     : out STD_LOGIC_VECTOR(3 downto 0);
            gt_txusrclk2                   : out STD_LOGIC;
            gt_loopback_in                 : in  STD_LOGIC_VECTOR(11 downto 0);
            gt_rxrecclkout                 : out STD_LOGIC_VECTOR(3 downto 0);
            gt_powergoodout                : out STD_LOGIC_VECTOR(3 downto 0);
            gt_ref_clk_out                 : out STD_LOGIC;
            gtwiz_reset_tx_datapath        : in  STD_LOGIC;
            gtwiz_reset_rx_datapath        : in  STD_LOGIC;
            sys_reset                      : in  STD_LOGIC;
            gt_ref_clk_p                   : in  STD_LOGIC;
            gt_ref_clk_n                   : in  STD_LOGIC;
            init_clk                       : in  STD_LOGIC;
            rx_axis_tvalid                 : out STD_LOGIC;
            rx_axis_tdata                  : out STD_LOGIC_VECTOR(511 downto 0);
            rx_axis_tlast                  : out STD_LOGIC;
            rx_axis_tkeep                  : out STD_LOGIC_VECTOR(63 downto 0);
            rx_axis_tuser                  : out STD_LOGIC;
            rx_otn_bip8_0                  : out STD_LOGIC_VECTOR(7 downto 0);
            rx_otn_bip8_1                  : out STD_LOGIC_VECTOR(7 downto 0);
            rx_otn_bip8_2                  : out STD_LOGIC_VECTOR(7 downto 0);
            rx_otn_bip8_3                  : out STD_LOGIC_VECTOR(7 downto 0);
            rx_otn_bip8_4                  : out STD_LOGIC_VECTOR(7 downto 0);
            rx_otn_data_0                  : out STD_LOGIC_VECTOR(65 downto 0);
            rx_otn_data_1                  : out STD_LOGIC_VECTOR(65 downto 0);
            rx_otn_data_2                  : out STD_LOGIC_VECTOR(65 downto 0);
            rx_otn_data_3                  : out STD_LOGIC_VECTOR(65 downto 0);
            rx_otn_data_4                  : out STD_LOGIC_VECTOR(65 downto 0);
            rx_otn_ena                     : out STD_LOGIC;
            rx_otn_lane0                   : out STD_LOGIC;
            rx_otn_vlmarker                : out STD_LOGIC;
            rx_preambleout                 : out STD_LOGIC_VECTOR(55 downto 0);
            usr_rx_reset                   : out STD_LOGIC;
            gt_rxusrclk2                   : out STD_LOGIC;
            stat_rx_aligned                : out STD_LOGIC;
            stat_rx_aligned_err            : out STD_LOGIC;
            stat_rx_bad_code               : out STD_LOGIC_VECTOR(2 downto 0);
            stat_rx_bad_fcs                : out STD_LOGIC_VECTOR(2 downto 0);
            stat_rx_bad_preamble           : out STD_LOGIC;
            stat_rx_bad_sfd                : out STD_LOGIC;
            stat_rx_bip_err_0              : out STD_LOGIC;
            stat_rx_bip_err_1              : out STD_LOGIC;
            stat_rx_bip_err_10             : out STD_LOGIC;
            stat_rx_bip_err_11             : out STD_LOGIC;
            stat_rx_bip_err_12             : out STD_LOGIC;
            stat_rx_bip_err_13             : out STD_LOGIC;
            stat_rx_bip_err_14             : out STD_LOGIC;
            stat_rx_bip_err_15             : out STD_LOGIC;
            stat_rx_bip_err_16             : out STD_LOGIC;
            stat_rx_bip_err_17             : out STD_LOGIC;
            stat_rx_bip_err_18             : out STD_LOGIC;
            stat_rx_bip_err_19             : out STD_LOGIC;
            stat_rx_bip_err_2              : out STD_LOGIC;
            stat_rx_bip_err_3              : out STD_LOGIC;
            stat_rx_bip_err_4              : out STD_LOGIC;
            stat_rx_bip_err_5              : out STD_LOGIC;
            stat_rx_bip_err_6              : out STD_LOGIC;
            stat_rx_bip_err_7              : out STD_LOGIC;
            stat_rx_bip_err_8              : out STD_LOGIC;
            stat_rx_bip_err_9              : out STD_LOGIC;
            stat_rx_block_lock             : out STD_LOGIC_VECTOR(19 downto 0);
            stat_rx_broadcast              : out STD_LOGIC;
            stat_rx_fragment               : out STD_LOGIC_VECTOR(2 downto 0);
            stat_rx_framing_err_0          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_1          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_10         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_11         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_12         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_13         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_14         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_15         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_16         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_17         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_18         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_19         : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_2          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_3          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_4          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_5          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_6          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_7          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_8          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_9          : out STD_LOGIC_VECTOR(1 downto 0);
            stat_rx_framing_err_valid_0    : out STD_LOGIC;
            stat_rx_framing_err_valid_1    : out STD_LOGIC;
            stat_rx_framing_err_valid_10   : out STD_LOGIC;
            stat_rx_framing_err_valid_11   : out STD_LOGIC;
            stat_rx_framing_err_valid_12   : out STD_LOGIC;
            stat_rx_framing_err_valid_13   : out STD_LOGIC;
            stat_rx_framing_err_valid_14   : out STD_LOGIC;
            stat_rx_framing_err_valid_15   : out STD_LOGIC;
            stat_rx_framing_err_valid_16   : out STD_LOGIC;
            stat_rx_framing_err_valid_17   : out STD_LOGIC;
            stat_rx_framing_err_valid_18   : out STD_LOGIC;
            stat_rx_framing_err_valid_19   : out STD_LOGIC;
            stat_rx_framing_err_valid_2    : out STD_LOGIC;
            stat_rx_framing_err_valid_3    : out STD_LOGIC;
            stat_rx_framing_err_valid_4    : out STD_LOGIC;
            stat_rx_framing_err_valid_5    : out STD_LOGIC;
            stat_rx_framing_err_valid_6    : out STD_LOGIC;
            stat_rx_framing_err_valid_7    : out STD_LOGIC;
            stat_rx_framing_err_valid_8    : out STD_LOGIC;
            stat_rx_framing_err_valid_9    : out STD_LOGIC;
            stat_rx_got_signal_os          : out STD_LOGIC;
            stat_rx_hi_ber                 : out STD_LOGIC;
            stat_rx_inrangeerr             : out STD_LOGIC;
            stat_rx_internal_local_fault   : out STD_LOGIC;
            stat_rx_jabber                 : out STD_LOGIC;
            stat_rx_local_fault            : out STD_LOGIC;
            stat_rx_mf_err                 : out STD_LOGIC_VECTOR(19 downto 0);
            stat_rx_mf_len_err             : out STD_LOGIC_VECTOR(19 downto 0);
            stat_rx_mf_repeat_err          : out STD_LOGIC_VECTOR(19 downto 0);
            stat_rx_misaligned             : out STD_LOGIC;
            stat_rx_multicast              : out STD_LOGIC;
            stat_rx_oversize               : out STD_LOGIC;
            stat_rx_packet_1024_1518_bytes : out STD_LOGIC;
            stat_rx_packet_128_255_bytes   : out STD_LOGIC;
            stat_rx_packet_1519_1522_bytes : out STD_LOGIC;
            stat_rx_packet_1523_1548_bytes : out STD_LOGIC;
            stat_rx_packet_1549_2047_bytes : out STD_LOGIC;
            stat_rx_packet_2048_4095_bytes : out STD_LOGIC;
            stat_rx_packet_256_511_bytes   : out STD_LOGIC;
            stat_rx_packet_4096_8191_bytes : out STD_LOGIC;
            stat_rx_packet_512_1023_bytes  : out STD_LOGIC;
            stat_rx_packet_64_bytes        : out STD_LOGIC;
            stat_rx_packet_65_127_bytes    : out STD_LOGIC;
            stat_rx_packet_8192_9215_bytes : out STD_LOGIC;
            stat_rx_packet_bad_fcs         : out STD_LOGIC;
            stat_rx_packet_large           : out STD_LOGIC;
            stat_rx_packet_small           : out STD_LOGIC_VECTOR(2 downto 0);
            ctl_rx_enable                  : in  STD_LOGIC;
            ctl_rx_force_resync            : in  STD_LOGIC;
            ctl_rx_test_pattern            : in  STD_LOGIC;
            core_rx_reset                  : in  STD_LOGIC;
            rx_clk                         : in  STD_LOGIC;
            stat_rx_received_local_fault   : out STD_LOGIC;
            stat_rx_remote_fault           : out STD_LOGIC;
            stat_rx_status                 : out STD_LOGIC;
            stat_rx_stomped_fcs            : out STD_LOGIC_VECTOR(2 downto 0);
            stat_rx_synced                 : out STD_LOGIC_VECTOR(19 downto 0);
            stat_rx_synced_err             : out STD_LOGIC_VECTOR(19 downto 0);
            stat_rx_test_pattern_mismatch  : out STD_LOGIC_VECTOR(2 downto 0);
            stat_rx_toolong                : out STD_LOGIC;
            stat_rx_total_bytes            : out STD_LOGIC_VECTOR(6 downto 0);
            stat_rx_total_good_bytes       : out STD_LOGIC_VECTOR(13 downto 0);
            stat_rx_total_good_packets     : out STD_LOGIC;
            stat_rx_total_packets          : out STD_LOGIC_VECTOR(2 downto 0);
            stat_rx_truncated              : out STD_LOGIC;
            stat_rx_undersize              : out STD_LOGIC_VECTOR(2 downto 0);
            stat_rx_unicast                : out STD_LOGIC;
            stat_rx_vlan                   : out STD_LOGIC;
            stat_rx_pcsl_demuxed           : out STD_LOGIC_VECTOR(19 downto 0);
            stat_rx_pcsl_number_0          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_1          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_10         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_11         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_12         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_13         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_14         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_15         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_16         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_17         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_18         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_19         : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_2          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_3          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_4          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_5          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_6          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_7          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_8          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_rx_pcsl_number_9          : out STD_LOGIC_VECTOR(4 downto 0);
            stat_tx_bad_fcs                : out STD_LOGIC;
            stat_tx_broadcast              : out STD_LOGIC;
            stat_tx_frame_error            : out STD_LOGIC;
            stat_tx_local_fault            : out STD_LOGIC;
            stat_tx_multicast              : out STD_LOGIC;
            stat_tx_packet_1024_1518_bytes : out STD_LOGIC;
            stat_tx_packet_128_255_bytes   : out STD_LOGIC;
            stat_tx_packet_1519_1522_bytes : out STD_LOGIC;
            stat_tx_packet_1523_1548_bytes : out STD_LOGIC;
            stat_tx_packet_1549_2047_bytes : out STD_LOGIC;
            stat_tx_packet_2048_4095_bytes : out STD_LOGIC;
            stat_tx_packet_256_511_bytes   : out STD_LOGIC;
            stat_tx_packet_4096_8191_bytes : out STD_LOGIC;
            stat_tx_packet_512_1023_bytes  : out STD_LOGIC;
            stat_tx_packet_64_bytes        : out STD_LOGIC;
            stat_tx_packet_65_127_bytes    : out STD_LOGIC;
            stat_tx_packet_8192_9215_bytes : out STD_LOGIC;
            stat_tx_packet_large           : out STD_LOGIC;
            stat_tx_packet_small           : out STD_LOGIC;
            stat_tx_total_bytes            : out STD_LOGIC_VECTOR(5 downto 0);
            stat_tx_total_good_bytes       : out STD_LOGIC_VECTOR(13 downto 0);
            stat_tx_total_good_packets     : out STD_LOGIC;
            stat_tx_total_packets          : out STD_LOGIC;
            stat_tx_unicast                : out STD_LOGIC;
            stat_tx_vlan                   : out STD_LOGIC;
            ctl_tx_enable                  : in  STD_LOGIC;
            ctl_tx_test_pattern            : in  STD_LOGIC;
            ctl_tx_send_idle               : in  STD_LOGIC;
            ctl_tx_send_rfi                : in  STD_LOGIC;
            ctl_tx_send_lfi                : in  STD_LOGIC;
            core_tx_reset                  : in  STD_LOGIC;
            tx_axis_tready                 : out STD_LOGIC;
            tx_axis_tvalid                 : in  STD_LOGIC;
            tx_axis_tdata                  : in  STD_LOGIC_VECTOR(511 downto 0);
            tx_axis_tlast                  : in  STD_LOGIC;
            tx_axis_tkeep                  : in  STD_LOGIC_VECTOR(63 downto 0);
            tx_axis_tuser                  : in  STD_LOGIC;
            tx_ovfout                      : out STD_LOGIC;
            tx_unfout                      : out STD_LOGIC;
            tx_preamblein                  : in  STD_LOGIC_VECTOR(55 downto 0);
            usr_tx_reset                   : out STD_LOGIC;
            core_drp_reset                 : in  STD_LOGIC;
            drp_clk                        : in  STD_LOGIC;
            drp_addr                       : in  STD_LOGIC_VECTOR(9 downto 0);
            drp_di                         : in  STD_LOGIC_VECTOR(15 downto 0);
            drp_en                         : in  STD_LOGIC;
            drp_do                         : out STD_LOGIC_VECTOR(15 downto 0);
            drp_rdy                        : out STD_LOGIC;
            drp_we                         : in  STD_LOGIC
        );
    end component EthMACPHY100GQSFP24x;

    signal lbus_rx_clk         : STD_LOGIC;
    signal lbus_tx_clk         : STD_LOGIC;
    signal lbus_rx_reset       : STD_LOGIC;
    signal lbus_tx_reset       : STD_LOGIC;
    signal ctl_tx_send_idle    : STD_LOGIC;
    signal ctl_tx_send_rfi     : STD_LOGIC;
    signal ctl_tx_send_lfi     : STD_LOGIC;
    signal ctl_tx_test_pattern : STD_LOGIC;
    signal ctl_rx_force_resync : STD_LOGIC;
    signal ctl_rx_test_pattern : STD_LOGIC;
    signal gt_loopback_in      : STD_LOGIC_VECTOR(11 DOWNTO 0);
    signal tx_preamblein       : STD_LOGIC_VECTOR(55 DOWNTO 0);

    signal ctl_tx_send_idle_unsync    : STD_LOGIC;
    signal ctl_tx_send_rfi_unsync     : STD_LOGIC;
    signal ctl_tx_send_lfi_unsync     : STD_LOGIC;
    signal ctl_tx_test_pattern_unsync : STD_LOGIC;
    signal ctl_rx_force_resync_unsync : STD_LOGIC;
    signal ctl_rx_test_pattern_unsync : STD_LOGIC;
    signal gt_loopback_in_unsync      : STD_LOGIC_VECTOR(11 DOWNTO 0);

    signal drp_clk                      : STD_LOGIC;
    signal drp_addr                     : STD_LOGIC_VECTOR(9 DOWNTO 0);
    signal drp_di                       : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal drp_en                       : STD_LOGIC;
    signal drp_we                       : STD_LOGIC;
    constant C_COUNTERS_CLOCK_FREQUENCY : NATURAL                       := 322_265_625;
    signal lRxOneSecondCounter          : NATURAL range 0 to C_COUNTERS_CLOCK_FREQUENCY - 1;
    signal lTxOneSecondCounter          : NATURAL range 0 to C_COUNTERS_CLOCK_FREQUENCY - 1;
    signal tx_packet_rate_counter       : NATURAL;
    signal tx_packet_counter            : NATURAL;
    signal tx_valid_rate_counter        : NATURAL;
    signal tx_valid_counter             : NATURAL;
    signal rx_packet_rate_counter       : NATURAL;
    signal rx_packet_counter            : NATURAL;
    signal rx_valid_rate_counter        : NATURAL;
    signal rx_valid_counter             : NATURAL;
    signal rx_bad_packet_counter        : NATURAL;
    signal tx_sync_reg_counters_reset   : std_logic;
    signal tx_unsync_reg_counters_reset : std_logic;
    signal rx_sync_reg_counters_reset   : std_logic;
    signal rx_unsync_reg_counters_reset : std_logic;
    signal laxis_tx_tlast               : std_logic;
    signal laxis_tx_tvalid              : std_logic;
    signal laxis_tx_tuser               : std_logic;
    -- Set core type to CPU_TX/RX_Enable := Enable
    -- Core Revision := 1.0
    -- Core Type :=5 := 100GbE   
    constant C_CORE_TYPE                : std_logic_vector(15 downto 0) := X"1005";
begin
    axis_tx_clkout <= lbus_tx_clk;
    lbus_rx_clk    <= axis_rx_clkin;
    lbus_rx_reset  <= Reset or lbus_reset;
    lbus_tx_reset  <= Reset or lbus_reset;
    axis_tx_tlast  <= laxis_tx_tlast;
    axis_tx_tvalid <= laxis_tx_tvalid;
    axis_tx_tuser  <= laxis_tx_tuser;

    -- We are not using the custom preamble
    tx_preamblein <= (others => '0');
    -- Tie down DRP as it is not used
    drp_clk       <= '0';
    drp_addr      <= (others => '0');
    drp_di        <= (others => '0');
    drp_en        <= '0';
    drp_we        <= '0';

    --Register MAP interface settings
    gmac_reg_core_type    <= "0000000" & Enable & "0000000" & Enable & C_CORE_TYPE;
    gmac_reg_phy_status_h <= (others => '0');
    gmac_reg_phy_status_l <= (others => '0');

    gmac_reg_tx_packet_count <= std_logic_vector(to_unsigned(tx_packet_counter, gmac_reg_tx_packet_count'length));
    gmac_reg_tx_valid_count  <= std_logic_vector(to_unsigned(tx_valid_counter, gmac_reg_tx_valid_count'length));

    gmac_reg_rx_packet_count     <= std_logic_vector(to_unsigned(rx_packet_counter, gmac_reg_rx_packet_count'length));
    gmac_reg_rx_valid_count      <= std_logic_vector(to_unsigned(rx_valid_counter, gmac_reg_rx_valid_count'length));
    gmac_reg_rx_bad_packet_count <= std_logic_vector(to_unsigned(rx_bad_packet_counter, gmac_reg_rx_bad_packet_count'length));

    PhySettingsProc : process(lbus_tx_clk)
    begin
        if rising_edge(lbus_tx_clk) then
            if ((tx_sync_reg_counters_reset = '1') or (lbus_reset = '1') or (Reset = '1')) then
                -- Don't send idle frames 
                ctl_tx_send_idle    <= '0';
                -- Don't send remote fault indicators 
                ctl_tx_send_rfi     <= '0';
                -- Don't send local fault indicators       
                ctl_tx_send_lfi     <= '0';
                -- Don't set transmitter to send test patterns 
                ctl_tx_test_pattern <= '0';
                -- Don't force resynchronizations   
                ctl_rx_force_resync <= '0';
                -- Don't set receiver to test patterns
                ctl_rx_test_pattern <= '0';
                -- Set loop back to normal operation for all 4 MGTs
                gt_loopback_in      <= X"000";
            else
                -- Don't send idle frames 
                ctl_tx_send_idle_unsync    <= gmac_reg_phy_control_h(0);
                ctl_tx_send_idle           <= ctl_tx_send_idle_unsync;
                -- Don't send remote fault indicators 
                ctl_tx_send_rfi            <= ctl_tx_send_rfi_unsync;
                ctl_tx_send_rfi_unsync     <= gmac_reg_phy_control_h(1);
                -- Don't send local fault indicators       
                ctl_tx_send_lfi            <= ctl_tx_send_lfi_unsync;
                ctl_tx_send_lfi_unsync     <= gmac_reg_phy_control_h(2);
                -- Don't set transmitter to send test patterns 
                ctl_tx_test_pattern        <= ctl_tx_test_pattern_unsync;
                ctl_tx_test_pattern_unsync <= gmac_reg_phy_control_h(3);
                -- Don't force resynchronizations   
                ctl_rx_force_resync        <= ctl_rx_force_resync_unsync;
                ctl_rx_force_resync_unsync <= gmac_reg_phy_control_h(4);
                -- Don't set receiver to test patterns
                ctl_rx_test_pattern        <= ctl_rx_test_pattern_unsync;
                ctl_rx_test_pattern_unsync <= gmac_reg_phy_control_h(5);
                -- Set loop back to normal operation for all 4 MGTs
                gt_loopback_in             <= gt_loopback_in_unsync;
                gt_loopback_in_unsync      <= gmac_reg_phy_control_l(11 downto 0);
            end if;
        end if;
    end process PhySettingsProc;

    RxCountersProc : process(lbus_tx_clk)
    begin
        if rising_edge(lbus_tx_clk) then
            -- Safely cross the clock domain from the AXILite interface to LBUS
            tx_unsync_reg_counters_reset <= gmac_reg_counters_reset;
            tx_sync_reg_counters_reset   <= tx_unsync_reg_counters_reset;
            if ((tx_sync_reg_counters_reset = '1') or (lbus_reset = '1') or (Reset = '1')) then
                -- Reset all registers to zero
                gmac_reg_rx_packet_rate <= (others => '0');
                gmac_reg_rx_valid_rate  <= (others => '0');
                rx_packet_rate_counter  <= 0;
                rx_packet_counter       <= 0;
                rx_valid_rate_counter   <= 0;
                rx_valid_counter        <= 0;
                rx_bad_packet_counter   <= 0;
                lRxOneSecondCounter     <= 0;
            else
                -- One Second Timer clock
                if (lRxOneSecondCounter = C_COUNTERS_CLOCK_FREQUENCY - 1) then
                    -- This timer is used to generate a tick every one second
                    gmac_reg_rx_packet_rate <= std_logic_vector(to_unsigned(rx_packet_rate_counter, gmac_reg_rx_packet_rate'length));
                    gmac_reg_rx_valid_rate  <= std_logic_vector(to_unsigned(rx_valid_rate_counter, gmac_reg_rx_valid_rate'length));
                    rx_packet_rate_counter  <= 0;
                    rx_valid_rate_counter   <= 0;
                    lRxOneSecondCounter     <= 0;
                else
                    if ((laxis_tx_tlast = '1') and (laxis_tx_tvalid = '1')) then
                        -- Increment the packet counters
                        rx_packet_rate_counter <= rx_packet_rate_counter + 1;
                        rx_packet_counter      <= rx_packet_counter + 1;
                    end if;

                    if ((laxis_tx_tlast = '1') and (laxis_tx_tvalid = '1') and (laxis_tx_tuser = '0')) then
                        -- Increment the valid counters
                        rx_valid_rate_counter <= rx_valid_rate_counter + 1;
                        rx_valid_counter      <= rx_valid_counter + 1;
                    end if;
                    if ((laxis_tx_tlast = '1') and (laxis_tx_tvalid = '1') and (laxis_tx_tuser = '1')) then
                        -- Increment the bad packet counters
                        rx_bad_packet_counter <= rx_bad_packet_counter + 1;
                    end if;
                    lRxOneSecondCounter <= lRxOneSecondCounter + 1;
                end if;

            end if;
        end if;
    end process RxCountersProc;

    TxCountersProc : process(lbus_rx_clk)
    begin
        if rising_edge(lbus_rx_clk) then
            -- Safely cross the clock domain from the AXILite interface to LBUS
            rx_unsync_reg_counters_reset <= gmac_reg_counters_reset;
            rx_sync_reg_counters_reset   <= rx_unsync_reg_counters_reset;
            if ((rx_sync_reg_counters_reset = '1') or (lbus_reset = '1') or (Reset = '1')) then
                -- Reset all registers to zero
                gmac_reg_tx_packet_rate <= (others => '0');
                gmac_reg_tx_valid_rate  <= (others => '0');
                tx_packet_rate_counter  <= 0;
                tx_packet_counter       <= 0;
                tx_valid_rate_counter   <= 0;
                tx_valid_counter        <= 0;
                lTxOneSecondCounter     <= 0;
            else
                -- One Second Timer clock
                if (lTxOneSecondCounter = C_COUNTERS_CLOCK_FREQUENCY - 1) then
                    -- This timer is used to generate a tick every one second
                    gmac_reg_tx_packet_rate <= std_logic_vector(to_unsigned(tx_packet_rate_counter, gmac_reg_tx_packet_rate'length));
                    gmac_reg_tx_valid_rate  <= std_logic_vector(to_unsigned(tx_valid_rate_counter, gmac_reg_tx_valid_rate'length));
                    tx_packet_rate_counter  <= 0;
                    tx_valid_rate_counter   <= 0;
                    lTxOneSecondCounter     <= 0;
                else
                    if ((axis_rx_tlast = '1') and (axis_rx_tvalid = '1')) then
                        -- Increment the packet counters
                        tx_packet_rate_counter <= tx_packet_rate_counter + 1;
                        tx_packet_counter      <= tx_packet_counter + 1;
                    end if;

                    if ((axis_rx_tlast = '1') and (axis_rx_tvalid = '1') and (axis_rx_tuser = '0')) then
                        -- Increment the valid counters
                        tx_valid_rate_counter <= tx_valid_rate_counter + 1;
                        tx_valid_counter      <= tx_valid_counter + 1;
                    end if;

                    lTxOneSecondCounter <= lTxOneSecondCounter + 1;
                end if;

            end if;
        end if;
    end process TxCountersProc;

    MACPHY_QSFP2_i : EthMACPHY100GQSFP24x
        port map(
            gt_rxp_in                      => qsfp_mgt_rx_p,
            gt_rxn_in                      => qsfp_mgt_rx_n,
            gt_txp_out                     => qsfp_mgt_tx_p,
            gt_txn_out                     => qsfp_mgt_tx_n,
            gt_txusrclk2                   => lbus_tx_clk,
            gt_loopback_in                 => gt_loopback_in,
            gt_rxrecclkout                 => open,
            gt_powergoodout                => open,
            gt_ref_clk_out                 => open,
            gtwiz_reset_tx_datapath        => lbus_tx_reset,
            gtwiz_reset_rx_datapath        => lbus_rx_reset,
            sys_reset                      => Reset,
            gt_ref_clk_p                   => mgt_qsfp_clock_p,
            gt_ref_clk_n                   => mgt_qsfp_clock_n,
            init_clk                       => Clk100MHz,
            rx_axis_tvalid                 => laxis_tx_tvalid,
            rx_axis_tdata                  => axis_tx_tdata,
            rx_axis_tlast                  => laxis_tx_tlast,
            rx_axis_tkeep                  => axis_tx_tkeep,
            rx_axis_tuser                  => laxis_tx_tuser,
            rx_otn_bip8_0                  => open,
            rx_otn_bip8_1                  => open,
            rx_otn_bip8_2                  => open,
            rx_otn_bip8_3                  => open,
            rx_otn_bip8_4                  => open,
            rx_otn_data_0                  => open,
            rx_otn_data_1                  => open,
            rx_otn_data_2                  => open,
            rx_otn_data_3                  => open,
            rx_otn_data_4                  => open,
            rx_otn_ena                     => open,
            rx_otn_lane0                   => open,
            rx_otn_vlmarker                => open,
            rx_preambleout                 => open,
            usr_rx_reset                   => open,
            gt_rxusrclk2                   => open,
            stat_rx_aligned                => open,
            stat_rx_aligned_err            => open,
            stat_rx_bad_code               => open,
            stat_rx_bad_fcs                => open,
            stat_rx_bad_preamble           => open,
            stat_rx_bad_sfd                => open,
            stat_rx_bip_err_0              => open,
            stat_rx_bip_err_1              => open,
            stat_rx_bip_err_10             => open,
            stat_rx_bip_err_11             => open,
            stat_rx_bip_err_12             => open,
            stat_rx_bip_err_13             => open,
            stat_rx_bip_err_14             => open,
            stat_rx_bip_err_15             => open,
            stat_rx_bip_err_16             => open,
            stat_rx_bip_err_17             => open,
            stat_rx_bip_err_18             => open,
            stat_rx_bip_err_19             => open,
            stat_rx_bip_err_2              => open,
            stat_rx_bip_err_3              => open,
            stat_rx_bip_err_4              => open,
            stat_rx_bip_err_5              => open,
            stat_rx_bip_err_6              => open,
            stat_rx_bip_err_7              => open,
            stat_rx_bip_err_8              => open,
            stat_rx_bip_err_9              => open,
            stat_rx_block_lock             => open,
            stat_rx_broadcast              => open,
            stat_rx_fragment               => open,
            stat_rx_framing_err_0          => open,
            stat_rx_framing_err_1          => open,
            stat_rx_framing_err_10         => open,
            stat_rx_framing_err_11         => open,
            stat_rx_framing_err_12         => open,
            stat_rx_framing_err_13         => open,
            stat_rx_framing_err_14         => open,
            stat_rx_framing_err_15         => open,
            stat_rx_framing_err_16         => open,
            stat_rx_framing_err_17         => open,
            stat_rx_framing_err_18         => open,
            stat_rx_framing_err_19         => open,
            stat_rx_framing_err_2          => open,
            stat_rx_framing_err_3          => open,
            stat_rx_framing_err_4          => open,
            stat_rx_framing_err_5          => open,
            stat_rx_framing_err_6          => open,
            stat_rx_framing_err_7          => open,
            stat_rx_framing_err_8          => open,
            stat_rx_framing_err_9          => open,
            stat_rx_framing_err_valid_0    => open,
            stat_rx_framing_err_valid_1    => open,
            stat_rx_framing_err_valid_10   => open,
            stat_rx_framing_err_valid_11   => open,
            stat_rx_framing_err_valid_12   => open,
            stat_rx_framing_err_valid_13   => open,
            stat_rx_framing_err_valid_14   => open,
            stat_rx_framing_err_valid_15   => open,
            stat_rx_framing_err_valid_16   => open,
            stat_rx_framing_err_valid_17   => open,
            stat_rx_framing_err_valid_18   => open,
            stat_rx_framing_err_valid_19   => open,
            stat_rx_framing_err_valid_2    => open,
            stat_rx_framing_err_valid_3    => open,
            stat_rx_framing_err_valid_4    => open,
            stat_rx_framing_err_valid_5    => open,
            stat_rx_framing_err_valid_6    => open,
            stat_rx_framing_err_valid_7    => open,
            stat_rx_framing_err_valid_8    => open,
            stat_rx_framing_err_valid_9    => open,
            stat_rx_got_signal_os          => open,
            stat_rx_hi_ber                 => open,
            stat_rx_inrangeerr             => open,
            stat_rx_internal_local_fault   => open,
            stat_rx_jabber                 => open,
            stat_rx_local_fault            => open,
            stat_rx_mf_err                 => open,
            stat_rx_mf_len_err             => open,
            stat_rx_mf_repeat_err          => open,
            stat_rx_misaligned             => open,
            stat_rx_multicast              => open,
            stat_rx_oversize               => open,
            stat_rx_packet_1024_1518_bytes => open,
            stat_rx_packet_128_255_bytes   => open,
            stat_rx_packet_1519_1522_bytes => open,
            stat_rx_packet_1523_1548_bytes => open,
            stat_rx_packet_1549_2047_bytes => open,
            stat_rx_packet_2048_4095_bytes => open,
            stat_rx_packet_256_511_bytes   => open,
            stat_rx_packet_4096_8191_bytes => open,
            stat_rx_packet_512_1023_bytes  => open,
            stat_rx_packet_64_bytes        => open,
            stat_rx_packet_65_127_bytes    => open,
            stat_rx_packet_8192_9215_bytes => open,
            stat_rx_packet_bad_fcs         => open,
            stat_rx_packet_large           => open,
            stat_rx_packet_small           => open,
            ctl_rx_enable                  => Enable,
            ctl_rx_force_resync            => ctl_rx_force_resync,
            ctl_rx_test_pattern            => ctl_rx_test_pattern,
            core_rx_reset                  => lbus_rx_reset,
            rx_clk                         => lbus_rx_clk,
            stat_rx_received_local_fault   => open,
            stat_rx_remote_fault           => open,
            stat_rx_status                 => open,
            stat_rx_stomped_fcs            => open,
            stat_rx_synced                 => open,
            stat_rx_synced_err             => open,
            stat_rx_test_pattern_mismatch  => open,
            stat_rx_toolong                => open,
            stat_rx_total_bytes            => open,
            stat_rx_total_good_bytes       => open,
            stat_rx_total_good_packets     => open,
            stat_rx_total_packets          => open,
            stat_rx_truncated              => open,
            stat_rx_undersize              => open,
            stat_rx_unicast                => open,
            stat_rx_vlan                   => open,
            stat_rx_pcsl_demuxed           => open,
            stat_rx_pcsl_number_0          => open,
            stat_rx_pcsl_number_1          => open,
            stat_rx_pcsl_number_10         => open,
            stat_rx_pcsl_number_11         => open,
            stat_rx_pcsl_number_12         => open,
            stat_rx_pcsl_number_13         => open,
            stat_rx_pcsl_number_14         => open,
            stat_rx_pcsl_number_15         => open,
            stat_rx_pcsl_number_16         => open,
            stat_rx_pcsl_number_17         => open,
            stat_rx_pcsl_number_18         => open,
            stat_rx_pcsl_number_19         => open,
            stat_rx_pcsl_number_2          => open,
            stat_rx_pcsl_number_3          => open,
            stat_rx_pcsl_number_4          => open,
            stat_rx_pcsl_number_5          => open,
            stat_rx_pcsl_number_6          => open,
            stat_rx_pcsl_number_7          => open,
            stat_rx_pcsl_number_8          => open,
            stat_rx_pcsl_number_9          => open,
            stat_tx_bad_fcs                => open,
            stat_tx_broadcast              => open,
            stat_tx_frame_error            => open,
            stat_tx_local_fault            => open,
            stat_tx_multicast              => open,
            stat_tx_packet_1024_1518_bytes => open,
            stat_tx_packet_128_255_bytes   => open,
            stat_tx_packet_1519_1522_bytes => open,
            stat_tx_packet_1523_1548_bytes => open,
            stat_tx_packet_1549_2047_bytes => open,
            stat_tx_packet_2048_4095_bytes => open,
            stat_tx_packet_256_511_bytes   => open,
            stat_tx_packet_4096_8191_bytes => open,
            stat_tx_packet_512_1023_bytes  => open,
            stat_tx_packet_64_bytes        => open,
            stat_tx_packet_65_127_bytes    => open,
            stat_tx_packet_8192_9215_bytes => open,
            stat_tx_packet_large           => open,
            stat_tx_packet_small           => open,
            stat_tx_total_bytes            => open,
            stat_tx_total_good_bytes       => open,
            stat_tx_total_good_packets     => open,
            stat_tx_total_packets          => open,
            stat_tx_unicast                => open,
            stat_tx_vlan                   => open,
            ctl_tx_enable                  => Enable,
            ctl_tx_test_pattern            => ctl_tx_test_pattern,
            ctl_tx_send_idle               => ctl_tx_send_idle,
            ctl_tx_send_rfi                => ctl_tx_send_rfi,
            ctl_tx_send_lfi                => ctl_tx_send_lfi,
            core_tx_reset                  => lbus_tx_reset,
            tx_axis_tready                 => axis_rx_tready,
            tx_axis_tvalid                 => axis_rx_tvalid,
            tx_axis_tdata                  => axis_rx_tdata,
            tx_axis_tlast                  => axis_rx_tlast,
            tx_axis_tkeep                  => axis_rx_tkeep,
            tx_axis_tuser                  => axis_rx_tuser,
            tx_ovfout                      => lbus_tx_ovfout,
            tx_unfout                      => lbus_tx_unfout,
            tx_preamblein                  => tx_preamblein,
            usr_tx_reset                   => open,
            core_drp_reset                 => Reset,
            drp_clk                        => drp_clk,
            drp_addr                       => drp_addr,
            drp_di                         => drp_di,
            drp_en                         => drp_en,
            drp_do                         => open,
            drp_rdy                        => open,
            drp_we                         => drp_we
        );

end architecture rtl;
