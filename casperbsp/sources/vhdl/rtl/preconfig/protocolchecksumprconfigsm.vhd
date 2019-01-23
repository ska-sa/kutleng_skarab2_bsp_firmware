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
-- Module Name      : protocolchecksumprconfigsm - rtl                         -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The protocolchecksumprconfigsm module receives UDP frames-
--                    and verifies all frames for UDP checksum integrity.      -
--                    When the checksum is correct then the fame is passed on  -
--                    for ICAP3 writing else an error is reported if there is  -
--                    a checksum error of bad frame.                           -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity protocolchecksumprconfigsm is
    generic(
        G_SLOT_WIDTH : natural := 4;
        --G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
        -- ICAP Ring buffer needs 100 DWORDS
        -- The address is log2(100))=7 bits wide
        G_ICAP_RB_ADDR_WIDTH : natural := 7;        
        -- The address width is log2(2048/(512/8))=5 bits wide
        G_ADDR_WIDTH : natural := 5
    );
    port(
        axis_clk                       : in  STD_LOGIC;
        axis_reset                     : in  STD_LOGIC;
        -- IP Addressing information
        ClientMACAddress               : out STD_LOGIC_VECTOR(47 downto 0);
        ClientIPAddress                : out STD_LOGIC_VECTOR(31 downto 0);
        ClientPort                     : out STD_LOGIC_VECTOR(15 downto 0);
        -- Packet Write in addressed bus format
        -- Packet Readout in addressed bus format
        FilterRingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        FilterRingBufferSlotClear      : out STD_LOGIC;
        FilterRingBufferSlotStatus     : in  STD_LOGIC;
        FilterRingBufferSlotTypeStatus : in  STD_LOGIC;
        FilterRingBufferDataRead       : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        FilterRingBufferByteEnable     : in  STD_LOGIC_VECTOR(63 downto 0);
        FilterRingBufferDataIn         : in  STD_LOGIC_VECTOR(511 downto 0);
        FilterRingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        -- Packet Readout in addressed bus format
        ICAPRingBufferSlotID           : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        ICAPRingBufferSlotSet          : out STD_LOGIC;
        ICAPRingBufferSlotStatus       : in  STD_LOGIC;
        ICAPRingBufferSlotType         : out STD_LOGIC;
        ICAPRingBufferDataWrite        : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        ICAPRingBufferByteEnable       : out STD_LOGIC_VECTOR(3 downto 0);
        ICAPRingBufferDataOut          : out STD_LOGIC_VECTOR(31 downto 0);
        ICAPRingBufferAddress          : out STD_LOGIC_VECTOR(G_ICAP_RB_ADDR_WIDTH - 1 downto 0);
        -- Protocol Error
        -- Backoff signal to indicate sender is busy with response                 
        SenderBusy                     : in  STD_LOGIC;
        -- Signal to indicate an erroneous packet condition  
        ProtocolError                  : out STD_LOGIC;
        -- Clear signal to indicate acknowledgement of transaction
        ProtocolErrorClear             : in  STD_LOGIC;
        -- Error type indication
        ProtocolErrorID                : out STD_LOGIC_VECTOR(31 downto 0);
        -- IP Identification 
        ProtocolIPIdentification       : out STD_LOGIC_VECTOR(15 downto 0);
        -- Protocol ID for framing
        ProtocolID                     : out STD_LOGIC_VECTOR(15 downto 0);
        -- Protocol frame sequence
        ProtocolSequence               : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity protocolchecksumprconfigsm;

architecture rtl of protocolchecksumprconfigsm is

    type ConfigurationControllerSM_t is (
        InitialiseSt,                   -- On the reset state
        CheckSlotSt,
        NextSlotSt,
        ReadBufferSt,
        WaitBufferSt,
        CacheDecodePacketSt,
        SaveUDPIPDataSt,
        WriteICAPBufferSt,
        CalculateUDPHeaderCheckSum,
        UpdateCheckOffsetSt,
        UpdateCheckIterationSt,
        ClearSlotSt,
        CompleteUDPCheckSum,
        CompareChecksumSt,
        SetAndNextICAPBufferSlotSt,
        SendErrorResponseSt
    );
    signal StateVariable            : ConfigurationControllerSM_t := InitialiseSt;
    signal lRecvRingBufferSlotID    : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lRecvRingBufferAddress   : unsigned(G_ADDR_WIDTH - 1 downto 0);
    signal lSenderRingBufferSlotID  : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lSenderRingBufferAddress : unsigned(G_ADDR_WIDTH - 1 downto 0);
    

    -- Have 7 iterations for a maximum frame of 98DWORDS on 512 bit AXI-bus with 
    constant C_BUFFER_FRAME_ITERATIONS_MAX : natural := (7 - 1);
    -- Have 100 DWORDS for a maximum frame of 98DWORDS on 32 bit ICAP-bus with 
    constant C_PACKET_DWORD_POINTER_MAX : natural := (100 - 1);
    -- Have 3 DWORDS for a command of 1DWORDS on 32 bit ICAP-bus with 
    constant C_COMMAND_DWORD_POINTER_MAX : natural := (3 - 1);
    -- Have 16 DWORDS on the 512-bit buffer     
    constant C_BUFFER_DWORD_POINTER_MAX : natural := (16 - 1);
    -- Have 6 DWORDS on the 512-bit buffer for DWORD command
    -- Offset is at 11 th DWORD     
    constant C_BUFFER_COMMAND_DWORD_POINTER_OFFSET : natural := (11 - 1);
    -- Have 6 DWORDS on the 512-bit buffer for DWORD command     
    constant C_BUFFER_COMMAND_DWORD_POINTER_MAX : natural := (6 - 1);    
    -- Need to iterate 6 times to calculate UDP header checksum     
    constant C_UDP_HEADER_CHECKSUM_COUNTER_MAX : natural := (6 - 1);    
    -- Need to iterate 7 times to finalize UDP header checksum     
    constant C_FINAL_CHECKSUM_COUNTER_MAX : natural := (7 - 1);  
      
    constant C_RESPONSE_UDP_LENGTH    : std_logic_vector(15 downto 0) := X"0012";
    constant C_RESPONSE_IPV4_LENGTH   : std_logic_vector(15 downto 0) := X"0026";
    constant C_RESPONSE_ETHER_TYPE    : std_logic_vector(15 downto 0) := X"0800";
    constant C_RESPONSE_IPV4IHL       : std_logic_vector(7 downto 0)  := X"45";
    constant C_RESPONSE_DSCPECN       : std_logic_vector(7 downto 0)  := X"00";
    constant C_RESPONSE_FLAGS_OFFSET  : std_logic_vector(15 downto 0) := X"4000";
    constant C_RESPONSE_TIME_TO_LEAVE : std_logic_vector(7 downto 0)  := X"40";
    constant C_RESPONSE_UDP_PROTOCOL  : std_logic_vector(7 downto 0)  := X"11";

    -- Tuples registers
    signal lRingBufferData          : std_logic_vector(511 downto 0);
    type PayLoadArray_t is array (0 to C_BUFFER_DWORD_POINTER_MAX) of std_logic_vector(31 downto 0);
    signal lPayloadArray            : PayLoadArray_t;
    signal lBufferDwordPointer      : natural range 0 to C_BUFFER_DWORD_POINTER_MAX;
    signal lUDPHeaderCheckSumCounter: natural range 0 to C_UDP_HEADER_CHECKSUM_COUNTER_MAX;
    signal lFinalCheckSumCounter    : natural range 0 to C_FINAL_CHECKSUM_COUNTER_MAX;

    alias lDestinationMACAddress    : std_logic_vector(47 downto 0) is lRingBufferData(47 downto 0);
    alias lSourceMACAddress         : std_logic_vector(47 downto 0) is lRingBufferData(95 downto 48);
--    alias lEtherType                : std_logic_vector(15 downto 0) is lRingBufferData(111 downto 96);
--    alias lIPVIHL                   : std_logic_vector(7  downto 0) is lRingBufferData(119 downto 112);
--    alias lDSCPECN                  : std_logic_vector(7  downto 0) is lRingBufferData(127 downto 120);
--    alias lTotalLength              : std_logic_vector(15 downto 0) is lRingBufferData(143 downto 128);
    alias lIdentification           : std_logic_vector(15 downto 0) is lRingBufferData(159 downto 144);
--    alias lFlagsOffset              : std_logic_vector(15 downto 0) is lRingBufferData(175 downto 160);
--    alias lTimeToLeave              : std_logic_vector(7  downto 0) is lRingBufferData(183 downto 176);
--    alias lProtocol                 : std_logic_vector(7  downto 0) is lRingBufferData(191 downto 184);
--    alias lIPHeaderChecksum         : std_logic_vector(15 downto 0) is lRingBufferData(207 downto 192);
    alias lSourceIPAddress          : std_logic_vector(31 downto 0) is lRingBufferData(239 downto 208);
    alias lDestinationIPAddress     : std_logic_vector(31 downto 0) is lRingBufferData(271 downto 240);
    alias lSourceUDPPort            : std_logic_vector(15 downto 0) is lRingBufferData(287 downto 272);
    alias lDestinationUDPPort       : std_logic_vector(15 downto 0) is lRingBufferData(303 downto 288);
    alias lUDPDataStreamLength      : std_logic_vector(15 downto 0) is lRingBufferData(319 downto 304);
    alias lUDPCheckSum              : std_logic_vector(15 downto 0) is lRingBufferData(335 downto 320);
    alias lPRPacketID               : std_logic_vector(15 downto 0) is lRingBufferData(351 downto 336);
    alias lPRPacketSequence         : std_logic_vector(31 downto 0) is lRingBufferData(383 downto 352);
    alias lPRDWordCommand           : std_logic_vector(31 downto 0) is lRingBufferData(415 downto 384);
    signal lUDPHDRCheckSum          : unsigned(17 downto 0);
    signal lUDPFinalCheckSum          : std_logic_vector(15 downto 0);
    
    signal lPreUDPHDRCheckSum       : unsigned(17 downto 0);
    signal lServerMACAddress        : std_logic_vector(47 downto 0);
    signal lServerMACAddressChanged : std_logic;
    signal lServerIPAddress         : std_logic_vector(31 downto 0);
    signal lServerIPAddressChanged  : std_logic;
    signal lServerPort              : std_logic_vector(15 downto 0);
    signal lServerPortChanged       : std_logic;
    signal lClientMACAddress        : std_logic_vector(47 downto 0);
    signal lClientMACAddressChanged : std_logic;
    signal lClientIPAddress         : std_logic_vector(31 downto 0);
    signal lClientIPAddressChanged  : std_logic;
    signal lClientPort              : std_logic_vector(15 downto 0);
    signal lClientPortChanged       : std_logic;
    signal lAddressingChanged       : std_logic;
    signal lBufferFrameIterations   : natural range 0 to C_BUFFER_FRAME_ITERATIONS_MAX;
    signal lInvalidPacket           : std_logic;
    
    

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
    FilterRingBufferSlotID  <= std_logic_vector(lRecvRingBufferSlotID);
    FilterRingBufferAddress <= std_logic_vector(lRecvRingBufferAddress);
    ICAPRingBufferSlotID    <= std_logic_vector(lSenderRingBufferSlotID);
    ICAPRingBufferAddress   <= std_logic_vector(lSenderRingBufferAddress);
    -- Save the client addressing information to be able to respond to it
    ClientMACAddress        <= lClientMACAddress;
    ClientIPAddress         <= lClientIPAddress;
    ClientPort              <= lClientPort;
        
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
                        StateVariable             <= CheckSlotSt;
                        FilterRingBufferDataRead  <= '0';
                        FilterRingBufferSlotClear <= '0';
                        lRecvRingBufferSlotID     <= (others => '0');
                        lRecvRingBufferAddress    <= (others => '0');
                        lSenderRingBufferSlotID   <= (others => '0');
                        lSenderRingBufferAddress  <= (others => '0');
                        ICAPRingBufferDataWrite   <= '0';
                        ICAPRingBufferSlotSet     <= '0';

                    when CheckSlotSt =>
                        FilterRingBufferSlotClear <= '0';
                        ICAPRingBufferSlotSet <= '0';
                        lRecvRingBufferAddress <= (others => '0');
                        lSenderRingBufferAddress  <= (others => '0');
                        
                        if (FilterRingBufferSlotStatus = '1') then
                            -- The current slot has data 
                            StateVariable <= ReadBufferSt;
                        else
                            FilterRingBufferDataRead <= '0';
                            lBufferFrameIterations <= 0;
                            StateVariable            <= CheckSlotSt;
                        end if;

                    when ReadBufferSt =>
                        -- Pull the data 
                        FilterRingBufferDataRead <= '1';
                        lBufferDwordPointer <= 0;
                        StateVariable            <= WaitBufferSt;

                    when WaitBufferSt =>
                        -- Wait for the data 
                        FilterRingBufferDataRead <= '1';
                        StateVariable            <= CacheDecodePacketSt;
                        
                    when CacheDecodePacketSt =>
                        FilterRingBufferDataRead <= '0';                        
                        
                        if (lBufferFrameIterations = 0) then
                            -- Save the data on the correct framing order                                                        
                            lPayloadArray(0) <= lRingBufferData((32*(C_BUFFER_COMMAND_DWORD_POINTER_OFFSET+1))-1 downto ((32*C_BUFFER_COMMAND_DWORD_POINTER_OFFSET)-16)) & byteswap(lIdentification);                            
                            for i in 1 to C_BUFFER_COMMAND_DWORD_POINTER_MAX loop
                                lPayloadArray(i) <= lRingBufferData((32*((i+C_BUFFER_COMMAND_DWORD_POINTER_OFFSET)+1))-1 downto (32*(i+C_BUFFER_COMMAND_DWORD_POINTER_OFFSET)));
                            end loop;
                            if ( ((lPRPacketID(7 downto 0) = X"01") and (lUDPDataStreamLength = X"0012")) or
                                ((lPRPacketID(7 downto 0) = X"62") and (lUDPDataStreamLength = X"0196"))) then
                                -- This is a valid packet because it meets the framing requirements                                
                                lInvalidPacket <= '0';
                                
                            else
                                lInvalidPacket <= '1';
                                -- We have an error condition
                                -- Save the error condition
                            end if;
                            StateVariable <= SaveUDPIPDataSt;                                
                            
                        else
                            -- Save the ring buffer data.
                            for i in 0 to C_BUFFER_DWORD_POINTER_MAX loop
                                lPayloadArray(i) <= lRingBufferData((32*(i+1))-1 downto (32*i));
                            end loop;
                            
                            StateVariable <= WriteICAPBufferSt;
                        end if;

                    when SaveUDPIPDataSt =>
                        if (lInvalidPacket = '1') then
                            StateVariable <= SendErrorResponseSt;
                        else
                            if (lBufferFrameIterations = 0) then
                                StateVariable <= CalculateUDPHeaderCheckSum;
                            else
                                StateVariable <= WriteICAPBufferSt;
                            end if;
                        end if;

                        
                    when CalculateUDPHeaderCheckSum =>
                        if (lUDPHeaderCheckSumCounter = C_UDP_HEADER_CHECKSUM_COUNTER_MAX) then
                            -- Done with UDP Header CheckSum calculation
                            StateVariable <= WriteICAPBufferSt;
                        else
                            -- Keep calculating the UDP header checksum untill done
                            StateVariable <= CalculateUDPHeaderCheckSum;
                            lUDPHeaderCheckSumCounter <= lUDPHeaderCheckSumCounter + 1;
                            
                            case (lUDPHeaderCheckSumCounter) is
                                when 0 =>
                                when 1 => 
                                when 2 => 
                                when 3=>
                                when others => null;
                            end case;
                        end if;

                    when WriteICAPBufferSt =>
                        ICAPRingBufferDataWrite <= '1';
                        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
                        -- we use it to save TLAST
                        ICAPRingBufferByteEnable(3 downto 1) <= (others => '1');
                        if (lPRPacketID(7 downto 0) = X"01") then
                            -- Signal the last data packet
                            ICAPRingBufferByteEnable(0) <= '1';
                        else
                            if (lPRPacketID(7 downto 0) = X"62") then
                                if (lSenderRingBufferAddress = C_PACKET_DWORD_POINTER_MAX) then
                                    -- This is the last frame packet
                                    ICAPRingBufferByteEnable(0) <= '1';                                    
                                else
                                    ICAPRingBufferByteEnable(0) <= '0';
                                end if;
                            else                                
                                ICAPRingBufferByteEnable(0) <= '0';
                            end if;
                        end if;
                        -- Output the DWORD at the lBufferDwordPointer index
                        ICAPRingBufferDataOut <= lPayloadArray(lBufferDwordPointer);                         
                        -- Go to next DWORD
                        StateVariable <= UpdateCheckOffsetSt;

                    when UpdateCheckOffsetSt =>
                        ICAPRingBufferDataWrite <= '0';
                        lSenderRingBufferAddress <= lSenderRingBufferAddress + '1';
                        -- Point to next DWORD index within the 512-bit buffer
                        lBufferDwordPointer <= lBufferDwordPointer + 1;
                        
                        
                        if (lPRPacketID(7 downto 0) = X"01") then
                            -- This is a command 
                            if (lSenderRingBufferAddress = C_COMMAND_DWORD_POINTER_MAX) then
                                -- Done with data
                                StateVariable <= UpdateCheckIterationSt;
                            else
                                -- Keep reading data
                                StateVariable <= WriteICAPBufferSt;
                            end if;
                            
                        else
                            -- This is a FRAME 
                            if ( (lSenderRingBufferAddress = C_PACKET_DWORD_POINTER_MAX) or 
                                 (lBufferDwordPointer = C_BUFFER_DWORD_POINTER_MAX)
                                ) then
                                -- Done with data (either at end of 100 DWORDS 
                                -- or 16 DWORDS on 512 - buffer
                                StateVariable <= UpdateCheckIterationSt;
                            else
                                -- Keep reading data
                                StateVariable <= WriteICAPBufferSt;
                            end if;
                        end if;

    
                    when UpdateCheckIterationSt =>
                        -- Increment pointer to data source.
                        lRecvRingBufferAddress <= lRecvRingBufferAddress + '1';
                        
                        if (lPRPacketID(7 downto 0) = X"01") then
                            -- Done with data since this is just one DWORD
                            StateVariable <= ClearSlotSt;
                        else
                            -- This is a FRAME,iterate till done 
                            if (lBufferFrameIterations = C_BUFFER_FRAME_ITERATIONS_MAX) then
                                -- Done with data
                                StateVariable <= ClearSlotSt;
                            else
                                -- Keep reading data,till whole 98 DWORD frame
                                -- is fully consumed and forwarded
                                StateVariable <= ReadBufferSt;                            
                            end if;
                        end if;

                    when ClearSlotSt =>
                        FilterRingBufferSlotClear <= '1';                        
                        StateVariable <= NextSlotSt;

                    when NextSlotSt =>
                        FilterRingBufferSlotClear <= '0';
                        -- Point to next slot
                        lRecvRingBufferSlotID <= lRecvRingBufferSlotID + '1';                        
                        StateVariable <= CompleteUDPCheckSum;
                        
                    when CompleteUDPCheckSum =>
                        if (lFinalCheckSumCounter = C_FINAL_CHECKSUM_COUNTER_MAX) then
                            StateVariable <= CompareChecksumSt;
                        else
                            -- Keep calculating the checksum untill done
                            StateVariable <= CompleteUDPCheckSum;
                            lFinalCheckSumCounter <= lFinalCheckSumCounter + 1;
                            
                            case (lFinalCheckSumCounter) is
                                when 0 =>
                                when 1 => 
                                when 2 =>
                                when others => null;
                            end case;
                        end if;

                    -- Response processing    
                    when CompareChecksumSt =>

                        if (lUDPFinalCheckSum = lUDPCheckSum) then
                            -- Done with data
                            StateVariable <= SetAndNextICAPBufferSlotSt;
                        else
                            -- Got checksum error 
                            -- Save error state
                            StateVariable <= SendErrorResponseSt;
                        end if;

                    when SetAndNextICAPBufferSlotSt =>
                        -- Data has integrity forward it by setting the active
                        -- ICAP Ring Buffer slot
                        ICAPRingBufferSlotSet <= '1';
                        lSenderRingBufferSlotID <= lSenderRingBufferSlotID + '1';                        
                        -- Go check for data on next receiver ring buffer slot
                        StateVariable <= CheckSlotSt;

                    when SendErrorResponseSt =>
                        -- Prepare a UDP Error packet
                        StateVariable <= CheckSlotSt;

                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process SynchStateProc;

end architecture rtl;
