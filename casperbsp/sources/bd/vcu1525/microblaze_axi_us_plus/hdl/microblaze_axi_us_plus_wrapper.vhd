--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.1 (lin64) Build 2188600 Wed Apr  4 18:39:19 MDT 2018
--Date        : Mon Feb 18 22:35:39 2019
--Host        : benjamin-ubuntu-ws running 64-bit Ubuntu 16.04.5 LTS
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
    rs232_uart_rxd : in STD_LOGIC;
    rs232_uart_txd : out STD_LOGIC
  );
end microblaze_axi_us_plus_wrapper;

architecture STRUCTURE of microblaze_axi_us_plus_wrapper is
  component microblaze_axi_us_plus is
  port (
    PSReset : in STD_LOGIC;
    ClockStable : in STD_LOGIC;
    rs232_uart_rxd : in STD_LOGIC;
    rs232_uart_txd : out STD_LOGIC;
    PSClock : in STD_LOGIC
  );
  end component microblaze_axi_us_plus;
begin
microblaze_axi_us_plus_i: component microblaze_axi_us_plus
     port map (
      ClockStable => ClockStable,
      PSClock => PSClock,
      PSReset => PSReset,
      rs232_uart_rxd => rs232_uart_rxd,
      rs232_uart_txd => rs232_uart_txd
    );
end STRUCTURE;
