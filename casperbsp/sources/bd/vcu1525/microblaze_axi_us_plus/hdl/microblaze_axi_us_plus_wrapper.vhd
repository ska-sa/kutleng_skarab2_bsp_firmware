--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
--Date        : Fri Apr  5 08:30:42 2019
--Host        : benjamin-ubuntu-ws running 64-bit Ubuntu 16.04.5 LTS
--Command     : generate_target microblaze_axi_us_plus_wrapper.bd
--Design      : microblaze_axi_us_plus_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--library UNISIM;
--use UNISIM.VCOMPONENTS.ALL;
entity microblaze_axi_us_plus_wrapper is
	generic(
		-- Users to add parameters here
		C_ARP_CACHE_ASIZE      : natural := 13;
		C_DATA_TX_BUFFER_ASIZE : natural := 13;
		C_DATA_RX_BUFFER_ASIZE : natural := 13;
		C_SLOT_WIDTH           : natural := 4
	);
	port(
		------------------------------------------------------------------------
		-- MAC PHY Register Interface according to EthernetCore Memory MAP    --
		------------------------------------------------------------------------ 
		gmac_reg_phy_control_h                 : in  STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_phy_control_l                 : in  STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_mac_address                   : in  STD_LOGIC_VECTOR(47 downto 0);
		gmac_reg_local_ip_address              : in  STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_gateway_ip_address            : in  STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_multicast_ip_address          : in  STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_multicast_ip_mask             : in  STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_udp_port                      : in  STD_LOGIC_VECTOR(15 downto 0);
		gmac_reg_udp_port_mask                 : in  STD_LOGIC_VECTOR(15 downto 0);
		gmac_reg_mac_enable                    : in  STD_LOGIC;
		gmac_reg_mac_promiscous_mode           : in  STD_LOGIC;
		gmac_reg_counters_reset                : in  STD_LOGIC;
		gmac_reg_core_type                     : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_phy_status_h                  : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_phy_status_l                  : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_tx_packet_rate                : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_tx_packet_count               : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_tx_valid_rate                 : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_tx_valid_count                : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_tx_overflow_count             : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_tx_afull_count                : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_rx_packet_rate                : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_rx_packet_count               : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_rx_valid_rate                 : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_rx_valid_count                : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_rx_overflow_count             : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_rx_almost_full_count          : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_rx_bad_packet_count           : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_arp_size                      : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_reg_tx_word_size                  : out STD_LOGIC_VECTOR(15 downto 0);
		gmac_reg_rx_word_size                  : out STD_LOGIC_VECTOR(15 downto 0);
		gmac_reg_tx_buffer_max_size            : out STD_LOGIC_VECTOR(15 downto 0);
		gmac_reg_rx_buffer_max_size            : out STD_LOGIC_VECTOR(15 downto 0);
		gmac_arp_cache_write_enable            : in  STD_LOGIC;
		gmac_arp_cache_read_enable             : in  STD_LOGIC;
		gmac_arp_cache_write_data              : in  STD_LOGIC_VECTOR(31 downto 0);
		gmac_arp_cache_read_data               : out STD_LOGIC_VECTOR(31 downto 0);
		gmac_arp_cache_write_address           : in  STD_LOGIC_VECTOR(C_ARP_CACHE_ASIZE - 1 downto 0);
		gmac_arp_cache_read_address            : in  STD_LOGIC_VECTOR(C_ARP_CACHE_ASIZE - 1 downto 0);
		gmac_tx_data_write_enable              : in  STD_LOGIC;
		gmac_tx_data_read_enable               : in  STD_LOGIC;
		gmac_tx_data_write_data                : in  STD_LOGIC_VECTOR(15 downto 0);
		gmac_tx_data_write_byte_enable         : in  STD_LOGIC_VECTOR(2 downto 0);
		gmac_tx_data_read_data                 : out STD_LOGIC_VECTOR(15 downto 0);
		gmac_tx_data_read_byte_enable          : out STD_LOGIC_VECTOR(2 downto 0);
		gmac_tx_data_write_address             : in  STD_LOGIC_VECTOR(C_DATA_TX_BUFFER_ASIZE - 1 downto 0);
		gmac_tx_data_read_address              : in  STD_LOGIC_VECTOR(C_DATA_TX_BUFFER_ASIZE - 1 downto 0);
		gmac_tx_ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
		gmac_tx_ringbuffer_slot_set            : in  STD_LOGIC;
		gmac_tx_ringbuffer_slot_status         : out STD_LOGIC;
		gmac_tx_ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
		gmac_rx_data_write_enable              : in  STD_LOGIC;
		gmac_rx_data_read_enable               : in  STD_LOGIC;
		gmac_rx_data_write_data                : in  STD_LOGIC_VECTOR(15 downto 0);
		gmac_rx_data_write_byte_enable         : in  STD_LOGIC_VECTOR(2 downto 0);
		gmac_rx_data_read_data                 : out STD_LOGIC_VECTOR(15 downto 0);
		gmac_rx_data_read_byte_enable          : out STD_LOGIC_VECTOR(2 downto 0);
		gmac_rx_data_write_address             : in  STD_LOGIC_VECTOR(C_DATA_RX_BUFFER_ASIZE - 1 downto 0);
		gmac_rx_data_read_address              : in  STD_LOGIC_VECTOR(C_DATA_RX_BUFFER_ASIZE - 1 downto 0);
		gmac_rx_ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
		gmac_rx_ringbuffer_slot_clear          : in  STD_LOGIC;
		gmac_rx_ringbuffer_slot_status         : out STD_LOGIC;
		gmac_rx_ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
		ClockStable                            : in  STD_LOGIC;
		PSClock                                : in  STD_LOGIC;
		PSReset                                : in  STD_LOGIC;
		rs232_uart_rxd                         : in  STD_LOGIC;
		rs232_uart_txd                         : out STD_LOGIC
	);
end microblaze_axi_us_plus_wrapper;

architecture STRUCTURE of microblaze_axi_us_plus_wrapper is
	component microblaze_axi_us_plus is
		generic(
			-- Users to add parameters here
			C_ARP_CACHE_ASIZE      : natural := 13;
			C_DATA_TX_BUFFER_ASIZE : natural := 13;
			C_DATA_RX_BUFFER_ASIZE : natural := 13;
			C_SLOT_WIDTH           : natural := 4
		);
		port(
			------------------------------------------------------------------------
			-- MAC PHY Register Interface according to EthernetCore Memory MAP    --
			------------------------------------------------------------------------ 
			gmac_reg_phy_control_h                 : in  STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_phy_control_l                 : in  STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_mac_address                   : in  STD_LOGIC_VECTOR(47 downto 0);
			gmac_reg_local_ip_address              : in  STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_gateway_ip_address            : in  STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_multicast_ip_address          : in  STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_multicast_ip_mask             : in  STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_udp_port                      : in  STD_LOGIC_VECTOR(15 downto 0);
			gmac_reg_udp_port_mask                 : in  STD_LOGIC_VECTOR(15 downto 0);
			gmac_reg_mac_enable                    : in  STD_LOGIC;
			gmac_reg_mac_promiscous_mode           : in  STD_LOGIC;
			gmac_reg_counters_reset                : in  STD_LOGIC;
			gmac_reg_core_type                     : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_phy_status_h                  : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_phy_status_l                  : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_tx_packet_rate                : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_tx_packet_count               : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_tx_valid_rate                 : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_tx_valid_count                : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_tx_overflow_count             : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_tx_afull_count                : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_rx_packet_rate                : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_rx_packet_count               : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_rx_valid_rate                 : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_rx_valid_count                : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_rx_overflow_count             : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_rx_almost_full_count          : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_rx_bad_packet_count           : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_arp_size                      : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_reg_tx_word_size                  : out STD_LOGIC_VECTOR(15 downto 0);
			gmac_reg_rx_word_size                  : out STD_LOGIC_VECTOR(15 downto 0);
			gmac_reg_tx_buffer_max_size            : out STD_LOGIC_VECTOR(15 downto 0);
			gmac_reg_rx_buffer_max_size            : out STD_LOGIC_VECTOR(15 downto 0);
			gmac_arp_cache_write_enable            : in  STD_LOGIC;
			gmac_arp_cache_read_enable             : in  STD_LOGIC;
			gmac_arp_cache_write_data              : in  STD_LOGIC_VECTOR(31 downto 0);
			gmac_arp_cache_read_data               : out STD_LOGIC_VECTOR(31 downto 0);
			gmac_arp_cache_write_address           : in  STD_LOGIC_VECTOR(C_ARP_CACHE_ASIZE - 1 downto 0);
			gmac_arp_cache_read_address            : in  STD_LOGIC_VECTOR(C_ARP_CACHE_ASIZE - 1 downto 0);
			gmac_tx_data_write_enable              : in  STD_LOGIC;
			gmac_tx_data_read_enable               : in  STD_LOGIC;
			gmac_tx_data_write_data                : in  STD_LOGIC_VECTOR(15 downto 0);
			gmac_tx_data_write_byte_enable         : in  STD_LOGIC_VECTOR(2 downto 0);
			gmac_tx_data_read_data                 : out STD_LOGIC_VECTOR(15 downto 0);
			gmac_tx_data_read_byte_enable          : out STD_LOGIC_VECTOR(2 downto 0);
			gmac_tx_data_write_address             : in  STD_LOGIC_VECTOR(C_DATA_TX_BUFFER_ASIZE - 1 downto 0);
			gmac_tx_data_read_address              : in  STD_LOGIC_VECTOR(C_DATA_TX_BUFFER_ASIZE - 1 downto 0);
			gmac_tx_ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
			gmac_tx_ringbuffer_slot_set            : in  STD_LOGIC;
			gmac_tx_ringbuffer_slot_status         : out STD_LOGIC;
			gmac_tx_ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
			gmac_rx_data_write_enable              : in  STD_LOGIC;
			gmac_rx_data_read_enable               : in  STD_LOGIC;
			gmac_rx_data_write_data                : in  STD_LOGIC_VECTOR(15 downto 0);
			gmac_rx_data_write_byte_enable         : in  STD_LOGIC_VECTOR(2 downto 0);
			gmac_rx_data_read_data                 : out STD_LOGIC_VECTOR(15 downto 0);
			gmac_rx_data_read_byte_enable          : out STD_LOGIC_VECTOR(2 downto 0);
			gmac_rx_data_write_address             : in  STD_LOGIC_VECTOR(C_DATA_RX_BUFFER_ASIZE - 1 downto 0);
			gmac_rx_data_read_address              : in  STD_LOGIC_VECTOR(C_DATA_RX_BUFFER_ASIZE - 1 downto 0);
			gmac_rx_ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
			gmac_rx_ringbuffer_slot_clear          : in  STD_LOGIC;
			gmac_rx_ringbuffer_slot_status         : out STD_LOGIC;
			gmac_rx_ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
			PSClock                                : in  STD_LOGIC;
			PSReset                                : in  STD_LOGIC;
			ClockStable                            : in  STD_LOGIC;
			rs232_uart_rxd                         : in  STD_LOGIC;
			rs232_uart_txd                         : out STD_LOGIC
		);
	end component microblaze_axi_us_plus;
begin
	microblaze_axi_us_plus_i : component microblaze_axi_us_plus
		generic map(
			-- Users to add parameters here
			C_ARP_CACHE_ASIZE      => C_ARP_CACHE_ASIZE,
			C_DATA_TX_BUFFER_ASIZE => C_DATA_TX_BUFFER_ASIZE,
			C_DATA_RX_BUFFER_ASIZE => C_DATA_RX_BUFFER_ASIZE,
			C_SLOT_WIDTH           => C_SLOT_WIDTH
		)
		port map(
			gmac_reg_phy_control_h                 => gmac_reg_phy_control_h,
			gmac_reg_phy_control_l                 => gmac_reg_phy_control_l,
			gmac_reg_mac_address                   => gmac_reg_mac_address,
			gmac_reg_local_ip_address              => gmac_reg_local_ip_address,
			gmac_reg_gateway_ip_address            => gmac_reg_gateway_ip_address,
			gmac_reg_multicast_ip_address          => gmac_reg_multicast_ip_address,
			gmac_reg_multicast_ip_mask             => gmac_reg_multicast_ip_mask,
			gmac_reg_udp_port                      => gmac_reg_udp_port,
			gmac_reg_udp_port_mask                 => gmac_reg_udp_port_mask,
			gmac_reg_mac_enable                    => gmac_reg_mac_enable,
			gmac_reg_mac_promiscous_mode           => gmac_reg_mac_promiscous_mode,
			gmac_reg_counters_reset                => gmac_reg_counters_reset,
			gmac_reg_core_type                     => gmac_reg_core_type,
			gmac_reg_phy_status_h                  => gmac_reg_phy_status_h,
			gmac_reg_phy_status_l                  => gmac_reg_phy_status_l,
			gmac_reg_tx_packet_rate                => gmac_reg_tx_packet_rate,
			gmac_reg_tx_packet_count               => gmac_reg_tx_packet_count,
			gmac_reg_tx_valid_rate                 => gmac_reg_tx_valid_rate,
			gmac_reg_tx_valid_count                => gmac_reg_tx_valid_count,
			gmac_reg_tx_overflow_count             => gmac_reg_tx_overflow_count,
			gmac_reg_tx_afull_count                => gmac_reg_tx_afull_count,
			gmac_reg_rx_packet_rate                => gmac_reg_rx_packet_rate,
			gmac_reg_rx_packet_count               => gmac_reg_rx_packet_count,
			gmac_reg_rx_valid_rate                 => gmac_reg_rx_valid_rate,
			gmac_reg_rx_valid_count                => gmac_reg_rx_valid_count,
			gmac_reg_rx_overflow_count             => gmac_reg_rx_overflow_count,
			gmac_reg_rx_almost_full_count          => gmac_reg_rx_almost_full_count,
			gmac_reg_rx_bad_packet_count           => gmac_reg_rx_bad_packet_count,
			gmac_reg_arp_size                      => gmac_reg_arp_size,
			gmac_reg_tx_word_size                  => gmac_reg_tx_word_size,
			gmac_reg_rx_word_size                  => gmac_reg_rx_word_size,
			gmac_reg_tx_buffer_max_size            => gmac_reg_tx_buffer_max_size,
			gmac_reg_rx_buffer_max_size            => gmac_reg_rx_buffer_max_size,
			gmac_arp_cache_write_enable            => gmac_arp_cache_write_enable,
			gmac_arp_cache_read_enable             => gmac_arp_cache_read_enable,
			gmac_arp_cache_write_data              => gmac_arp_cache_write_data,
			gmac_arp_cache_read_data               => gmac_arp_cache_read_data,
			gmac_arp_cache_write_address           => gmac_arp_cache_write_address,
			gmac_arp_cache_read_address            => gmac_arp_cache_read_address,
			gmac_tx_data_write_enable              => gmac_tx_data_write_enable,
			gmac_tx_data_read_enable               => gmac_tx_data_read_enable,
			gmac_tx_data_write_data                => gmac_tx_data_write_data,
			gmac_tx_data_write_byte_enable         => gmac_tx_data_write_byte_enable,
			gmac_tx_data_read_data                 => gmac_tx_data_read_data,
			gmac_tx_data_read_byte_enable          => gmac_tx_data_read_byte_enable,
			gmac_tx_data_write_address             => gmac_tx_data_write_address,
			gmac_tx_data_read_address              => gmac_tx_data_read_address,
			gmac_tx_ringbuffer_slot_id             => gmac_tx_ringbuffer_slot_id,
			gmac_tx_ringbuffer_slot_set            => gmac_tx_ringbuffer_slot_set,
			gmac_tx_ringbuffer_slot_status         => gmac_tx_ringbuffer_slot_status,
			gmac_tx_ringbuffer_number_slots_filled => gmac_tx_ringbuffer_number_slots_filled,
			gmac_rx_data_write_enable              => gmac_rx_data_write_enable,
			gmac_rx_data_read_enable               => gmac_rx_data_read_enable,
			gmac_rx_data_write_data                => gmac_rx_data_write_data,
			gmac_rx_data_write_byte_enable         => gmac_rx_data_write_byte_enable,
			gmac_rx_data_read_data                 => gmac_rx_data_read_data,
			gmac_rx_data_read_byte_enable          => gmac_rx_data_read_byte_enable,
			gmac_rx_data_write_address             => gmac_rx_data_write_address,
			gmac_rx_data_read_address              => gmac_rx_data_read_address,
			gmac_rx_ringbuffer_slot_id             => gmac_rx_ringbuffer_slot_id,
			gmac_rx_ringbuffer_slot_clear          => gmac_rx_ringbuffer_slot_clear,
			gmac_rx_ringbuffer_slot_status         => gmac_rx_ringbuffer_slot_status,
			gmac_rx_ringbuffer_number_slots_filled => gmac_rx_ringbuffer_number_slots_filled,
			ClockStable                            => ClockStable,
			PSClock                                => PSClock,
			PSReset                                => PSReset,
			rs232_uart_rxd                         => rs232_uart_rxd,
			rs232_uart_txd                         => rs232_uart_txd
		);
end STRUCTURE;
