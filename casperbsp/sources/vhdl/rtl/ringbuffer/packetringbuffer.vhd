----------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronic Systems 
-- Engineer         : Benjamin Hector Hlophe 
-- 
-- Design Name      : CASPER BSP
-- Module Name      : packetringbuffer - rtl
-- Project Name     : N/A
-- Target Devices   : N/A
-- Tool Versions    : N/A  
-- Description      : This module is used to create a packet ring buffer for 
--                    packet  buffering. 
-- Dependencies     : none
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity packetringbuffer is
	generic(
		G_SLOT_WIDTH : natural := 4;
		G_ADDR_WIDTH : natural := 8;
		G_DATA_WIDTH : natural := 64
	);
	port(
		Clk                    : in  STD_LOGIC;
		-- Transmission port
		TxPacketByteEnable     : out STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
		TxPacketDataRead       : in  STD_LOGIC;
		TxPacketData           : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
		TxPacketAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
		TxPacketSlotClear      : in  STD_LOGIC;
		TxPacketSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		TxPacketSlotStatus     : out STD_LOGIC;
		TxPacketSlotTypeStatus : out STD_LOGIC;
		-- Reception port
		RxPacketByteEnable     : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
		RxPacketDataWrite      : in  STD_LOGIC;
		RxPacketData           : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
		RxPacketAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
		RxPacketSlotSet        : in  STD_LOGIC;
		RxPacketSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		RxPacketSlotType       : in  STD_LOGIC
	);
end entity packetringbuffer;

architecture rtl of packetringbuffer is
	component packetstatusram is
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
	end component packetstatusram;
	component packetramsp is
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
	end component packetramsp;

	signal lRxPacketAddress : std_logic_vector((RxPacketAddress'length + RxPacketSlotID'length) - 1 downto 0);
	signal lTxPacketAddress : std_logic_vector((TxPacketAddress'length + TxPacketSlotID'length) - 1 downto 0);
	signal lTxPacketData    : std_logic_vector((TxPacketData'length + TxPacketByteEnable'length) - 1 downto 0);
	signal lRxPacketData    : std_logic_vector((RxPacketData'length + RxPacketByteEnable'length) - 1 downto 0);
	signal VCC_onebit       : std_logic;
	signal GND_twobit       : std_logic_vector(1 downto 0);
begin
	VCC_onebit <= '1';
	GND_twobit <= "00";

	packetstatusram_i : packetstatusram
		generic map(
			C_ADDR_WIDTH => G_SLOT_WIDTH
		)
		port map(
			ClkA          => Clk,
			ClkB          => Clk,
			-- Port A
			EnableA       => RxPacketSlotSet,
			WriteAEnable  => RxPacketSlotSet,
			WriteAData(0) => RxPacketSlotSet,
			WriteAData(1) => RxPacketSlotType,
			WriteAAddress => RxPacketSlotID,
			ReadAData     => open,
			-- Port B
			WriteBAddress => TxPacketSlotID,
			EnableB       => VCC_onebit,
			WriteBEnable  => TxPacketSlotClear,
			WriteBData    => GND_twobit,
			ReadBData(0)  => TxPacketSlotStatus,
			ReadBData(1)  => TxPacketSlotTypeStatus
		);

	lRxPacketData((RxPacketByteEnable'length+RxPacketData'length)-1 downto RxPacketData'length) <= RxPacketByteEnable;
	lRxPacketData(RxPacketData'length-1 downto 0)                                               <= RxPacketData;

	lRxPacketAddress((RxPacketSlotID'length+RxPacketAddress'length)-1 downto RxPacketAddress'length) <= RxPacketSlotID;
	lRxPacketAddress(RxPacketAddress'length-1 downto 0)                                              <= RxPacketAddress;

	lTxPacketAddress((TxPacketSlotID'length+TxPacketAddress'length)-1 downto TxPacketAddress'length) <= TxPacketSlotID;
	lTxPacketAddress(TxPacketAddress'length-1 downto 0)                                              <= TxPacketAddress;

	TxPacketByteEnable <= lTxPacketData((TxPacketByteEnable'length + TxPacketData'length) - 1 downto TxPacketData'length);
	TxPacketData       <= lTxPacketData(TxPacketData'length - 1 downto 0);

	Buffer_i : packetramsp
		generic map(
			C_ADDR_WIDTH => (RxPacketAddress'length + RxPacketSlotID'length),
			C_DATA_WIDTH => (RxPacketData'length + RxPacketByteEnable'length)
		)
		port map(
			Clk          => Clk,
			WriteAddress => lRxPacketAddress,
			ReadAddress  => lTxPacketAddress,
			WriteEnable  => RxPacketDataWrite,
			ReadEnable   => TxPacketDataRead,
			WriteData    => lRxPacketData,
			ReadData     => lTxPacketData
		);
end architecture rtl;
