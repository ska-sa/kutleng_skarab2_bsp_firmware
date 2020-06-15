--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : packetramsp - rtl                                        -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to create a true dual port ram for   -
--                    packet slot buffering.                                   -
--                    TODO                                                     -
--                    The packetstatusram module can carry auxiliary           - 
--                    information this information buffer, this can be packet  - 
--                    forwarding information                                   -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity assymetricdualportpacketram is
    generic(
            G_ADDR_AWIDTH : natural := 8 + 2;
            G_DATA_AWIDTH : natural := 64;
            G_ADDR_BWIDTH : natural := 8 + 2;
            G_DATA_BWIDTH : natural := 64
        );
        port(
            ClkA          : in  STD_LOGIC;
            ClkB          : in  STD_LOGIC;
            -- Port A
            WriteAAddress : in  STD_LOGIC_VECTOR(G_ADDR_AWIDTH - 1 downto 0);
            EnableA       : in  STD_LOGIC;
            WriteAEnable  : in  STD_LOGIC;
            WriteAData    : in  STD_LOGIC_VECTOR(G_DATA_AWIDTH - 1 downto 0);
            ReadAData     : out STD_LOGIC_VECTOR(G_DATA_AWIDTH - 1 downto 0);
            -- Port B
            WriteBAddress : in  STD_LOGIC_VECTOR(G_ADDR_BWIDTH - 1 downto 0);
            EnableB       : in  STD_LOGIC;
            WriteBEnable  : in  STD_LOGIC;
            WriteBData    : in  STD_LOGIC_VECTOR(G_DATA_BWIDTH - 1 downto 0);
            ReadBData     : out STD_LOGIC_VECTOR(G_DATA_BWIDTH - 1 downto 0)
    );
end entity assymetricdualportpacketram;

architecture rtl of assymetricdualportpacketram is
    -- Declaration of ram signals
    type PacketStatusRAM_t is array ((2**G_ADDR_AWIDTH) - 1 downto 0) of std_logic_vector(1 downto 0);
    shared variable RAMData : PacketStatusRAM_t;
begin

    RAMPORTA : process(ClkA)
    begin
        if rising_edge(ClkA) then
            if (EnableA = '1') then
                if (WriteAEnable = '1') then
                    RAMData(to_integer(unsigned(WriteAAddress))) := WriteAData;
                end if;
                ReadAData <= RAMData(to_integer(unsigned(WriteAAddress)));
            end if;
        end if;
    end process RAMPORTA;

    RAMPORTB : process(ClkB)
    begin
        if rising_edge(ClkB) then
            if (EnableB = '1') then
                if (WriteBEnable = '1') then
                    RAMData(to_integer(unsigned(WriteBAddress))) := WriteBData;
                end if;
                ReadBData <= RAMData(to_integer(unsigned(WriteBAddress)));
            end if;
        end if;
    end process RAMPORTB;

end architecture rtl;
