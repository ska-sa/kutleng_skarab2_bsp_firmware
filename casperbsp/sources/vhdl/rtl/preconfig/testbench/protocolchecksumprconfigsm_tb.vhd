--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : protocolchecksumprconfigsm_tb - behavoral                -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The protocolchecksumprconfigsm module receives UDP frames-
--                    and verifies all frames for UDP checksum integrity.      -
--                    When the checksum is correct then the fame is passed on  -
--                    for ICAP3 writing else an error is reported if there is  -
--                    a checksum error of bad frame.                           -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity protocolchecksumprconfigsm_tb is
end entity protocolchecksumprconfigsm_tb;

architecture behavoral of protocolchecksumprconfigsm_tb is
component protocolchecksumprconfigsm is
    generic(
        G_SLOT_WIDTH         : natural := 4;
        --G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
        -- ICAP Ring buffer needs 100 DWORDS
        -- The address is log2(100))=7 bits wide
        G_ICAP_RB_ADDR_WIDTH : natural := 7;
        -- The address width is log2(2048/(512/8))=5 bits wide
        G_ADDR_WIDTH         : natural := 5
    );
    port(
        axis_clk                       : in  STD_LOGIC;
        axis_reset                     : in  STD_LOGIC;
        -- IP Addressing information
        ClientMACAddress               : out STD_LOGIC_VECTOR(47 downto 0);
        ClientIPAddress                : out STD_LOGIC_VECTOR(31 downto 0);
        ClientUDPPort                  : out STD_LOGIC_VECTOR(15 downto 0);
        -- Packet Write in addressed bus format
        -- Packet Readout in addressed bus format
        FilterRingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        FilterRingBufferSlotClear      : out STD_LOGIC;
        FilterRingBufferSlotStatus     : in  STD_LOGIC;
        FilterRingBufferSlotTypeStatus : in  STD_LOGIC;
        FilterRingBufferDataRead       : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        FilterRingBufferByteEnable     : in  STD_LOGIC_VECTOR(63 downto 0);
        FilterRingBufferDataIn         : in  STD_LOGIC_VECTOR(511 downto 0);
        FilterRingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        -- Packet Readout in addressed bus format
        ICAPRingBufferSlotID           : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        ICAPRingBufferSlotSet          : out STD_LOGIC;
        ICAPRingBufferSlotStatus       : in  STD_LOGIC;
        ICAPRingBufferSlotType         : out STD_LOGIC;
        ICAPRingBufferDataWrite        : out STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        ICAPRingBufferByteEnable       : out STD_LOGIC_VECTOR(3 downto 0);
        ICAPRingBufferDataOut          : out STD_LOGIC_VECTOR(31 downto 0);
        ICAPRingBufferAddress          : out STD_LOGIC_VECTOR(G_ICAP_RB_ADDR_WIDTH - 1 downto 0);
        -- Protocol Error
        -- Back off signal to indicate sender is busy with response                 
        SenderBusy                     : in  STD_LOGIC;
        -- Signal to indicate an erroneous packet condition  
        ProtocolError                  : out STD_LOGIC;
        -- Clear signal to indicate acknowledgement of transaction
        ProtocolErrorClear             : in  STD_LOGIC;
        -- Error type indication
        ProtocolErrorID                : out STD_LOGIC_VECTOR(31 downto 0);
        -- IP Identification 
        ProtocolIPIdentification       : out STD_LOGIC_VECTOR(15 downto 0);
        -- Protocol ID for framing
        ProtocolID                     : out STD_LOGIC_VECTOR(15 downto 0);
        -- Protocol frame sequence
        ProtocolSequence               : out STD_LOGIC_VECTOR(31 downto 0)
    );
end component protocolchecksumprconfigsm;

        constant G_SLOT_WIDTH         : natural := 4;
        constant G_ICAP_RB_ADDR_WIDTH : natural := 7;
        constant G_ADDR_WIDTH         : natural := 5;

    signal    axis_clk                       :  STD_LOGIC := '1';
    signal    axis_reset                     :  STD_LOGIC := '1';
        -- IP Addressing information
    signal    ClientMACAddress               :  STD_LOGIC_VECTOR(47 downto 0);
    signal    ClientIPAddress                :  STD_LOGIC_VECTOR(31 downto 0);
    signal    ClientUDPPort                  :  STD_LOGIC_VECTOR(15 downto 0);
        -- Packet Write in addressed bus format
        -- Packet Readout in addressed bus format
    signal    FilterRingBufferSlotID         :  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal    FilterRingBufferSlotClear      :  STD_LOGIC;
    signal    FilterRingBufferSlotStatus     :  STD_LOGIC := '0';
    signal    FilterRingBufferSlotTypeStatus :  STD_LOGIC := '0';
    signal    FilterRingBufferDataRead       :  STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
    signal    FilterRingBufferByteEnable     :  STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal    FilterRingBufferDataIn         :  STD_LOGIC_VECTOR(511 downto 0) := (others => '0');
    signal    FilterRingBufferAddress        :  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        -- Packet Readout in addressed bus format
    signal    ICAPRingBufferSlotID           :  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal    ICAPRingBufferSlotSet          :  STD_LOGIC;
    signal    ICAPRingBufferSlotStatus       :  STD_LOGIC := '0';
    signal    ICAPRingBufferSlotType         :  STD_LOGIC;
    signal    ICAPRingBufferDataWrite        :  STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
    signal    ICAPRingBufferByteEnable       : STD_LOGIC_VECTOR(3 downto 0);
    signal    ICAPRingBufferDataOut          : STD_LOGIC_VECTOR(31 downto 0);
    signal    ICAPRingBufferAddress          : STD_LOGIC_VECTOR(G_ICAP_RB_ADDR_WIDTH - 1 downto 0);
        -- Protocol Error
        -- Back off signal to indicate sender is busy with response                 
    signal    SenderBusy                     : STD_LOGIC := '0';
        -- Signal to indicate an erroneous packet condition  
    signal    ProtocolError                  : STD_LOGIC;
        -- Clear signal to indicate acknowledgement of transaction
    signal    ProtocolErrorClear             : STD_LOGIC := '0';
        -- Error type indication
    signal    ProtocolErrorID                : STD_LOGIC_VECTOR(31 downto 0);
        -- IP Identification 
    signal    ProtocolIPIdentification       : STD_LOGIC_VECTOR(15 downto 0);
        -- Protocol ID for framing
    signal    ProtocolID                     : STD_LOGIC_VECTOR(15 downto 0);
        -- Protocol frame sequence
    signal    ProtocolSequence               : STD_LOGIC_VECTOR(31 downto 0);

	constant C_CLK_PERIOD					: time := 10 ns;
begin

axis_clk <= not axis_clk after C_CLK_PERIOD/2;
axis_reset <= '1','0' after C_CLK_PERIOD * 10;
FilterRingBufferSlotStatus <= '0', '1' after C_CLK_PERIOD * 10;
FilterRingBufferDataIn <= (others => '0'), X"0000000000000000000000006c726f5701000000da0195831e001027f1d80d01a8c00801a8c0522b11400040038c32000045000870fe8e6acc4c4b0c80d9bed4" after C_CLK_PERIOD*10;

UUT:protocolchecksumprconfigsm 
    generic map(
        G_SLOT_WIDTH         => G_SLOT_WIDTH,
        G_ICAP_RB_ADDR_WIDTH => G_ICAP_RB_ADDR_WIDTH,
        G_ADDR_WIDTH         => G_ADDR_WIDTH
    )
    port map(
        axis_clk                       => axis_clk,
        axis_reset                     => axis_reset,
        -- IP Addressing information
        ClientMACAddress               => ClientMACAddress,
        ClientIPAddress                => ClientIPAddress,
        ClientUDPPort                  => ClientUDPPort,
        -- Packet Write in addressed bus format
        -- Packet Readout in addressed bus format
        FilterRingBufferSlotID         => FilterRingBufferSlotID,
        FilterRingBufferSlotClear      => FilterRingBufferSlotClear,
        FilterRingBufferSlotStatus     => FilterRingBufferSlotStatus,
        FilterRingBufferSlotTypeStatus => FilterRingBufferSlotTypeStatus,
        FilterRingBufferDataRead       => FilterRingBufferDataRead,
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        FilterRingBufferByteEnable     => FilterRingBufferByteEnable,
        FilterRingBufferDataIn         => FilterRingBufferDataIn,
        FilterRingBufferAddress        => FilterRingBufferAddress,
        -- Packet Readout in addressed bus format
        ICAPRingBufferSlotID           => ICAPRingBufferSlotID,
        ICAPRingBufferSlotSet          => ICAPRingBufferSlotSet,
        ICAPRingBufferSlotStatus       => ICAPRingBufferSlotStatus,
        ICAPRingBufferSlotType         => ICAPRingBufferSlotType,
        ICAPRingBufferDataWrite        => ICAPRingBufferDataWrite,
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        ICAPRingBufferByteEnable       => ICAPRingBufferByteEnable,
        ICAPRingBufferDataOut          => ICAPRingBufferDataOut,
        ICAPRingBufferAddress          => ICAPRingBufferAddress,
        -- Protocol Error
        -- Back off signal to indicate sender is busy with response                 
        SenderBusy                     => SenderBusy,
        -- Signal to indicate an erroneous packet condition  
        ProtocolError                  => ProtocolError,
        -- Clear signal to indicate acknowledgement of transaction
        ProtocolErrorClear             => ProtocolErrorClear,
        -- Error type indication
        ProtocolErrorID                => ProtocolErrorID,
        -- IP Identification 
        ProtocolIPIdentification       => ProtocolIPIdentification,
        -- Protocol ID for framing
        ProtocolID                     => ProtocolID,
        -- Protocol frame sequence
        ProtocolSequence               => ProtocolSequence
    );
end architecture behavoral;
