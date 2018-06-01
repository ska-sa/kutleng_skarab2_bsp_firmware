----------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronic Systems 
-- Engineer         : Benjamin Hector Hlophe 
-- 
-- Design Name      : PCIe Video DMA
-- Module Name      : partialblinker - rtl
-- Project Name     : N/A
-- Target Devices   : N/A
-- Tool Versions    : N/A  
-- Description      : This module is used to flash leds at a rate determined by the generics.
--                    The correct CLOCKFREQUENCY parameter and LEDFLASHRATE must 
--                    be provided.
-- Dependencies     : none
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity partialblinker is
	port(
	clk_100MHz : IN  STD_LOGIC;
	partial_bit_leds  : out  STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
end entity partialblinker;

architecture rtl of partialblinker is
	component ledflasher is
		generic(
			-- Clock frequency in Hz
			CLOCKFREQUENCY : NATURAL := 50_000_000;
			-- LED flashrate in Hz
			LEDFLASHRATE   : NATURAL := 1
		);
		port(
			Clk : in  STD_LOGIC;
			LED : out STD_LOGIC
		);
	end component ledflasher;
begin

	LED5_i : ledflasher
		generic map(
			CLOCKFREQUENCY => 100_000_000,
			LEDFLASHRATE   => 5
		)
		port map(
			Clk => clk_100MHz,
			LED => partial_bit_leds(0)
		);

	LED6_i : ledflasher
		generic map(
			CLOCKFREQUENCY => 100_000_000,
			LEDFLASHRATE   => 3
		)
		port map(
			Clk => clk_100MHz,
			LED => partial_bit_leds(1)
		);

	LED7_i : ledflasher
		generic map(
			CLOCKFREQUENCY => 100_000_000,
			LEDFLASHRATE   => 2
		)
		port map(
			Clk => clk_100MHz,
			LED => partial_bit_leds(2)
		);

	LED8_i : ledflasher
		generic map(
			CLOCKFREQUENCY => 100_000_000,
			LEDFLASHRATE   => 1
		)
		port map(
			Clk => clk_100MHz,
			LED => partial_bit_leds(3)
		);

end architecture rtl;
