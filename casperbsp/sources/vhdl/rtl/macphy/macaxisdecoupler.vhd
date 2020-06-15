--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : macaxisdecoupler - rtl                                   -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The macaxisdecoupler module receives and send axis packet-
--                    streams, it works by decoupling the axis interface from a-
--                    synchronous burst interface to a throttled asynchrounous -
--                    interface. This module also filters all bad packets using-
--                    tuser on the rx interface.                               -
-- Dependencies     : macaxissender,macaxisreceiver                            -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity macaxisdecoupler is
    port(
        axis_tx_clk       : in  STD_LOGIC;
        axis_rx_clk       : in  STD_LOGIC;
        axis_reset        : in  STD_LOGIC;
        DataRateBackOff   : in  STD_LOGIC;
        TXOverFlowCount   : out STD_LOGIC_VECTOR(31 downto 0);
        TXAlmostFullCount : out STD_LOGIC_VECTOR(31 downto 0);
        --Outputs to AXIS bus MAC side 
        axis_tx_tdata     : out STD_LOGIC_VECTOR(511 downto 0);
        axis_tx_tvalid    : out STD_LOGIC;
        axis_tx_tready    : in  STD_LOGIC;
        axis_tx_tuser     : out STD_LOGIC;
        axis_tx_tkeep     : out STD_LOGIC_VECTOR(63 downto 0);
        axis_tx_tlast     : out STD_LOGIC;
        --Inputs from AXIS bus of the MAC side
        axis_rx_tready    : out STD_LOGIC;
        axis_rx_tdata     : in  STD_LOGIC_VECTOR(511 downto 0);
        axis_rx_tvalid    : in  STD_LOGIC;
        axis_rx_tuser     : in  STD_LOGIC;
        axis_rx_tkeep     : in  STD_LOGIC_VECTOR(63 downto 0);
        axis_rx_tlast     : in  STD_LOGIC
    );
end entity macaxisdecoupler;

architecture rtl of macaxisdecoupler is
    component macaxissender
        generic(
            G_SLOT_WIDTH : natural;
            G_ADDR_WIDTH : natural
        );
        port(
            axis_clk                 : in  STD_LOGIC;
            axis_reset               : in  STD_LOGIC;
            DataRateBackOff          : in  STD_LOGIC;            
            RingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotClear      : out STD_LOGIC;
            RingBufferSlotStatus     : in  STD_LOGIC;
            RingBufferSlotTypeStatus : in  STD_LOGIC;
            RingBufferDataRead       : out STD_LOGIC;
            RingBufferDataEnable     : in  STD_LOGIC_VECTOR(63 downto 0);
            RingBufferDataIn         : in  STD_LOGIC_VECTOR(511 downto 0);
            RingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            axis_tx_tdata            : out STD_LOGIC_VECTOR(511 downto 0);
            axis_tx_tvalid           : out STD_LOGIC;
            axis_tx_tready           : in  STD_LOGIC;
            axis_tx_tuser            : out STD_LOGIC;
            axis_tx_tkeep            : out STD_LOGIC_VECTOR(63 downto 0);
            axis_tx_tlast            : out STD_LOGIC
        );
    end component macaxissender;

    component macaxisreceiver
        generic(
            G_SLOT_WIDTH : natural;
            G_ADDR_WIDTH : natural
        );
        port(
            axis_ringbuffer_clk      : in  STD_LOGIC;
            axis_rx_clk              : in  STD_LOGIC;
            axis_reset               : in  STD_LOGIC;
            RXOverFlowCount          : out STD_LOGIC_VECTOR(31 downto 0);
            RXAlmostFullCount        : out STD_LOGIC_VECTOR(31 downto 0);
            RingBufferSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotClear      : in  STD_LOGIC;
            RingBufferSlotStatus     : out STD_LOGIC;
            RingBufferSlotTypeStatus : out STD_LOGIC;
            RingBufferDataRead       : in  STD_LOGIC;
            RingBufferDataEnable     : out STD_LOGIC_VECTOR(63 downto 0);
            RingBufferDataOut        : out STD_LOGIC_VECTOR(511 downto 0);
            RingBufferAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            axis_rx_tdata            : in  STD_LOGIC_VECTOR(511 downto 0);
            axis_rx_tvalid           : in  STD_LOGIC;
            axis_rx_tuser            : in  STD_LOGIC;
            axis_rx_tready           : out STD_LOGIC;
            axis_rx_tkeep            : in  STD_LOGIC_VECTOR(63 downto 0);
            axis_rx_tlast            : in  STD_LOGIC
        );
    end component macaxisreceiver;
    constant G_SLOT_WIDTH : natural := 4;
    constant G_ADDR_WIDTH : natural := 5;

    signal RingBufferSlotID         : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal RingBufferSlotClear      : STD_LOGIC;
    signal RingBufferSlotStatus     : STD_LOGIC;
    signal RingBufferSlotTypeStatus : STD_LOGIC;
    signal RingBufferDataRead       : STD_LOGIC;
    signal RingBufferDataEnable     : STD_LOGIC_VECTOR(63 downto 0);
    signal RingBufferData           : STD_LOGIC_VECTOR(511 downto 0);
    signal RingBufferAddress        : STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);

begin

    UDPSender_i : macaxissender
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH
        )
        port map(
            axis_clk                 => axis_tx_clk,
            axis_reset               => axis_reset,
            DataRateBackOff          => DataRateBackOff,
            RingBufferSlotID         => RingBufferSlotID,
            RingBufferSlotClear      => RingBufferSlotClear,
            RingBufferSlotStatus     => RingBufferSlotStatus,
            RingBufferSlotTypeStatus => RingBufferSlotTypeStatus,
            RingBufferDataRead       => RingBufferDataRead,
            RingBufferDataEnable     => RingBufferDataEnable,
            RingBufferDataIn         => RingBufferData,
            RingBufferAddress        => RingBufferAddress,
            axis_tx_tdata            => axis_tx_tdata,
            axis_tx_tvalid           => axis_tx_tvalid,
            axis_tx_tready           => axis_tx_tready,
            axis_tx_tuser            => axis_tx_tuser, 
            axis_tx_tkeep            => axis_tx_tkeep,
            axis_tx_tlast            => axis_tx_tlast
        );

    UDPReceiver_i : macaxisreceiver
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH
        )
        port map(
            axis_ringbuffer_clk      => axis_tx_clk,
            axis_rx_clk              => axis_rx_clk,
            axis_reset               => axis_reset,
            RXOverFlowCount          => TXOverFlowCount,
            RXAlmostFullCount        => TXAlmostFullCount,
            RingBufferSlotID         => RingBufferSlotID,
            RingBufferSlotClear      => RingBufferSlotClear,
            RingBufferSlotStatus     => RingBufferSlotStatus,
            RingBufferSlotTypeStatus => RingBufferSlotTypeStatus,
            RingBufferDataRead       => RingBufferDataRead,
            RingBufferDataEnable     => RingBufferDataEnable,
            RingBufferDataOut        => RingBufferData,
            RingBufferAddress        => RingBufferAddress,
            axis_rx_tdata            => axis_rx_tdata,
            axis_rx_tvalid           => axis_rx_tvalid,
            axis_rx_tuser            => axis_rx_tuser,
            axis_rx_tready           => axis_rx_tready,
            axis_rx_tkeep            => axis_rx_tkeep,
            axis_rx_tlast            => axis_rx_tlast
        );
end architecture rtl;
