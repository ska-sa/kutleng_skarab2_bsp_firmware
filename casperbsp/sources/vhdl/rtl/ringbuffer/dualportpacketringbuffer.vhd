--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : dualportpacketringbuffer - rtl                           -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module is used to create a dual packet ring buffer  -
--                    for packet  buffering.                                   -
--                    The ring buffer operates using a (2**G_SLOT_WIDTH)-1     -
--                    buffer slots. On each slot the data size is              -
--                    ((G_DATA_WIDTH) * ((2**G_ADDR_WIDTH)-1))/8 bytes long.   -
--                    It is also desirable to provide a ringbuffer fullness    -
--                    status, this can be used as a packet priority for        -
--                    consumers that consume data from the ring buffer. Zero   -
--                    fullness means the ringbuffer is empty, but when the     -
--                    fullness approaches (2**G_SLOT_WIDTH)-1 then the         -
--                    ringbuffer must be emptied urgently to avoid overflow.   -
--                    TODO                                                     -
--                    The ringbuffer module can carry auxiliary information on - 
--                    the slot information buffer, this can be packet          -
--                    forwarding information                                   -
-- Dependencies     : packetramsp,packetstatusram                              -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dualportpacketringbuffer is
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
end entity dualportpacketringbuffer;

architecture rtl of dualportpacketringbuffer is
    component packetstatusram is
        generic(
            G_ADDR_WIDTH : natural := 4
        );
        port(
            ClkA          : in  STD_LOGIC;
            ClkB          : in  STD_LOGIC;
            -- Port A
            EnableA       : in  STD_LOGIC;
            WriteAEnable  : in  STD_LOGIC;
            WriteAData    : in  STD_LOGIC_VECTOR(1 downto 0);
            WriteAAddress : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            ReadAData     : out STD_LOGIC_VECTOR(1 downto 0);
            -- Port B
            WriteBAddress : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            EnableB       : in  STD_LOGIC;
            WriteBEnable  : in  STD_LOGIC;
            WriteBData    : in  STD_LOGIC_VECTOR(1 downto 0);
            ReadBData     : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component packetstatusram;
    component packetramdp is
        generic(
            G_ADDR_WIDTH : natural := 8 + 2;
            G_DATA_WIDTH : natural := 64
        );
        port(
            ClkA          : in  STD_LOGIC;
            ClkB          : in  STD_LOGIC;
            -- Port A
            WriteAAddress : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            EnableA       : in  STD_LOGIC;
            WriteAEnable  : in  STD_LOGIC;
            WriteAData    : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
            ReadAData     : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
            -- Port B
            WriteBAddress : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            EnableB       : in  STD_LOGIC;
            WriteBEnable  : in  STD_LOGIC;
            WriteBData    : in  STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0);
            ReadBData     : out STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0)
        );
    end component packetramdp;

    signal lRxPacketAddress : std_logic_vector((RxPacketAddress'length + RxPacketSlotID'length) - 1 downto 0);
    signal lTxPacketAddress : std_logic_vector((TxPacketAddress'length + TxPacketSlotID'length) - 1 downto 0);
    signal lTxPacketData    : std_logic_vector((TxPacketData'length + TxPacketByteEnable'length) - 1 downto 0);
    signal lRxPacketData    : std_logic_vector((RxPacketData'length + RxPacketByteEnable'length) - 1 downto 0);
    signal VCC_onebit       : std_logic;
    signal GND_onebit       : std_logic;
    signal GND_twobit       : std_logic_vector(1 downto 0);
    signal GND_dwidth       : std_logic_vector(((G_DATA_WIDTH) + (G_DATA_WIDTH / 8)) - 1 downto 0);

begin
    VCC_onebit <= '1';
    GND_onebit <= '0';
    GND_twobit <= "00";
    GND_dwidth <= (others => '0');

    packetstatusram_i : packetstatusram
        generic map(
            G_ADDR_WIDTH => G_SLOT_WIDTH
        )
        port map(
            ClkA          => RxClk,
            ClkB          => TxClk,
            -- Port A
            EnableA       => RxPacketSlotSet,
            WriteAEnable  => RxPacketSlotSet,
            WriteAData(0) => RxPacketSlotSet,
            WriteAData(1) => RxPacketSlotType,
            WriteAAddress => RxPacketSlotID,
            ReadAData(0)  => RxPacketSlotStatus,
            ReadAData(1)  => RxPacketSlotTypeStatus,
            -- Port B
            WriteBAddress => TxPacketSlotID,
            EnableB       => VCC_onebit,
            WriteBEnable  => TxPacketSlotClear,
            WriteBData    => GND_twobit,
            ReadBData(0)  => TxPacketSlotStatus,
            ReadBData(1)  => TxPacketSlotTypeStatus
        );

    lRxPacketData((RxPacketByteEnable'length + RxPacketData'length) - 1 downto RxPacketData'length) <= RxPacketByteEnable;
    lRxPacketData(RxPacketData'length - 1 downto 0)                                                 <= RxPacketData;

    lRxPacketAddress((RxPacketSlotID'length + RxPacketAddress'length) - 1 downto RxPacketAddress'length) <= RxPacketSlotID;
    lRxPacketAddress(RxPacketAddress'length - 1 downto 0)                                                <= RxPacketAddress;

    lTxPacketAddress((TxPacketSlotID'length + TxPacketAddress'length) - 1 downto TxPacketAddress'length) <= TxPacketSlotID;
    lTxPacketAddress(TxPacketAddress'length - 1 downto 0)                                                <= TxPacketAddress;

    TxPacketByteEnable <= lTxPacketData((TxPacketByteEnable'length + TxPacketData'length) - 1 downto TxPacketData'length);
    TxPacketData       <= lTxPacketData(TxPacketData'length - 1 downto 0);

    Buffer_i : packetramdp
        generic map(
            G_ADDR_WIDTH => (RxPacketAddress'length + RxPacketSlotID'length),
            G_DATA_WIDTH => (RxPacketData'length + RxPacketByteEnable'length)
        )
        port map(
            ClkA          => RxClk,
            ClkB          => TxClk,
            WriteAAddress => lRxPacketAddress,
            EnableA       => RxPacketDataWrite,
            WriteAEnable  => RxPacketDataWrite,
            WriteAData    => lRxPacketData,
            ReadAData     => open,
            WriteBAddress => lTxPacketAddress,
            EnableB       => TxPacketDataRead,
            WriteBEnable  => GND_onebit,
            WriteBData    => GND_dwidth,
            ReadBData     => lTxPacketData
        );
end architecture rtl;
