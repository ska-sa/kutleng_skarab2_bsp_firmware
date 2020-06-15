--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : assymetrictruedualportram - rtl                          -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to infer a dual block write first ram-
--                    This is taken from Xilinx UG901 with minor modifications.-
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity assymetrictruedualportram is
    generic(
        WIDTHB     : integer := 4;
        SIZEB      : integer := 8192;
        ADDRWIDTHB : integer := 13;
        WIDTHA     : integer := 16;
        SIZEA      : integer := 2048;
        ADDRWIDTHA : integer := 11
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
end entity assymetrictruedualportram;
architecture rtl of assymetrictruedualportram is
    function max(L, R : INTEGER) return INTEGER is
    begin
        if L > R then
            return L;
        else
            return R;
        end if;
    end;
    function min(L, R : INTEGER) return INTEGER is
    begin
        if L < R then
            return L;
        else
            return R;
        end if;
    end;
    function log2(val : INTEGER) return natural is
        variable res : natural;
    begin
        for i in 0 to 31 loop
            if (val <= (2 ** i)) then
                res := i;
                exit;
            end if;
        end loop;
        return res;
    end function log2;
    constant minWIDTH : integer := min(WIDTHA, WIDTHB);
    constant maxWIDTH : integer := max(WIDTHA, WIDTHB);
    constant maxSIZE  : integer := max(SIZEA, SIZEB);
    constant RATIO    : integer := maxWIDTH / minWIDTH;

    -- An asymmetric RAM is modeled in a similar way as a symmetric RAM, with an
    -- array of array object. Its aspect ratio corresponds to the port with the
    -- lower data width (larger depth)
    type ramType is array (0 to maxSIZE - 1) of std_logic_vector(minWIDTH - 1 downto 0);

    signal my_ram : ramType := (others => (others => '0'));

    signal readA : std_logic_vector(WIDTHA - 1 downto 0) := (others => '0');
    signal readB : std_logic_vector(WIDTHB - 1 downto 0) := (others => '0');
    signal regA  : std_logic_vector(WIDTHA - 1 downto 0) := (others => '0');
    signal regB  : std_logic_vector(WIDTHB - 1 downto 0) := (others => '0');
begin
    process(clkA)
    begin
        if rising_edge(clkA) then
            for i in 0 to RATIO - 1 loop
                if enA = '1' then
                    readA((i + 1) * minWIDTH - 1 downto i * minWIDTH) <= my_ram(conv_integer(addrA & conv_std_logic_vector(i, log2(RATIO))));
                end if;
            end loop;
            regA <= readA;
        end if;
    end process;

    process(clkB)
    begin
        if rising_edge(clkB) then
            if enB = '1' then
                if weB = '1' then
                    my_ram(conv_integer(addrB)) <= diB;
                end if;
                -- The read statement below is placed after the write statement -- on purpose
                -- to ensure write-first synchronization through the variable
                -- mechanism
                readB <= my_ram(conv_integer(addrB));
            end if;
            regB <= readB;
        end if;
    end process;
    doA <= regA;
    doB <= regB;
end architecture rtl;
