--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : protocolresponderprconfigsm_tb - behavorial              -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The configcontroller module receives commands and frames -
--                    for partial reconfiguration and writes to the ICAPE3.    -
--                    The module doesn't check for errors or anything,it just  -
--                    writes the DWORD or the FRAME.It responds with a DWORD   -
--                    status that contains all the necessary errors or status  -
--                    of the partial reconfiguration operation.                -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity protocolresponderprconfigsm_tb is
end entity protocolresponderprconfigsm_tb;

architecture behavorial of protocolresponderprconfigsm_tb is
    component protocolresponderprconfigsm is
        generic(
            G_SLOT_WIDTH : natural := 4;
            --G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
            -- The address width is log2(2048/(512/8))=5 bits wide
            G_ADDR_WIDTH : natural := 5
        );
        port(
            icap_clk                   : in  STD_LOGIC;
            icap_reset                 : in  STD_LOGIC;
            -- Source IP Addressing information
            ServerMACAddress           : in  STD_LOGIC_VECTOR(47 downto 0);
            ServerIPAddress            : in  STD_LOGIC_VECTOR(31 downto 0);
            ServerPort                 : in  STD_LOGIC_VECTOR(15 downto 0);
            -- Response IP Addressing information
            ClientMACAddress           : in  STD_LOGIC_VECTOR(47 downto 0);
            ClientIPAddress            : in  STD_LOGIC_VECTOR(31 downto 0);
            ClientUDPPort              : in  STD_LOGIC_VECTOR(15 downto 0);
            -- Packet Readout in addressed bus format
            SenderRingBufferSlotID     : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            SenderRingBufferSlotSet    : out STD_LOGIC;
            SenderRingBufferSlotType   : out STD_LOGIC;
            SenderRingBufferDataWrite  : out STD_LOGIC;
            -- Enable[0] is a special bit (we assume always 1 when packet is valid)
            -- we use it to save TLAST
            SenderRingBufferDataEnable : out STD_LOGIC_VECTOR(63 downto 0);
            SenderRingBufferDataOut    : out STD_LOGIC_VECTOR(511 downto 0);
            SenderRingBufferAddress    : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            -- Handshaking signals
            -- Status signal to show when the packet sender is busy
            SenderBusy                 : out STD_LOGIC;
            -- Protocol Error
            ProtocolError              : in  STD_LOGIC;
            ProtocolErrorClear         : out STD_LOGIC;
            ProtocolErrorID            : in  STD_LOGIC_VECTOR(31 downto 0);
            ProtocolIPIdentification   : in  STD_LOGIC_VECTOR(15 downto 0);
            ProtocolID                 : in  STD_LOGIC_VECTOR(15 downto 0);
            ProtocolSequence           : in  STD_LOGIC_VECTOR(31 downto 0);
            -- ICAP Writer Response
            ICAPWriteDone              : in  STD_LOGIC;
            ICAPWriteResponseSent      : out STD_LOGIC;
            ICAPIPIdentification       : in  STD_LOGIC_VECTOR(15 downto 0);
            ICAPProtocolID             : in  STD_LOGIC_VECTOR(15 downto 0);
            ICAPProtocolSequence       : in  STD_LOGIC_VECTOR(31 downto 0);
            --ICAPE3 interface
            ICAP_PRDONE                : in  STD_LOGIC;
            ICAP_PRERROR               : in  STD_LOGIC;
            ICAP_DataOut               : in  STD_LOGIC_VECTOR(31 downto 0)
        );
    end component protocolresponderprconfigsm;

    constant G_SLOT_WIDTH             : natural                       := 4;
    constant G_ADDR_WIDTH             : natural                       := 5;
    signal icap_clk                   : STD_LOGIC                     := '1';
    signal icap_reset                 : STD_LOGIC                     := '1';
    constant ServerMACAddress         : STD_LOGIC_VECTOR(47 downto 0) := X"000A35024192";
    constant ServerIPAddress          : STD_LOGIC_VECTOR(31 downto 0) := X"C0A8640A";
    constant ServerPort               : STD_LOGIC_VECTOR(15 downto 0) := X"2710";
    constant ClientMACAddress         : STD_LOGIC_VECTOR(47 downto 0) := X"506B4BC3FAEC";
    constant ClientIPAddress          : STD_LOGIC_VECTOR(31 downto 0) := X"C0A86409";
    constant ClientUDPPort            : STD_LOGIC_VECTOR(15 downto 0) := X"894A";
    signal SenderRingBufferSlotID     : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal SenderRingBufferSlotSet    : STD_LOGIC;
    signal SenderRingBufferSlotType   : STD_LOGIC;
    signal SenderRingBufferDataWrite  : STD_LOGIC;
    signal SenderRingBufferDataEnable : STD_LOGIC_VECTOR(63 downto 0);
    signal SenderRingBufferDataOut    : STD_LOGIC_VECTOR(511 downto 0);
    signal SenderRingBufferAddress    : STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
    signal SenderBusy                 : STD_LOGIC;
    signal ProtocolError              : STD_LOGIC                     := '0';
    signal ProtocolErrorClear         : STD_LOGIC;
    constant ProtocolErrorID          : STD_LOGIC_VECTOR(31 downto 0) := X"20212021";
    constant ProtocolIPIdentification : STD_LOGIC_VECTOR(15 downto 0) := X"6E0F";
    constant ProtocolID               : STD_LOGIC_VECTOR(15 downto 0) := X"2021";
    constant ProtocolSequence         : STD_LOGIC_VECTOR(31 downto 0) := X"20212021";
    signal ICAPWriteDone              : STD_LOGIC                     := '0';
    signal ICAPWriteResponseSent      : STD_LOGIC;
    constant ICAPIPIdentification     : STD_LOGIC_VECTOR(15 downto 0) := X"6E0F";
    constant ICAPProtocolID           : STD_LOGIC_VECTOR(15 downto 0) := X"2021";
    constant ICAPProtocolSequence     : STD_LOGIC_VECTOR(31 downto 0) := X"20212021";
    constant ICAP_PRDONE              : STD_LOGIC                     := '1';
    constant ICAP_PRERROR             : STD_LOGIC                     := '0';
    constant ICAP_DataOut             : STD_LOGIC_VECTOR(31 downto 0) := X"20212021";

    constant C_CLK_PERIOD : time := 10 ns;
begin

    ClockProc : process
    begin
        icap_clk <= '1';
        wait for C_CLK_PERIOD / 2;
        icap_clk <= '0';
        wait for C_CLK_PERIOD / 2;
    end process ClockProc;

    StimProc : process
    begin
        icap_reset <= '1';
        wait for C_CLK_PERIOD * 10;
        icap_reset <= '0';
        wait for C_CLK_PERIOD * 40;
        ICAPWriteDone <= '1';
        wait until ICAPWriteResponseSent = '1';
        ICAPWriteDone <= '0';
        wait for C_CLK_PERIOD * 40;

        ProtocolError <= '1';
        wait until ProtocolErrorClear = '1';
        ProtocolError <= '0';
        wait;
    end process StimProc;

    UUT_i : protocolresponderprconfigsm
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH
        )
        port map(
            icap_clk                   => icap_clk,
            icap_reset                 => icap_reset,
            ServerMACAddress           => ServerMACAddress,
            ServerIPAddress            => ServerIPAddress,
            ServerPort                 => ServerPort,
            ClientMACAddress           => ClientMACAddress,
            ClientIPAddress            => ClientIPAddress,
            ClientUDPPort              => ClientUDPPort,
            SenderRingBufferSlotID     => SenderRingBufferSlotID,
            SenderRingBufferSlotSet    => SenderRingBufferSlotSet,
            SenderRingBufferSlotType   => SenderRingBufferSlotType,
            SenderRingBufferDataWrite  => SenderRingBufferDataWrite,
            SenderRingBufferDataEnable => SenderRingBufferDataEnable,
            SenderRingBufferDataOut    => SenderRingBufferDataOut,
            SenderRingBufferAddress    => SenderRingBufferAddress,
            SenderBusy                 => SenderBusy,
            ProtocolError              => ProtocolError,
            ProtocolErrorClear         => ProtocolErrorClear,
            ProtocolErrorID            => ProtocolErrorID,
            ProtocolIPIdentification   => ProtocolIPIdentification,
            ProtocolID                 => ProtocolID,
            ProtocolSequence           => ProtocolSequence,
            ICAPWriteDone              => ICAPWriteDone,
            ICAPWriteResponseSent      => ICAPWriteResponseSent,
            ICAPIPIdentification       => ICAPIPIdentification,
            ICAPProtocolID             => ICAPProtocolID,
            ICAPProtocolSequence       => ICAPProtocolSequence,
            ICAP_PRDONE                => ICAP_PRDONE,
            ICAP_PRERROR               => ICAP_PRERROR,
            ICAP_DataOut               => ICAP_DataOut
        );

end architecture behavorial;
