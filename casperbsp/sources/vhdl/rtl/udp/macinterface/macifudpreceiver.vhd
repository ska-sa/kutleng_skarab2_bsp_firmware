----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.04.2018 16:59:29
-- Design Name: 
-- Module Name: macifudpreceiver - rtl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity macifudpreceiver is
	generic(
		G_SLOT_WIDTH      : natural                          := 4;
		G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
		-- The address width is log2(2048/(512/8))=5 bits wide
		G_ADDR_WIDTH      : natural                          := 5
	);
	port(
		axis_clk                 : in  STD_LOGIC;
		axis_reset               : in  STD_LOGIC;
		-- Setup information
		ReceiverMACAddress       : in  STD_LOGIC_VECTOR(47 downto 0);
		ReceiverIPAddress        : in  STD_LOGIC_VECTOR(31 downto 0);
		-- Packet Readout in addressed bus format
		RingBufferSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		RingBufferSlotClear      : in  STD_LOGIC;
		RingBufferSlotStatus     : out STD_LOGIC;
		RingBufferSlotTypeStatus : out STD_LOGIC;
		RingBufferSlotsFilled    : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		RingBufferDataRead       : in  STD_LOGIC;
		-- Enable[0] is a special bit (we assume always 1 when packet is valid)
		-- we use it to save TLAST
		RingBufferDataEnable     : out STD_LOGIC_VECTOR(63 downto 0);
		RingBufferDataOut        : out STD_LOGIC_VECTOR(511 downto 0);
		RingBufferAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
		--Inputs from AXIS bus of the MAC side
		axis_rx_tdata            : in  STD_LOGIC_VECTOR(511 downto 0);
		axis_rx_tvalid           : in  STD_LOGIC;
		axis_rx_tuser            : in  STD_LOGIC;
		axis_rx_tkeep            : in  STD_LOGIC_VECTOR(63 downto 0);
		axis_rx_tlast            : in  STD_LOGIC
	);
end entity macifudpreceiver;

architecture rtl of macifudpreceiver is

	component packetringbuffer is
		generic(
			G_SLOT_WIDTH : natural := 4;
			G_ADDR_WIDTH : natural := 5;
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
	end component packetringbuffer;

	type AxisUDPReaderSM_t is (
		InitialiseSt,                   -- On the reset state
		ProcessPacketSt                 -- UDP Processing (Accepts UDP Packets 64 bytes and more)
	);
	signal StateVariable : AxisUDPReaderSM_t := InitialiseSt;

	-- Packet Type VLAN=0x8100 
	--constant C_VLAN_TYPE      : std_logic_vector(15 downto 0)       := X"8100";
	-- Packet Type DVLAN=0x88A8 
	--constant C_DVLAN_TYPE     : std_logic_vector(15 downto 0)       := X"88A8";
	-- IPV4 Type=0x0800 
	constant C_IPV4_TYPE         : std_logic_vector(15 downto 0) := X"0800";
	-- IP Version and Header Length =0x45 
	constant C_IPV_IHL           : std_logic_vector(7 downto 0)  := X"45";
	-- UDP Protocol =0x06 	
	constant C_UDP_PROTOCOL      : std_logic_vector(7 downto 0)  := X"11";
	-- Tuples registers
	signal lPacketByteEnable     : std_logic_vector(RingBufferDataEnable'length - 1 downto 0);
	signal lPacketDataWrite      : std_logic;
	signal lPacketData           : std_logic_vector(RingBufferDataOut'length - 1 downto 0);
	signal lPacketAddressCounter : unsigned(RingBufferAddress'length - 1 downto 0);
	signal lPacketAddress        : unsigned(RingBufferAddress'length - 1 downto 0);
	signal lPacketSlotSet        : std_logic;
	signal lPacketSlotType       : std_logic;
	signal lPacketSlotID         : unsigned(RingBufferSlotID'length - 1 downto 0);
	signal lInPacket             : std_logic;
	alias lDestinationMACAddress : std_logic_vector(47 downto 0) is axis_rx_tdata(47 downto 0);
	alias lSourceMACAddress      : std_logic_vector(47 downto 0) is axis_rx_tdata(95 downto 48);
	alias lEtherType             : std_logic_vector(15 downto 0) is axis_rx_tdata(111 downto 96);
	alias lIPVIHL                : std_logic_vector(7  downto 0) is axis_rx_tdata(119 downto 112);
	alias lDSCPECN               : std_logic_vector(7  downto 0) is axis_rx_tdata(127 downto 120);
	alias lTotalLength           : std_logic_vector(15 downto 0) is axis_rx_tdata(143 downto 128);
	alias lIdentification        : std_logic_vector(15 downto 0) is axis_rx_tdata(159 downto 144);
	alias lFlagsOffset           : std_logic_vector(15 downto 0) is axis_rx_tdata(175 downto 160);
	alias lTimeToLeave           : std_logic_vector(7  downto 0) is axis_rx_tdata(183 downto 176);
	alias lProtocol              : std_logic_vector(7  downto 0) is axis_rx_tdata(191 downto 184);
	alias lHeaderChecksum        : std_logic_vector(15 downto 0) is axis_rx_tdata(207 downto 192);
	alias lSourceIPAddress       : std_logic_vector(31 downto 0) is axis_rx_tdata(239 downto 208);
	alias lDestinationIPAddress  : std_logic_vector(31 downto 0) is axis_rx_tdata(271 downto 240);
	alias lSourceUDPPort         : std_logic_vector(15 downto 0) is axis_rx_tdata(287 downto 272);
	alias lDestinationUDPPort    : std_logic_vector(15 downto 0) is axis_rx_tdata(303 downto 288);
	alias lUDPDataStreamLength   : std_logic_vector(15 downto 0) is axis_rx_tdata(319 downto 304);
	alias lUDPCheckSum           : std_logic_vector(15 downto 0) is axis_rx_tdata(335 downto 320);
	signal lFilledSlots           : unsigned(G_SLOT_WIDTH - 1 downto 0);
	-- The left over is 22 bytes
	function byteswap(DataIn : in std_logic_vector)
	return std_logic_vector is
		variable RData48 : std_logic_vector(47 downto 0);
		variable RData32 : std_logic_vector(31 downto 0);
		variable RData24 : std_logic_vector(23 downto 0);
		variable RData16 : std_logic_vector(15 downto 0);
	begin
		if (DataIn'length = RData48'length) then
			RData48(7 downto 0)   := DataIn(47 downto 40);
			RData48(15 downto 8)  := DataIn(39 downto 32);
			RData48(23 downto 16) := DataIn(31 downto 24);
			RData48(31 downto 24) := DataIn(23 downto 16);
			RData48(39 downto 32) := DataIn(15 downto 8);
			RData48(47 downto 40) := DataIn(7 downto 0);
			return std_logic_vector(RData48);
		end if;
		if (DataIn'length = RData32'length) then
			RData32(7 downto 0)   := DataIn(31 downto 24);
			RData32(15 downto 8)  := DataIn(23 downto 16);
			RData32(23 downto 16) := DataIn(15 downto 8);
			RData32(31 downto 24) := DataIn(7 downto 0);
			return std_logic_vector(RData32);
		end if;
		if (DataIn'length = RData24'length) then
			RData24(7 downto 0)   := DataIn(23 downto 16);
			RData24(15 downto 8)  := DataIn(15 downto 8);
			RData24(23 downto 16) := DataIn(7 downto 0);
			return std_logic_vector(RData24);
		end if;
		if (DataIn'length = RData16'length) then
			RData16(7 downto 0)  := DataIn(15 downto 8);
			RData16(15 downto 8) := DataIn(7 downto 0);
			return std_logic_vector(RData16);
		end if;
	end byteswap;

begin
	FilledSlotCounterProc : process(axis_clk)
	begin
		if rising_edge(axis_clk) then
			if (axis_reset = '1') then
				lFilledSlots <= (others => '0');
			else
				if ((RingBufferSlotClear = '0') and (lPacketSlotSet = '1')) then
					lFilledSlots <= lFilledSlots + 1;
				elsif ((RingBufferSlotClear = '1') and (lPacketSlotSet = '0')) then
					lFilledSlots <= lFilledSlots - 1;
				else
					-- Its a neutral operation
					lFilledSlots <= lFilledSlots;
				end if;
			end if;
		end if;
	end process FilledSlotCounterProc;

	RingBufferSlotsFilled <= std_logic_vector(lFilledSlots);
	PacketBuffer_i : packetringbuffer
		generic map(
			G_SLOT_WIDTH => RingBufferSlotID'length,
			G_ADDR_WIDTH => RingBufferAddress'length,
			G_DATA_WIDTH => RingBufferDataOut'length
		)
		port map(
			Clk                    => axis_clk,
			-- Transmission port
			TxPacketByteEnable     => RingBufferDataEnable,
			TxPacketDataRead       => RingBufferDataRead,
			TxPacketData           => RingBufferDataOut,
			TxPacketAddress        => RingBufferAddress,
			TxPacketSlotClear      => RingBufferSlotClear,
			TxPacketSlotID         => RingBufferSlotID,
			TxPacketSlotStatus     => RingBufferSlotStatus,
			TxPacketSlotTypeStatus => RingBufferSlotTypeStatus,
			RxPacketByteEnable     => lPacketByteEnable,
			RxPacketDataWrite      => lPacketDataWrite,
			RxPacketData           => lPacketData,
			RxPacketAddress        => std_logic_vector(lPacketAddress),
			RxPacketSlotSet        => lPacketSlotSet,
			RxPacketSlotID         => std_logic_vector(lPacketSlotID),
			RxPacketSlotType       => lPacketSlotType
		);

	SynchStateProc : process(axis_clk)
	begin
		if rising_edge(axis_clk) then
			if (axis_reset = '1') then
				-- Initialize SM on reset
				StateVariable <= InitialiseSt;
			else
				case (StateVariable) is
					when InitialiseSt =>

						-- Wait for packet after initialization
						StateVariable         <= ProcessPacketSt;
						lPacketAddressCounter <= (others => '0');
						lPacketAddress        <= (others => '0');
						lPacketSlotID         <= (others => '0');
						lPacketDataWrite      <= '0';
						lInPacket             <= '0';

					when ProcessPacketSt =>
						lPacketAddress <= lPacketAddressCounter;
						if (lPacketSlotSet = '1') then
							-- If the previous slot was set then point to next slot.
							lPacketSlotID <= unsigned(lPacketSlotID) + 1;
						end if;

						if ((lInPacket = '1') or -- Already processing a packet
							(           -- First Time processing a packet or 64 byte packet
							(lInPacket = '0') and -- First Time processing a packet or 64 byte packet 
							(           -- First Time processing a packet or 64 byte packet
							(axis_rx_tvalid = '1') and -- Check the valid
							(axis_rx_tuser /= '1') and -- Check for errors 
							(lEtherType = byteswap(C_IPV4_TYPE)) and -- Check the Frame Type
							(lDestinationUDPPort = byteswap(std_logic_vector(to_unsigned(G_UDP_SERVER_PORT, lDestinationUDPPort'length)))) and -- Check the UDP Port   
							(lDestinationIPAddress = byteswap(ReceiverIPAddress)) and -- Check the Destination IP Address   
							(lDestinationMACAddress = byteswap(ReceiverMACAddress)) and -- Check the Destination MAC Address   
							(lIPVIHL = C_IPV_IHL) and -- Check the IPV4 IHL 									 
							(lProtocol = C_UDP_PROTOCOL) -- Check the UDP Protocol
							)           -- First Time processing a packet or 64 byte packet
							)           -- First Time processing a packet or 64 byte packet 
							) then
							-- Write the packet by passing the tvalid signal
							lPacketDataWrite <= axis_rx_tvalid;
							--Send the ARP Response
							if (lInpacket = '0') then
								-- This is the first 64 bytes								
								lPacketData(47 downto 0)    <= lSourceMACAddress;
								lPacketData(95 downto 48)   <= lDestinationMACAddress;
								lPacketData(111 downto 96)  <= lEtherType;
								lPacketData(119 downto 112) <= lIPVIHL;
								lPacketData(127 downto 120) <= lDSCPECN;
								lPacketData(143 downto 128) <= lTotalLength;
								lPacketData(159 downto 144) <= lIdentification;
								lPacketData(175 downto 160) <= lFlagsOffset;
								lPacketData(183 downto 176) <= lTimeToLeave;
								lPacketData(191 downto 184) <= lProtocol;
								lPacketData(207 downto 192) <= lHeaderChecksum;
								lPacketData(239 downto 208) <= lDestinationIPAddress;
								lPacketData(271 downto 240) <= lSourceIPAddress;
								lPacketData(287 downto 272) <= lDestinationUDPPort;
								lPacketData(303 downto 288) <= lSourceUDPPort;
								lPacketData(319 downto 304) <= lUDPDataStreamLength;
								lPacketData(335 downto 320) <= lUDPCheckSum;
								lPacketData(511 downto 336) <= axis_rx_tdata(511 downto 336);
							else
								-- This is other bytes
								-- Pass all data
								lPacketData <= axis_rx_tdata;

							end if;
							-- This is UDP Transfer to this server port on this system

							--  Save the packet for processing
							if ((axis_rx_tlast = '1') and (axis_rx_tvalid = '1')) then
								-- This is the very last 64 byte packet data
								-- Go to next slot
								lPacketSlotType                <= axis_rx_tvalid;
								if (axis_rx_tuser = '1') then
									-- There was an error
									StateVariable <= InitialiseSt;
								else
									StateVariable <= ProcessPacketSt;
								end if;
								-- If this is the last segment then restart the packet address
								lInPacket                      <= '0';
								lPacketSlotSet                 <= '1';
								--
								lPacketAddressCounter          <= (others => '0');
								lPacketByteEnable(0)           <= '1';
								lPacketByteEnable(63 downto 1) <= axis_rx_tkeep(63 downto 1);
							else
								-- This is a longer than 64 byte packet
								lInPacket                      <= '1';
								-- tkeep(0) is always 1 when writing data is valid 
								lPacketByteEnable(0)           <= '0';
								lPacketByteEnable(63 downto 1) <= axis_rx_tkeep(63 downto 1);
								if (axis_rx_tvalid = '1') then
									lPacketAddressCounter          <= unsigned(lPacketAddressCounter) + 1;
								end if;
								lPacketSlotSet                 <= '0';
								-- Keep processing packets
								StateVariable                  <= ProcessPacketSt;
							end if;
						else
							lPacketDataWrite <= '0';
							lPacketSlotType  <= '0';
							lPacketSlotSet   <= '0';

						end if;

					when others =>
						StateVariable <= InitialiseSt;
				end case;
			end if;
		end if;
	end process SynchStateProc;

end architecture rtl;
