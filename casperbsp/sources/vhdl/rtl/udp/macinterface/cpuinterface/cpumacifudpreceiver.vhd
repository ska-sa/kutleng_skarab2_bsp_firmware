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
-- Module Name      : cpumacifudpreceiver - rtl                                -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The cpumacifudpreceiver module receives UDP/IP data from -
--                    the CPU interface.It uses RX 2K ringbuffers.             -
-- Dependencies     : macifudpreceiver                                         -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpumacifudpreceiver is
	generic(
		G_SLOT_WIDTH      : natural := 4;
		G_AXIS_DATA_WIDTH : natural := 512;
		-- The address width is log2(2048/(512/8))=5 bits wide
		G_ADDR_WIDTH      : natural := 5
	);
	port(
		axis_clk                       : in  STD_LOGIC;
		aximm_clk                      : in  STD_LOGIC;
		axis_reset                     : in  STD_LOGIC;
		-- Setup information
		reg_mac_address                : in  STD_LOGIC_VECTOR(47 downto 0);
		reg_udp_port                   : in  STD_LOGIC_VECTOR(15 downto 0);
		reg_udp_port_mask              : in  STD_LOGIC_VECTOR(15 downto 0);
		-- Packet Readout in addressed bus format
		data_write_enable              : in  STD_LOGIC;
		data_read_enable               : in  STD_LOGIC;
		data_write_data                : in  STD_LOGIC_VECTOR(15 downto 0);
		-- The Byte Enable is as follows
		-- Bit (0-1) Byte Enables
		-- Bit (2) Maps to TLAST (To terminate the data stream).		
		data_write_byte_enable         : in  STD_LOGIC_VECTOR(2 downto 0);
		data_read_data                 : out STD_LOGIC_VECTOR(15 downto 0);
		-- The Byte Enable is as follows
		-- Bit (0-1) Byte Enables
		-- Bit (2) Maps to TLAST (To terminate the data stream).		
		data_read_byte_enable          : out STD_LOGIC_VECTOR(2 downto 0);
		data_write_address             : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
		data_read_address              : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
		ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		ringbuffer_slot_clear          : in  STD_LOGIC;
		ringbuffer_slot_status         : out STD_LOGIC;
		ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		--Inputs from AXIS bus of the MAC side
		axis_rx_tdata                  : in  STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
		axis_rx_tvalid                 : in  STD_LOGIC;
		axis_rx_tuser                  : in  STD_LOGIC;
		axis_rx_tkeep                  : in  STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
		axis_rx_tlast                  : in  STD_LOGIC
	);
end entity cpumacifudpreceiver;

architecture rtl of cpumacifudpreceiver is

begin

end architecture rtl;
