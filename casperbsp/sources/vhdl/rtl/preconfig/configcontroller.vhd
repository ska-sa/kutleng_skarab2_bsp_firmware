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
-- Module Name      : configcontroller - rtl                                   -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The configcontroller module receives commands and frames -
--                    for partial reconfiguration and writes to the ICAPE3.    -
--                    The module doesn't check for errors or anything,it just  -
--                    writes the DWORD or the FRAME.It responds with a DWORD   -
--                    status that contains all the necessary errors or status  -
--                    of the partial reconfiguration operation.                -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity configcontroller is
    generic(
        G_SLOT_WIDTH : natural := 4;
        --G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
        -- The address width is log2(2048/(512/8))=5 bits wide
        G_ADDR_WIDTH : natural := 5
    );
    port(
        icap_clk                       : in  STD_LOGIC;
        axis_reset                     : in  STD_LOGIC;
        -- Packet Write in addressed bus format
        -- Packet Readout in addressed bus format
        RecvRingBufferSlotID           : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        RecvRingBufferSlotClear        : out STD_LOGIC;
        RecvRingBufferSlotStatus       : in  STD_LOGIC;
        RecvRingBufferSlotTypeStatus   : in  STD_LOGIC;
        RecvRingBufferSlotsFilled      : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        RecvRingBufferDataRead         : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        RecvRingBufferDataEnable       : in  STD_LOGIC_VECTOR(63 downto 0);
        RecvRingBufferDataIn           : in  STD_LOGIC_VECTOR(511 downto 0);
        RecvRingBufferAddress          : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        -- Packet Readout in addressed bus format
        SenderRingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        SenderRingBufferSlotSet        : out STD_LOGIC;
        SenderRingBufferSlotStatus     : out STD_LOGIC;
        SenderRingBufferSlotTypeStatus : out STD_LOGIC;
        SenderRingBufferSlotsFilled    : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        SenderRingBufferDataWrite      : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        SenderRingBufferDataEnable     : out STD_LOGIC_VECTOR(63 downto 0);
        SenderRingBufferDataOut        : out STD_LOGIC_VECTOR(511 downto 0);
        SenderRingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        --Inputs from AXIS bus of the MAC side
        --ICAPE3 interface
        ICAP_CSIB                      : out STD_LOGIC;
        ICAP_RDWRB                     : out STD_LOGIC;
        ICAP_PRDONE                    : in  STD_LOGIC;
        ICAP_PRERROR                   : in  STD_LOGIC;
        ICAP_AVAIL                     : in  STD_LOGIC;
        ICAP_DataIn                    : out STD_LOGIC_VECTOR(31 downto 0);
        ICAP_DataOut                   : in  STD_LOGIC_VECTOR(31 downto 0)
    );
end entity configcontroller;

architecture rtl of configcontroller is

    type ConfigurationControllerSM_t is (
        InitialiseSt,                   -- On the reset state
        CheckSlotSt,
        NextSlotSt,
        ProcessPacketSt,
        CheckCommandSt,
        ProcessCommandSt,
        WriteCommandToICAPSt,
        WaitCommandAvailICAPSt,
        ProcessFrameSt,
        FetchDWordSt,
        WriteFrameDWordToICAPSt,
        WaitFrameAvailICAPSt,
        NextFrameDWordSt,
        GetICAPStatusSt,
        GenerateIPCheckSumSt,
        WriteUDPResponceSt,
        ProcessSlotsSt,
        NextSlotsSt,
        SendErrorResponseSt
    );
    signal StateVariable            : ConfigurationControllerSM_t   := InitialiseSt;
    -- Tuples registers
    signal lRecvRingBufferSlotID    : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lRecvRingBufferAddress   : unsigned(G_ADDR_WIDTH - 1 downto 0);
    signal lSenderRingBufferSlotID  : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lSenderRingBufferAddress : unsigned(G_ADDR_WIDTH - 1 downto 0);
    constant C_DWORD_MAX            : natural                       := (16 - 1);
    constant C_FIRST_DWORD_OFFSET   : natural                       := 12;
    constant C_ICAP_NOP_COMMAND     : std_logic_vector(31 downto 0) := X"20000000";

    type DWordArray16_t is array (0 to C_DWORD_MAX) of std_logic_vector(31 downto 0);
    signal lReadDWordArray : DWordArray16_t;
    alias lDestinationMACAddress : std_logic_vector(47 downto 0) is RecvRingBufferDataIn(47 downto 0);
    alias lSourceMACAddress : std_logic_vector(47 downto 0) is RecvRingBufferDataIn(95 downto 48);
    alias lEtherType : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(111 downto 96);
    alias lIPVIHL : std_logic_vector(7  downto 0) is RecvRingBufferDataIn(119 downto 112);
    alias lDSCPECN : std_logic_vector(7  downto 0) is RecvRingBufferDataIn(127 downto 120);
    alias lTotalLength : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(143 downto 128);
    alias lIdentification : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(159 downto 144);
    alias lFlagsOffset : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(175 downto 160);
    alias lTimeToLeave : std_logic_vector(7  downto 0) is RecvRingBufferDataIn(183 downto 176);
    alias lProtocol : std_logic_vector(7  downto 0) is RecvRingBufferDataIn(191 downto 184);
    alias lHeaderChecksum : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(207 downto 192);
    alias lSourceIPAddress : std_logic_vector(31 downto 0) is RecvRingBufferDataIn(239 downto 208);
    alias lDestinationIPAddress : std_logic_vector(31 downto 0) is RecvRingBufferDataIn(271 downto 240);
    alias lSourceUDPPort : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(287 downto 272);
    alias lDestinationUDPPort : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(303 downto 288);
    alias lUDPDataStreamLength : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(319 downto 304);
    alias lUDPCheckSum : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(335 downto 320);
    alias lPRPacketID : std_logic_vector(15 downto 0) is RecvRingBufferDataIn(351 downto 336);
    alias lPRPacketSequence : std_logic_vector(31 downto 0) is RecvRingBufferDataIn(383 downto 352);
    alias lPRDWordCommand : std_logic_vector(31 downto 0) is RecvRingBufferDataIn(415 downto 384);
    signal lFilledSlots : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lDWordIndex : natural range 0 to C_DWORD_MAX;
    signal lResponcePacketHDR : std_logic_vector(15 downto 0);
    signal lResponcePacketSequenceNumber : std_logic_vector(31 downto 0);
    signal lResponcePacketICAPOut : std_logic_vector(31 downto 0);
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

    function bitreverse(DataIn : std_logic_vector) return std_logic_vector is
        variable RData : std_logic_vector(DataIn'high downto DataIn'low);
    begin
        for i in DataIn'high downto DataIn'low loop
            RData(i) := DataIn(DataIn'high - i);
        end loop;
        return RData;
    end function bitreverse;

    function bitbyteswap(DataIn : in std_logic_vector)
    return std_logic_vector is
        variable RData32 : std_logic_vector(31 downto 0);
    begin
        if (DataIn'length = RData32'length) then
            for i in 0 to 3 loop
                RData32((8 + (8 * i)) - 1 downto (8 * i)) := bitreverse(DataIn((8 + (8 * i)) - 1 downto (8 * i)));
            end loop;
            return std_logic_vector(RData32);
        else
            return DataIn;
        end if;
    end function bitbyteswap;

begin
    RecvRingBufferSlotID  <= std_logic_vector(lRecvRingBufferSlotID);
    RecvRingBufferAddress <= std_logic_vector(lRecvRingBufferAddress);
    FilledSlotsProc : process(icap_clk)
    begin
        if rising_edge(icap_clk) then
            SenderRingBufferSlotsFilled <= RecvRingBufferSlotsFilled;
        end if;
    end process FilledSlotsProc;

    SaveDWordArrayProc : process(icap_clk)
    begin
        -- Investigate not saving this on a register
        if rising_edge(icap_clk) then
            for i in 0 to 15 loop
                lReadDWordArray(i) <= RecvRingBufferDataIn((32 * (i + 1)) - 1 downto (32 * (i)));
            end loop;
        end if;
    end process SaveDWordArrayProc;

    SynchStateProc : process(icap_clk)
    begin
        if rising_edge(icap_clk) then
            if (axis_reset = '1') then
                -- Initialize SM on reset
                ICAP_RDWRB    <= '0';
                ICAP_CSIB     <= '1';
                -- Tie ICAP Data to NOP Command when being initialized
                ICAP_DataIn   <= bitbyteswap(C_ICAP_NOP_COMMAND);
                StateVariable <= InitialiseSt;
            else
                case (StateVariable) is
                    when InitialiseSt =>
                        -- Wait for packet after initialization
                        StateVariable             <= CheckSlotSt;
                        lRecvRingBufferAddress    <= (others => '0');
                        RecvRingBufferDataRead    <= '0';
                        RecvRingBufferSlotClear   <= '0';
                        lRecvRingBufferSlotID     <= (others => '0');
                        lSenderRingBufferSlotID   <= (others => '0');
                        lSenderRingBufferAddress  <= (others => '0');
                        SenderRingBufferDataWrite <= '0';
                        SenderRingBufferSlotSet   <= '0';
                        ICAP_CSIB                 <= '1';
                        ICAP_RDWRB                <= '0';
                        -- Tie ICAP Data to NOP Command when being initialized
                        ICAP_DataIn   <= bitbyteswap(C_ICAP_NOP_COMMAND);

                    when CheckSlotSt =>
                        lRecvRingBufferAddress <= (others => '0');
                        if (RecvRingBufferSlotStatus = '1') then
                            -- The current slot has data 
                            -- Pull the data 
                            RecvRingBufferDataRead <= '1';
                            StateVariable          <= ProcessPacketSt;
                        else
                            RecvRingBufferDataRead <= '0';
                            StateVariable          <= CheckSlotSt;
                        end if;

                    when NextSlotSt =>
                        -- Go to next Slot
                        lRecvRingBufferSlotID   <= lRecvRingBufferSlotID + 1;
                        lRecvRingBufferAddress  <= (others => '0');
                        RecvRingBufferSlotClear <= '0';
                        RecvRingBufferDataRead  <= '0';
                        ICAP_CSIB               <= '1';
                        StateVariable           <= CheckSlotSt;

                    when ProcessPacketSt =>
                        -- Go to check the command
                        StateVariable <= CheckCommandSt;

                    when CheckCommandSt =>

                        if (lPRPacketID = X"DA01") then
                            -- Forward the ICAP status bits
                            lResponcePacketHDR <= ICAP_PRERROR & ICAP_PRDONE & lPRPacketID(13 downto 0);
                            StateVariable      <= ProcessCommandSt;
                        else
                            if (lPRPacketID = X"A562") then
                                StateVariable      <= ProcessFrameSt;
                                lResponcePacketHDR <= ICAP_PRERROR & ICAP_PRDONE & lPRPacketID(13 downto 0);
                            else
                                StateVariable      <= SendErrorResponseSt;
                                lResponcePacketHDR <= ICAP_PRERROR & ICAP_PRDONE & lPRPacketID(13 downto 8) & X"0E";
                            end if;
                        end if;

                    when ProcessCommandSt =>
                        
                        -- Start Process to write DWORD Command to the ICAP                        
                        StateVariable <= WaitCommandAvailICAPSt;

                    when WaitCommandAvailICAPSt =>
                        
                        -- Check if the ICAP is ready to receive commands
                        -- i.e read or write
                        if (ICAP_AVAIL = '1') then
                            -- ICAP is ready write the command
                            -- Set ICAP to Write mode
                            ICAP_RDWRB    <= '0';
                            -- Do the Xilinx bitswapping on bytes, refer to
                            -- UG570(v1.9) April 2,2018,Figure 9-1,Page 140
                            ICAP_DataIn   <= bitbyteswap(lPRDWordCommand);
                            StateVariable <= WriteCommandToICAPSt;
                        else
                            -- Wait for the ICAP to be ready
                            StateVariable <= WaitCommandAvailICAPSt;
                        end if;
                        
                    when WriteCommandToICAPSt =>
                        
                        -- Assert chip select for the ICAP
                        -- It is active low :(
                        ICAP_CSIB     <= '0';
                        -- Go to save the ICAP Status after the command
                        StateVariable <= GetICAPStatusSt;

                    -- Error processing    
                    when SendErrorResponseSt =>
                        -- Prepare a UDP Error packet
                        StateVariable <= GetICAPStatusSt;

                    -- Response processing    
                    when GetICAPStatusSt =>
                        -- Disselect the ICAP.
                        ICAP_CSIB          <= '1';
                        -- Append the ICAP status on the return bytes
                        -- Update the status bits on the Response Header
                        lResponcePacketHDR <= ICAP_PRERROR & ICAP_PRDONE & lResponcePacketHDR(13 downto 0);
                        -- Save the ICAP Status Data
                        lResponcePacketICAPOut <= ICAP_DataOut;
                        StateVariable      <= GenerateIPCheckSumSt;

                    when GenerateIPCheckSumSt =>
                        -- Calculate the IP Checksum Here
                        StateVariable <= WriteUDPResponceSt;
                    when WriteUDPResponceSt =>
                        -- Prepare the response packet to the Ringbuffer
                        StateVariable <= ProcessSlotsSt;

                    when ProcessSlotsSt =>
                        -- Clear the receiver slot						
                        RecvRingBufferSlotClear <= '1';
                        -- Set the transmitter slot
                        SenderRingBufferSlotSet <= '1';
                        -- Save the return packet
                        SenderRingBufferDataEnable <= RecvRingBufferDataEnable;
                        -- Write the response packet to the Ringbuffer                        
                        SenderRingBufferDataWrite <= '1';
                        -- Go to the next slots so that the system
                        -- can progress on the systems slots
                        StateVariable           <= NextSlotsSt;

                    when NextSlotsSt =>
                        -- Transmitter
                        lSenderRingBufferSlotID   <= lSenderRingBufferSlotID + 1;
                        lSenderRingBufferAddress  <= (others => '0');
                        SenderRingBufferSlotSet   <= '0';
                        SenderRingBufferDataWrite <= '0';
                        -- Go to check the next available receiver slot
                        StateVariable             <= NextSlotSt;

                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process SynchStateProc;

end architecture rtl;
