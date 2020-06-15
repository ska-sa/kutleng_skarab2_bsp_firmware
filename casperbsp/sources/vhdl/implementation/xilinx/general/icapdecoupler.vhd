
--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : icapdecoupler - rtl                                      -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module decouples the ICAP for async AVAIL signal by -
--                  : using a AXIS FIFO with async tready signal.              -
--                                                                             -
-- Dependencies     : icapfifo                                                 -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity icapdecoupler is
    port(
        axis_clk        : in  STD_LOGIC;
        axis_reset      : in  STD_LOGIC;
        axis_prog_full  : out STD_LOGIC;
        axis_prog_empty : out STD_LOGIC;
        axis_data_count : out std_logic_vector(13 downto 0);
        ICAPClk125MHz   : in  STD_LOGIC;
        ICAP_AVAIL      : out STD_LOGIC;
        ICAP_DataOut    : out STD_LOGIC_VECTOR(31 downto 0);
        ICAP_PRDONE     : out STD_LOGIC;
        ICAP_PRERROR    : out STD_LOGIC;
        ICAP_CSIB       : in  STD_LOGIC;
        ICAP_DataIn     : in  STD_LOGIC_VECTOR(31 downto 0);
        ICAP_RDWRB      : in  STD_LOGIC
    );
end entity icapdecoupler;

architecture rtl of icapdecoupler is
    component icapfifo is
        port(
            s_aclk             : in  std_logic;
            m_aclk             : in  std_logic;
            s_aresetn          : in  std_logic;
            axis_prog_full     : out std_logic;
            axis_prog_empty    : out std_logic;
            axis_wr_data_count : out std_logic_vector(13 downto 0);
            axis_rd_data_count : out std_logic_vector(13 downto 0);
            s_axis_tvalid      : in  std_logic;
            s_axis_tready      : out std_logic;
            s_axis_tdata       : in  std_logic_vector(31 downto 0);
            s_axis_tuser       : in  std_logic_vector(0 downto 0);
            m_axis_tvalid      : out std_logic;
            m_axis_tready      : in  std_logic;
            m_axis_tdata       : out std_logic_vector(31 downto 0);
            m_axis_tuser       : out std_logic_vector(0 downto 0)
        );
    end component icapfifo;
    --    component icap_ila is
    --        port(
    --            clk    : IN STD_LOGIC;
    --            probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe4 : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    --            probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe7 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    --            probe8 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    --            probe9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe11 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe12 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    --            probe13 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
    --        );
    --    end component icap_ila;
    --    component icap_ila_slow is
    --        port(
    --            clk    : IN STD_LOGIC;
    --            probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    --            probe3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    --            probe4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0)
    --        );
    --    end component icap_ila_slow;

    signal m_axis_tdata     : std_logic_vector(31 downto 0);
    signal m_axis_tuser     : std_logic;
    signal m_axis_tready    : std_logic;
    signal m_axis_tvalid    : std_logic;
    signal m_axis_tvalidn   : std_logic;
    signal s_aresetn        : std_logic;
    signal s_axis_tvalid    : std_logic;
    signal laxis_prog_full  : std_logic;
    signal laxis_prog_empty : std_logic;
    signal lICAP_AVAIL      : std_logic;
    signal laxis_data_count : std_logic_vector(13 downto 0);
    signal lICAP_DataOut    : std_logic_vector(31 downto 0);
begin
    axis_prog_full  <= laxis_prog_full;
    axis_prog_empty <= laxis_prog_empty;
    ICAP_AVAIL      <= lICAP_AVAIL;
    axis_data_count <= laxis_data_count;
    ICAP_DataOut    <= lICAP_DataOut;

    s_axis_tvalid  <= not ICAP_CSIB;
    s_aresetn      <= not axis_reset;
    m_axis_tvalidn <= not m_axis_tvalid;

    ICAPFIFO_i : icapfifo
        port map(
            s_aclk             => axis_clk,
            m_aclk             => ICAPClk125MHz,
            s_aresetn          => s_aresetn,
            axis_prog_full     => laxis_prog_full,
            axis_prog_empty    => laxis_prog_empty,
            axis_wr_data_count => laxis_data_count,
            axis_rd_data_count => open,
            s_axis_tvalid      => s_axis_tvalid,
            s_axis_tready      => lICAP_AVAIL,
            s_axis_tdata       => ICAP_DataIn,
            s_axis_tuser(0)    => ICAP_RDWRB,
            m_axis_tvalid      => m_axis_tvalid,
            m_axis_tready      => m_axis_tready,
            m_axis_tdata       => m_axis_tdata,
            m_axis_tuser(0)    => m_axis_tuser
        );

    ICAPE3_i : ICAPE3
        generic map(
            DEVICE_ID         => X"03628093",
            ICAP_AUTO_SWITCH  => "DISABLE",
            SIM_CFG_FILE_NAME => "NONE"
        )
        port map(
            AVAIL   => m_axis_tready,
            O       => lICAP_DataOut,
            PRDONE  => ICAP_PRDONE,
            PRERROR => ICAP_PRERROR,
            CLK     => ICAPClk125MHz,
            --CLK     => axis_clk,
            CSIB    => m_axis_tvalidn,
            I       => m_axis_tdata,
            RDWRB   => m_axis_tuser
        );

        --    ICAPE_ILAi : icap_ila
        --        port map(
        --            clk       => axis_clk,
        --            probe0(0) => ICAPClk125MHz,
        --            probe1(0) => s_aresetn,
        --            probe2(0) => laxis_prog_full,
        --            probe3(0) => laxis_prog_empty,
        --            probe4    => laxis_data_count,
        --            probe5(0) => s_axis_tvalid,
        --            probe6(0) => lICAP_AVAIL,
        --            probe7    => ICAP_DataIn,
        --            probe8    => lICAP_DataOut,
        --            probe9(0) => ICAP_RDWRB,
        --            probe10(0)=> m_axis_tvalid,
        --            probe11(0)=> m_axis_tready,
        --            probe12   => m_axis_tdata,
        --            probe13(0)=> m_axis_tuser
        --        );
        --        
        --    ICAPE_ILA_Si : icap_ila_slow
        --        port map(
        --            clk       => ICAPClk125MHz,
        --            probe0(0) => m_axis_tuser,
        --            probe1(0) => m_axis_tready,
        --            probe2(0) => m_axis_tvalidn,
        --            probe3    => lICAP_DataOut,
        --            probe4    => m_axis_tdata
        --        );        
end architecture rtl;

