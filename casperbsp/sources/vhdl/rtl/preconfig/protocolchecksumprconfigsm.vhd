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

entity protocolchecksumprconfigsm is
    generic(
        G_SLOT_WIDTH : natural := 4;
        --G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
        -- The address width is log2(2048/(512/8))=5 bits wide
        G_ADDR_WIDTH : natural := 5
    );
    port(
        axis_clk                       : in  STD_LOGIC;
        axis_reset                     : in  STD_LOGIC;
        -- Packet Write in addressed bus format
        -- Packet Readout in addressed bus format
        FilterRingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        FilterRingBufferSlotClear      : out STD_LOGIC;
        FilterRingBufferSlotStatus     : in  STD_LOGIC;
        FilterRingBufferSlotTypeStatus : in  STD_LOGIC;
        FilterRingBufferDataRead       : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        FilterRingBufferByteEnable     : in  STD_LOGIC_VECTOR(3 downto 0);
        FilterRingBufferDataIn         : in  STD_LOGIC_VECTOR(31 downto 0);
        FilterRingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        -- Packet Readout in addressed bus format
        ICAPRingBufferSlotID           : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        ICAPRingBufferSlotSet          : out STD_LOGIC;
        ICAPRingBufferSlotStatus       : in  STD_LOGIC;
        ICAPRingBufferSlotType         : out STD_LOGIC;
        ICAPRingBufferDataWrite        : out STD_LOGIC;
        SenderBusy                     : in  STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        ICAPRingBufferByteEnable       : out STD_LOGIC_VECTOR(3 downto 0);
        ICAPRingBufferDataOut          : out STD_LOGIC_VECTOR(31 downto 0);
        ICAPRingBufferAddress          : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        -- Protocol Error
        ProtocolError                  : out STD_LOGIC;
        ProtocolErrorClear             : in  STD_LOGIC;
        ProtocolErrorID                : out STD_LOGIC_VECTOR(31 downto 0);
        ProtocolIPIdentification       : out STD_LOGIC_VECTOR(15 downto 0);
        ProtocolID                     : out STD_LOGIC_VECTOR(15 downto 0);
        ProtocolSequence               : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity protocolchecksumprconfigsm;

architecture rtl of protocolchecksumprconfigsm is

    type ConfigurationControllerSM_t is (
        InitialiseSt,                   -- On the reset state
        CheckSlotSt,
        NextSlotSt,
        ComposeResponsePacketSt,
        CheckCommandSt,
        ProcessCommandSt,
        ProcessFrameSt,
        GetICAPStatusSt,
        PrepareResponseHeader,
        GenerateIPCheckSumSt,
        WriteUDPResponceSt,
        ProcessSlotsSt,
        NextSlotsSt,
        SendErrorResponseSt
    );
    signal StateVariable              : ConfigurationControllerSM_t := InitialiseSt;
    signal lRecvRingBufferSlotID    : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lRecvRingBufferAddress   : unsigned(G_ADDR_WIDTH - 1 downto 0);
    signal lSenderRingBufferSlotID  : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lSenderRingBufferAddress : unsigned(G_ADDR_WIDTH - 1 downto 0);

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
    FilterRingBufferSlotID    <= std_logic_vector(lRecvRingBufferSlotID);
    FilterRingBufferAddress   <= std_logic_vector(lRecvRingBufferAddress);
    ICAPRingBufferSlotID  <= std_logic_vector(lSenderRingBufferSlotID);
    ICAPRingBufferAddress <= std_logic_vector(lSenderRingBufferAddress);
    
    FilledSlotsProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            --ICAPRingBufferSlotsFilled <= FilterRingBufferSlotsFilled;
        end if;
    end process FilledSlotsProc;


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
                        lRecvRingBufferAddress    <= (others => '0');
                        FilterRingBufferDataRead    <= '0';
                        FilterRingBufferSlotClear   <= '0';
                        lRecvRingBufferSlotID     <= (others => '0');
                        lSenderRingBufferSlotID   <= (others => '0');
                        lSenderRingBufferAddress  <= (others => '0');
                        ICAPRingBufferDataWrite <= '0';
                        ICAPRingBufferSlotSet   <= '0';

                    when CheckSlotSt =>
                        lRecvRingBufferAddress <= (others => '0');
                        if (FilterRingBufferSlotStatus = '1') then
                            -- The current slot has data 
                            -- Pull the data 
                            FilterRingBufferDataRead <= '1';
                            StateVariable          <= ComposeResponsePacketSt;
                        else
                            FilterRingBufferDataRead <= '0';
                            StateVariable          <= CheckSlotSt;
                        end if;

                    when NextSlotSt =>
                        -- Go to next Slot
                        lRecvRingBufferSlotID   <= lRecvRingBufferSlotID + 1;
                        lRecvRingBufferAddress  <= (others => '0');
                        FilterRingBufferSlotClear <= '0';
                        FilterRingBufferDataRead  <= '0';
                        StateVariable           <= CheckSlotSt;

                    when ComposeResponsePacketSt =>
                        StateVariable                           <= CheckCommandSt;

                    when CheckCommandSt =>

                                StateVariable      <= SendErrorResponseSt;

                    when ProcessFrameSt =>
                            -- Stop writing since the ICAP is not ready
                            StateVariable <= ProcessFrameSt;

                    when ProcessCommandSt =>

                            -- Wait for the ICAP to be ready
                            StateVariable <= ProcessCommandSt;

                    -- Error processing    
                    when SendErrorResponseSt =>
                        -- Prepare a UDP Error packet
                        StateVariable <= GetICAPStatusSt;

                    -- Response processing    
                    when GetICAPStatusSt =>

                        StateVariable <= PrepareResponseHeader;

                    when PrepareResponseHeader =>

                        StateVariable <= GenerateIPCheckSumSt;

                    when GenerateIPCheckSumSt =>
                        -- TODO Do the calculation
                        -- Calculate the IP Checksum Here
                        StateVariable                           <= WriteUDPResponceSt;
                    when WriteUDPResponceSt =>
                        -- Prepare the response packet to the Ringbuffer
                        StateVariable <= ProcessSlotsSt;

                    when ProcessSlotsSt =>
                        -- Set the transmitter slot
                        ICAPRingBufferSlotSet        <= '1';
                        -- Save the return packet
                        -- Write the response packet to the Ringbuffer                        
                        ICAPRingBufferDataWrite      <= '1';
                        -- Go to the next slots so that the system
                        -- can progress on the systems slots
                        StateVariable                  <= NextSlotsSt;

                    when NextSlotsSt =>
                        -- Transmitter
                        lSenderRingBufferSlotID    <= lSenderRingBufferSlotID + 1;
                        lSenderRingBufferAddress   <= (others => '0');
                        ICAPRingBufferDataOut    <= (others => '0');
                        ICAPRingBufferSlotSet    <= '0';
                        ICAPRingBufferDataWrite  <= '0';
                        -- Clear the receiver slot
                        FilterRingBufferSlotClear    <= '1';
                        -- Go to check the next available receiver slot
                        StateVariable              <= NextSlotSt;

                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process SynchStateProc;

end architecture rtl;
