
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
-- Module Name      : icapdecoupler - rtl                                      -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module decouples the ICAP for async AVAIL signal by -
--                  : using a AXIS FIFO with async tready signal.              -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity icapdecoupler is
    port(
        ICAPClk125MHz : in  STD_LOGIC;
        ICAPRst       : in  STD_LOGIC;
        ICAP_AVAIL    : out STD_LOGIC;
        ICAP_DataOut  : out STD_LOGIC_VECTOR(31 downto 0);
        ICAP_PRDONE   : out STD_LOGIC;
        ICAP_PRERROR  : out STD_LOGIC;
        ICAP_CSIB     : in  STD_LOGIC;
        ICAP_DataIn   : in  STD_LOGIC_VECTOR(31 downto 0);
        ICAP_RDWRB    : in  STD_LOGIC
    );
end entity icapdecoupler;

architecture rtl of icapdecoupler is
    component icapfifo is
        port(
            s_aclk        : in  std_logic;
            s_aresetn     : in  std_logic;
            s_axis_tvalid : in  std_logic;
            s_axis_tready : out std_logic;
            s_axis_tdata  : in  std_logic_vector(31 downto 0);
            s_axis_tuser  : in  std_logic_vector(0 downto 0);
            m_axis_tvalid : out std_logic;
            m_axis_tready : in  std_logic;
            m_axis_tdata  : out std_logic_vector(31 downto 0);
            m_axis_tuser  : out std_logic_vector(0 downto 0)
        );
    end component icapfifo;

    signal m_axis_tdata   : std_logic_vector(31 downto 0);
    signal m_axis_tuser   : std_logic;
    signal m_axis_tready  : std_logic;
    signal m_axis_tvalid  : std_logic;
    signal m_axis_tvalidn : std_logic;
    signal s_aresetn      : std_logic;
    signal s_axis_tvalid  : std_logic;
begin

    s_axis_tvalid  <= not ICAP_CSIB;
    s_aresetn      <= not ICAPRst;
    m_axis_tvalidn <= not m_axis_tvalid;

    ICAPFIFO_i : icapfifo
        port map(
            s_aclk          => ICAPClk125MHz,
            s_aresetn       => s_aresetn,
            s_axis_tvalid   => s_axis_tvalid,
            s_axis_tready   => ICAP_AVAIL,
            s_axis_tdata    => ICAP_DataIn,
            s_axis_tuser(0) => ICAP_RDWRB,
            m_axis_tvalid   => m_axis_tvalid,
            m_axis_tready   => m_axis_tready,
            m_axis_tdata    => m_axis_tdata,
            m_axis_tuser(0) => m_axis_tuser
        );

    ICAPE3_i : ICAPE3
        generic map(
            DEVICE_ID         => X"03628093",
            ICAP_AUTO_SWITCH  => "DISABLE",
            SIM_CFG_FILE_NAME => "NONE"
        )
        port map(
            AVAIL   => m_axis_tready,
            O       => ICAP_DataOut,
            PRDONE  => ICAP_PRDONE,
            PRERROR => ICAP_PRERROR,
            CLK     => ICAPClk125MHz,
            CSIB    => m_axis_tvalidn,
            I       => m_axis_tdata,
            RDWRB   => m_axis_tuser
        );

end architecture rtl;

