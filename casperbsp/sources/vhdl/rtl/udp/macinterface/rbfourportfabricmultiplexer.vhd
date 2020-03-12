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
-- Module Name      : rbfourportfabricmultiplexer - rtl                        -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This multiplexes three AXIS streams to one.              -
--                                                                             -
-- Dependencies     : None                                                     -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rbfourportfabricmultiplexer is
    generic(
        G_MAX_PACKET_BLOCKS_SIZE : natural := 64;
        G_DATA_WIDTH             : natural := 512;
        G_ADDR_WIDTH             : natural := 5;
        G_SLOT_WIDTH             : natural := 4
    );
    port(
        axis_clk                    : in  STD_LOGIC;
        axis_reset                  : in  STD_LOGIC;
        -- Inputs from down stream
        MuxRequestSlot              : in  STD_LOGIC;
        MuxAckSlot                  : out STD_LOGIC;
        MuxSlotID                   : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        --Outputs to down stream 
        RingBufferSlotID            : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        RingBufferSlotClear         : in  STD_LOGIC;
        RingBufferSlotStatus        : out STD_LOGIC;
        RingBufferSlotTypeStatus    : out STD_LOGIC;
        RingBufferDataRead          : in  STD_LOGIC;
        RingBufferDataEnable        : out STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
        RingBufferData              : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        RingBufferAddress           : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        ------------------------------------------------------------------------
        --Inputs from up stream                                                -
        ------------------------------------------------------------------------
        -- Port 1                                                              -
        ------------------------------------------------------------------------
        Rx1RingBufferSlotsFilled    : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        Rx1RingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        Rx1RingBufferSlotClear      : out STD_LOGIC;
        Rx1RingBufferSlotStatus     : in  STD_LOGIC;
        Rx1RingBufferSlotTypeStatus : in  STD_LOGIC;
        Rx1RingBufferDataRead       : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        Rx1RingBufferDataEnable     : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
        Rx1RingBufferData           : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        Rx1RingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        ------------------------------------------------------------------------
        -- Port 2                                                              -
        ------------------------------------------------------------------------
        Rx2RingBufferSlotsFilled    : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        Rx2RingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        Rx2RingBufferSlotClear      : out STD_LOGIC;
        Rx2RingBufferSlotStatus     : in  STD_LOGIC;
        Rx2RingBufferSlotTypeStatus : in  STD_LOGIC;
        Rx2RingBufferDataRead       : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        Rx2RingBufferDataEnable     : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
        Rx2RingBufferData           : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        Rx2RingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        ------------------------------------------------------------------------
        -- Port 3                                                              -
        ------------------------------------------------------------------------
        Rx3RingBufferSlotsFilled    : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        Rx3RingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        Rx3RingBufferSlotClear      : out STD_LOGIC;
        Rx3RingBufferSlotStatus     : in  STD_LOGIC;
        Rx3RingBufferSlotTypeStatus : in  STD_LOGIC;
        Rx3RingBufferDataRead       : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        Rx3RingBufferDataEnable     : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
        Rx3RingBufferData           : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        Rx3RingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        ------------------------------------------------------------------------
        -- Port 4                                                              -
        ------------------------------------------------------------------------
        Rx4RingBufferSlotsFilled    : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        Rx4RingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        Rx4RingBufferSlotClear      : out STD_LOGIC;
        Rx4RingBufferSlotStatus     : in  STD_LOGIC;
        Rx4RingBufferSlotTypeStatus : in  STD_LOGIC;
        Rx4RingBufferDataRead       : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        Rx4RingBufferDataEnable     : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
        Rx4RingBufferData           : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        Rx4RingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0)
    );
end entity rbfourportfabricmultiplexer;

architecture rtl of rbfourportfabricmultiplexer is
    type RBMultiplexerSM_t is (
        InitialiseSt,
        CheckForSlotRequestSt,
        CheckForHighestPrioritySlotSt,
        SaveHighestPrioritySlotSt,
        AckSlotSt,
        WaitForSlotClearSt,
        AdvanceSlotRoundRobinSt
    );
    signal StateVariable : RBMultiplexerSM_t := InitialiseSt;
    signal lActivePort   : natural range 0 to 3;

begin
    CombProc : process(RingBufferSlotID, RingBufferSlotClear, RingBufferDataRead, -- Outputs 
        RingBufferAddress, Rx1RingBufferSlotStatus, Rx1RingBufferSlotTypeStatus, -- Rx1
        Rx1RingBufferDataEnable, Rx1RingBufferData, Rx2RingBufferSlotStatus, --Rx2
        Rx2RingBufferSlotTypeStatus, Rx2RingBufferDataEnable, Rx2RingBufferData, --Rx2
        Rx3RingBufferSlotStatus, Rx3RingBufferSlotTypeStatus, Rx3RingBufferDataEnable, --Rx3
        Rx3RingBufferData, Rx4RingBufferSlotStatus, Rx4RingBufferSlotTypeStatus, --Rx4
        Rx4RingBufferDataEnable, Rx4RingBufferData) --Rx4
    begin
        case (lActivePort) is
            when 0 =>
                RingBufferSlotStatus     <= Rx1RingBufferSlotStatus;
                Rx1RingBufferSlotID      <= RingBufferSlotID;
                Rx1RingBufferSlotClear   <= RingBufferSlotClear;
                RingBufferSlotTypeStatus <= Rx1RingBufferSlotTypeStatus;
                Rx1RingBufferDataRead    <= RingBufferDataRead;
                RingBufferDataEnable     <= Rx1RingBufferDataEnable;
                RingBufferData           <= Rx1RingBufferData;
                Rx1RingBufferAddress     <= RingBufferAddress;
            when 1 =>
                RingBufferSlotStatus     <= Rx2RingBufferSlotStatus;
                Rx2RingBufferSlotID      <= RingBufferSlotID;
                Rx2RingBufferSlotClear   <= RingBufferSlotClear;
                RingBufferSlotTypeStatus <= Rx2RingBufferSlotTypeStatus;
                Rx2RingBufferDataRead    <= RingBufferDataRead;
                RingBufferDataEnable     <= Rx2RingBufferDataEnable;
                RingBufferData           <= Rx2RingBufferData;
                Rx2RingBufferAddress     <= RingBufferAddress;
            when 2 =>
                RingBufferSlotStatus     <= Rx3RingBufferSlotStatus;
                Rx3RingBufferSlotID      <= RingBufferSlotID;
                Rx3RingBufferSlotClear   <= RingBufferSlotClear;
                RingBufferSlotTypeStatus <= Rx3RingBufferSlotTypeStatus;
                Rx3RingBufferDataRead    <= RingBufferDataRead;
                RingBufferDataEnable     <= Rx3RingBufferDataEnable;
                RingBufferData           <= Rx3RingBufferData;
                Rx3RingBufferAddress     <= RingBufferAddress;
            when 3 =>
                RingBufferSlotStatus     <= Rx4RingBufferSlotStatus;
                Rx4RingBufferSlotID      <= RingBufferSlotID;
                Rx4RingBufferSlotClear   <= RingBufferSlotClear;
                RingBufferSlotTypeStatus <= Rx4RingBufferSlotTypeStatus;
                Rx4RingBufferDataRead    <= RingBufferDataRead;
                RingBufferDataEnable     <= Rx4RingBufferDataEnable;
                RingBufferData           <= Rx4RingBufferData;
                Rx4RingBufferAddress     <= RingBufferAddress;
            when others =>
                RingBufferSlotStatus     <= Rx1RingBufferSlotStatus;
                Rx1RingBufferSlotID      <= RingBufferSlotID;
                Rx1RingBufferSlotClear   <= RingBufferSlotClear;
                RingBufferSlotTypeStatus <= Rx1RingBufferSlotTypeStatus;
                Rx1RingBufferDataRead    <= RingBufferDataRead;
                RingBufferDataEnable     <= Rx1RingBufferDataEnable;
                RingBufferData           <= Rx1RingBufferData;
                Rx1RingBufferAddress     <= RingBufferAddress;
        end case;
    end process CombProc;

    StateMachineProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                StateVariable <= InitialiseSt;
            else
                case StateVariable is
                    -- Evaluate Ethernet header
                    when InitialiseSt =>
                        StateVariable <= CheckForSlotRequestSt;
                    when CheckForSlotRequestSt =>
                        StateVariable <= SaveHighestPrioritySlotSt;
                    when SaveHighestPrioritySlotSt =>
                        StateVariable <= CheckForHighestPrioritySlotSt;
                    when CheckForHighestPrioritySlotSt =>
                        StateVariable <= AckSlotSt;
                    when AckSlotSt =>
                        StateVariable <= WaitForSlotClearSt;
                    when WaitForSlotClearSt =>
                        StateVariable <= AdvanceSlotRoundRobinSt;
                    when AdvanceSlotRoundRobinSt =>
                        StateVariable <= CheckForSlotRequestSt;
                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process StateMachineProc;

end architecture rtl;
