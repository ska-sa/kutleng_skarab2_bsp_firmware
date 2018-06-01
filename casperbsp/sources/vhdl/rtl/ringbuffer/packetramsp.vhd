----------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronic Systems 
-- Engineer         : Benjamin Hector Hlophe 
-- 
-- Design Name      : CASPER BSP
-- Module Name      : packetramsp - rtl
-- Project Name     : N/A
-- Target Devices   : N/A
-- Tool Versions    : N/A  
-- Description      : This module is used to produce a single port block ram for 
--                    packet buffering. 
-- Dependencies     : none
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity packetramsp is
	generic(
		C_ADDR_WIDTH : natural := 8 + 2;
		C_DATA_WIDTH : natural := 64
	);
	port(
		Clk          : in  STD_LOGIC;
		WriteAddress : in  STD_LOGIC_VECTOR(C_ADDR_WIDTH - 1 downto 0);
		ReadAddress  : in  STD_LOGIC_VECTOR(C_ADDR_WIDTH - 1 downto 0);
		WriteEnable  : in  STD_LOGIC;
		ReadEnable   : in  STD_LOGIC;
		WriteData    : in  STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 downto 0);
		ReadData     : out STD_LOGIC_VECTOR(C_DATA_WIDTH - 1 downto 0)
	);
end entity packetramsp;

architecture rtl of packetramsp is
	-- Declaration of ram signals
	type PacketRAM_t is array ((2**C_ADDR_WIDTH) - 1 downto 0) of std_logic_vector(C_DATA_WIDTH - 1 downto 0);
	signal RAMData : PacketRAM_t;
begin

	RAMWrite : process(Clk)
	begin
		if rising_edge(Clk) then
			if (WriteEnable = '1') then
				RAMData(to_integer(unsigned(WriteAddress))) <= WriteData;
			end if;
		end if;
	end process RAMWrite;

	RAMRead : process(Clk)
	begin
		if rising_edge(Clk) then
			if (ReadEnable = '1') then
				ReadData <= RAMData(to_integer(unsigned(ReadAddress)));
			end if;
		end if;
	end process RAMRead;

end architecture rtl;
