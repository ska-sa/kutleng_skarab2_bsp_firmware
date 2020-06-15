--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : ledflasher - rtl                                      -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to blink leds periodically.          -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ledflasher is
    generic(
        -- Clock frequency in Hz
        G_CLOCK_FREQUENCY : NATURAL := 50_000_000;
        -- LED flash rate in Hz
        G_LED_FLASH_RATE  : NATURAL := 1
    );
    port(
        Clk : in  STD_LOGIC;
        LED : out STD_LOGIC
    );
end entity ledflasher;

architecture rtl of ledflasher is
    constant C_PRESCALER_MAXIMUM : NATURAL                                := ((G_CLOCK_FREQUENCY / G_LED_FLASH_RATE) / 2) - 1;
    signal PrescalerCounter      : NATURAL range 0 to C_PRESCALER_MAXIMUM := 0;
    signal lLED                  : STD_LOGIC                              := '0';

begin

    LED <= lLED;

    FlasherProc : process(Clk)
    begin
        if rising_edge(Clk) then
            if (PrescalerCounter = C_PRESCALER_MAXIMUM) then
                PrescalerCounter <= 0;
                lLED             <= not lLED;
            else
                PrescalerCounter <= PrescalerCounter + 1;
            end if;
        end if;
    end process FlasherProc;

end architecture rtl;
