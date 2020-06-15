--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : lbustxaxisrx - rtl                                       -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to map the AXIS to L-BUS interface.  -
--                                                                             -
-- Dependencies     : maptokeeptomty,mapaxisdatatolbus                         -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lbustxaxisrx is
    port(
        lbus_txclk      : in  STD_LOGIC;
        lbus_txreset    : in  STD_LOGIC;
        -- Inputs from AXIS bus
        axis_rx_tdata   : in  STD_LOGIC_VECTOR(511 downto 0);
        axis_rx_tvalid  : in  STD_LOGIC;
        axis_rx_tready  : out STD_LOGIC;
        axis_rx_tkeep   : in  STD_LOGIC_VECTOR(63 downto 0);
        axis_rx_tlast   : in  STD_LOGIC;
        axis_rx_tuser   : in  STD_LOGIC;
        -- Outputs to L-BUS interface
        lbus_tx_rdyout  : in  STD_LOGIC;
        -- Segment 0
        lbus_txdataout0 : out STD_LOGIC_VECTOR(127 downto 0);
        lbus_txenaout0  : out STD_LOGIC;
        lbus_txsopout0  : out STD_LOGIC;
        lbus_txeopout0  : out STD_LOGIC;
        lbus_txerrout0  : out STD_LOGIC;
        lbus_txmtyout0  : out STD_LOGIC_VECTOR(3 downto 0);
        -- Segment 1
        lbus_txdataout1 : out STD_LOGIC_VECTOR(127 downto 0);
        lbus_txenaout1  : out STD_LOGIC;
        lbus_txsopout1  : out STD_LOGIC;
        lbus_txeopout1  : out STD_LOGIC;
        lbus_txerrout1  : out STD_LOGIC;
        lbus_txmtyout1  : out STD_LOGIC_VECTOR(3 downto 0);
        -- Segment 2
        lbus_txdataout2 : out STD_LOGIC_VECTOR(127 downto 0);
        lbus_txenaout2  : out STD_LOGIC;
        lbus_txsopout2  : out STD_LOGIC;
        lbus_txeopout2  : out STD_LOGIC;
        lbus_txerrout2  : out STD_LOGIC;
        lbus_txmtyout2  : out STD_LOGIC_VECTOR(3 downto 0);
        -- Segment 3		
        lbus_txdataout3 : out STD_LOGIC_VECTOR(127 downto 0);
        lbus_txenaout3  : out STD_LOGIC;
        lbus_txsopout3  : out STD_LOGIC;
        lbus_txeopout3  : out STD_LOGIC;
        lbus_txerrout3  : out STD_LOGIC;
        lbus_txmtyout3  : out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity lbustxaxisrx;

architecture rtl of lbustxaxisrx is
    component maptokeeptomty is
        port(
            lbus_txclk  : in  STD_LOGIC;
            axis_tkeep  : in  STD_LOGIC_VECTOR(15 downto 0);
            lbus_mtyout : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component maptokeeptomty;

    component mapaxisdatatolbus is
        port(
            lbus_txclk   : in  STD_LOGIC;
            axis_data    : in  STD_LOGIC_VECTOR(127 downto 0);
            lbus_dataout : out STD_LOGIC_VECTOR(127 downto 0)
        );
    end component mapaxisdatatolbus;
    signal paxis_tvalid : std_logic;

begin

    -- Tie TREADY to the tx_rdyout without delay as this will control empty slots
    axis_rx_tready <= lbus_tx_rdyout;
    -- We will only have SOP in segement 0
    -- Tie down all other SOPs they are not used
    lbus_txsopout1 <= '0';
    lbus_txsopout2 <= '0';
    lbus_txsopout3 <= '0';

    seg0mtymapping_i : maptokeeptomty
        port map(
            lbus_txclk  => lbus_txclk,
            axis_tkeep  => axis_rx_tkeep(15 downto 0),
            lbus_mtyout => lbus_txmtyout0
        );

    seg0datamapping_i : mapaxisdatatolbus
        port map(
            lbus_txclk   => lbus_txclk,
            axis_data    => axis_rx_tdata(127 downto 0),
            lbus_dataout => lbus_txdataout0
        );

    seg1mtymapping_i : maptokeeptomty
        port map(
            lbus_txclk  => lbus_txclk,
            axis_tkeep  => axis_rx_tkeep(31 downto 16),
            lbus_mtyout => lbus_txmtyout1
        );

    seg1datamapping_i : mapaxisdatatolbus
        port map(
            lbus_txclk   => lbus_txclk,
            axis_data    => axis_rx_tdata(255 downto 128),
            lbus_dataout => lbus_txdataout1
        );

    seg2mtymapping_i : maptokeeptomty
        port map(
            lbus_txclk  => lbus_txclk,
            axis_tkeep  => axis_rx_tkeep(47 downto 32),
            lbus_mtyout => lbus_txmtyout2
        );

    seg2datamapping_i : mapaxisdatatolbus
        port map(
            lbus_txclk   => lbus_txclk,
            axis_data    => axis_rx_tdata(383 downto 256),
            lbus_dataout => lbus_txdataout2
        );

    seg3mtymapping_i : maptokeeptomty
        port map(
            lbus_txclk  => lbus_txclk,
            axis_tkeep  => axis_rx_tkeep(63 downto 48),
            lbus_mtyout => lbus_txmtyout3
        );

    seg3datamapping_i : mapaxisdatatolbus
        port map(
            lbus_txclk   => lbus_txclk,
            axis_data    => axis_rx_tdata(511 downto 384),
            lbus_dataout => lbus_txdataout3
        );

    EnableAndEOPMappingProc : process(lbus_txclk)
    begin
        if rising_edge(lbus_txclk) then
            if (lbus_txreset = '1') then
                -- Deassert enable signals on reset
                lbus_txenaout0 <= '0';
                lbus_txenaout1 <= '0';
                lbus_txenaout2 <= '0';
                lbus_txenaout3 <= '0';
                lbus_txeopout0 <= '0';
                lbus_txeopout1 <= '0';
                lbus_txeopout2 <= '0';
                lbus_txeopout3 <= '0';
                lbus_txerrout0 <= '0';
                lbus_txerrout1 <= '0';
                lbus_txerrout2 <= '0';
                lbus_txerrout3 <= '0';
            else
                if (axis_rx_tlast = '1') then
                    -- There is TLAST so EOP must be generated

                    -- Determine where the EOP sits based on TKEEP
                    if (axis_rx_tkeep(63 downto 16) = X"000000000000") then
                        -- Only segment 0 is activated 
                        lbus_txeopout0 <= '1';
                        lbus_txeopout1 <= '0';
                        lbus_txeopout2 <= '0';
                        lbus_txeopout3 <= '0';
                        lbus_txenaout0 <= axis_rx_tvalid;
                        lbus_txenaout1 <= '0';
                        lbus_txenaout2 <= '0';
                        lbus_txenaout3 <= '0';
                        lbus_txerrout0 <= axis_rx_tuser;
                        lbus_txerrout1 <= '0';
                        lbus_txerrout2 <= '0';
                        lbus_txerrout3 <= '0';
                    else
                        if (axis_rx_tkeep(63 downto 32) = X"00000000") then
                            -- Segment 0 to 1 are activated 
                            lbus_txeopout0 <= '0';
                            lbus_txeopout1 <= '1';
                            lbus_txeopout2 <= '0';
                            lbus_txeopout3 <= '0';
                            lbus_txenaout0 <= axis_rx_tvalid;
                            lbus_txenaout1 <= axis_rx_tvalid;
                            lbus_txenaout2 <= '0';
                            lbus_txenaout3 <= '0';
                            lbus_txerrout0 <= axis_rx_tuser;
                            lbus_txerrout1 <= axis_rx_tuser;
                            lbus_txerrout2 <= '0';
                            lbus_txerrout3 <= '0';
                        else
                            if (axis_rx_tkeep(63 downto 48) = X"0000") then
                                -- Segment 0 to 2 are activated 
                                lbus_txeopout0 <= '0';
                                lbus_txeopout1 <= '0';
                                lbus_txeopout2 <= '1';
                                lbus_txeopout3 <= '0';
                                lbus_txenaout0 <= axis_rx_tvalid;
                                lbus_txenaout1 <= axis_rx_tvalid;
                                lbus_txenaout2 <= axis_rx_tvalid;
                                lbus_txenaout3 <= '0';
                                lbus_txerrout0 <= axis_rx_tuser;
                                lbus_txerrout1 <= axis_rx_tuser;
                                lbus_txerrout2 <= axis_rx_tuser;
                                lbus_txerrout3 <= '0';
                            else
                                -- Segment 0 to 3 are activated
                                lbus_txeopout0 <= '0';
                                lbus_txeopout1 <= '0';
                                lbus_txeopout2 <= '0';
                                lbus_txeopout3 <= '1';
                                lbus_txenaout0 <= axis_rx_tvalid;
                                lbus_txenaout1 <= axis_rx_tvalid;
                                lbus_txenaout2 <= axis_rx_tvalid;
                                lbus_txenaout3 <= axis_rx_tvalid;
                                lbus_txerrout0 <= axis_rx_tuser;
                                lbus_txerrout1 <= axis_rx_tuser;
                                lbus_txerrout2 <= axis_rx_tuser;
                                lbus_txerrout3 <= axis_rx_tuser;
                            end if;
                        end if;
                    end if;
                else
                    -- There is no TLAST
                    -- No EOP will be generated
                    lbus_txeopout0 <= '0';
                    lbus_txeopout1 <= '0';
                    lbus_txeopout2 <= '0';
                    lbus_txeopout3 <= '0';
                    -- If there is a valid transaction we pass it through
                    -- We assume all segments are activated is there is no TLAST
                    lbus_txenaout0 <= axis_rx_tvalid;
                    lbus_txenaout1 <= axis_rx_tvalid;
                    lbus_txenaout2 <= axis_rx_tvalid;
                    lbus_txenaout3 <= axis_rx_tvalid;

                end if;
            end if;
        end if;
    end process EnableAndEOPMappingProc;

    SOPMappingProc : process(lbus_txclk)
    begin
        if rising_edge(lbus_txclk) then
            paxis_tvalid <= axis_rx_tvalid;
            if (paxis_tvalid = '0' and axis_rx_tvalid = '1') then
                -- This is the start of the transaction signal start of sop
                lbus_txsopout0 <= '1';
            else
                -- We are inside the data transfer keep sop tied to ground
                lbus_txsopout0 <= '0';
            end if;
        end if;
    end process SOPMappingProc;

end architecture rtl;
