--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : ramdpwrr - rtl                                           -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to produce a dual port ram for       -
--                    arp address tables.                                      -
--                    Two ports are employed:                                  -
--                    PortA:Write+Read                                         -
--                    PortB:Read                                               -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--                  : V1.1 - Change to have two ports and clocks.              -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ramdpwrr is
    generic(
        G_INIT_VALUE : std_logic := '0';
        G_ADDR_WIDTH : natural   := 8 + 2;
        G_DATA_WIDTH : natural   := 64
    );
    port(
        -- Port A
        ClkA          : in  STD_LOGIC;
        -- PortB
        ClkB          : in  STD_LOGIC;
        -- Port A
        WriteAAddress : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        EnableA       : in  STD_LOGIC;
        WriteAEnable  : in  STD_LOGIC;
        WriteAData    : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        ReadAData     : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        -- Port B
        ReadBAddress  : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        EnableB       : in  STD_LOGIC;
        ReadBData     : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0)
    );
end entity ramdpwrr;

architecture rtl of ramdpwrr is
    -- Declaration of ram signals
    type PacketRAM_t is array ((2**G_ADDR_WIDTH) - 1 downto 0) of std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    shared variable RAMData : PacketRAM_t := (others => (others => G_INIT_VALUE));
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
                ReadBData <= RAMData(to_integer(unsigned(ReadBAddress)));
            end if;
        end if;
    end process RAMPORTB;

end architecture rtl;
