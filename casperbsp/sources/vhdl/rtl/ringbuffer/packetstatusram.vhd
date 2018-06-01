----------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronic Systems 
-- Engineer         : Benjamin Hector Hlophe 
-- 
-- Design Name      : CASPER BSP
-- Module Name      : packetstatusram - rtl
-- Project Name     : N/A
-- Target Devices   : N/A
-- Tool Versions    : N/A  
-- Description      : This module is used to create a true dual port ram for  
--                    packet slot colouring. 
-- Dependencies     : none
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity packetstatusram is
	generic(
		C_ADDR_WIDTH : natural := 4
	);
	port(
		ClkA          : in  STD_LOGIC;
		ClkB          : in  STD_LOGIC;
		-- Port A
		EnableA       : in  STD_LOGIC;
		WriteAEnable  : in  STD_LOGIC;
		WriteAData    : in  STD_LOGIC_VECTOR(1 downto 0);
		WriteAAddress : in  STD_LOGIC_VECTOR(C_ADDR_WIDTH - 1 downto 0);
		ReadAData     : out STD_LOGIC_VECTOR(1 downto 0);
		-- Port B
		WriteBAddress : in  STD_LOGIC_VECTOR(C_ADDR_WIDTH - 1 downto 0);
		EnableB       : in  STD_LOGIC;
		WriteBEnable  : in  STD_LOGIC;
		WriteBData    : in  STD_LOGIC_VECTOR(1 downto 0);
		ReadBData     : out STD_LOGIC_VECTOR(1 downto 0)
	);
end entity packetstatusram;

architecture rtl of packetstatusram is
	-- Declaration of ram signals
	type PacketStatusRAM_t is array ((2**C_ADDR_WIDTH) - 1 downto 0) of std_logic_vector(1 downto 0);
	shared variable RAMData : PacketStatusRAM_t;
begin

	RAMPORTA : process(ClkA)
	begin
		if rising_edge(ClkA) then
			if (EnableA = '1') then
				if (WriteAEnable = '1') then
					RAMData(to_integer(unsigned(WriteAAddress))) := WriteAData;
				end if;
				ReadAData <= RAMData(to_integer(unsigned(WriteAAddress)));
			end if;
		end if;
	end process RAMPORTA;

	RAMPORTB : process(ClkB)
	begin
		if rising_edge(ClkB) then
			if (EnableB = '1') then
				if (WriteBEnable = '1') then
					RAMData(to_integer(unsigned(WriteBAddress))) := WriteBData;
				end if;
				ReadBData <= RAMData(to_integer(unsigned(WriteBAddress)));
			end if;
		end if;
	end process RAMPORTB;

end architecture rtl;
