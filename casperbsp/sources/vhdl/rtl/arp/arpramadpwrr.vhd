--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : arpramadpwrr - rtl                                       -
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

entity arpramadpwrr is
    generic(
        G_INIT_VALUE : std_logic := '0';
        G_ADDR_WIDTH : natural   := 13;
        G_DATA_WIDTH : natural   := 32
    );
    port(
        ClkA          : in  STD_LOGIC;
        ClkB          : in  STD_LOGIC;
        -- Port A
        WriteAEnable  : in  STD_LOGIC;
        WriteAAddress : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        WriteAData    : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        ReadAEnable   : in  STD_LOGIC;
        ReadAAddress  : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        ReadAData     : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
        -- Port B
        ReadBAddress  : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 2 downto 0);
        ReadBEnable   : in  STD_LOGIC;
        ReadBData     : out STD_LOGIC_VECTOR((G_DATA_WIDTH * 2) - 1 downto 0)
    );
end entity arpramadpwrr;

architecture rtl of arpramadpwrr is
    component ramdpwrr is
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
    end component ramdpwrr;
    signal ReadWriteAddress : std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
    signal ReadADataL       : STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
    signal ReadADataH       : STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
    signal EnableA          : STD_LOGIC;
    signal iWriteAEnable    : STD_LOGIC;
begin

    AddressProc : process(WriteAEnable, ReadAEnable, ReadAAddress, WriteAAddress)
    begin
        if (ReadAEnable = '1') then
            -- This is a read transaction
            -- Use read address and block write operations
            iWriteAEnable    <= '0';
            ReadWriteAddress <= ReadAAddress;
        else
            -- This maybe a write transaction pass it's signals through
            iWriteAEnable    <= WriteAEnable;
            ReadWriteAddress <= WriteAAddress;
        end if;
    end process AddressProc;

    ReadDataProc : process(ReadWriteAddress(0), ReadADataH, ReadADataL)
    begin
        if (ReadWriteAddress(0) = '1') then
            -- Upper Data Operation
            ReadAData <= ReadADataH;
        else
            -- Lower Data Operation
            ReadAData <= ReadADataL;
        end if;
    end process ReadDataProc;

    EnableA <= not (ReadWriteAddress(0));

    RAMH : ramdpwrr
        generic map(
            G_INIT_VALUE => G_INIT_VALUE,
            G_ADDR_WIDTH => G_ADDR_WIDTH - 1,
            G_DATA_WIDTH => G_DATA_WIDTH
        )
        port map(
            ClkA          => ClkA,
            ClkB          => ClkB,
            WriteAAddress => ReadWriteAddress(G_ADDR_WIDTH - 1 downto 1),
            EnableA       => ReadWriteAddress(0),
            WriteAEnable  => iWriteAEnable,
            WriteAData    => WriteAData,
            ReadAData     => ReadADataH,
            ReadBAddress  => ReadBAddress,
            EnableB       => ReadBEnable,
            ReadBData     => ReadBData((G_DATA_WIDTH * 2) - 1 downto G_DATA_WIDTH)
        );

    RAML : ramdpwrr
        generic map(
            G_INIT_VALUE => G_INIT_VALUE,
            G_ADDR_WIDTH => G_ADDR_WIDTH - 1,
            G_DATA_WIDTH => G_DATA_WIDTH
        )
        port map(
            ClkA          => ClkA,
            ClkB          => ClkB,
            WriteAAddress => ReadWriteAddress(G_ADDR_WIDTH - 1 downto 1),
            EnableA       => EnableA,
            WriteAEnable  => iWriteAEnable,
            WriteAData    => WriteAData,
            ReadAData     => ReadADataL,
            ReadBAddress  => ReadBAddress,
            EnableB       => ReadBEnable,
            ReadBData     => ReadBData(G_DATA_WIDTH - 1 downto 0)
        );

end architecture rtl;
