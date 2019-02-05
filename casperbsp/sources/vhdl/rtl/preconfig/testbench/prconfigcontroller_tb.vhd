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
-- Module Name      : prconfigcontroller_tb - rtl                              -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module instantiates the ARP,Streaming Data over UDP -
--                    and the Partial Reconfiguration UDP Controller.          -
--                    TODO                                                     -
--                    Must connect a Microblaze module, which can do the ARP   -
--                    and control ARP,RARP,DHCP,and the AXI Lite bus.          -
--                                                                             -
-- Dependencies     : macifudpserver,arpmodule,axisthreeportfabricmultiplexer  -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity prconfigcontroller_tb is
end entity prconfigcontroller_tb;

architecture rtl of prconfigcontroller_tb is

    component prconfigcontroller is
        generic(
            G_SLOT_WIDTH      : natural                          := 4;
            G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
            -- The address width is log2(2048/(512/8))=5 bits wide
            G_ADDR_WIDTH      : natural                          := 5
        );
        port(
            --312.50MHz system clock
            axis_clk          : in  STD_LOGIC;
            -- 95 MHz ICAP clock
            icap_clk          : in  STD_LOGIC;
            -- Module reset
            -- Must be synchronized internally for each clock domain
            axis_reset        : in  STD_LOGIC;
            -- Setup information
            ServerMACAddress  : in  STD_LOGIC_VECTOR(47 downto 0);
            ServerIPAddress   : in  STD_LOGIC_VECTOR(31 downto 0);
            --Inputs from AXIS bus of the MAC side
            axis_rx_tdata     : in  STD_LOGIC_VECTOR(511 downto 0);
            axis_rx_tvalid    : in  STD_LOGIC;
            axis_rx_tuser     : in  STD_LOGIC;
            axis_rx_tkeep     : in  STD_LOGIC_VECTOR(63 downto 0);
            axis_rx_tlast     : in  STD_LOGIC;
            --Outputs to AXIS bus MAC side 
            axis_tx_tpriority : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            axis_tx_tdata     : out STD_LOGIC_VECTOR(511 downto 0);
            axis_tx_tvalid    : out STD_LOGIC;
            axis_tx_tready    : in  STD_LOGIC;
            axis_tx_tkeep     : out STD_LOGIC_VECTOR(63 downto 0);
            axis_tx_tlast     : out STD_LOGIC;
            ICAP_PRDONE       : in  std_logic;
            ICAP_PRERROR      : in  std_logic;
            ICAP_AVAIL        : in  std_logic;
            ICAP_CSIB         : out std_logic;
            ICAP_RDWRB        : out std_logic;
            ICAP_DataOut      : in  std_logic_vector(31 downto 0);
            ICAP_DataIn       : out std_logic_vector(31 downto 0)
        );
    end component prconfigcontroller;

    constant G_SLOT_WIDTH     : natural                          := 4;
    constant G_EMAC_ADDR      : std_logic_vector(47 downto 0)    := X"000A_3502_4192";
    constant G_PR_SERVER_PORT : natural range 0 to ((2**16) - 1) := 10000;
    constant G_IP_ADDR        : std_logic_vector(31 downto 0)    := X"C0A8_640A"; --192.168.100.10
    signal axis_clk           : std_logic                        := '1';
    signal icap_clk           : std_logic                        := '1';
    signal axis_reset         : std_logic                        := '1';
    signal ICAP_PRDONE        : std_logic                        := '0';
    signal ICAP_PRERROR       : std_logic                        := '0';
    signal ICAP_AVAIL         : std_logic                        := '1';
    signal ICAP_CSIB          : std_logic;
    signal ICAP_RDWRB         : std_logic;
    signal ICAP_DataOut       : std_logic_vector(31 downto 0)    := (others => '0');
    signal ICAP_DataIn        : std_logic_vector(31 downto 0);

    signal axis_rx_tdata  : STD_LOGIC_VECTOR(511 downto 0);
    signal axis_rx_tvalid : STD_LOGIC;
    signal axis_rx_tkeep  : STD_LOGIC_VECTOR(63 downto 0);
    signal axis_rx_tlast  : STD_LOGIC;
    signal axis_rx_tuser  : STD_LOGIC;

    signal axis_tx_tpriority_1_pr : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal axis_tx_tdata_1_pr     : STD_LOGIC_VECTOR(511 downto 0);
    signal axis_tx_tvalid_1_pr    : STD_LOGIC;
    signal axis_tx_tkeep_1_pr     : STD_LOGIC_VECTOR(63 downto 0);
    signal axis_tx_tlast_1_pr     : STD_LOGIC;
    signal axis_tx_tready_1_pr    : STD_LOGIC := '1';

    constant C_ICAP_CLK_PERIOD : time := 10.52 ns;
    constant C_CLK_PERIOD      : time := 3.2 ns;
begin
    icap_clk   <= not icap_clk after C_ICAP_CLK_PERIOD / 2;
    axis_clk   <= not axis_clk after C_CLK_PERIOD / 2;
    axis_reset <= '1', '0' after C_ICAP_CLK_PERIOD * 20;
    --icap_clk <= axis_clk; -- Just for simulation purporses

    Stimproc : process
    begin
        axis_rx_tdata  <= (others => '0');
        axis_rx_tvalid <= '0';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= (others => '0');
        axis_rx_tlast  <= '0';
        wait for C_ICAP_CLK_PERIOD * 30;
        -- Send DWORD 1 FFFF_FFFF : Sequence 0000_0001
        axis_rx_tdata  <= X"f0a90c0f0000000000000000ffffffff0000000101da4dfe1200102778b50a64a8c09664a8c028da11400040ad16260000450008acfbc34b6b50924102350a00";
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tlast  <= '1';
        axis_rx_tvalid <= '1';
        wait for C_CLK_PERIOD;
        axis_rx_tlast  <= '0';
        axis_rx_tvalid <= '0';
        -- Send DWORD 2 FFFF_FFFF : Sequence 0000_0014
        wait for C_CLK_PERIOD;
        axis_rx_tdata  <= X"2ac843fa0000000000000000aa9955660000001401da4deb1200102778b50a64a8c09664a8c015da11400040c016260000450008acfbc34b6b50924102350a00";
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tlast  <= '1';
        axis_rx_tvalid <= '1';
        wait for C_CLK_PERIOD;
        axis_rx_tlast  <= '0';
        axis_rx_tvalid <= '0';
        -- Send FRAME 3 FFFF_FFFF : Sequence 0000_00159
        wait for C_CLK_PERIOD;
        axis_rx_tdata  <= X"00000000c0900000000003133000405d0000015962a56d759601102774830a64a8c09664a8c0c8281140004089c6aa0100450008acfbc34b6b50924102350a00";
        axis_rx_tkeep  <= X"ffffffffffffffff";
        axis_rx_tvalid <= '1';
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tdata  <= X"00000000000000007ff500000000000000000000c0e800000000031500000000000000000000000000000000c120000000001ff9000000007ff5000000000000";
        axis_rx_tkeep  <= X"ffffffffffffffff";
        axis_rx_tvalid <= '1';
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tdata  <= X"0000000000000000000000000000000000000000000000007ffd00000000000000000000080000000000006000000000000000000000000000000000c1200000";
        axis_rx_tkeep  <= X"ffffffffffffffff";
        axis_rx_tvalid <= '1';
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tdata  <= X"0000000000000000000002f4000000007ffd0000000000000000000064100000000000000000000000000000000000000000000000010000000002f300000000";
        axis_rx_tkeep  <= X"ffffffffffffffff";
        axis_rx_tvalid <= '1';
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tdata  <= X"00000000000000000000000000000000000000000000000000002f2f000000002f2f00000000000000000000000000000000000000000000ff00000000000000";
        axis_rx_tkeep  <= X"ffffffffffffffff";
        axis_rx_tvalid <= '1';
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tdata  <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
        axis_rx_tkeep  <= X"ffffffffffffffff";
        axis_rx_tvalid <= '1';
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tdata  <= X"00000000214830bb000000000000000000000000000000000000000010bd00000000000000000000000000000000000000000000000000000000000000000000";
        axis_rx_tkeep  <= X"00ffffffffffffff";
        axis_rx_tlast  <= '1';
        axis_rx_tvalid <= '1';
        wait for C_CLK_PERIOD;
        axis_rx_tlast  <= '0';
        axis_rx_tvalid <= '0';
        -- Send DWORD 3 AA99_5566 : Sequence 0000_0014
        wait for C_CLK_PERIOD;
        axis_rx_tdata  <= X"2ac843fa0000000000000000aa9955660000001401da4deb1200102778b50a64a8c09664a8c015da11400040c016260000450008acfbc34b6b50924102350a00";
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_ICAP_CLK_PERIOD;
        axis_rx_tlast  <= '1';
        axis_rx_tvalid <= '1';
        wait for C_CLK_PERIOD;
        axis_rx_tlast  <= '0';
        axis_rx_tvalid <= '0';
        wait;
    end process stimproc;
    UUT_i : prconfigcontroller
        generic map(
            G_SLOT_WIDTH      => G_SLOT_WIDTH,
            G_UDP_SERVER_PORT => G_PR_SERVER_PORT,
            G_ADDR_WIDTH      => 5
        )
        port map(
            axis_clk          => axis_clk,
            -- 95 MHz ICAP Clock 
            icap_clk          => icap_clk,
            axis_reset        => axis_reset,
            -- Setup information
            ServerMACAddress  => G_EMAC_ADDR,
            ServerIPAddress   => G_IP_ADDR,
            --Outputs to AXIS bus MAC side 
            axis_tx_tpriority => axis_tx_tpriority_1_pr,
            axis_tx_tdata     => axis_tx_tdata_1_pr,
            axis_tx_tvalid    => axis_tx_tvalid_1_pr,
            axis_tx_tready    => axis_tx_tready_1_pr,
            axis_tx_tkeep     => axis_tx_tkeep_1_pr,
            axis_tx_tlast     => axis_tx_tlast_1_pr,
            --Inputs from AXIS bus of the MAC side
            axis_rx_tdata     => axis_rx_tdata,
            axis_rx_tvalid    => axis_rx_tvalid,
            axis_rx_tuser     => axis_rx_tuser,
            axis_rx_tkeep     => axis_rx_tkeep,
            axis_rx_tlast     => axis_rx_tlast,
            ICAP_PRDONE       => ICAP_PRDONE,
            ICAP_PRERROR      => ICAP_PRERROR,
            ICAP_AVAIL        => ICAP_AVAIL,
            ICAP_CSIB         => ICAP_CSIB,
            ICAP_RDWRB        => ICAP_RDWRB,
            ICAP_DataOut      => ICAP_DataOut,
            ICAP_DataIn       => ICAP_DataIn
        );

end architecture rtl;
