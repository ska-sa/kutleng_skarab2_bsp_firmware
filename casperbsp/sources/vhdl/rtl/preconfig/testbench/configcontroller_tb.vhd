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
-- Module Name      : configcontroller_tb - rtl                                -
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

entity configcontroller_tb is
end entity configcontroller_tb;

architecture behavorial of configcontroller_tb is

    component configcontroller is
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
    end component configcontroller;

    constant C_SLOT_WIDTH                 : natural                                     := 4;
    constant C_ADDR_WIDTH                 : natural                                     := 5;
    signal icap_clk                       : STD_LOGIC                                   := '1';
    signal axis_reset                     : STD_LOGIC                                   := '1';
    signal RecvRingBufferSlotID           : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
    signal RecvRingBufferSlotClear        : STD_LOGIC;
    signal RecvRingBufferSlotStatus       : STD_LOGIC                                   := '0';
    signal RecvRingBufferSlotTypeStatus   : STD_LOGIC                                   := '0';
    signal RecvRingBufferSlotsFilled      : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0) := (others => '0');
    signal RecvRingBufferDataRead         : STD_LOGIC;
    signal RecvRingBufferDataEnable       : STD_LOGIC_VECTOR(63 downto 0)               := (others => '0');
    signal RecvRingBufferDataIn           : STD_LOGIC_VECTOR(511 downto 0)              := (others => '0');
    signal RecvRingBufferAddress          : STD_LOGIC_VECTOR(C_ADDR_WIDTH - 1 downto 0);
    signal SenderRingBufferSlotID         : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
    signal SenderRingBufferSlotSet        : STD_LOGIC;
    signal SenderRingBufferSlotStatus     : STD_LOGIC;
    signal SenderRingBufferSlotTypeStatus : STD_LOGIC;
    signal SenderRingBufferSlotsFilled    : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
    signal SenderRingBufferDataWrite      : STD_LOGIC;
    signal SenderRingBufferDataEnable     : STD_LOGIC_VECTOR(63 downto 0);
    signal SenderRingBufferDataOut        : STD_LOGIC_VECTOR(511 downto 0);
    signal SenderRingBufferAddress        : STD_LOGIC_VECTOR(C_ADDR_WIDTH - 1 downto 0);
    signal ICAP_CSIB                      : STD_LOGIC;
    signal ICAP_RDWRB                     : STD_LOGIC;
    signal ICAP_PRDONE                    : STD_LOGIC                                   := '0';
    signal ICAP_PRERROR                   : STD_LOGIC                                   := '0';
    signal ICAP_AVAIL                     : STD_LOGIC                                   := '1';
    signal ICAP_DataIn                    : STD_LOGIC_VECTOR(31 downto 0);
    signal ICAP_DataOut                   : STD_LOGIC_VECTOR(31 downto 0)               := (others => '0');

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
        variable RData48 : std_logic_vector(47 downto 0);
        variable RData32 : std_logic_vector(31 downto 0);
        variable RData24 : std_logic_vector(23 downto 0);
        variable RData16 : std_logic_vector(15 downto 0);
    begin
        if (DataIn'length = RData48'length) then
            RData48(7 downto 0)   := bitreverse(DataIn(47 downto 40));
            RData48(15 downto 8)  := bitreverse(DataIn(39 downto 32));
            RData48(23 downto 16) := bitreverse(DataIn(31 downto 24));
            RData48(31 downto 24) := bitreverse(DataIn(23 downto 16));
            RData48(39 downto 32) := bitreverse(DataIn(15 downto 8));
            RData48(47 downto 40) := bitreverse(DataIn(7 downto 0));
            return std_logic_vector(RData48);
        end if;
        if (DataIn'length = RData32'length) then
            RData32(7 downto 0)   := bitreverse(DataIn(31 downto 24));
            RData32(15 downto 8)  := bitreverse(DataIn(23 downto 16));
            RData32(23 downto 16) := bitreverse(DataIn(15 downto 8));
            RData32(31 downto 24) := bitreverse(DataIn(7 downto 0));
            return std_logic_vector(RData32);
        end if;
        if (DataIn'length = RData24'length) then
            RData24(7 downto 0)   := bitreverse(DataIn(23 downto 16));
            RData24(15 downto 8)  := bitreverse(DataIn(15 downto 8));
            RData24(23 downto 16) := bitreverse(DataIn(7 downto 0));
            return std_logic_vector(RData24);
        end if;
        if (DataIn'length = RData16'length) then
            RData16(7 downto 0)  := bitreverse(DataIn(15 downto 8));
            RData16(15 downto 8) := bitreverse(DataIn(7 downto 0));
            return std_logic_vector(RData16);
        else
            return DataIn;
        end if;
    end function bitbyteswap;

    constant C_CLK_PERIOD : time := 10 ns;
begin
    icap_clk   <= not icap_clk after C_CLK_PERIOD / 2;
    axis_reset <= '1', '0' after C_CLK_PERIOD * 20;

    UUT_i : configcontroller
        generic map(
            G_SLOT_WIDTH => C_SLOT_WIDTH,
            G_ADDR_WIDTH => C_ADDR_WIDTH
        )
        port map(
            icap_clk                       => icap_clk,
            axis_reset                     => axis_reset,
            RecvRingBufferSlotID           => RecvRingBufferSlotID,
            RecvRingBufferSlotClear        => RecvRingBufferSlotClear,
            RecvRingBufferSlotStatus       => RecvRingBufferSlotStatus,
            RecvRingBufferSlotTypeStatus   => RecvRingBufferSlotTypeStatus,
            RecvRingBufferSlotsFilled      => RecvRingBufferSlotsFilled,
            RecvRingBufferDataRead         => RecvRingBufferDataRead,
            RecvRingBufferDataEnable       => RecvRingBufferDataEnable,
            RecvRingBufferDataIn           => RecvRingBufferDataIn,
            RecvRingBufferAddress          => RecvRingBufferAddress,
            SenderRingBufferSlotID         => SenderRingBufferSlotID,
            SenderRingBufferSlotSet        => SenderRingBufferSlotSet,
            SenderRingBufferSlotStatus     => SenderRingBufferSlotStatus,
            SenderRingBufferSlotTypeStatus => SenderRingBufferSlotTypeStatus,
            SenderRingBufferSlotsFilled    => SenderRingBufferSlotsFilled,
            SenderRingBufferDataWrite      => SenderRingBufferDataWrite,
            SenderRingBufferDataEnable     => SenderRingBufferDataEnable,
            SenderRingBufferDataOut        => SenderRingBufferDataOut,
            SenderRingBufferAddress        => SenderRingBufferAddress,
            ICAP_CSIB                      => ICAP_CSIB,
            ICAP_RDWRB                     => ICAP_RDWRB,
            ICAP_PRDONE                    => ICAP_PRDONE,
            ICAP_PRERROR                   => ICAP_PRERROR,
            ICAP_AVAIL                     => ICAP_AVAIL,
            ICAP_DataIn                    => ICAP_DataIn,
            ICAP_DataOut                   => ICAP_DataOut
        );
ICAP_DataOut <= byteswap(ICAP_DataIn);
    StimProc : process
    begin
        wait for C_CLK_PERIOD * 40;
        --------------------------------------------------------------------------------
        -- Send a 64 byte packet from WireShark
        -- Internet Protocol Version 4, Src: 192.168.1.8 Dst: 192.168.1.13
        -- User Datagram Protocol, Src Port: 55537, Dst Port: 10000
        -- Data (22 bytes)
        -- Data: 01da00000001576f726c000000000000000000000000
        -- [Length: 22]
        --------------------------------------------------------------------------------
        RecvRingBufferDataIn     <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        RecvRingBufferDataEnable <= X"0000000000000000";
        RecvRingBufferSlotStatus <= '0';
        wait for C_CLK_PERIOD;
        RecvRingBufferDataIn     <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        RecvRingBufferDataEnable <= X"0000000000000000";
        RecvRingBufferSlotStatus <= '0';
        wait for C_CLK_PERIOD;
        RecvRingBufferSlotStatus <= '1';
        wait until RecvRingBufferDataRead = '1';
            RecvRingBufferDataIn     <= X"0000000000000000000000006c726f5701000000da0195831e001027f1d80d01a8c00801a8c0522b11400040038c32000045000870fe8e6acc4c4b0c80d9bed4";
            -- expect data as follows = X"0000000000000000000000006c726f5701000000da0193b01e00f1d810270801a8c00d01a8c0b46e11400040a1483200004500084b0c80d9bed470fe8e6acc4c";
            RecvRingBufferDataEnable <= X"ffffffffffffffff";
        wait until SenderRingBufferDataWrite = '1';        
            -- expect data as follows = X"0000000000000000000000006c726f5701000000da0193b01e00f1d810270801a8c00d01a8c0b46e11400040a1483200004500084b0c80d9bed470fe8e6acc4c";
        wait for C_CLK_PERIOD;
        RecvRingBufferDataIn     <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        RecvRingBufferDataEnable <= X"0000000000000000";
        wait until RecvRingBufferSlotClear = '1'; 
        RecvRingBufferSlotStatus <= '0';          
        wait;
    end process StimProc;

end architecture behavorial;
