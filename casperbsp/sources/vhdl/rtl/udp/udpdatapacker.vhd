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
        destination_ip                 : in  STD_LOGIC_VECTOR(31 downto 0);
        destination_udp_port           : in  STD_LOGIC_VECTOR(15 downto 0);
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
        SenderRingBufferDataEnable     : out STD_LOGIC_VECTOR(63 downto 0);
        SenderRingBufferData           : out STD_LOGIC_VECTOR(511 downto 0);
        SenderRingBufferAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        --
        axis_tuser                     : in  STD_LOGIC_VECTOR(1 downto 0);
        axis_tdata                     : in  STD_LOGIC_VECTOR(511 downto 0);
        axis_tvalid                    : in  STD_LOGIC;
        axis_tready                    : out STD_LOGIC;
        axis_tkeep                     : in  STD_LOGIC_VECTOR(63 downto 0);
        axis_tlast                     : in  STD_LOGIC
    );
end entity udpdatapacker;

architecture rtl of udpdatapacker is

begin

end architecture rtl;
