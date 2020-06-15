--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : udpdatastripper_tb - rtl                                 -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module test the udpdatastripper statemachine        -
--                                                                             -
-- Dependencies     : udpdatastripper                                          -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udpdatastripper_tb is
end entity udpdatastripper_tb;

architecture rtl of udpdatastripper_tb is
    component udpdatastripper is
	generic(
		G_SLOT_WIDTH : natural := 4;
		G_ADDR_WIDTH : natural := 5
	);
	port(
		axis_clk                 : in  STD_LOGIC;
		axis_reset               : in  STD_LOGIC;
		EthernetMACEnable        : in  STD_LOGIC;
		-- Packet Readout in addressed bus format
		RecvRingBufferSlotID     : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		RecvRingBufferSlotClear  : out STD_LOGIC;
		RecvRingBufferSlotStatus : in  STD_LOGIC;
		RecvRingBufferDataRead   : out STD_LOGIC;
		-- Enable[0] is a special bit (we assume always 1 when packet is valid)
		-- we use it to save TLAST
		RecvRingBufferDataEnable : in  STD_LOGIC_VECTOR(63 downto 0);
		RecvRingBufferDataOut    : in  STD_LOGIC_VECTOR(511 downto 0);
		RecvRingBufferAddress    : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
		--
		UDPPacketLength          : out STD_LOGIC_VECTOR(15 downto 0);
        --
		axis_tuser               : out STD_LOGIC;
		axis_tdata               : out STD_LOGIC_VECTOR(511 downto 0);
		axis_tvalid              : out STD_LOGIC;
		axis_tready              : in  STD_LOGIC;
		axis_tkeep               : out STD_LOGIC_VECTOR(63 downto 0);
		axis_tlast               : out STD_LOGIC
	);
    end component udpdatastripper;
	component dualportpacketringbuffer is
		generic(
		    G_SLOT_WIDTH : natural := 4;
		    G_ADDR_WIDTH : natural := 8;
		    G_DATA_WIDTH : natural := 64
		);
		port(
		    RxClk                  : in  STD_LOGIC;
		    TxClk                  : in  STD_LOGIC;
		    -- Transmission port
		    TxPacketByteEnable     : out STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
		    TxPacketDataRead       : in  STD_LOGIC;
		    TxPacketData           : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
		    TxPacketAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
		    TxPacketSlotClear      : in  STD_LOGIC;
		    TxPacketSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		    TxPacketSlotStatus     : out STD_LOGIC;
		    TxPacketSlotTypeStatus : out STD_LOGIC;
		    -- Reception port
		    RxPacketByteEnable     : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
		    RxPacketDataWrite      : in  STD_LOGIC;
		    RxPacketData           : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
		    RxPacketAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
		    RxPacketSlotSet        : in  STD_LOGIC;
		    RxPacketSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
		    RxPacketSlotType       : in  STD_LOGIC;
		    RxPacketSlotStatus     : out STD_LOGIC;
		    RxPacketSlotTypeStatus : out STD_LOGIC
		);
	end component dualportpacketringbuffer;
	component axistwoportfabricmultiplexer is
	    generic(
	        G_MAX_PACKET_BLOCKS_SIZE : natural := 64;
	        G_PRIORITY_WIDTH         : natural := 4;
	        G_DATA_WIDTH             : natural := 8
	    );
	    port(
	        axis_clk            : in  STD_LOGIC;
	        axis_reset          : in  STD_LOGIC;
	        --Inputs from AXIS bus of the MAC side
	        --Outputs to AXIS bus MAC side 
	        axis_tx_tdata       : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
	        axis_tx_tvalid      : out STD_LOGIC;
	        axis_tx_tready      : in  STD_LOGIC;
	        axis_tx_tkeep       : out STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
	        axis_tx_tlast       : out STD_LOGIC;
	        axis_tx_tuser       : out STD_LOGIC;
	        -- Port 1
	        axis_rx_tpriority_1 : in  STD_LOGIC_VECTOR(G_PRIORITY_WIDTH - 1 downto 0);
	        axis_rx_tdata_1     : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
	        axis_rx_tvalid_1    : in  STD_LOGIC;
	        axis_rx_tready_1    : out STD_LOGIC;
	        axis_rx_tkeep_1     : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
	        axis_rx_tlast_1     : in  STD_LOGIC;
	        -- Port 2
	        axis_rx_tpriority_2 : in  STD_LOGIC_VECTOR(G_PRIORITY_WIDTH - 1 downto 0);
	        axis_rx_tdata_2     : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
	        axis_rx_tvalid_2    : in  STD_LOGIC;
	        axis_rx_tready_2    : out STD_LOGIC;
	        axis_rx_tkeep_2     : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
	        axis_rx_tlast_2     : in  STD_LOGIC
	    );
	end component axistwoportfabricmultiplexer;

    constant G_SLOT_WIDTH      : natural := 4;
    constant G_ADDR_WIDTH      : natural := 5;
	constant G_DATA_WIDTH      : natural := 512;
    signal axis_clk                       : STD_LOGIC                                              := '0';
    signal axis_reset                     : STD_LOGIC                                              := '0';
    signal EthernetMACEnable              : STD_LOGIC                                              := '1';
	signal RecvRingBufferSlotID           : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
	signal RecvRingBufferSlotClear        : STD_LOGIC;
	signal RecvRingBufferSlotStatus       : STD_LOGIC := '0';
	signal RecvRingBufferDataRead   	  : STD_LOGIC;
	signal RecvRingBufferDataEnable 	  : STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0) := (others => '0');
	signal RecvRingBufferDataOut    	  : STD_LOGIC_VECTOR(G_DATA_WIDTH-1 downto 0) := (others => '0');
	signal RecvRingBufferAddress    	  : STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
    signal UDPPacketLength                : STD_LOGIC_VECTOR(15 downto 0);
    signal axis_tuser                     : STD_LOGIC;
    signal axis_tdata                     : STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
    signal axis_tvalid                    : STD_LOGIC;
    signal axis_tready                    : STD_LOGIC := '1';
    signal axis_tkeep                     : STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
    signal axis_tlast                     : STD_LOGIC;
	
    signal axis_tx_tpriority_udp             : STD_LOGIC_VECTOR(G_SLOT_WIDTH-1 downto 0):= X"1";
    signal axis_tx_tdata_udp                     : STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal axis_tx_tvalid_udp                    : STD_LOGIC := '0';
    signal axis_tx_tready_udp                    : STD_LOGIC;
    signal axis_tx_tkeep_udp                     : STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0):= (others => '0');
    signal axis_tx_tlast_udp                     : STD_LOGIC := '0';
    signal axis_tx_tuser_udp                     : STD_LOGIC := '0';

    signal axis_tx_tpriority_cpu             : STD_LOGIC_VECTOR(G_SLOT_WIDTH-1 downto 0) := X"0";
    signal axis_tx_tdata_cpu                     : STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal axis_tx_tvalid_cpu                    : STD_LOGIC := '0';
    signal axis_tx_tready_cpu                    : STD_LOGIC;
    signal axis_tx_tkeep_cpu                     : STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0):= (others => '0');
    signal axis_tx_tlast_cpu                     : STD_LOGIC := '0';

	signal RxPacketByteEnable     		  : STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0) := (others => '0');
	signal RxPacketDataWrite      		  : STD_LOGIC := '0';
	signal RxPacketData           		  : STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0) := (others => '0');
	signal RxPacketAddress        		  : STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0) := (others => '0');
	signal RxPacketSlotSet        		  : STD_LOGIC := '0';
	signal RxPacketSlotID         		  : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0) := (others => '0');
	signal RxPacketSlotType       		  : STD_LOGIC := '0';
    constant C_CLK_PERIOD                 : time                                                   := 10 ns;
begin
    axis_clk           <= not axis_clk after C_CLK_PERIOD / 2;
    axis_reset         <= '1', '0' after C_CLK_PERIOD * 10;
    axis_tready        <= not axis_tready after C_CLK_PERIOD;
	RBi:dualportpacketringbuffer 
		generic map(
		    G_SLOT_WIDTH => G_SLOT_WIDTH,
		    G_ADDR_WIDTH => G_ADDR_WIDTH,
		    G_DATA_WIDTH => G_DATA_WIDTH
		)
		port map(
		    RxClk                  => axis_clk,
		    TxClk                  => axis_clk,
		    TxPacketByteEnable     => RecvRingBufferDataEnable,
		    TxPacketDataRead       => RecvRingBufferDataRead,
		    TxPacketData           => RecvRingBufferDataOut,
		    TxPacketAddress        => RecvRingBufferAddress,
		    TxPacketSlotClear      => RecvRingBufferSlotClear,
		    TxPacketSlotID         => RecvRingBufferSlotID,
		    TxPacketSlotStatus     => RecvRingBufferSlotStatus,
		    TxPacketSlotTypeStatus => open,
		    -- Reception port
		    RxPacketByteEnable     => RxPacketByteEnable,
		    RxPacketDataWrite      => RxPacketDataWrite,
		    RxPacketData           => RxPacketData,
		    RxPacketAddress        => RxPacketAddress,
		    RxPacketSlotSet        => RxPacketSlotSet,
		    RxPacketSlotID         => RxPacketSlotID,
		    RxPacketSlotType       => RxPacketSlotType,
		    RxPacketSlotStatus     => open,
		    RxPacketSlotTypeStatus => open
		);
    DSRBi : udpdatastripper
        generic map(
            G_SLOT_WIDTH      => G_SLOT_WIDTH,
            G_ADDR_WIDTH      => G_ADDR_WIDTH
        )
        port map(
            axis_clk                       => axis_clk,
            axis_reset                     => axis_reset,
            UDPPacketLength                => UDPPacketLength,
			EthernetMACEnable			   => EthernetMACEnable,
			RecvRingBufferSlotID     	   => RecvRingBufferSlotID,
	 		RecvRingBufferSlotClear   	   => RecvRingBufferSlotClear,
	 		RecvRingBufferSlotStatus       => RecvRingBufferSlotStatus,
	 		RecvRingBufferDataRead         => RecvRingBufferDataRead,
	 		RecvRingBufferDataEnable       => RecvRingBufferDataEnable,
	 		RecvRingBufferDataOut          => RecvRingBufferDataOut,
	 		RecvRingBufferAddress          => RecvRingBufferAddress,
            axis_tuser                     => axis_tx_tuser_udp,
            axis_tdata                     => axis_tx_tdata_udp,
            axis_tready                    => axis_tx_tready_udp,
            axis_tkeep                     => axis_tx_tkeep_udp,
            axis_tvalid                    => axis_tx_tvalid_udp,
            axis_tlast                     => axis_tx_tlast_udp
        );

            AXISMUX_i : axistwoportfabricmultiplexer
                generic map(
                    G_MAX_PACKET_BLOCKS_SIZE => 64,
                    G_PRIORITY_WIDTH         => G_SLOT_WIDTH,
                    G_DATA_WIDTH             => G_DATA_WIDTH
                )
                port map(
                    axis_clk            => axis_clk,
                    axis_reset          => axis_reset,
                    axis_tx_tdata       => axis_tdata,
                    axis_tx_tvalid      => axis_tvalid,
                    axis_tx_tready      => axis_tready,
                    axis_tx_tkeep       => axis_tkeep,
                    axis_tx_tlast       => axis_tlast,
                    axis_tx_tuser       => axis_tuser,
                    -- Port 1 - ARP Controller Module
                    axis_rx_tpriority_1 => axis_tx_tpriority_cpu,
                    axis_rx_tdata_1     => axis_tx_tdata_cpu,
                    axis_rx_tvalid_1    => axis_tx_tvalid_cpu,
                    axis_rx_tready_1    => axis_tx_tready_cpu,
                    axis_rx_tkeep_1     => axis_tx_tkeep_cpu,
                    axis_rx_tlast_1     => axis_tx_tlast_cpu,
                    -- Port 2 - Streaming Data Module
                    axis_rx_tpriority_2 => axis_tx_tpriority_udp,
                    axis_rx_tdata_2     => axis_tx_tdata_udp,
                    axis_rx_tvalid_2    => axis_tx_tvalid_udp,
                    axis_rx_tready_2    => axis_tx_tready_udp,
                    axis_rx_tkeep_2     => axis_tx_tkeep_udp,
                    axis_rx_tlast_2     => axis_tx_tlast_udp
                );

    SimProcProc : process
    begin

        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"0000";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"0001";
		wait for C_CLK_PERIOD*2;
		
        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"0001";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';		
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"0010";
		wait for C_CLK_PERIOD*2;
        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"0010";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"0011";
		wait for C_CLK_PERIOD*2;
        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"0011";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"0100";
		wait for C_CLK_PERIOD*2;
        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"0100";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"0101";
		wait for C_CLK_PERIOD*2;
        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"0101";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"0110";
		wait for C_CLK_PERIOD*2;
        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"0110";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"0111";
		wait for C_CLK_PERIOD*2;
        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"0111";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"1000";
		wait for C_CLK_PERIOD*2;
        RxPacketData      		<= X"ffffffff0020ffffffff0000ffffffff00000000f4ad87f2de03b8d910279664a8c00a64a8c05f1b11400040aad1f20300450008924102350a00acfbc34b6b50";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000ffffffff0020ffffffff0000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0020200000000000200000000020200000000000aa9955660020ffffffff0000ffffffff0020112200440000000000bb0020ffffffff0000ffffffff0020ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000070020000000003020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff20000000ffff2000000000c0";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"002020000000000020000000002020000000000020000000002020000000000020000000002020000000ffff20000000ffff20000000bb0020000000ffff2000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000200000000020200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"00111";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000000000002000000000202000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01000";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"20000000000020000000000020000000000020000000000020000000000020000000000020000000002020000000000020000000002020000000000020000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01001";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"000000002000ffff0000ffffffff0000ffff000000000000ffff0000adf400000000200000000000200000000000200000000000200000000000200000000000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01010";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01011";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000002000bb000000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff0000ffffffff0000ffff000000002000ffff";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01100";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"0000000000000020000000200000000020000000000000000020000099aa00000000200066550000ffffffff0000ffff000000002000ffff0000440022110000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01101";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"00000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000000000000000002000000020000000002000";
        RxPacketByteEnable      <= X"fffffffffffffffe";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01110";
		wait for C_CLK_PERIOD;
        RxPacketData      		<= X"ffff000000000000002000000020ffff0000ffff000000000000002000000020c000000020000000000000000020000000200007000030000000000000000020";
        RxPacketByteEnable      <= X"ffffffffffffffff";
        RxPacketDataWrite     	<= '1';
		RxPacketAddress         <= B"01111";
		wait for C_CLK_PERIOD;
        RxPacketSlotID      	<= B"1000";
        RxPacketSlotSet      	<= '1';
		wait for C_CLK_PERIOD;
        RxPacketSlotSet      	<= '0';
		wait for C_CLK_PERIOD*2;
        RxPacketSlotID      	<= B"0000";
		wait for C_CLK_PERIOD*2;
		
		wait for C_CLK_PERIOD*40;		
		-- Terminate the simulation
		std.env.finish;		
    end process SimProcProc;

end architecture rtl;
