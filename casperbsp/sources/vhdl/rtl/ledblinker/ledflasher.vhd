----------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronic Systems 
-- Engineer         : Benjamin Hector Hlophe 
-- 
-- Design Name      : PCIe Video DMA
-- Module Name      : ledflasher - rtl
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

entity ledflasher is
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
end entity ledflasher;

architecture rtl of ledflasher is
	constant PrescalerMaximum : NATURAL                             := ((CLOCKFREQUENCY / LEDFLASHRATE) / 2) - 1;
	signal PrescalerCounter   : NATURAL range 0 to PrescalerMaximum := 0;
	signal iled               : STD_LOGIC                           := '0';

begin

	LED <= iled;

	FlasherProc : process(Clk)
	begin
		if rising_edge(Clk) then
			if (PrescalerCounter = PrescalerMaximum) then
				PrescalerCounter <= 0;
				iled             <= not iled;
			else
				PrescalerCounter <= PrescalerCounter + 1;
			end if;
		end if;
	end process FlasherProc;

end architecture rtl;
