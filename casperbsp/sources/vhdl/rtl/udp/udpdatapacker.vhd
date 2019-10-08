--------------------------------------------------------------------------------
-- Legal & Copyright:   (c) 2018 Kutleng Engineering Technologies (Pty) Ltd    - 
--                                                                             -
-- This program is the proprietary software of Kutleng Engineering Technologies-
-- and/or its licensors, and may only be used, duplicated, modified or         -
-- distributed pursuant to the terms and conditions of a separate, written     -
-- license agreement executed between you and Kutleng (an "Authorized License")-
-- Except as set forth in an Authorized License, Kutleng grants no license     -
-- (express or implied), right to use, or waiver of any kind with respect to   -
-- the Software, and Kutleng expressly reserves all rights in and to the       -
-- Software and all intellectual property rights therein.  IF YOU HAVE NO      -
-- AUTHORIZED LICENSE, THEN YOU HAVE NO RIGHT TO USE THIS SOFTWARE IN ANY WAY, -
-- AND SHOULD IMMEDIATELY NOTIFY KUTLENG AND DISCONTINUE ALL USE OF THE        -
-- SOFTWARE.                                                                   -
--                                                                             -
-- Except as expressly set forth in the Authorized License,                    -
--                                                                             -
-- 1.     This program, including its structure, sequence and organization,    -
-- constitutes the valuable trade secrets of Kutleng, and you shall use all    -
-- reasonable efforts to protect the confidentiality thereof,and to use this   -
-- information only in connection with South African Radio Astronomy           -
-- Observatory (SARAO) products.                                               -
--                                                                             -
-- 2.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE SOFTWARE IS PROVIDED     -
-- "AS IS" AND WITH ALL FAULTS AND KUTLENG MAKES NO PROMISES, REPRESENTATIONS  -
-- OR WARRANTIES, EITHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE, WITH       -
-- RESPECT TO THE SOFTWARE.  KUTLENG SPECIFICALLY DISCLAIMS ANY AND ALL IMPLIED-
-- WARRANTIES OF TITLE, MERCHANTABILITY, NONINFRINGEMENT, FITNESS FOR A        -
-- PARTICULAR PURPOSE, LACK OF VIRUSES, ACCURACY OR COMPLETENESS, QUIET        -
-- ENJOYMENT, QUIET POSSESSION OR CORRESPONDENCE TO DESCRIPTION. YOU ASSUME THE-
-- ENJOYMENT, QUIET POSSESSION USE OR PERFORMANCE OF THE SOFTWARE.             -
--                                                                             -
-- 3.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL KUTLENG OR -
-- ITS LICENSORS BE LIABLE FOR (i) CONSEQUENTIAL, INCIDENTAL, SPECIAL, INDIRECT-
-- , OR EXEMPLARY DAMAGES WHATSOEVER ARISING OUT OF OR IN ANY WAY RELATING TO  -
-- YOUR USE OF OR INABILITY TO USE THE SOFTWARE EVEN IF KUTLENG HAS BEEN       -
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGES; OR (ii) ANY AMOUNT IN EXCESS OF -
-- THE AMOUNT ACTUALLY PAID FOR THE SOFTWARE ITSELF OR ZAR R1, WHICHEVER IS    -
-- GREATER. THESE LIMITATIONS SHALL APPLY NOTWITHSTANDING ANY FAILURE OF       -
-- ESSENTIAL PURPOSE OF ANY LIMITED REMEDY.                                    -
-- --------------------------------------------------------------------------- -
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS                    -
-- PART OF THIS FILE AT ALL TIMES.                                             -
--=============================================================================-
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : udpdatapacker - rtl                                      -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module performs data streaming over UDP             -
--                                                                             -
-- Dependencies     : macifudpserver,udpdatastripper,udpdatapacker             -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udpdatapacker is
    generic(
        G_SLOT_WIDTH      : natural := 4;
        G_AXIS_DATA_WIDTH : natural := 512;
        G_ARP_CACHE_ASIZE : natural := 13;
        G_ARP_DATA_WIDTH  : natural := 32; -- The address width is log2(2048/(512/8))=5 bits wide
        G_ADDR_WIDTH      : natural := 5
    );
    port(
        axis_clk                       : in  STD_LOGIC;
        axis_app_clk                   : in  STD_LOGIC;
        axis_reset                     : in  STD_LOGIC;
        mac_address                    : in  STD_LOGIC_VECTOR(47 downto 0);
        local_ip_address               : in  STD_LOGIC_VECTOR(31 downto 0);
        gateway_ip_address             : in  STD_LOGIC_VECTOR(31 downto 0);
        multicast_ip_address           : in  STD_LOGIC_VECTOR(31 downto 0);
        multicast_ip_mask              : in  STD_LOGIC_VECTOR(31 downto 0);
        mac_enable                     : in  STD_LOGIC;
        tx_overflow_count              : out STD_LOGIC_VECTOR(31 downto 0);
        tx_afull_count                 : out STD_LOGIC_VECTOR(31 downto 0);
        source_udp_port                : in  STD_LOGIC_VECTOR(15 downto 0);
        ARPReadDataEnable              : out STD_LOGIC;
        ARPReadData                    : in  STD_LOGIC_VECTOR((G_ARP_DATA_WIDTH * 2) - 1 downto 0);
        ARPReadAddress                 : out STD_LOGIC_VECTOR(G_ARP_CACHE_ASIZE - 1 downto 0);
        -- Packet Readout in addressed bus format
        SenderRingBufferSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        SenderRingBufferSlotClear      : in  STD_LOGIC;
        SenderRingBufferSlotStatus     : out STD_LOGIC;
        SenderRingBufferSlotTypeStatus : out STD_LOGIC;
        SenderRingBufferSlotsFilled    : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        SenderRingBufferDataRead       : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        SenderRingBufferDataEnable     : out STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
        SenderRingBufferData           : out STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
        SenderRingBufferAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        --
        destination_ip                 : in  STD_LOGIC_VECTOR(31 downto 0);
        destination_udp_port           : in  STD_LOGIC_VECTOR(15 downto 0);
        udp_packet_length              : in  STD_LOGIC_VECTOR(15 downto 0);
        axis_tuser                     : in  STD_LOGIC_VECTOR(1 downto 0);
        axis_tdata                     : in  STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
        axis_tvalid                    : in  STD_LOGIC;
        axis_tready                    : out STD_LOGIC;
        axis_tkeep                     : in  STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
        axis_tlast                     : in  STD_LOGIC
    );
end entity udpdatapacker;

architecture rtl of udpdatapacker is
    component dualportpacketringbuffer is
        generic(
            G_SLOT_WIDTH : natural := 4;
            G_ADDR_WIDTH : natural := 8;
            G_DATA_WIDTH : natural := 64
        );
        port(
            RxClk                  : in  STD_LOGIC;
            TxClk                  : in  STD_LOGIC;
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
            RxPacketSlotType       : in  STD_LOGIC;
            RxPacketSlotStatus     : out STD_LOGIC;
            RxPacketSlotTypeStatus : out STD_LOGIC
        );
    end component dualportpacketringbuffer;

    type UDPDataPackerSM_t is (
        InitialiseSt,                   -- On the reset state
        WaitForPacketStreamSt,
        GenerateIPAddressesSt,
        ARPTableLookUpSt,
        ProcessARPTableLookUpSt,
        ProcessAddressingChangesSt,
        PreComputeHeaderCheckSumSt,
        WriteUDPStreamSt,
        NextSlotsSt
    );
    signal StateVariable : UDPDataPackerSM_t := InitialiseSt;
    constant C_DWORD_MAX : natural           := (16 - 1);

    signal C_RESPONSE_UDP_LENGTH      : std_logic_vector(15 downto 0) := X"0012";
    signal C_RESPONSE_IPV4_LENGTH     : std_logic_vector(15 downto 0) := X"0026";
    constant C_RESPONSE_ETHER_TYPE    : std_logic_vector(15 downto 0) := X"0800";
    constant C_RESPONSE_IPV4IHL       : std_logic_vector(7 downto 0)  := X"45";
    constant C_RESPONSE_DSCPECN       : std_logic_vector(7 downto 0)  := X"00";
    constant C_RESPONSE_FLAGS_OFFSET  : std_logic_vector(15 downto 0) := X"4000";
    constant C_RESPONSE_TIME_TO_LEAVE : std_logic_vector(7 downto 0)  := X"40";
    constant C_RESPONSE_UDP_PROTOCOL  : std_logic_vector(7 downto 0)  := X"11";

    -- Tuples registers
    signal lPacketData : std_logic_vector(511 downto 0);

    alias lDestinationMACAddress    : std_logic_vector(47 downto 0) is lPacketData(47 downto 0);
    alias lSourceMACAddress         : std_logic_vector(47 downto 0) is lPacketData(95 downto 48);
    alias lEtherType                : std_logic_vector(15 downto 0) is lPacketData(111 downto 96);
    alias lIPVIHL                   : std_logic_vector(7  downto 0) is lPacketData(119 downto 112);
    alias lDSCPECN                  : std_logic_vector(7  downto 0) is lPacketData(127 downto 120);
    alias lTotalLength              : std_logic_vector(15 downto 0) is lPacketData(143 downto 128);
    alias lIdentification           : std_logic_vector(15 downto 0) is lPacketData(159 downto 144);
    alias lFlagsOffset              : std_logic_vector(15 downto 0) is lPacketData(175 downto 160);
    alias lTimeToLeave              : std_logic_vector(7  downto 0) is lPacketData(183 downto 176);
    alias lProtocol                 : std_logic_vector(7  downto 0) is lPacketData(191 downto 184);
    alias lIPHeaderChecksum         : std_logic_vector(15 downto 0) is lPacketData(207 downto 192);
    alias lSourceIPAddress          : std_logic_vector(31 downto 0) is lPacketData(239 downto 208);
    alias lDestinationIPAddress     : std_logic_vector(31 downto 0) is lPacketData(271 downto 240);
    alias lSourceUDPPort            : std_logic_vector(15 downto 0) is lPacketData(287 downto 272);
    alias lDestinationUDPPort       : std_logic_vector(15 downto 0) is lPacketData(303 downto 288);
    alias lUDPDataStreamLength      : std_logic_vector(15 downto 0) is lPacketData(319 downto 304);
    alias lUDPCheckSum              : std_logic_vector(15 downto 0) is lPacketData(335 downto 320);
    alias lPRPacketID               : std_logic_vector(15 downto 0) is lPacketData(351 downto 336);
    alias lPRPacketSequence         : std_logic_vector(31 downto 0) is lPacketData(383 downto 352);
    alias lPRDWordCommand           : std_logic_vector(31 downto 0) is lPacketData(415 downto 384);
    --    alias lPRFIFOState              : std_logic_vector(15 downto 0) is lPacketAddress(367 downto 352);
    --    alias lPRPacketSequence         : std_logic_vector(31 downto 0) is lRingBufferData(399 downto 368);
    --    alias lPRDWordCommand           : std_logic_vector(31 downto 0) is lRingBufferData(431 downto 400);
    signal lIPHDRCheckSum           : unsigned(16 downto 0);
    signal lPreIPHDRCheckSum        : unsigned(17 downto 0);
    signal lServerMACAddress        : std_logic_vector(47 downto 0);
    signal lServerMACAddressChanged : std_logic;
    signal lServerIPAddress         : std_logic_vector(31 downto 0);
    signal lServerIPAddressChanged  : std_logic;
    signal lServerUDPPort           : std_logic_vector(15 downto 0);
    signal lServerUDPPortChanged    : std_logic;
    signal lClientMACAddress        : std_logic_vector(47 downto 0);
    signal lClientMACAddressChanged : std_logic;
    signal lClientIPAddress         : std_logic_vector(31 downto 0);
    signal SourceIPAddress          : std_logic_vector(31 downto 0);
    signal lClientIPAddressChanged  : std_logic;
    signal lClientUDPPort           : std_logic_vector(15 downto 0);
    signal lClientUDPPortChanged    : std_logic;
    signal lUDPPacketLengthChanged  : std_logic;
    signal lAddressingChanged       : std_logic;
    signal lProtocolErrorStatus     : std_logic;
    signal lIPIdentification        : unsigned(15 downto 0);
    signal lCheckSumCounter         : natural range 0 to C_DWORD_MAX;
    signal lPacketByteEnable        : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
    signal lPacketDataWrite         : STD_LOGIC;
    signal lPacketAddress           : unsigned(G_ADDR_WIDTH - 1 downto 0);
    signal lPacketSlotSet           : STD_LOGIC;
    signal lPacketSlotID            : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lPacketSlotType          : STD_LOGIC;
    signal lPacketSlotStatus        : STD_LOGIC;
    signal lPacketSlotTypeStatus    : STD_LOGIC;

    -- The left over is 22 bytes
    function byteswap(DataIn : in unsigned)
    return unsigned is
        variable RData48 : unsigned(47 downto 0);
        variable RData32 : unsigned(31 downto 0);
        variable RData24 : unsigned(23 downto 0);
        variable RData16 : unsigned(15 downto 0);
    begin
        if (DataIn'length = RData48'length) then
            RData48(7 downto 0)   := DataIn((47 + DataIn'right) downto (40 + DataIn'right));
            RData48(15 downto 8)  := DataIn((39 + DataIn'right) downto (32 + DataIn'right));
            RData48(23 downto 16) := DataIn((31 + DataIn'right) downto (24 + DataIn'right));
            RData48(31 downto 24) := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData48(39 downto 32) := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData48(47 downto 40) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return unsigned(RData48);
        end if;
        if (DataIn'length = RData32'length) then
            RData32(7 downto 0)   := DataIn((31 + DataIn'right) downto (24 + DataIn'right));
            RData32(15 downto 8)  := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData32(23 downto 16) := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData32(31 downto 24) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return unsigned(RData32);
        end if;
        if (DataIn'length = RData24'length) then
            RData24(7 downto 0)   := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData24(15 downto 8)  := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData24(23 downto 16) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return unsigned(RData24);
        end if;
        if (DataIn'length = RData16'length) then
            RData16(7 downto 0)  := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData16(15 downto 8) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return unsigned(RData16);
        end if;
    end byteswap;

    function byteswap(DataIn : in std_logic_vector)
    return std_logic_vector is
        variable RData48 : std_logic_vector(47 downto 0);
        variable RData32 : std_logic_vector(31 downto 0);
        variable RData24 : std_logic_vector(23 downto 0);
        variable RData16 : std_logic_vector(15 downto 0);
    begin
        if (DataIn'length = RData48'length) then
            RData48(7 downto 0)   := DataIn((47 + DataIn'right) downto (40 + DataIn'right));
            RData48(15 downto 8)  := DataIn((39 + DataIn'right) downto (32 + DataIn'right));
            RData48(23 downto 16) := DataIn((31 + DataIn'right) downto (24 + DataIn'right));
            RData48(31 downto 24) := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData48(39 downto 32) := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData48(47 downto 40) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return std_logic_vector(RData48);
        end if;
        if (DataIn'length = RData32'length) then
            RData32(7 downto 0)   := DataIn((31 + DataIn'right) downto (24 + DataIn'right));
            RData32(15 downto 8)  := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData32(23 downto 16) := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData32(31 downto 24) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return std_logic_vector(RData32);
        end if;
        if (DataIn'length = RData24'length) then
            RData24(7 downto 0)   := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData24(15 downto 8)  := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData24(23 downto 16) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return std_logic_vector(RData24);
        end if;
        if (DataIn'length = RData16'length) then
            RData16(7 downto 0)  := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData16(15 downto 8) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return std_logic_vector(RData16);
        end if;
    end byteswap;

begin

    DSRBi : dualportpacketringbuffer
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH,
            G_DATA_WIDTH => G_AXIS_DATA_WIDTH
        )
        port map(
            RxClk                  => axis_clk,
            TxClk                  => axis_app_clk,
            -- Transmission port
            TxPacketByteEnable     => SenderRingBufferDataEnable,
            TxPacketDataRead       => SenderRingBufferDataRead,
            TxPacketData           => SenderRingBufferData,
            TxPacketAddress        => SenderRingBufferAddress,
            TxPacketSlotClear      => SenderRingBufferSlotClear,
            TxPacketSlotID         => SenderRingBufferSlotID,
            TxPacketSlotStatus     => SenderRingBufferSlotStatus,
            TxPacketSlotTypeStatus => SenderRingBufferSlotTypeStatus,
            -- Reception port
            RxPacketByteEnable     => lPacketByteEnable,
            RxPacketDataWrite      => lPacketDataWrite,
            RxPacketData           => lPacketData,
            RxPacketAddress        => std_logic_vector(lPacketAddress),
            RxPacketSlotSet        => lPacketSlotSet,
            RxPacketSlotID         => std_logic_vector(lPacketSlotID),
            RxPacketSlotType       => lPacketSlotType,
            RxPacketSlotStatus     => lPacketSlotStatus,
            RxPacketSlotTypeStatus => lPacketSlotTypeStatus
        );

    AddressingChangeProc : process(axis_clk)
    begin
        if (rising_edge(axis_clk)) then

            if (C_RESPONSE_UDP_LENGTH = udp_packet_length) then
                lUDPPacketLengthChanged <= '0';
            else
                -- Flag the change of UDP packet length
                lUDPPacketLengthChanged <= '1';
            end if;

            if (lServerMACAddress = mac_address) then
                lServerMACAddressChanged <= '0';
            else
                -- Flag the change of MAC address
                lServerMACAddressChanged <= '1';
            end if;
            -- Source IP adress my be local IP or multicast IP,
            -- Depending on the destination IP
            if (lServerIPAddress = SourceIPAddress) then
                lServerIPAddressChanged <= '0';
            else
                -- Flag the change of IP address
                lServerIPAddressChanged <= '1';
            end if;

            if (lServerUDPPort = source_udp_port) then
                lServerUDPPortChanged <= '0';
            else
                -- Flag the change of port
                lServerUDPPortChanged <= '1';
            end if;

            if (lClientMACAddress = lClientMACAddress) then
                lClientMACAddressChanged <= '0';
            else
                -- Flag the change of MAC address
                lClientMACAddressChanged <= '1';
            end if;
            -- Destination IP maybe the raw Ip or the gateway
            if (lClientIPAddress = destination_ip) then
                lClientIPAddressChanged <= '0';
            else
                -- Flag the change of IP address
                lClientIPAddressChanged <= '1';
            end if;

            if (lClientUDPPort = destination_udp_port) then
                lClientUDPPortChanged <= '0';
            else
                -- Flag the change of port
                lClientUDPPortChanged <= '1';
            end if;

            lAddressingChanged <= lClientUDPPortChanged or lClientIPAddressChanged or lClientMACAddressChanged or lServerUDPPortChanged or lServerIPAddressChanged or lServerMACAddressChanged or lUDPPacketLengthChanged;

        end if;
    end process AddressingChangeProc;

    SynchStateProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then

            if (axis_reset = '1') then

                StateVariable <= InitialiseSt;
            else
                case (StateVariable) is

                    when InitialiseSt =>

                        -- Wait for packet after initialization
                        StateVariable        <= WaitForPacketStreamSt;
                        lPacketSlotID        <= (others => '0');
                        lPacketAddress       <= (others => '0');
                        -- Reset the packet data to null
                        lPacketData          <= (others => '0');
                        lPacketDataWrite     <= '0';
                        lPacketSlotSet       <= '0';
                        lPacketSlotType      <= '0';
                        lProtocolErrorStatus <= '0';
                        lCheckSumCounter     <= 0;

                    when WaitForPacketStreamSt =>
                        lCheckSumCounter            <= 0;
                        --------------------------------------------------------
                        --                  Ethernet Header                    -
                        --------------------------------------------------------                        
                        -- Swap the source and destination MACS
                        lDestinationMACAddress      <= byteswap(lClientMACAddress);
                        lSourceMACAddress           <= byteswap(mac_address);
                        lEtherType                  <= byteswap(C_RESPONSE_ETHER_TYPE);
                        --------------------------------------------------------
                        --                   IPV4 Header                       -
                        --------------------------------------------------------                         
                        lIPVIHL                     <= C_RESPONSE_IPV4IHL;
                        lDSCPECN                    <= C_RESPONSE_DSCPECN;
                        lTotalLength                <= byteswap(C_RESPONSE_IPV4_LENGTH);
                        lIdentification             <= byteswap(std_logic_vector(lIPIdentification));
                        lFlagsOffset                <= byteswap(C_RESPONSE_FLAGS_OFFSET);
                        lTimeToLeave                <= C_RESPONSE_TIME_TO_LEAVE;
                        lProtocol                   <= C_RESPONSE_UDP_PROTOCOL;
                        -- The checksum must change now
                        lIPHeaderChecksum           <= (others => '0');
                        -- Swap the IP Addresses
                        lDestinationIPAddress       <= byteswap(destination_ip);
                        lSourceIPAddress            <= byteswap(SourceIPAddress);
                        -- Swap the ports
                        lDestinationUDPPort         <= byteswap(destination_udp_port);
                        lSourceUDPPort              <= byteswap(source_udp_port);
                        -- Change the UDP length
                        -- TODO Set the UDP Packet length
                        lUDPDataStreamLength        <= byteswap(C_RESPONSE_UDP_LENGTH);
                        -- The UDP Checksum must change or can put to zero
                        lUDPCheckSum                <= (others => '0');
                        -- These three will be overwritten later
                        -- Rest of data is zeros
                        lPacketData(511 downto 416) <= (others => '0');
                        if (lAddressingChanged = '1') then
                            -- Go to check if dressing has changed
                            StateVariable <= GenerateIPAddressesSt;
                        else
                            StateVariable <= WriteUDPStreamSt;
                        end if;

                    when GenerateIPAddressesSt =>
                        StateVariable <= ARPTableLookUpSt;
                    when ARPTableLookUpSt =>
                        StateVariable <= ProcessARPTableLookUpSt;
                    when ProcessARPTableLookUpSt =>
                        StateVariable <= ProcessAddressingChangesSt;
                    when ProcessAddressingChangesSt =>

                        if (lAddressingChanged = '1') then
                            -- Save the new addressing as it has changed.
                            lServerMACAddress <= byteswap(mac_address);
                            lServerIPAddress  <= byteswap(SourceIPAddress);
                            lServerUDPPort    <= byteswap(source_udp_port);
                            lClientMACAddress <= byteswap(lClientMACAddress);
                            lClientIPAddress  <= byteswap(destination_ip);
                            lClientUDPPort    <= byteswap(destination_udp_port);
                            StateVariable     <= PrecomputeHeaderCheckSumSt;

                        end if;

                    when PreComputeHeaderCheckSumSt =>
                        if (lCheckSumCounter = 10) then
                            lCheckSumCounter <= 0;
                            StateVariable    <= WriteUDPStreamSt;
                        else
                            lCheckSumCounter <= lCheckSumCounter + 1;
                            StateVariable    <= PrecomputeHeaderCheckSumSt;
                        end if;

                        case (lCheckSumCounter) is
                            when 0 =>
                                lPreIPHDRCheckSum <= '0' & '0' & unsigned(byteswap(lDestinationIPAddress(15 downto 0)));

                            when 1 =>
                                lPreIPHDRCheckSum(16 downto 0) <= ('0' & lPreIPHDRCheckSum(15 downto 0)) + ('0' & unsigned(byteswap(lDestinationIPAddress(31 downto 16)))) + lPreIPHDRCheckSum(17 downto 16);

                            when 2 =>
                                lPreIPHDRCheckSum(16 downto 0) <= ('0' & lPreIPHDRCheckSum(15 downto 0)) + ('0' & unsigned(byteswap(lSourceIPAddress(15 downto 0)))) + lPreIPHDRCheckSum(17 downto 16);

                            when 3 =>
                                lPreIPHDRCheckSum(16 downto 0) <= ('0' & lPreIPHDRCheckSum(15 downto 0)) + ('0' & unsigned(byteswap(lSourceIPAddress(31 downto 16)))) + lPreIPHDRCheckSum(17 downto 16);

                            when 4 =>
                                lPreIPHDRCheckSum(16 downto 0) <= ('0' & lPreIPHDRCheckSum(15 downto 0)) + (unsigned(C_RESPONSE_TIME_TO_LEAVE) & unsigned(C_RESPONSE_UDP_PROTOCOL)) + lPreIPHDRCheckSum(17 downto 16);

                            when 5 =>
                                lPreIPHDRCheckSum(16 downto 0) <= ('0' & lPreIPHDRCheckSum(15 downto 0)) + ('0' & unsigned(C_RESPONSE_FLAGS_OFFSET)) + lPreIPHDRCheckSum(17 downto 16);

                            when 6 =>
                                lPreIPHDRCheckSum(16 downto 0) <= ('0' & lPreIPHDRCheckSum(15 downto 0)) + ('0' & unsigned(C_RESPONSE_IPV4_LENGTH)) + lPreIPHDRCheckSum(17 downto 16);

                            when 7 =>
                                lPreIPHDRCheckSum(16 downto 0) <= ('0' & lPreIPHDRCheckSum(15 downto 0)) + ('0' & unsigned(C_RESPONSE_IPV4IHL) & unsigned(C_RESPONSE_DSCPECN)) + lPreIPHDRCheckSum(17 downto 16);

                            when 8 =>
                                lIPHDRCheckSum <= ('0' & lPreIPHDRCheckSum(15 downto 0)) + ('0' & unsigned(lIPIdentification)) + lPreIPHDRCheckSum(17 downto 16);

                            when 9 =>
                                if (lIPHDRCheckSum(16) = '1') then
                                    lIPHDRCheckSum(15 downto 0) <= lIPHDRCheckSum(15 downto 0) + 1;
                                end if;

                            when 10 =>
                                if (lIPHDRCheckSum(15 downto 0) /= X"FFFF") then
                                    lIPHeaderChecksum <= not (byteswap(std_logic_vector(lIPHDRCheckSum(15 downto 0))));
                                else
                                    lIPHeaderChecksum <= byteswap(std_logic_vector(lIPHDRCheckSum(15 downto 0)));
                                end if;

                            when others =>
                                null;
                        end case;

                    when WriteUDPStreamSt =>
                        -- Set the transmitter slot
                        lPacketSlotSet    <= '1';
                        lPacketSlotType   <= '1';
                        -- Save the return packet
                        lPacketByteEnable <= X"0fffffffffffffff";
                        -- Write the response packet to the Ringbuffer                        
                        lPacketDataWrite  <= '1';
                        -- Go to the next slots so that the system
                        -- can progress on the systems slots
                        StateVariable     <= NextSlotsSt;

                    when NextSlotsSt =>
                        -- Transmitter
                        lPacketSlotID     <= lPacketSlotID + 1;
                        lPacketAddress    <= lPacketAddress + 1;
                        lPacketByteEnable <= (others => '0');
                        lPacketData       <= (others => '0');
                        lPacketSlotSet    <= '0';
                        lPacketDataWrite  <= '0';
                        -- Go to check to see if there has been a ready response
                        -- packet from ICAP or Packet Error
                        StateVariable     <= WaitForPacketStreamSt;

                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process SynchStateProc;

end architecture rtl;
