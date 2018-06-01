library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gmactop is
	port(
		-- Reference clock to generate 100MHz from
		sysclk1_300_p     : in  STD_LOGIC;
		sysclk1_300_n     : in  STD_LOGIC;
		-- Ethernet reference clock for 156.25MHz
		-- QSFP+ 1
		mgt_qsfp1_clock_p : in  STD_LOGIC;
		mgt_qsfp1_clock_n : in  STD_LOGIC;
		-- QSFP+ 2
		mgt_qsfp2_clock_p : in  STD_LOGIC;
		mgt_qsfp2_clock_n : in  STD_LOGIC;
		--RX     
		qsfp1_mgt_rx0_p   : in  STD_LOGIC;
		qsfp1_mgt_rx0_n   : in  STD_LOGIC;
		qsfp1_mgt_rx1_p   : in  STD_LOGIC;
		qsfp1_mgt_rx1_n   : in  STD_LOGIC;
		qsfp1_mgt_rx2_p   : in  STD_LOGIC;
		qsfp1_mgt_rx2_n   : in  STD_LOGIC;
		qsfp1_mgt_rx3_p   : in  STD_LOGIC;
		qsfp1_mgt_rx3_n   : in  STD_LOGIC;
		-- TX
		qsfp1_mgt_tx0_p   : out STD_LOGIC;
		qsfp1_mgt_tx0_n   : out STD_LOGIC;
		qsfp1_mgt_tx1_p   : out STD_LOGIC;
		qsfp1_mgt_tx1_n   : out STD_LOGIC;
		qsfp1_mgt_tx2_p   : out STD_LOGIC;
		qsfp1_mgt_tx2_n   : out STD_LOGIC;
		qsfp1_mgt_tx3_p   : out STD_LOGIC;
		qsfp1_mgt_tx3_n   : out STD_LOGIC;
		-- Settings
		qsfp1_modsell_ls  : out STD_LOGIC;
		qsfp1_resetl_ls   : out STD_LOGIC;
		qsfp1_modprsl_ls  : in  STD_LOGIC;
		qsfp1_intl_ls     : in  STD_LOGIC;
		qsfp1_lpmode_ls   : out STD_LOGIC;
		-- QSFP+ 2
		--RX
		qsfp2_mgt_rx0_p   : in  STD_LOGIC;
		qsfp2_mgt_rx0_n   : in  STD_LOGIC;
		qsfp2_mgt_rx1_p   : in  STD_LOGIC;
		qsfp2_mgt_rx1_n   : in  STD_LOGIC;
		qsfp2_mgt_rx2_p   : in  STD_LOGIC;
		qsfp2_mgt_rx2_n   : in  STD_LOGIC;
		qsfp2_mgt_rx3_p   : in  STD_LOGIC;
		qsfp2_mgt_rx3_n   : in  STD_LOGIC;
		-- TX
		qsfp2_mgt_tx0_p   : out STD_LOGIC;
		qsfp2_mgt_tx0_n   : out STD_LOGIC;
		qsfp2_mgt_tx1_p   : out STD_LOGIC;
		qsfp2_mgt_tx1_n   : out STD_LOGIC;
		qsfp2_mgt_tx2_p   : out STD_LOGIC;
		qsfp2_mgt_tx2_n   : out STD_LOGIC;
		qsfp2_mgt_tx3_p   : out STD_LOGIC;
		qsfp2_mgt_tx3_n   : out STD_LOGIC;
		-- Settings
		qsfp2_modsell_ls  : out STD_LOGIC;
		qsfp2_resetl_ls   : out STD_LOGIC;
		qsfp2_modprsl_ls  : in  STD_LOGIC;
		qsfp2_intl_ls     : in  STD_LOGIC;
		qsfp2_lpmode_ls   : out STD_LOGIC;
		--
		partial_bit_leds  : out STD_LOGIC_VECTOR(3 downto 0);
		-- LEDs for debug     
		blink_led         : out STD_LOGIC_VECTOR(3 downto 0)
	);
end entity gmactop;

architecture rtl of gmactop is

	component gmacqsfp1top is
		port(
			-- Reference clock to generate 100MHz from
			Clk100MHz        : in  STD_LOGIC;
			-- Global System Enable
			Enable           : in  STD_LOGIC;
			Reset            : in  STD_LOGIC;
			-- Ethernet reference clock for 156.25MHz
			-- QSFP+ 
			mgt_qsfp_clock_p : in  STD_LOGIC;
			mgt_qsfp_clock_n : in  STD_LOGIC;
			--RX     
			qsfp_mgt_rx0_p   : in  STD_LOGIC;
			qsfp_mgt_rx0_n   : in  STD_LOGIC;
			qsfp_mgt_rx1_p   : in  STD_LOGIC;
			qsfp_mgt_rx1_n   : in  STD_LOGIC;
			qsfp_mgt_rx2_p   : in  STD_LOGIC;
			qsfp_mgt_rx2_n   : in  STD_LOGIC;
			qsfp_mgt_rx3_p   : in  STD_LOGIC;
			qsfp_mgt_rx3_n   : in  STD_LOGIC;
			-- TX
			qsfp_mgt_tx0_p   : out STD_LOGIC;
			qsfp_mgt_tx0_n   : out STD_LOGIC;
			qsfp_mgt_tx1_p   : out STD_LOGIC;
			qsfp_mgt_tx1_n   : out STD_LOGIC;
			qsfp_mgt_tx2_p   : out STD_LOGIC;
			qsfp_mgt_tx2_n   : out STD_LOGIC;
			qsfp_mgt_tx3_p   : out STD_LOGIC;
			qsfp_mgt_tx3_n   : out STD_LOGIC;
			-- Lbus and AXIS
			-- This bus runs at 322.265625MHz
			lbus_reset       : in  STD_LOGIC;
			-- Overflow signal
			lbus_tx_ovfout   : out STD_LOGIC;
			-- Underflow signal
			lbus_tx_unfout   : out STD_LOGIC;
			-- AXIS Bus
			-- RX Bus
			axis_rx_clkin    : in  STD_LOGIC;
			axis_rx_tdata    : in  STD_LOGIC_VECTOR(511 downto 0);
			axis_rx_tvalid   : in  STD_LOGIC;
			axis_rx_tready   : out STD_LOGIC;
			axis_rx_tkeep    : in  STD_LOGIC_VECTOR(63 downto 0);
			axis_rx_tlast    : in  STD_LOGIC;
			axis_rx_tuser    : in  STD_LOGIC;
			-- TX Bus
			axis_tx_clkout   : out STD_LOGIC;
			axis_tx_tdata    : out STD_LOGIC_VECTOR(511 downto 0);
			axis_tx_tvalid   : out STD_LOGIC;
			axis_tx_tkeep    : out STD_LOGIC_VECTOR(63 downto 0);
			axis_tx_tlast    : out STD_LOGIC;
			-- User signal for errors and dropping of packets
			axis_tx_tuser    : out STD_LOGIC
		);
	end component gmacqsfp1top;

	component gmacqsfp2top is
		port(
			-- Reference clock to generate 100MHz from
			Clk100MHz        : in  STD_LOGIC;
			-- Global System Enable
			Enable           : in  STD_LOGIC;
			Reset            : in  STD_LOGIC;
			-- Ethernet reference clock for 156.25MHz
			-- QSFP+ 
			mgt_qsfp_clock_p : in  STD_LOGIC;
			mgt_qsfp_clock_n : in  STD_LOGIC;
			--RX     
			qsfp_mgt_rx0_p   : in  STD_LOGIC;
			qsfp_mgt_rx0_n   : in  STD_LOGIC;
			qsfp_mgt_rx1_p   : in  STD_LOGIC;
			qsfp_mgt_rx1_n   : in  STD_LOGIC;
			qsfp_mgt_rx2_p   : in  STD_LOGIC;
			qsfp_mgt_rx2_n   : in  STD_LOGIC;
			qsfp_mgt_rx3_p   : in  STD_LOGIC;
			qsfp_mgt_rx3_n   : in  STD_LOGIC;
			-- TX
			qsfp_mgt_tx0_p   : out STD_LOGIC;
			qsfp_mgt_tx0_n   : out STD_LOGIC;
			qsfp_mgt_tx1_p   : out STD_LOGIC;
			qsfp_mgt_tx1_n   : out STD_LOGIC;
			qsfp_mgt_tx2_p   : out STD_LOGIC;
			qsfp_mgt_tx2_n   : out STD_LOGIC;
			qsfp_mgt_tx3_p   : out STD_LOGIC;
			qsfp_mgt_tx3_n   : out STD_LOGIC;
			-- Lbus and AXIS
			-- This bus runs at 322.265625MHz
			lbus_reset       : in  STD_LOGIC;
			-- Overflow signal
			lbus_tx_ovfout   : out STD_LOGIC;
			-- Underflow signal
			lbus_tx_unfout   : out STD_LOGIC;
			-- AXIS Bus
			-- RX Bus
			axis_rx_clkin    : in  STD_LOGIC;
			axis_rx_tdata    : in  STD_LOGIC_VECTOR(511 downto 0);
			axis_rx_tvalid   : in  STD_LOGIC;
			axis_rx_tready   : out STD_LOGIC;
			axis_rx_tkeep    : in  STD_LOGIC_VECTOR(63 downto 0);
			axis_rx_tlast    : in  STD_LOGIC;
			-- TX Bus
			axis_tx_clkout   : out STD_LOGIC;
			axis_tx_tdata    : out STD_LOGIC_VECTOR(511 downto 0);
			axis_tx_tvalid   : out STD_LOGIC;
			axis_tx_tkeep    : out STD_LOGIC_VECTOR(63 downto 0);
			axis_tx_tlast    : out STD_LOGIC;
			-- User signal for errors and dropping of packets
			axis_tx_tuser    : out STD_LOGIC
		);
	end component gmacqsfp2top;

	component clockgen100mhz is
		port(
			clk_out1  : out STD_LOGIC;
			locked    : out STD_LOGIC;
			clk_in1_p : in  STD_LOGIC;
			clk_in1_n : in  STD_LOGIC
		);
	end component clockgen100mhz;

	component ledflasher is
		generic(
			-- Clock frequency in Hz
			CLOCKFREQUENCY : NATURAL := 50_000_000;
			-- LED flashrate in Hz
			LEDFLASHRATE   : NATURAL := 1
		);
		port(
			Clk : in  STD_LOGIC;
			LED : out STD_LOGIC
		);
	end component ledflasher;

	component axisila is
		port(
			clk     : IN STD_LOGIC;
			probe0  : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
			probe1  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe2  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe3  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
			probe4  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe5  : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
			probe6  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe7  : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
			probe8  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe9  : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe11 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe12 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe13 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe14 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe15 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
		);
	end component axisila;

	component resetvio is
		port(
			clk        : IN  STD_LOGIC;
			probe_in0  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe_in1  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe_in2  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe_in3  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe_out1 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			probe_out2 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
		);
	end component resetvio;

	component arpmodule is
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
			axis_tx_tpriority : out STD_LOGIC_VECTOR(3 downto 0);
			axis_tx_tdata     : out STD_LOGIC_VECTOR(511 downto 0);
			axis_tx_tvalid    : out STD_LOGIC;
			axis_tx_tready    : in  STD_LOGIC;
			axis_tx_tkeep     : out STD_LOGIC_VECTOR(63 downto 0);
			axis_tx_tlast     : out STD_LOGIC
		);
	end component arpmodule;
	component ipcomms is
		generic(
			G_DATA_WIDTH      : natural                          := 512;
			G_EMAC_ADDR       : std_logic_vector(47 downto 0)    := X"000A_3502_4194";
			G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
			G_PR_SERVER_PORT  : natural range 0 to ((2**16) - 1) := 5;
			G_IP_ADDR         : std_logic_vector(31 downto 0)    := X"C0A8_0A0A" --192.168.10.10
		);
		port(
			axis_clk       : in  STD_LOGIC;
			axis_reset     : in  STD_LOGIC;
			--Outputs to AXIS bus MAC side 
			axis_tx_tdata  : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
			axis_tx_tvalid : out STD_LOGIC;
			axis_tx_tready : in  STD_LOGIC;
			axis_tx_tkeep  : out STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
			axis_tx_tlast  : out STD_LOGIC;
			axis_tx_tuser  : out STD_LOGIC;
			--Inputs from AXIS bus of the MAC side
			axis_rx_tdata  : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
			axis_rx_tvalid : in  STD_LOGIC;
			axis_rx_tuser  : in  STD_LOGIC;
			axis_rx_tkeep  : in  STD_LOGIC_VECTOR((G_DATA_WIDTH / 8) - 1 downto 0);
			axis_rx_tlast  : in  STD_LOGIC
		);
	end component ipcomms;
	component axispacketbufferfifo
		port(
			s_aclk        : IN  STD_LOGIC;
			s_aresetn     : IN  STD_LOGIC;
			s_axis_tvalid : IN  STD_LOGIC;
			s_axis_tready : OUT STD_LOGIC;
			s_axis_tdata  : IN  STD_LOGIC_VECTOR(511 DOWNTO 0);
			s_axis_tkeep  : IN  STD_LOGIC_VECTOR(63 DOWNTO 0);
			s_axis_tlast  : IN  STD_LOGIC;
			s_axis_tuser  : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
			m_axis_tvalid : OUT STD_LOGIC;
			m_axis_tready : IN  STD_LOGIC;
			m_axis_tdata  : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
			m_axis_tkeep  : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
			m_axis_tlast  : OUT STD_LOGIC;
			m_axis_tuser  : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
		);
	end component axispacketbufferfifo;
	component partialblinker is
		port(
			clk_100MHz       : IN  STD_LOGIC;
			partial_bit_leds : out STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	end component partialblinker;

	signal RefClk100MHz    : std_logic;
	signal RefClkLocked    : std_logic;
	signal Reset           : std_logic;
	signal lReset          : std_logic;
	signal lbus_reset      : std_logic;
	signal lbus1_tx_ovfout : std_logic;
	signal lbus2_tx_ovfout : std_logic;
	signal lbus1_tx_unfout : std_logic;
	signal lbus2_tx_unfout : std_logic;

	signal ClkQSFP1 : std_logic;
	signal ClkQSFP2 : std_logic;

	signal axis_rx_tdata_1  : STD_LOGIC_VECTOR(511 downto 0);
	signal axis_rx_tvalid_1 : STD_LOGIC;
	signal axis_rx_tkeep_1  : STD_LOGIC_VECTOR(63 downto 0);
	signal axis_rx_tlast_1  : STD_LOGIC;
	signal axis_rx_tuser_1  : STD_LOGIC;

	signal axis_tx_tdata_1_fifo  : STD_LOGIC_VECTOR(511 downto 0);
	signal axis_tx_tvalid_1_fifo : STD_LOGIC;
	signal axis_tx_tkeep_1_fifo  : STD_LOGIC_VECTOR(63 downto 0);
	signal axis_tx_tlast_1_fifo  : STD_LOGIC;
	signal axis_tx_tready_1_fifo : STD_LOGIC;
	signal axis_tx_tuser_1_fifo  : STD_LOGIC;

	signal axis_tx_tdata_1  : STD_LOGIC_VECTOR(511 downto 0);
	signal axis_tx_tvalid_1 : STD_LOGIC;
	signal axis_tx_tkeep_1  : STD_LOGIC_VECTOR(63 downto 0);
	signal axis_tx_tlast_1  : STD_LOGIC;
	signal axis_tx_tready_1 : STD_LOGIC;
	signal axis_tx_tuser_1  : STD_LOGIC;

	signal axis_rx_tdata_2  : STD_LOGIC_VECTOR(511 downto 0);
	signal axis_rx_tvalid_2 : STD_LOGIC;
	signal axis_rx_tkeep_2  : STD_LOGIC_VECTOR(63 downto 0);
	signal axis_rx_tlast_2  : STD_LOGIC;
	signal axis_rx_tuser_2  : STD_LOGIC;

	signal axis_tx_tdata_2  : STD_LOGIC_VECTOR(511 downto 0);
	signal axis_tx_tvalid_2 : STD_LOGIC;
	signal axis_tx_tkeep_2  : STD_LOGIC_VECTOR(63 downto 0);
	signal axis_tx_tlast_2  : STD_LOGIC;
	signal axis_tx_tready_2 : STD_LOGIC;

	signal Enable : STD_LOGIC;

	constant C_EMAC_ADDR_1     : std_logic_vector(47 downto 0) := X"000A_3502_4192";
	constant C_EMAC_ADDR_2     : std_logic_vector(47 downto 0) := X"000A_3502_4194";
	constant C_IP_ADDR_1       : std_logic_vector(31 downto 0) := X"C0A8_0A0A"; --192.168.10.10
	constant C_IP_ADDR_2       : std_logic_vector(31 downto 0) := X"C0A8_0A0F"; --192.168.10.15
	constant C_UDP_SERVER_PORT : natural                       := 10000;
	constant C_PR_SERVER_PORT  : natural                       := 20000;

begin

	Reset            <= (not RefClkLocked) or lReset;
	-- Dont set module to low power mode
	qsfp1_lpmode_ls  <= '0';
	-- Dont select the module
	qsfp1_modsell_ls <= '1';
	-- Keep the module out of reset    
	qsfp1_resetl_ls  <= '1';

	-- Dont set module to low power mode
	qsfp2_lpmode_ls  <= '0';
	-- Dont select the module
	qsfp2_modsell_ls <= '1';
	-- Keep the module out of reset    
	qsfp2_resetl_ls  <= '1';

	-- Make this the partial black box
	PartialBlinker_i : partialblinker
		port map(
			clk_100MHz       => RefClk100MHz,
			partial_bit_leds => partial_bit_leds
		);

	LED1_i : ledflasher
		generic map(
			CLOCKFREQUENCY => 322_265_625,
			LEDFLASHRATE   => 1
		)
		port map(
			Clk => ClkQSFP1,
			LED => blink_led(0)
		);

	LED2_i : ledflasher
		generic map(
			CLOCKFREQUENCY => 322_265_625,
			LEDFLASHRATE   => 2
		)
		port map(
			Clk => ClkQSFP1,
			LED => blink_led(1)
		);

	LED3_i : ledflasher
		generic map(
			CLOCKFREQUENCY => 322_265_625,
			LEDFLASHRATE   => 1
		)
		port map(
			Clk => ClkQSFP2,
			LED => blink_led(2)
		);

	LED4_i : ledflasher
		generic map(
			CLOCKFREQUENCY => 322_265_625,
			LEDFLASHRATE   => 2
		)
		port map(
			Clk => ClkQSFP2,
			LED => blink_led(3)
		);

	ClockGen100MHz_i : clockgen100mhz
		port map(
			clk_out1  => RefClk100MHz,
			locked    => RefClkLocked,
			clk_in1_p => sysclk1_300_p,
			clk_in1_n => sysclk1_300_n
		);

	GMAC1_i : gmacqsfp1top
		port map(
			Clk100MHz        => RefClk100MHz,
			Enable           => Enable,
			Reset            => Reset,
			mgt_qsfp_clock_p => mgt_qsfp1_clock_p,
			mgt_qsfp_clock_n => mgt_qsfp1_clock_n,
			qsfp_mgt_rx0_p   => qsfp1_mgt_rx0_p,
			qsfp_mgt_rx0_n   => qsfp1_mgt_rx0_n,
			qsfp_mgt_rx1_p   => qsfp1_mgt_rx1_p,
			qsfp_mgt_rx1_n   => qsfp1_mgt_rx1_n,
			qsfp_mgt_rx2_p   => qsfp1_mgt_rx2_p,
			qsfp_mgt_rx2_n   => qsfp1_mgt_rx2_n,
			qsfp_mgt_rx3_p   => qsfp1_mgt_rx3_p,
			qsfp_mgt_rx3_n   => qsfp1_mgt_rx3_n,
			qsfp_mgt_tx0_p   => qsfp1_mgt_tx0_p,
			qsfp_mgt_tx0_n   => qsfp1_mgt_tx0_n,
			qsfp_mgt_tx1_p   => qsfp1_mgt_tx1_p,
			qsfp_mgt_tx1_n   => qsfp1_mgt_tx1_n,
			qsfp_mgt_tx2_p   => qsfp1_mgt_tx2_p,
			qsfp_mgt_tx2_n   => qsfp1_mgt_tx2_n,
			qsfp_mgt_tx3_p   => qsfp1_mgt_tx3_p,
			qsfp_mgt_tx3_n   => qsfp1_mgt_tx3_n,
			axis_tx_clkout   => ClkQSFP1,
			axis_rx_clkin    => ClkQSFP1,
			lbus_tx_ovfout   => lbus1_tx_ovfout,
			lbus_tx_unfout   => lbus1_tx_unfout,
			lbus_reset       => lbus_reset,
			--
			axis_rx_tdata    => axis_tx_tdata_1_fifo, --ClkQSFP1
			axis_rx_tvalid   => axis_tx_tvalid_1_fifo, --ClkQSFP1
			axis_rx_tready   => axis_tx_tready_1_fifo, --ClkQSFP1
			axis_rx_tkeep    => axis_tx_tkeep_1_fifo, --ClkQSFP1
			axis_rx_tlast    => axis_tx_tlast_1_fifo, --ClkQSFP1
			axis_rx_tuser    => axis_tx_tuser_1_fifo, --ClkQSFP1
			--
			axis_tx_tdata    => axis_rx_tdata_1, --ClkQSFP1
			axis_tx_tvalid   => axis_rx_tvalid_1, --ClkQSFP1
			axis_tx_tkeep    => axis_rx_tkeep_1, --ClkQSFP1
			axis_tx_tlast    => axis_rx_tlast_1, --ClkQSFP1
			axis_tx_tuser    => axis_rx_tuser_1 --ClkQSFP1
		);

	AXISPAcketBufferFIFO_i : axispacketbufferfifo
		PORT MAP(
			s_aclk          => ClkQSFP1,
			s_aresetn       => RefClkLocked,
			s_axis_tvalid   => axis_tx_tvalid_1,
			s_axis_tready   => axis_tx_tready_1,
			s_axis_tdata    => axis_tx_tdata_1,
			s_axis_tkeep    => axis_tx_tkeep_1,
			s_axis_tlast    => axis_tx_tlast_1,
			s_axis_tuser(0) => axis_tx_tuser_1,
			m_axis_tvalid   => axis_tx_tvalid_1_fifo,
			m_axis_tready   => axis_tx_tready_1_fifo,
			m_axis_tdata    => axis_tx_tdata_1_fifo,
			m_axis_tkeep    => axis_tx_tkeep_1_fifo,
			m_axis_tlast    => axis_tx_tlast_1_fifo,
			m_axis_tuser(0) => axis_tx_tuser_1_fifo
		);

	IPCOMMS_i : ipcomms
		generic map(
			G_DATA_WIDTH      => 512,
			G_EMAC_ADDR       => C_EMAC_ADDR_1,
			G_IP_ADDR         => C_IP_ADDR_1,
			G_UDP_SERVER_PORT => C_UDP_SERVER_PORT,
			G_PR_SERVER_PORT  => C_PR_SERVER_PORT
		)
		port map(
			axis_clk       => ClkQSFP1,
			axis_reset     => Reset,
			--Outputs to AXIS bus MAC side 
			axis_tx_tdata  => axis_tx_tdata_1,
			axis_tx_tvalid => axis_tx_tvalid_1,
			axis_tx_tready => axis_tx_tready_1,
			axis_tx_tkeep  => axis_tx_tkeep_1,
			axis_tx_tlast  => axis_tx_tlast_1,
			axis_tx_tuser  => axis_tx_tuser_1,
			--Inputs from AXIS bus of the MAC side
			axis_rx_tdata  => axis_rx_tdata_1,
			axis_rx_tvalid => axis_rx_tvalid_1,
			axis_rx_tuser  => axis_rx_tuser_1,
			axis_rx_tkeep  => axis_rx_tkeep_1,
			axis_rx_tlast  => axis_rx_tlast_1
		);
	GMAC2_i : gmacqsfp2top
		port map(
			Clk100MHz        => RefClk100MHz,
			Enable           => Enable,
			Reset            => Reset,
			mgt_qsfp_clock_p => mgt_qsfp2_clock_p,
			mgt_qsfp_clock_n => mgt_qsfp2_clock_n,
			qsfp_mgt_rx0_p   => qsfp2_mgt_rx0_p,
			qsfp_mgt_rx0_n   => qsfp2_mgt_rx0_n,
			qsfp_mgt_rx1_p   => qsfp2_mgt_rx1_p,
			qsfp_mgt_rx1_n   => qsfp2_mgt_rx1_n,
			qsfp_mgt_rx2_p   => qsfp2_mgt_rx2_p,
			qsfp_mgt_rx2_n   => qsfp2_mgt_rx2_n,
			qsfp_mgt_rx3_p   => qsfp2_mgt_rx3_p,
			qsfp_mgt_rx3_n   => qsfp2_mgt_rx3_n,
			qsfp_mgt_tx0_p   => qsfp2_mgt_tx0_p,
			qsfp_mgt_tx0_n   => qsfp2_mgt_tx0_n,
			qsfp_mgt_tx1_p   => qsfp2_mgt_tx1_p,
			qsfp_mgt_tx1_n   => qsfp2_mgt_tx1_n,
			qsfp_mgt_tx2_p   => qsfp2_mgt_tx2_p,
			qsfp_mgt_tx2_n   => qsfp2_mgt_tx2_n,
			qsfp_mgt_tx3_p   => qsfp2_mgt_tx3_p,
			qsfp_mgt_tx3_n   => qsfp2_mgt_tx3_n,
			axis_tx_clkout   => ClkQSFP2,
			axis_rx_clkin    => ClkQSFP2,
			lbus_tx_ovfout   => lbus2_tx_ovfout,
			lbus_tx_unfout   => lbus2_tx_unfout,
			lbus_reset       => lbus_reset,
			--
			axis_rx_tdata    => axis_tx_tdata_2, --ClkQSFP1
			axis_rx_tvalid   => axis_tx_tvalid_2, --ClkQSFP1
			axis_rx_tready   => axis_tx_tready_2, --ClkQSFP1
			axis_rx_tkeep    => axis_tx_tkeep_2, --ClkQSFP1
			axis_rx_tlast    => axis_tx_tlast_2, --ClkQSFP1
			--
			axis_tx_tdata    => axis_rx_tdata_2, --ClkQSFP1
			axis_tx_tvalid   => axis_rx_tvalid_2, --ClkQSFP1
			axis_tx_tkeep    => axis_rx_tkeep_2, --ClkQSFP1
			axis_tx_tlast    => axis_rx_tlast_2, --ClkQSFP1
			axis_tx_tuser    => axis_rx_tuser_2 --ClkQSFP1
		);

	ARP2_i : arpmodule
		generic map(
			G_SLOT_WIDTH => 4
		)
		port map(
			axis_clk       => ClkQSFP2,
			axis_reset     => Reset,
			ARPMACAddress  => C_EMAC_ADDR_2,
			ARPIPAddress   => C_IP_ADDR_2,
			--
			axis_tx_tdata  => axis_tx_tdata_2,
			axis_tx_tvalid => axis_tx_tvalid_2,
			axis_tx_tready => axis_tx_tready_2,
			axis_tx_tkeep  => axis_tx_tkeep_2,
			axis_tx_tlast  => axis_tx_tlast_2,
			--
			axis_rx_tdata  => axis_rx_tdata_2,
			axis_rx_tvalid => axis_rx_tvalid_2,
			axis_rx_tuser  => axis_rx_tuser_2,
			axis_rx_tkeep  => axis_rx_tkeep_2,
			axis_rx_tlast  => axis_rx_tlast_2
		);

	TXAXIS_i : axisila
		port map(
			clk        => ClkQSFP1,
			probe0     => axis_rx_tdata_1,
			probe1(0)  => axis_rx_tvalid_1,
			probe2(0)  => axis_rx_tuser_1,
			probe3     => axis_rx_tkeep_1,
			probe4(0)  => axis_rx_tlast_1,
			probe5     => axis_tx_tdata_1,
			probe6(0)  => axis_tx_tvalid_1,
			probe7     => axis_tx_tkeep_1,
			probe8(0)  => axis_tx_tlast_1,
			probe9(0)  => axis_tx_tready_1,
			probe10(0) => lbus_reset,
			probe11(0) => lbus1_tx_ovfout,
			probe12(0) => lbus1_tx_unfout,
			probe13(0) => RefClkLocked,
			probe14(0) => Reset,
			probe15(0) => qsfp1_intl_ls
		);

	RXAXIS_i : axisila
		port map(
			clk        => ClkQSFP2,
			probe0     => axis_rx_tdata_2,
			probe1(0)  => axis_rx_tvalid_2,
			probe2(0)  => axis_rx_tuser_2,
			probe3     => axis_rx_tkeep_2,
			probe4(0)  => axis_rx_tlast_2,
			probe5     => axis_tx_tdata_2,
			probe6(0)  => axis_tx_tvalid_2,
			probe7     => axis_tx_tkeep_2,
			probe8(0)  => axis_tx_tlast_2,
			probe9(0)  => axis_tx_tready_2,
			probe10(0) => lbus_reset,
			probe11(0) => lbus2_tx_ovfout,
			probe12(0) => lbus2_tx_unfout,
			probe13(0) => RefClkLocked,
			probe14(0) => Reset,
			probe15(0) => qsfp2_intl_ls
		);

	RESET_VIO_i : resetvio
		port map(
			clk           => ClkQSFP1,
			probe_in0(0)  => qsfp1_modprsl_ls,
			probe_in1(0)  => qsfp1_intl_ls,
			probe_in2(0)  => qsfp2_modprsl_ls,
			probe_in3(0)  => qsfp2_intl_ls,
			probe_out0(0) => lbus_reset,
			probe_out1(0) => lReset,
			probe_out2(0) => Enable
		);

end architecture rtl;
