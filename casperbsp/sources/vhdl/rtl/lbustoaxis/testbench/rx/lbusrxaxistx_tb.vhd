--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : lbusrxaxistx_tb - rtl                                    -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to test mapping of the L-BUS to AXIS -
--                    interface.                                               -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity lbusrxaxistx_tb is
end entity lbusrxaxistx_tb;

architecture behavorial of lbusrxaxistx_tb is
    component lbusrxaxistx is
        port(
            lbus_rxclk     : in  STD_LOGIC;
            lbus_rxreset   : in  STD_LOGIC;
            -- Outputs to AXIS bus
            axis_tx_tdata  : out STD_LOGIC_VECTOR(511 downto 0);
            axis_tx_tvalid : out STD_LOGIC;
            axis_tx_tkeep  : out STD_LOGIC_VECTOR(63 downto 0);
            axis_tx_tlast  : out STD_LOGIC;
            axis_tx_tuser  : out STD_LOGIC;
            -- Inputs from L-BUS interface
            lbus_rxdatain0 : in  STD_LOGIC_VECTOR(127 downto 0);
            lbus_rxenain0  : in  STD_LOGIC;
            lbus_rxsopin0  : in  STD_LOGIC;
            lbus_rxeopin0  : in  STD_LOGIC;
            lbus_rxerrin0  : in  STD_LOGIC;
            lbus_rxmtyin0  : in  STD_LOGIC_VECTOR(3 downto 0);
            lbus_rxdatain1 : in  STD_LOGIC_VECTOR(127 downto 0);
            lbus_rxenain1  : in  STD_LOGIC;
            lbus_rxsopin1  : in  STD_LOGIC;
            lbus_rxeopin1  : in  STD_LOGIC;
            lbus_rxerrin1  : in  STD_LOGIC;
            lbus_rxmtyin1  : in  STD_LOGIC_VECTOR(3 downto 0);
            lbus_rxdatain2 : in  STD_LOGIC_VECTOR(127 downto 0);
            lbus_rxenain2  : in  STD_LOGIC;
            lbus_rxsopin2  : in  STD_LOGIC;
            lbus_rxeopin2  : in  STD_LOGIC;
            lbus_rxerrin2  : in  STD_LOGIC;
            lbus_rxmtyin2  : in  STD_LOGIC_VECTOR(3 downto 0);
            lbus_rxdatain3 : in  STD_LOGIC_VECTOR(127 downto 0);
            lbus_rxenain3  : in  STD_LOGIC;
            lbus_rxsopin3  : in  STD_LOGIC;
            lbus_rxeopin3  : in  STD_LOGIC;
            lbus_rxerrin3  : in  STD_LOGIC;
            lbus_rxmtyin3  : in  STD_LOGIC_VECTOR(3 downto 0)
        );
    end component lbusrxaxistx;

    signal lbus_rxclk     : STD_LOGIC                      := '1';
    signal lbus_rxreset   : STD_LOGIC                      := '1';
    signal axis_tx_tdata  : STD_LOGIC_VECTOR(511 downto 0);
    signal axis_tx_tvalid : STD_LOGIC;
    signal axis_tx_tkeep  : STD_LOGIC_VECTOR(63 downto 0);
    signal axis_tx_tlast  : STD_LOGIC;
    signal axis_tx_tuser  : STD_LOGIC;
    signal lbus_rxdatain0 : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal lbus_rxenain0  : STD_LOGIC                      := '0';
    signal lbus_rxsopin0  : STD_LOGIC                      := '0';
    signal lbus_rxeopin0  : STD_LOGIC                      := '0';
    signal lbus_rxerrin0  : STD_LOGIC                      := '0';
    signal lbus_rxmtyin0  : STD_LOGIC_VECTOR(3 downto 0)   := (others => '0');
    signal lbus_rxdatain1 : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal lbus_rxenain1  : STD_LOGIC                      := '0';
    signal lbus_rxsopin1  : STD_LOGIC                      := '0';
    signal lbus_rxeopin1  : STD_LOGIC                      := '0';
    signal lbus_rxerrin1  : STD_LOGIC                      := '0';
    signal lbus_rxmtyin1  : STD_LOGIC_VECTOR(3 downto 0)   := (others => '0');
    signal lbus_rxdatain2 : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal lbus_rxenain2  : STD_LOGIC                      := '0';
    signal lbus_rxsopin2  : STD_LOGIC                      := '0';
    signal lbus_rxeopin2  : STD_LOGIC                      := '0';
    signal lbus_rxerrin2  : STD_LOGIC                      := '0';
    signal lbus_rxmtyin2  : STD_LOGIC_VECTOR(3 downto 0)   := (others => '0');
    signal lbus_rxdatain3 : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal lbus_rxenain3  : STD_LOGIC                      := '0';
    signal lbus_rxsopin3  : STD_LOGIC                      := '0';
    signal lbus_rxeopin3  : STD_LOGIC                      := '0';
    signal lbus_rxerrin3  : STD_LOGIC                      := '0';
    signal lbus_rxmtyin3  : STD_LOGIC_VECTOR(3 downto 0)   := (others => '0');

    constant C_CLK_PERIOD : time := 10 ns;
begin

    lbus_rxclk   <= not lbus_rxclk after C_CLK_PERIOD / 2;
    lbus_rxreset <= '1', '0' after C_CLK_PERIOD * 2;

    StimProc : process
    begin
        wait for C_CLK_PERIOD * 4;
        -------------------------------------------------
        -- Send a IDLE 64 byte packet -aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        -------------------------------------------------
        -- Send a 64 byte packet --aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '1';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '1';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        -------------------------------------------------
        -- Send a 64 byte packet --aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF02";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '1';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF12";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF22";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF32";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '1';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        -------------------------------------------------
        -- Send a IDLE 64 byte packet -aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        -------------------------------------------------
        -- Send a 128 byte packet --aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '1';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF02";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF12";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF22";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF32";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '1';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        -------------------------------------------------
        -- Send a IDLE 64 byte packet -aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        -------------------------------------------------
        -- Send a 256 byte packet --aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '1';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF02";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF12";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF22";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF32";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF03";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF13";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF23";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF33";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF04";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF14";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF24";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF34";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '1';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;

        -------------------------------------------------
        -- Send a IDLE 64 byte packet -aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD * 4;
        -------------------------------------------------
        -- Send a 64 byte packet -- 16 aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '1';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '1';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;

        -------------------------------------------------
        -- Send a 64 byte packet -- 32 aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '1';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '1';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;

        -------------------------------------------------
        -- Send a 64 byte packet -- 48 aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '1';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '1';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;

        -------------------------------------------------
        -- Send a IDLE 64 byte packet -aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD * 4;
        -------------------------------------------------
        -- Send a 128 byte packet -- 16 aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '1';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF02";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF12";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF22";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF32";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '1';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;

        -------------------------------------------------
        -- Send a 128 byte packet -- 32 aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '1';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF02";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF12";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF22";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF32";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '1';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;

        -------------------------------------------------
        -- Send a 128 byte packet -- 48 aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF01";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '1';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF11";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF21";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF31";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF02";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '1';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        lbus_rxdatain0 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF12";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '1';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF22";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '1';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"DEADBEEFABCDEF01DEADBEEFABCDEF32";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '1';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '1';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD;
        -------------------------------------------------
        -- Send a IDLE 64 byte packet -aligned
        -------------------------------------------------			
        lbus_rxdatain0 <= X"00000000000000000000000000000000";
        lbus_rxmtyin0  <= X"0";
        lbus_rxenain0  <= '0';
        lbus_rxsopin0  <= '0';
        lbus_rxeopin0  <= '0';
        lbus_rxerrin0  <= '0';
        lbus_rxdatain1 <= X"00000000000000000000000000000000";
        lbus_rxmtyin1  <= X"0";
        lbus_rxenain1  <= '0';
        lbus_rxsopin1  <= '0';
        lbus_rxeopin1  <= '0';
        lbus_rxerrin1  <= '0';
        lbus_rxdatain2 <= X"00000000000000000000000000000000";
        lbus_rxmtyin2  <= X"0";
        lbus_rxenain2  <= '0';
        lbus_rxsopin2  <= '0';
        lbus_rxeopin2  <= '0';
        lbus_rxerrin2  <= '0';
        lbus_rxdatain3 <= X"00000000000000000000000000000000";
        lbus_rxmtyin3  <= X"0";
        lbus_rxenain3  <= '0';
        lbus_rxsopin3  <= '0';
        lbus_rxeopin3  <= '0';
        lbus_rxerrin3  <= '0';
        wait for C_CLK_PERIOD * 4;

        wait;
    end process StimProc;

    UUT_i : lbusrxaxistx
        port map(
            lbus_rxclk     => lbus_rxclk,
            lbus_rxreset   => lbus_rxreset,
            axis_tx_tdata  => axis_tx_tdata,
            axis_tx_tvalid => axis_tx_tvalid,
            axis_tx_tkeep  => axis_tx_tkeep,
            axis_tx_tlast  => axis_tx_tlast,
            axis_tx_tuser  => axis_tx_tuser,
            lbus_rxdatain0 => lbus_rxdatain0,
            lbus_rxenain0  => lbus_rxenain0,
            lbus_rxsopin0  => lbus_rxsopin0,
            lbus_rxeopin0  => lbus_rxeopin0,
            lbus_rxerrin0  => lbus_rxerrin0,
            lbus_rxmtyin0  => lbus_rxmtyin0,
            lbus_rxdatain1 => lbus_rxdatain1,
            lbus_rxenain1  => lbus_rxenain1,
            lbus_rxsopin1  => lbus_rxsopin1,
            lbus_rxeopin1  => lbus_rxeopin1,
            lbus_rxerrin1  => lbus_rxerrin1,
            lbus_rxmtyin1  => lbus_rxmtyin1,
            lbus_rxdatain2 => lbus_rxdatain2,
            lbus_rxenain2  => lbus_rxenain2,
            lbus_rxsopin2  => lbus_rxsopin2,
            lbus_rxeopin2  => lbus_rxeopin2,
            lbus_rxerrin2  => lbus_rxerrin2,
            lbus_rxmtyin2  => lbus_rxmtyin2,
            lbus_rxdatain3 => lbus_rxdatain3,
            lbus_rxenain3  => lbus_rxenain3,
            lbus_rxsopin3  => lbus_rxsopin3,
            lbus_rxeopin3  => lbus_rxeopin3,
            lbus_rxerrin3  => lbus_rxerrin3,
            lbus_rxmtyin3  => lbus_rxmtyin3
        );
end architecture behavorial;
