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
-- Module Name      : macaxisdecoupler - rtl                                   -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The macaxisdecoupler module receives and send axis packet-
--                    streams, it works by decoupling the axis interface from a-
--                    synchronous burst interface to a throttled asynchrounous -
--                    interface. This module also filters all bad packets using-
--                    tuser on the rx interface.                               -
-- Dependencies     : macaxissender,macaxisreceiver                            -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity macaxisdecoupler is
    port(
        axis_tx_clk       : in  STD_LOGIC;
        axis_rx_clk       : in  STD_LOGIC;
        axis_reset        : in  STD_LOGIC;
        DataRateBackOff   : in  STD_LOGIC;
        TXOverFlowCount   : out STD_LOGIC_VECTOR(31 downto 0);
        TXAlmostFullCount : out STD_LOGIC_VECTOR(31 downto 0);
        --Outputs to AXIS bus MAC side 
        axis_tx_tdata     : out STD_LOGIC_VECTOR(511 downto 0);
        axis_tx_tvalid    : out STD_LOGIC;
        axis_tx_tready    : in  STD_LOGIC;
        axis_tx_tuser     : out STD_LOGIC;
        axis_tx_tkeep     : out STD_LOGIC_VECTOR(63 downto 0);
        axis_tx_tlast     : out STD_LOGIC;
        --Inputs from AXIS bus of the MAC side
        axis_rx_tready    : out STD_LOGIC;
        axis_rx_tdata     : in  STD_LOGIC_VECTOR(511 downto 0);
        axis_rx_tvalid    : in  STD_LOGIC;
        axis_rx_tuser     : in  STD_LOGIC;
        axis_rx_tkeep     : in  STD_LOGIC_VECTOR(63 downto 0);
        axis_rx_tlast     : in  STD_LOGIC
    );
end entity macaxisdecoupler;

architecture rtl of macaxisdecoupler is
    component macaxissender
        generic(
            G_SLOT_WIDTH : natural;
            G_ADDR_WIDTH : natural
        );
        port(
            axis_clk                 : in  STD_LOGIC;
            axis_reset               : in  STD_LOGIC;
            DataRateBackOff          : in  STD_LOGIC;            
            RingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotClear      : out STD_LOGIC;
            RingBufferSlotStatus     : in  STD_LOGIC;
            RingBufferSlotTypeStatus : in  STD_LOGIC;
            RingBufferDataRead       : out STD_LOGIC;
            RingBufferDataEnable     : in  STD_LOGIC_VECTOR(63 downto 0);
            RingBufferDataIn         : in  STD_LOGIC_VECTOR(511 downto 0);
            RingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            axis_tx_tdata            : out STD_LOGIC_VECTOR(511 downto 0);
            axis_tx_tvalid           : out STD_LOGIC;
            axis_tx_tready           : in  STD_LOGIC;
            axis_tx_tuser            : out STD_LOGIC;
            axis_tx_tkeep            : out STD_LOGIC_VECTOR(63 downto 0);
            axis_tx_tlast            : out STD_LOGIC
        );
    end component macaxissender;

    component macaxisreceiver
        generic(
            G_SLOT_WIDTH : natural;
            G_ADDR_WIDTH : natural
        );
        port(
            axis_ringbuffer_clk      : in  STD_LOGIC;
            axis_rx_clk              : in  STD_LOGIC;
            axis_reset               : in  STD_LOGIC;
            RXOverFlowCount          : out STD_LOGIC_VECTOR(31 downto 0);
            RXAlmostFullCount        : out STD_LOGIC_VECTOR(31 downto 0);
            RingBufferSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotClear      : in  STD_LOGIC;
            RingBufferSlotStatus     : out STD_LOGIC;
            RingBufferSlotTypeStatus : out STD_LOGIC;
            RingBufferDataRead       : in  STD_LOGIC;
            RingBufferDataEnable     : out STD_LOGIC_VECTOR(63 downto 0);
            RingBufferDataOut        : out STD_LOGIC_VECTOR(511 downto 0);
            RingBufferAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            axis_rx_tdata            : in  STD_LOGIC_VECTOR(511 downto 0);
            axis_rx_tvalid           : in  STD_LOGIC;
            axis_rx_tuser            : in  STD_LOGIC;
            axis_rx_tready           : out STD_LOGIC;
            axis_rx_tkeep            : in  STD_LOGIC_VECTOR(63 downto 0);
            axis_rx_tlast            : in  STD_LOGIC
        );
    end component macaxisreceiver;
    constant G_SLOT_WIDTH : natural := 4;
    constant G_ADDR_WIDTH : natural := 5;

    signal RingBufferSlotID         : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal RingBufferSlotClear      : STD_LOGIC;
    signal RingBufferSlotStatus     : STD_LOGIC;
    signal RingBufferSlotTypeStatus : STD_LOGIC;
    signal RingBufferDataRead       : STD_LOGIC;
    signal RingBufferDataEnable     : STD_LOGIC_VECTOR(63 downto 0);
    signal RingBufferData           : STD_LOGIC_VECTOR(511 downto 0);
    signal RingBufferAddress        : STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);

begin

    UDPSender_i : macaxissender
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH
        )
        port map(
            axis_clk                 => axis_tx_clk,
            axis_reset               => axis_reset,
            DataRateBackOff          => DataRateBackOff,
            RingBufferSlotID         => RingBufferSlotID,
            RingBufferSlotClear      => RingBufferSlotClear,
            RingBufferSlotStatus     => RingBufferSlotStatus,
            RingBufferSlotTypeStatus => RingBufferSlotTypeStatus,
            RingBufferDataRead       => RingBufferDataRead,
            RingBufferDataEnable     => RingBufferDataEnable,
            RingBufferDataIn         => RingBufferData,
            RingBufferAddress        => RingBufferAddress,
            axis_tx_tdata            => axis_tx_tdata,
            axis_tx_tvalid           => axis_tx_tvalid,
            axis_tx_tready           => axis_tx_tready,
            axis_tx_tuser            => axis_tx_tuser, 
            axis_tx_tkeep            => axis_tx_tkeep,
            axis_tx_tlast            => axis_tx_tlast
        );

    UDPReceiver_i : macaxisreceiver
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH
        )
        port map(
            axis_ringbuffer_clk      => axis_tx_clk,
            axis_rx_clk              => axis_rx_clk,
            axis_reset               => axis_reset,
            RXOverFlowCount          => TXOverFlowCount,
            RXAlmostFullCount        => TXAlmostFullCount,
            RingBufferSlotID         => RingBufferSlotID,
            RingBufferSlotClear      => RingBufferSlotClear,
            RingBufferSlotStatus     => RingBufferSlotStatus,
            RingBufferSlotTypeStatus => RingBufferSlotTypeStatus,
            RingBufferDataRead       => RingBufferDataRead,
            RingBufferDataEnable     => RingBufferDataEnable,
            RingBufferDataOut        => RingBufferData,
            RingBufferAddress        => RingBufferAddress,
            axis_rx_tdata            => axis_rx_tdata,
            axis_rx_tvalid           => axis_rx_tvalid,
            axis_rx_tuser            => axis_rx_tuser,
            axis_rx_tready           => axis_rx_tready,
            axis_rx_tkeep            => axis_rx_tkeep,
            axis_rx_tlast            => axis_rx_tlast
        );
end architecture rtl;
