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
-- Module Name      : ringbufferfabricmultiplexer - rtl                        -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This multiplexes multiple AXIS streams to one.           -
--                    TODO                                                     -
--                    Find a parallel algorithm for the arbitration            -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ringbufferfabricmultiplexer is
    generic(
        G_MUX_PORTS  : natural := 7;
        G_DATA_WIDTH : natural := 512;
        G_ADDR_WIDTH : natural := 5;
        G_SLOT_WIDTH : natural := 4
    );
    port(
        axis_clk                   : in  STD_LOGIC;
        axis_reset                 : in  STD_LOGIC;
        MuxRequestSlot             : in  STD_LOGIC;
        MuxAckSlot                 : out STD_LOGIC;
        MuxSlotID                  : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        --Outputs to down stream 
        RingBufferSlotID           : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        RingBufferSlotClear        : in  STD_LOGIC;
        RingBufferSlotStatus       : out STD_LOGIC;
        RingBufferSlotTypeStatus   : out STD_LOGIC;
        RingBufferDataRead         : in  STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        RingBufferDataEnable       : out STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
        RingBufferData             : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        RingBufferAddress          : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        --Inputs from up stream 
        ----------------------------------------------------------------------------------------------------------------------
        RxRingBufferSlotID         : out STD_LOGIC_VECTOR(G_MUX_PORTS * G_SLOT_WIDTH - 1 downto 0);
        RxRingBufferSlotClear      : out STD_LOGIC_VECTOR(G_MUX_PORTS - 1 downto 0);
        RxRingBufferSlotStatus     : in  STD_LOGIC_VECTOR(G_MUX_PORTS - 1 downto 0);
        RxRingBufferSlotTypeStatus : in  STD_LOGIC_VECTOR(G_MUX_PORTS - 1 downto 0);
        RxRingBufferDataRead       : out STD_LOGIC_VECTOR(G_MUX_PORTS - 1 downto 0);
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        RxRingBufferDataEnable     : in  STD_LOGIC_VECTOR((G_MUX_PORTS * G_DATA_WIDTH / 8) - 1 downto 0);
        RxRingBufferData           : in  STD_LOGIC_VECTOR(G_MUX_PORTS * G_DATA_WIDTH - 1 downto 0);
        RxRingBufferAddress        : out STD_LOGIC_VECTOR(G_MUX_PORTS * G_ADDR_WIDTH - 1 downto 0)
    );
end entity ringbufferfabricmultiplexer;

architecture rtl of ringbufferfabricmultiplexer is
    type AxisMultiplexerSM_t is (
        -- Start checking for a ready packet
        SearchReadyPacket,
        -- Packet processing accepts axis Packets  less than 64 bytes and more
        -- It is important to note that packets can only have one clock cycle
        -- when they have packet data bytes length of less than (G_DATA_WIDTH/8).
        -- This can happen for ARP packets and UDP packets with less than 20 bytes pay load		
        ProcessPacketSt
    );
    type MuxDataArray_t is array (G_MUX_PORTS - 1 downto 0) of std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    type MuxDataEnableArray_t is array (G_MUX_PORTS - 1 downto 0) of std_logic_vector((G_DATA_WIDTH / 8) - 1 downto 0);
    type MuxSlotArray_t is array (G_MUX_PORTS - 1 downto 0) of std_logic_vector(G_SLOT_WIDTH - 1 downto 0);
    type MuxAddressArray_t is array (G_MUX_PORTS - 1 downto 0) of std_logic_vector(G_ADDR_WIDTH - 1 downto 0);

    constant C_MAXIMUM_CLOCKS_PER_TRANSFER : natural := (512 - 1);

    signal StateVariable     : AxisMultiplexerSM_t := SearchReadyPacket;
    signal rx_data_array     : MuxDataArray_t;
    signal rx_enable_array   : MuxDataEnableArray_t;
    signal rx_slot_array     : MuxSlotArray_t;
    signal rx_address_array  : MuxAddressArray_t;
    signal rx_slotclear      : std_logic_vector(G_MUX_PORTS - 1 downto 0);
    signal rx_slotstatus     : std_logic_vector(G_MUX_PORTS - 1 downto 0);
    signal rx_slottypestatus : std_logic_vector(G_MUX_PORTS - 1 downto 0);
    signal rx_dataread       : std_logic_vector(G_MUX_PORTS - 1 downto 0);

    signal SlotCounterMaximumReached : std_logic;

begin
    -- Combinational mux.
    SaveArraryProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            for n in 0 to (G_MUX_PORTS - 1) loop
                rx_data_array(n)                                                          <= RxRingBufferData((G_DATA_WIDTH * (n + 1)) - 1 downto G_DATA_WIDTH * n);
                rx_enable_array(n)                                                        <= RxRingBufferDataEnable(((G_DATA_WIDTH / 8) * (n + 1)) - 1 downto (G_DATA_WIDTH / 8) * n);
                RxRingBufferSlotID((G_SLOT_WIDTH * (n + 1)) - 1 downto G_SLOT_WIDTH * n)  <= rx_slot_array(n);
                RxRingBufferAddress((G_ADDR_WIDTH * (n + 1)) - 1 downto G_ADDR_WIDTH * n) <= rx_address_array(n);
                RxRingBufferDataRead(n)                                                   <= rx_dataread(n);
                RxRingBufferSlotClear(n)                                                  <= rx_slotclear(n);
                rx_slotstatus(n)                                                          <= RxRingBufferSlotStatus(n);
                rx_slottypestatus(n)                                                      <= RxRingBufferSlotTypeStatus(n);
            end loop;
        end if;
    end process SaveArraryProc;
    StateMachineProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                StateVariable <= SearchReadyPacket;
            else
                case StateVariable is
                    -- Evaluate Ethernet header
                    when SearchReadyPacket =>
                        StateVariable <= ProcessPacketSt;
                    when ProcessPacketSt =>
                        StateVariable <= ProcessPacketSt;
                    when others =>
                        StateVariable <= SearchReadyPacket;
                end case;
            end if;
        end if;
    end process StateMachineProc;

end architecture rtl;
