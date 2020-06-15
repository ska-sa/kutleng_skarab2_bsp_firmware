--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : assymetricdualportpacketram1to64byte - rtl               -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to create a true dual port ram for   -
--                    packet slot buffering. The ring buffer is asymmetric i.e -
--                    ingress is 1 byte and egress 64 bytes.                   -
--                    Data packing is little endian i.e. first byte to low bits-
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity assymetricdualportpacketram1to64byte is
    generic(
        G_ADDR_WIDTH : natural := 8 + 2;
        G_SLOT_WIDTH : natural := 4
    );
    port(
        ClkA             : in  STD_LOGIC;
        ClkB             : in  STD_LOGIC;
        -- Port A
        WriteByteEnableA : in  STD_LOGIC_VECTOR(0 downto 0);
        WriteAAddress    : in  STD_LOGIC_VECTOR((G_ADDR_WIDTH + G_SLOT_WIDTH) - 1 downto 0);
        EnableA          : in  STD_LOGIC;
        WriteAEnable     : in  STD_LOGIC;
        WriteAData       : in  STD_LOGIC_VECTOR(7 downto 0);
        ReadByteEnableA  : out STD_LOGIC_VECTOR(0 downto 0);
        ReadAData        : out STD_LOGIC_VECTOR(7 downto 0);
        -- Port B
        ReadBAddress     : in  STD_LOGIC_VECTOR((G_ADDR_WIDTH + G_SLOT_WIDTH - 5) - 1 downto 0);
        EnableB          : in  STD_LOGIC;
        ReadByteEnableB  : out STD_LOGIC_VECTOR((512 / 8) - 1 downto 0);
        ReadBData        : out STD_LOGIC_VECTOR(511 downto 0)
    );
end entity assymetricdualportpacketram1to64byte;

architecture rtl of assymetricdualportpacketram1to64byte is
    component assymetrictruedualportram is
        generic(
            WIDTHA     : integer := 4;
            SIZEA      : integer := 1024;
            ADDRWIDTHA : integer := 10;
            WIDTHB     : integer := 16;
            SIZEB      : integer := 256;
            ADDRWIDTHB : integer := 8
        );
        port(
            clkA  : in  std_logic;
            clkB  : in  std_logic;
            enA   : in  std_logic;
            enB   : in  std_logic;
            weB   : in  std_logic;
            addrA : in  std_logic_vector(ADDRWIDTHA - 1 downto 0);
            addrB : in  std_logic_vector(ADDRWIDTHB - 1 downto 0);
            doB   : out std_logic_vector(WIDTHB - 1 downto 0);
            diB   : in  std_logic_vector(WIDTHB - 1 downto 0);
            doA   : out std_logic_vector(WIDTHA - 1 downto 0)
        );
    end component assymetrictruedualportram;
begin

    -- Split the RAMS into sub blocks that are less than 256bits as this is the limit
    -- for generic inference.
    -- We need bit lengths of about 512 wide.
    RAMAi : assymetrictruedualportram
        generic map(
            WIDTHB     => 4,
            SIZEB      => (2**(G_ADDR_WIDTH + G_SLOT_WIDTH - 5)),
            ADDRWIDTHB => (G_ADDR_WIDTH + G_SLOT_WIDTH - 5),
            WIDTHA     => 256,
            SIZEA      => (2**(G_ADDR_WIDTH + G_SLOT_WIDTH)),
            ADDRWIDTHA => (G_ADDR_WIDTH + G_SLOT_WIDTH)
        )
        port map(
            clkA  => ClkB,
            clkB  => ClkA,
            enA   => EnableB,
            enB   => EnableA,
            weB   => WriteAEnable,
            addrB => WriteAAddress,
            addrA => ReadBAddress,
            diB   => WriteAData(3 downto 0),
            doB   => ReadAData(3 downto 0),
            doA   => ReadBData(255 downto 0)
        );

    RAMBi : assymetrictruedualportram
        generic map(
            WIDTHB     => 4,
            SIZEB      => (2**(G_ADDR_WIDTH + G_SLOT_WIDTH - 5)),
            ADDRWIDTHB => (G_ADDR_WIDTH + G_SLOT_WIDTH - 5),
            WIDTHA     => 256,
            SIZEA      => (2**(G_ADDR_WIDTH + G_SLOT_WIDTH)),
            ADDRWIDTHA => (G_ADDR_WIDTH + G_SLOT_WIDTH)
        )
        port map(
            clkA  => ClkB,
            clkB  => ClkA,
            enA   => EnableB,
            enB   => EnableA,
            weB   => WriteAEnable,
            addrB => WriteAAddress,
            addrA => ReadBAddress,
            diB   => WriteAData(7 downto 4),
            doB   => ReadAData(7 downto 4),
            doA   => ReadBData(511 downto 256)
        );

end architecture rtl;
