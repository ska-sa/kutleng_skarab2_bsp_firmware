--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : arpreceiver - rtl                                        -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module implements ARP & RARP protocol, for each     -
--                    request a corresponding response is generated.           -
--                    TODO                                                     -
--                    The ARP module needs to be extended to work on 802.1Q    - 
--                    based networks. At this moment it wont work where there  -
--                    is VLAN tagging.                                         -
-- Dependencies     : arpreceiver                                              -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arpmodule is
    generic(
        G_SLOT_WIDTH : natural := 4
    );
    port(
        axis_clk          : in  STD_LOGIC;
        axis_reset        : in  STD_LOGIC;
        -- Setup information
        ARPMACAddress     : in  STD_LOGIC_VECTOR(47 downto 0);
        ARPIPAddress      : in  STD_LOGIC_VECTOR(31 downto 0);
        --Inputs from AXIS bus 
        axis_rx_tdata     : in  STD_LOGIC_VECTOR(511 downto 0);
        axis_rx_tvalid    : in  STD_LOGIC;
        axis_rx_tuser     : in  STD_LOGIC;
        axis_rx_tkeep     : in  STD_LOGIC_VECTOR(63 downto 0);
        axis_rx_tlast     : in  STD_LOGIC;
        --Outputs to AXIS bus 
        axis_tx_tpriority : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        axis_tx_tdata     : out STD_LOGIC_VECTOR(511 downto 0);
        axis_tx_tvalid    : out STD_LOGIC;
        axis_tx_tready    : in  STD_LOGIC;
        axis_tx_tkeep     : out STD_LOGIC_VECTOR(63 downto 0);
        axis_tx_tlast     : out STD_LOGIC
    );
end entity arpmodule;

architecture rtl of arpmodule is
    component arpreceiver is
        generic(
            G_SLOT_WIDTH : natural := 4
        );
        port(
            axis_clk                 : in  STD_LOGIC;
            axis_reset               : in  STD_LOGIC;
            -- Setup information
            ARPMACAddress            : in  STD_LOGIC_VECTOR(47 downto 0);
            ARPIPAddress             : in  STD_LOGIC_VECTOR(31 downto 0);
            -- Bus Readout
            RingBufferSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotClear      : in  STD_LOGIC;
            RingBufferSlotStatus     : out STD_LOGIC;
            RingBufferSlotTypeStatus : out STD_LOGIC;
            RingBufferSlotsFilled    : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferDataRead       : in  STD_LOGIC;
            RingBufferDataEnable     : out STD_LOGIC_VECTOR(63 downto 0);
            RingBufferDataOut        : out STD_LOGIC_VECTOR(511 downto 0);
            RingBufferAddress        : in  STD_LOGIC_VECTOR(8 downto 0);
            --Inputs from AXIS bus 
            axis_rx_tdata            : in  STD_LOGIC_VECTOR(511 downto 0);
            axis_rx_tvalid           : in  STD_LOGIC;
            axis_rx_tuser            : in  STD_LOGIC;
            axis_rx_tkeep            : in  STD_LOGIC_VECTOR(63 downto 0);
            axis_rx_tlast            : in  STD_LOGIC
        );
    end component arpreceiver;

    type AxisARPWriterSM_t is (
        InitialiseSt,                   -- On the reset state
        CheckSlotSt,
        NextSlotSt,
        WaitSlotSt,
        WaitPacketSt,
        ProcessPacketSt,
        ClearSlotSt
    );
    signal StateVariable             : AxisARPWriterSM_t := InitialiseSt;
    -- Tuples registers
    signal lRingBufferSlotID         : unsigned(3 downto 0);
    signal lRingBufferSlotClear      : STD_LOGIC;
    signal lRingBufferSlotStatus     : STD_LOGIC;
    signal lRingBufferSlotTypeStatus : STD_LOGIC;
    signal lRingBufferDataRead       : STD_LOGIC;
    signal lRingBufferDataEnable     : STD_LOGIC_VECTOR(63 downto 0);
    signal lRingBufferDataOut        : STD_LOGIC_VECTOR(511 downto 0);
    signal lRingBufferAddress        : unsigned(8 downto 0);

begin

    ARPReceiver_i : arpreceiver
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH
        )
        port map(
            axis_clk                 => axis_clk,
            axis_reset               => axis_reset,
            -- Setup information
            ARPMACAddress            => ARPMACAddress,
            ARPIPAddress             => ARPIPAddress,
            -- Bus Readout
            RingBufferSlotID         => std_logic_vector(lRingBufferSlotID),
            RingBufferSlotClear      => lRingBufferSlotClear,
            RingBufferSlotStatus     => lRingBufferSlotStatus,
            RingBufferSlotTypeStatus => lRingBufferSlotTypeStatus,
            RingBufferSlotsFilled    => axis_tx_tpriority,
            RingBufferDataRead       => lRingBufferDataRead,
            RingBufferDataEnable     => lRingBufferDataEnable,
            RingBufferDataOut        => lRingBufferDataOut,
            RingBufferAddress        => std_logic_vector(lRingBufferAddress),
            --Inputs from AXIS bus 
            axis_rx_tdata            => axis_rx_tdata,
            axis_rx_tvalid           => axis_rx_tvalid,
            axis_rx_tuser            => axis_rx_tuser,
            axis_rx_tkeep            => axis_rx_tkeep,
            axis_rx_tlast            => axis_rx_tlast
        );

    SynchStateProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                -- Initialize SM on reset
                StateVariable <= InitialiseSt;
            else
                case (StateVariable) is
                    when InitialiseSt =>
                        -- Wait for packet after initialization
                        StateVariable        <= WaitSlotSt;
                        axis_tx_tvalid       <= '0';
                        axis_tx_tlast        <= '0';
                        axis_tx_tkeep        <= (others => '0');
                        axis_tx_tdata        <= (others => '0');
                        lRingBufferAddress   <= (others => '0');
                        lRingBufferDataRead  <= '0';
                        lRingBufferSlotClear <= '0';
                        lRingBufferSlotID    <= (others => '0');

                    when WaitSlotSt =>
                        StateVariable <= CheckSlotSt;

                    when CheckSlotSt =>
                        if (lRingBufferSlotStatus = '1') then
                            -- The current slot has data 
                            -- Pull the data 
                            lRingBufferDataRead <= '1';
                            -- Reset the data address
                            lRingBufferAddress  <= (others => '0');
                            StateVariable       <= WaitPacketSt;
                        else
                            lRingBufferDataRead <= '0';
                            StateVariable       <= NextSlotSt;
                        end if;

                    when NextSlotSt =>
                        -- Go to next Slot
                        lRingBufferSlotID    <= lRingBufferSlotID + 1;
                        axis_tx_tvalid       <= '0';
                        axis_tx_tlast        <= '0';
                        axis_tx_tkeep        <= (others => '0');
                        lRingBufferSlotClear <= '0';
                        StateVariable        <= WaitSlotSt;

                    when WaitPacketSt =>

                        StateVariable <= ProcessPacketSt;

                    when ProcessPacketSt =>
                        axis_tx_tvalid <= '1';
                        axis_tx_tdata  <= lRingBufferDataOut;
                        axis_tx_tkeep  <= lRingBufferDataEnable(63 downto 1) & '1';
                        if (axis_tx_tready = '1') then
                            if (lRingBufferDataEnable(0) = '1') then
                                -- Got TLAST
                                axis_tx_tlast        <= '1';
                                -- Reset the data address
                                lRingBufferAddress   <= (others => '0');
                                -- Clear the current slot
                                lRingBufferSlotClear <= '1';
                                -- Stop reading data
                                lRingBufferDataRead  <= '0';
                                -- Go to next slot
                                StateVariable        <= NextSlotSt;
                            else
                                -- read next address
                                axis_tx_tlast        <= '0';
                                lRingBufferSlotClear <= '0';
                                lRingBufferAddress   <= lRingBufferAddress + 1;
                                lRingBufferDataRead  <= '1';
                            end if;
                        else
                            -- Keep reading the slot till ready
                            lRingBufferSlotClear <= '0';
                            StateVariable        <= ProcessPacketSt;
                        end if;

                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process SynchStateProc;

end architecture rtl;
