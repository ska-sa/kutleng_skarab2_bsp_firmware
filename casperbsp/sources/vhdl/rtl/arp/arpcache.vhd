--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : arpcache - rtl                                           -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to create an ARP cache using dual    -
--                    port ram.                                                - 
-- Dependencies     : arpramadpwrr,arpramadpwr                                 -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arpcache is
    generic(
        G_WRITE_DATA_WIDTH : natural range 32 to 64 := 32;
        G_NUM_CACHE_BLOCKS : natural range 1 to 4   := 1;
        G_ARP_CACHE_ASIZE  : natural                := 13
    );
    port(
        CPUClk             : in  STD_LOGIC;
        EthernetClk        : in  STD_LOGIC_VECTOR(G_NUM_CACHE_BLOCKS - 1 downto 0);
        -- CPU port
        CPUReadDataEnable  : in  STD_LOGIC;
        CPUReadData        : out STD_LOGIC_VECTOR(G_WRITE_DATA_WIDTH - 1 downto 0);
        CPUReadAddress     : in  STD_LOGIC_VECTOR(G_ARP_CACHE_ASIZE - 1 downto 0);
        CPUWriteDataEnable : in  STD_LOGIC;
        CPUWriteData       : in  STD_LOGIC_VECTOR(G_WRITE_DATA_WIDTH - 1 downto 0);
        CPUWriteAddress    : in  STD_LOGIC_VECTOR(G_ARP_CACHE_ASIZE - 1 downto 0);
        -- Ethernet port
        ARPReadDataEnable  : in  STD_LOGIC_VECTOR(G_NUM_CACHE_BLOCKS - 1 downto 0);
        ARPReadData        : out STD_LOGIC_VECTOR((G_NUM_CACHE_BLOCKS * G_WRITE_DATA_WIDTH * 2) - 1 downto 0);
        ARPReadAddress     : in  STD_LOGIC_VECTOR((G_NUM_CACHE_BLOCKS * (G_ARP_CACHE_ASIZE - 1)) - 1 downto 0)
    );
end entity arpcache;

architecture rtl of arpcache is
    constant C_BROADCAST_ADDRESS_BIT : std_logic := '1';

    component arpramadpwrr is
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
    end component arpramadpwrr;
    component arpramadpwr is
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
            -- Port B
            ReadBAddress  : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 2 downto 0);
            ReadBEnable   : in  STD_LOGIC;
            ReadBData     : out STD_LOGIC_VECTOR((G_DATA_WIDTH * 2) - 1 downto 0)
        );
    end component arpramadpwr;

begin

    DPRAMi : for i in 0 to G_NUM_CACHE_BLOCKS - 1 generate
    begin
        DPRAM0i : if i = 0 generate
        begin
            DPRAM00i : arpramadpwrr
                generic map(
                    -- Initialize with all ones so that default is broadcast
                    -- MAC address FF:FF:FF:FF:FF:FF
                    G_INIT_VALUE => C_BROADCAST_ADDRESS_BIT,
                    G_ADDR_WIDTH => G_ARP_CACHE_ASIZE,
                    G_DATA_WIDTH => G_WRITE_DATA_WIDTH
                )
                port map(
                    ClkA          => CPUClk,
                    ClkB          => EthernetClk(i),
                    WriteAEnable  => CPUWriteDataEnable,
                    WriteAAddress => CPUWriteAddress,
                    WriteAData    => CPUWriteData,
                    ReadAEnable   => CPUReadDataEnable,
                    ReadAAddress  => CPUReadAddress,
                    ReadAData     => CPUReadData, -- The first cache block has readback
                    ReadBAddress  => ARPReadAddress((G_ARP_CACHE_ASIZE - 1) - 1 downto 0),
                    ReadBEnable   => ARPReadDataEnable(i),
                    ReadBData     => ARPReadData((G_WRITE_DATA_WIDTH * 2) - 1 downto 0)
                );
        end generate;
        DPRAMNi : if i /= 0 generate
        begin
            DPRAMN1i : arpramadpwr
                generic map(
                    -- Initialize with all ones so that default is broadcast
                    -- MAC address FF:FF:FF:FF:FF:FF
                    G_INIT_VALUE => C_BROADCAST_ADDRESS_BIT,
                    G_ADDR_WIDTH => G_ARP_CACHE_ASIZE,
                    G_DATA_WIDTH => G_WRITE_DATA_WIDTH
                )
                port map(
                    ClkA          => CPUClk,
                    ClkB          => EthernetClk(i),
                    WriteAEnable  => CPUWriteDataEnable,
                    WriteAAddress => CPUWriteAddress,
                    WriteAData    => CPUWriteData,
                    ReadBAddress  => ARPReadAddress(((G_ARP_CACHE_ASIZE - 1) * (i + 1)) - 1 downto ((G_ARP_CACHE_ASIZE - 1) * (i))),
                    ReadBEnable   => ARPReadDataEnable(i),
                    ReadBData     => ARPReadData(((G_WRITE_DATA_WIDTH * 2) * (i + 1)) - 1 downto ((G_WRITE_DATA_WIDTH * 2) * (i)))
                );
        end generate;
    end generate DPRAMi;

end architecture rtl;
