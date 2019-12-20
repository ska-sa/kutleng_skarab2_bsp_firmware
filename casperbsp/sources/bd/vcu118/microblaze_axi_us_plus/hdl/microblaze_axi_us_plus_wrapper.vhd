--Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2019.2 (lin64) Build 2700185 Thu Oct 24 18:45:48 MDT 2019
--Date        : Sat Nov 16 17:59:48 2019
--Host        : benjamin-ubuntu-ws running 64-bit Ubuntu 18.04.3 LTS
--Command     : generate_target microblaze_axi_us_plus_wrapper.bd
--Design      : microblaze_axi_us_plus_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity microblaze_axi_us_plus_wrapper is
  port (
    ClockStable : in STD_LOGIC;
    PSClock : in STD_LOGIC;
    PSReset : in STD_LOGIC;
    gmac_arp_cache_read_address : out STD_LOGIC_VECTOR ( 9 downto 0 );
    gmac_arp_cache_read_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_arp_cache_read_enable : out STD_LOGIC;
    gmac_arp_cache_write_address : out STD_LOGIC_VECTOR ( 9 downto 0 );
    gmac_arp_cache_write_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_arp_cache_write_enable : out STD_LOGIC;
    gmac_reg_arp_size : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_core_type : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_counters_reset : out STD_LOGIC;
    gmac_reg_gateway_ip_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_local_ip_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_mac_address : out STD_LOGIC_VECTOR ( 47 downto 0 );
    gmac_reg_mac_enable : out STD_LOGIC;
    gmac_reg_mac_promiscous_mode : out STD_LOGIC;
    gmac_reg_multicast_ip_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_multicast_ip_mask : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_phy_control_h : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_phy_control_l : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_phy_status_h : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_phy_status_l : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_almost_full_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_bad_packet_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_buffer_max_size : in STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_reg_rx_overflow_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_packet_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_packet_rate : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_valid_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_valid_rate : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_word_size : in STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_reg_tx_afull_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_buffer_max_size : in STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_reg_tx_overflow_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_packet_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_packet_rate : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_valid_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_valid_rate : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_word_size : in STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_reg_udp_port : out STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_reg_udp_port_mask : out STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_rx_data_read_address : out STD_LOGIC_VECTOR ( 10 downto 0 );
    gmac_rx_data_read_byte_enable : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gmac_rx_data_read_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    gmac_rx_data_read_enable : out STD_LOGIC;
    gmac_rx_data_write_address : out STD_LOGIC_VECTOR ( 10 downto 0 );
    gmac_rx_data_write_byte_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gmac_rx_data_write_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gmac_rx_data_write_enable : out STD_LOGIC;
    gmac_rx_ringbuffer_number_slots_filled : in STD_LOGIC_VECTOR ( 3 downto 0 );
    gmac_rx_ringbuffer_slot_clear : out STD_LOGIC;
    gmac_rx_ringbuffer_slot_id : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gmac_rx_ringbuffer_slot_status : in STD_LOGIC;
    gmac_tx_data_read_address : out STD_LOGIC_VECTOR ( 10 downto 0 );
    gmac_tx_data_read_byte_enable : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gmac_tx_data_read_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    gmac_tx_data_read_enable : out STD_LOGIC;
    gmac_tx_data_write_address : out STD_LOGIC_VECTOR ( 10 downto 0 );
    gmac_tx_data_write_byte_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gmac_tx_data_write_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gmac_tx_data_write_enable : out STD_LOGIC;
    gmac_tx_ringbuffer_number_slots_filled : in STD_LOGIC_VECTOR ( 3 downto 0 );
    gmac_tx_ringbuffer_slot_id : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gmac_tx_ringbuffer_slot_set : out STD_LOGIC;
    gmac_tx_ringbuffer_slot_status : in STD_LOGIC;
    rs232_uart_rxd : in STD_LOGIC;
    rs232_uart_txd : out STD_LOGIC
  );
end microblaze_axi_us_plus_wrapper;

architecture STRUCTURE of microblaze_axi_us_plus_wrapper is
  component microblaze_axi_us_plus is
  port (
    ClockStable : in STD_LOGIC;
    PSClock : in STD_LOGIC;
    PSReset : in STD_LOGIC;
    gmac_reg_mac_promiscous_mode : out STD_LOGIC;
    gmac_arp_cache_write_enable : out STD_LOGIC;
    gmac_reg_counters_reset : out STD_LOGIC;
    gmac_reg_phy_control_l : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_mac_address : out STD_LOGIC_VECTOR ( 47 downto 0 );
    gmac_reg_local_ip_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_phy_control_h : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_gateway_ip_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_multicast_ip_address : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_multicast_ip_mask : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_udp_port : out STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_reg_udp_port_mask : out STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_arp_cache_write_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_mac_enable : out STD_LOGIC;
    gmac_arp_cache_read_enable : out STD_LOGIC;
    gmac_arp_cache_write_address : out STD_LOGIC_VECTOR ( 9 downto 0 );
    gmac_tx_data_write_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gmac_arp_cache_read_address : out STD_LOGIC_VECTOR ( 9 downto 0 );
    gmac_tx_data_write_byte_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gmac_tx_data_write_address : out STD_LOGIC_VECTOR ( 10 downto 0 );
    gmac_tx_data_write_enable : out STD_LOGIC;
    gmac_tx_data_read_address : out STD_LOGIC_VECTOR ( 10 downto 0 );
    gmac_tx_ringbuffer_slot_id : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gmac_tx_data_read_enable : out STD_LOGIC;
    gmac_rx_data_write_data : out STD_LOGIC_VECTOR ( 7 downto 0 );
    gmac_rx_data_write_address : out STD_LOGIC_VECTOR ( 10 downto 0 );
    gmac_rx_data_write_byte_enable : out STD_LOGIC_VECTOR ( 1 downto 0 );
    gmac_rx_data_write_enable : out STD_LOGIC;
    gmac_rx_data_read_address : out STD_LOGIC_VECTOR ( 10 downto 0 );
    gmac_rx_ringbuffer_slot_id : out STD_LOGIC_VECTOR ( 3 downto 0 );
    gmac_tx_ringbuffer_slot_set : out STD_LOGIC;
    gmac_rx_data_read_enable : out STD_LOGIC;
    gmac_rx_ringbuffer_slot_clear : out STD_LOGIC;
    gmac_rx_ringbuffer_number_slots_filled : in STD_LOGIC_VECTOR ( 3 downto 0 );
    gmac_tx_data_read_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    gmac_reg_rx_overflow_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_tx_data_read_byte_enable : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gmac_rx_ringbuffer_slot_status : in STD_LOGIC;
    gmac_reg_rx_almost_full_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_bad_packet_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_tx_ringbuffer_number_slots_filled : in STD_LOGIC_VECTOR ( 3 downto 0 );
    gmac_reg_arp_size : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_word_size : in STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_tx_ringbuffer_slot_status : in STD_LOGIC;
    gmac_reg_rx_word_size : in STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_reg_tx_buffer_max_size : in STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_rx_data_read_data : in STD_LOGIC_VECTOR ( 7 downto 0 );
    gmac_reg_rx_buffer_max_size : in STD_LOGIC_VECTOR ( 15 downto 0 );
    gmac_arp_cache_read_data : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_rx_data_read_byte_enable : in STD_LOGIC_VECTOR ( 1 downto 0 );
    gmac_reg_rx_valid_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_valid_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_phy_status_l : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_packet_rate : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_overflow_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_afull_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_packet_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_packet_rate : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_packet_count : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_rx_valid_rate : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_phy_status_h : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_tx_valid_rate : in STD_LOGIC_VECTOR ( 31 downto 0 );
    gmac_reg_core_type : in STD_LOGIC_VECTOR ( 31 downto 0 );
    rs232_uart_rxd : in STD_LOGIC;
    rs232_uart_txd : out STD_LOGIC
  );
  end component microblaze_axi_us_plus;
begin
microblaze_axi_us_plus_i: component microblaze_axi_us_plus
     port map (
      ClockStable => ClockStable,
      PSClock => PSClock,
      PSReset => PSReset,
      gmac_arp_cache_read_address(9 downto 0) => gmac_arp_cache_read_address(9 downto 0),
      gmac_arp_cache_read_data(31 downto 0) => gmac_arp_cache_read_data(31 downto 0),
      gmac_arp_cache_read_enable => gmac_arp_cache_read_enable,
      gmac_arp_cache_write_address(9 downto 0) => gmac_arp_cache_write_address(9 downto 0),
      gmac_arp_cache_write_data(31 downto 0) => gmac_arp_cache_write_data(31 downto 0),
      gmac_arp_cache_write_enable => gmac_arp_cache_write_enable,
      gmac_reg_arp_size(31 downto 0) => gmac_reg_arp_size(31 downto 0),
      gmac_reg_core_type(31 downto 0) => gmac_reg_core_type(31 downto 0),
      gmac_reg_counters_reset => gmac_reg_counters_reset,
      gmac_reg_gateway_ip_address(31 downto 0) => gmac_reg_gateway_ip_address(31 downto 0),
      gmac_reg_local_ip_address(31 downto 0) => gmac_reg_local_ip_address(31 downto 0),
      gmac_reg_mac_address(47 downto 0) => gmac_reg_mac_address(47 downto 0),
      gmac_reg_mac_enable => gmac_reg_mac_enable,
      gmac_reg_mac_promiscous_mode => gmac_reg_mac_promiscous_mode,
      gmac_reg_multicast_ip_address(31 downto 0) => gmac_reg_multicast_ip_address(31 downto 0),
      gmac_reg_multicast_ip_mask(31 downto 0) => gmac_reg_multicast_ip_mask(31 downto 0),
      gmac_reg_phy_control_h(31 downto 0) => gmac_reg_phy_control_h(31 downto 0),
      gmac_reg_phy_control_l(31 downto 0) => gmac_reg_phy_control_l(31 downto 0),
      gmac_reg_phy_status_h(31 downto 0) => gmac_reg_phy_status_h(31 downto 0),
      gmac_reg_phy_status_l(31 downto 0) => gmac_reg_phy_status_l(31 downto 0),
      gmac_reg_rx_almost_full_count(31 downto 0) => gmac_reg_rx_almost_full_count(31 downto 0),
      gmac_reg_rx_bad_packet_count(31 downto 0) => gmac_reg_rx_bad_packet_count(31 downto 0),
      gmac_reg_rx_buffer_max_size(15 downto 0) => gmac_reg_rx_buffer_max_size(15 downto 0),
      gmac_reg_rx_overflow_count(31 downto 0) => gmac_reg_rx_overflow_count(31 downto 0),
      gmac_reg_rx_packet_count(31 downto 0) => gmac_reg_rx_packet_count(31 downto 0),
      gmac_reg_rx_packet_rate(31 downto 0) => gmac_reg_rx_packet_rate(31 downto 0),
      gmac_reg_rx_valid_count(31 downto 0) => gmac_reg_rx_valid_count(31 downto 0),
      gmac_reg_rx_valid_rate(31 downto 0) => gmac_reg_rx_valid_rate(31 downto 0),
      gmac_reg_rx_word_size(15 downto 0) => gmac_reg_rx_word_size(15 downto 0),
      gmac_reg_tx_afull_count(31 downto 0) => gmac_reg_tx_afull_count(31 downto 0),
      gmac_reg_tx_buffer_max_size(15 downto 0) => gmac_reg_tx_buffer_max_size(15 downto 0),
      gmac_reg_tx_overflow_count(31 downto 0) => gmac_reg_tx_overflow_count(31 downto 0),
      gmac_reg_tx_packet_count(31 downto 0) => gmac_reg_tx_packet_count(31 downto 0),
      gmac_reg_tx_packet_rate(31 downto 0) => gmac_reg_tx_packet_rate(31 downto 0),
      gmac_reg_tx_valid_count(31 downto 0) => gmac_reg_tx_valid_count(31 downto 0),
      gmac_reg_tx_valid_rate(31 downto 0) => gmac_reg_tx_valid_rate(31 downto 0),
      gmac_reg_tx_word_size(15 downto 0) => gmac_reg_tx_word_size(15 downto 0),
      gmac_reg_udp_port(15 downto 0) => gmac_reg_udp_port(15 downto 0),
      gmac_reg_udp_port_mask(15 downto 0) => gmac_reg_udp_port_mask(15 downto 0),
      gmac_rx_data_read_address(10 downto 0) => gmac_rx_data_read_address(10 downto 0),
      gmac_rx_data_read_byte_enable(1 downto 0) => gmac_rx_data_read_byte_enable(1 downto 0),
      gmac_rx_data_read_data(7 downto 0) => gmac_rx_data_read_data(7 downto 0),
      gmac_rx_data_read_enable => gmac_rx_data_read_enable,
      gmac_rx_data_write_address(10 downto 0) => gmac_rx_data_write_address(10 downto 0),
      gmac_rx_data_write_byte_enable(1 downto 0) => gmac_rx_data_write_byte_enable(1 downto 0),
      gmac_rx_data_write_data(7 downto 0) => gmac_rx_data_write_data(7 downto 0),
      gmac_rx_data_write_enable => gmac_rx_data_write_enable,
      gmac_rx_ringbuffer_number_slots_filled(3 downto 0) => gmac_rx_ringbuffer_number_slots_filled(3 downto 0),
      gmac_rx_ringbuffer_slot_clear => gmac_rx_ringbuffer_slot_clear,
      gmac_rx_ringbuffer_slot_id(3 downto 0) => gmac_rx_ringbuffer_slot_id(3 downto 0),
      gmac_rx_ringbuffer_slot_status => gmac_rx_ringbuffer_slot_status,
      gmac_tx_data_read_address(10 downto 0) => gmac_tx_data_read_address(10 downto 0),
      gmac_tx_data_read_byte_enable(1 downto 0) => gmac_tx_data_read_byte_enable(1 downto 0),
      gmac_tx_data_read_data(7 downto 0) => gmac_tx_data_read_data(7 downto 0),
      gmac_tx_data_read_enable => gmac_tx_data_read_enable,
      gmac_tx_data_write_address(10 downto 0) => gmac_tx_data_write_address(10 downto 0),
      gmac_tx_data_write_byte_enable(1 downto 0) => gmac_tx_data_write_byte_enable(1 downto 0),
      gmac_tx_data_write_data(7 downto 0) => gmac_tx_data_write_data(7 downto 0),
      gmac_tx_data_write_enable => gmac_tx_data_write_enable,
      gmac_tx_ringbuffer_number_slots_filled(3 downto 0) => gmac_tx_ringbuffer_number_slots_filled(3 downto 0),
      gmac_tx_ringbuffer_slot_id(3 downto 0) => gmac_tx_ringbuffer_slot_id(3 downto 0),
      gmac_tx_ringbuffer_slot_set => gmac_tx_ringbuffer_slot_set,
      gmac_tx_ringbuffer_slot_status => gmac_tx_ringbuffer_slot_status,
      rs232_uart_rxd => rs232_uart_rxd,
      rs232_uart_txd => rs232_uart_txd
    );
end STRUCTURE;
