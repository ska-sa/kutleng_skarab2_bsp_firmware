--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : macaxisreceiver - rtl                                    -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The macaxisreceiver module receives axis data streams,   -
--                    from a the AXI-Stream interface and writes them to a     -
--                    packetringbuffer.                                        -
--                    respective addressing and header information.            -
--                                                                             -
-- Dependencies     : packetringbuffer                                         -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity macaxisreceiver is
    generic(
        G_SLOT_WIDTH : natural := 4;
        -- For normal maximum ethernet frame packet size = ceil(1522)=2048 Bytes 
        -- The address width is log2(2048/(512/8))=5 bits wide
        -- 1 x (16KBRAM) per slot = 1 x 4 = 4 (16K BRAMS)/ 2 (32K BRAMS)   
        G_ADDR_WIDTH : natural := 5
        -- For 9600 Jumbo ethernet frame packet size = ceil(9600)=16384 Bytes 
        -- The address width is log2(16384/(512/8))=8 bits wide
        -- 64 x (16KBRAM) per slot = 32 x 4 = 128 (32K BRAMS)! 
        -- G_ADDR_WIDTH      : natural                          := 5
    );
    port(
        axis_ringbuffer_clk      : in  STD_LOGIC;
        axis_rx_clk              : in  STD_LOGIC;
        axis_reset               : in  STD_LOGIC;
        --        DataRateBackOff          : out STD_LOGIC;        
        -- MAC Statistics
        RXOverFlowCount          : out STD_LOGIC_VECTOR(31 downto 0);
        RXAlmostFullCount        : out STD_LOGIC_VECTOR(31 downto 0);
        -- Packet Readout in addressed bus format
        RingBufferSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        RingBufferSlotClear      : in  STD_LOGIC;
        RingBufferSlotStatus     : out STD_LOGIC;
        RingBufferSlotTypeStatus : out STD_LOGIC;
        RingBufferDataRead       : in  STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        RingBufferDataEnable     : out STD_LOGIC_VECTOR(63 downto 0);
        RingBufferDataOut        : out STD_LOGIC_VECTOR(511 downto 0);
        RingBufferAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        --Inputs from AXIS bus upstream burst interface
        axis_rx_tdata            : in  STD_LOGIC_VECTOR(511 downto 0);
        axis_rx_tvalid           : in  STD_LOGIC;
        axis_rx_tuser            : in  STD_LOGIC;
        axis_rx_tready           : out STD_LOGIC;
        axis_rx_tkeep            : in  STD_LOGIC_VECTOR(63 downto 0);
        axis_rx_tlast            : in  STD_LOGIC
    );
end entity macaxisreceiver;

architecture rtl of macaxisreceiver is

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

    type AxisReaderSM_t is (
        InitialiseSt,                   -- On the reset state
        ProcessPacketSt                 -- Packet Processing (Accepts Packets 64 bytes and more)
    );
    signal StateVariable          : AxisReaderSM_t                      := InitialiseSt;
    constant G_FILLED_SLOTS_MAX   : unsigned(G_SLOT_WIDTH - 1 downto 0) := (others => '1');
    constant G_FILLED_SLOTS_AFULL : unsigned(G_SLOT_WIDTH - 1 downto 0) := (G_FILLED_SLOTS_MAX / 2) + (G_FILLED_SLOTS_MAX / 4);
    signal lPacketByteEnable      : std_logic_vector(RingBufferDataEnable'length - 1 downto 0);
    signal lPacketDataWrite       : std_logic;
    signal lPacketData            : std_logic_vector(RingBufferDataOut'length - 1 downto 0);
    signal lPacketAddressCounter  : unsigned(RingBufferAddress'length - 1 downto 0);
    signal lPacketAddress         : unsigned(RingBufferAddress'length - 1 downto 0);
    signal lPacketSlotSet         : std_logic;
    signal lPacketSlotType        : std_logic;
    signal lPacketSlotID          : unsigned(RingBufferSlotID'length - 1 downto 0);
    signal lInPacket              : std_logic;
    signal lFilledSlots           : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotClearBuffer       : STD_LOGIC_VECTOR(1 downto 0);
    signal lSlotClear             : STD_LOGIC;
    signal lSlotSetBuffer         : STD_LOGIC_VECTOR(1 downto 0);
    signal lSlotSet               : STD_LOGIC;
    signal OverFlowCount          : unsigned(31 downto 0);
    signal AlmostFullCount        : unsigned(31 downto 0);

begin
    RXOverFlowCount   <= std_logic_vector(OverFlowCount);
    RXAlmostFullCount <= std_logic_vector(AlmostFullCount);
    --These slot clear and set operations are assynchronous and must have CDC.
    SlotSetClearProc : process(axis_ringbuffer_clk)
    begin
        if rising_edge(axis_ringbuffer_clk) then
            if (axis_reset = '1') then
                lSlotClear <= '0';
                lSlotSet   <= '0';
            else
                lSlotClearBuffer <= lSlotClearBuffer(0) & RingBufferSlotClear;
                lSlotSetBuffer   <= lSlotSetBuffer(0) & lPacketSlotSet;
                -- Slot clear is late processed
                if (lSlotClearBuffer = B"10") then
                    lSlotClear <= '1';
                else
                    lSlotClear <= '0';
                end if;
                -- Slot set is early processed
                if (lSlotSetBuffer = B"01") then
                    lSlotSet <= '1';
                else
                    lSlotSet <= '0';
                end if;

            end if;
        end if;
    end process SlotSetClearProc;

    FilledSlotCounterProc : process(axis_ringbuffer_clk)
    begin
        if rising_edge(axis_ringbuffer_clk) then
            if (axis_reset = '1') then
                lFilledSlots    <= (others => '0');
                OverFlowCount   <= (others => '0');
                AlmostFullCount <= (others => '0');
            else

                if ((lSlotClear = '0') and (lSlotSet = '1')) then
                    if (lFilledSlots /= G_FILLED_SLOTS_MAX) then
                        lFilledSlots <= lFilledSlots + 1;
                    end if;
                    if (lFilledSlots = G_FILLED_SLOTS_MAX) then
                        OverFlowCount <= OverFlowCount + 1;
                    end if;
                    if (lFilledSlots = G_FILLED_SLOTS_AFULL) then
                        AlmostFullCount <= AlmostFullCount + 1;
                    end if;
                elsif ((lSlotClear = '1') and (lSlotSet = '0')) then
                    if (lFilledSlots /= 0) then
                        lFilledSlots <= lFilledSlots - 1;
                    end if;
                else
                    -- Its a neutral operation
                    lFilledSlots <= lFilledSlots;
                end if;
            end if;
        end if;
    end process FilledSlotCounterProc;

    PacketBuffer_i : dualportpacketringbuffer
        generic map(
            G_SLOT_WIDTH => RingBufferSlotID'length,
            G_ADDR_WIDTH => RingBufferAddress'length,
            G_DATA_WIDTH => RingBufferDataOut'length
        )
        port map(
            RxClk                  => axis_rx_clk,
            TxClk                  => axis_ringbuffer_clk,
            -- Transmission port
            TxPacketByteEnable     => RingBufferDataEnable,
            TxPacketDataRead       => RingBufferDataRead,
            TxPacketData           => RingBufferDataOut,
            TxPacketAddress        => RingBufferAddress,
            TxPacketSlotClear      => RingBufferSlotClear,
            TxPacketSlotID         => RingBufferSlotID,
            TxPacketSlotStatus     => RingBufferSlotStatus,
            TxPacketSlotTypeStatus => RingBufferSlotTypeStatus,
            RxPacketByteEnable     => lPacketByteEnable,
            RxPacketDataWrite      => lPacketDataWrite,
            RxPacketData           => lPacketData,
            RxPacketAddress        => std_logic_vector(lPacketAddress),
            RxPacketSlotSet        => lPacketSlotSet,
            RxPacketSlotID         => std_logic_vector(lPacketSlotID),
            RxPacketSlotType       => lPacketSlotType,
            RxPacketSlotStatus     => open,
            RxPacketSlotTypeStatus => open
        );

    SynchStateProc : process(axis_rx_clk)
    begin
        if rising_edge(axis_rx_clk) then
            if (axis_reset = '1') then
                -- Initialize SM on reset
                StateVariable  <= InitialiseSt;
                -- Always start by saying system is ready to accept data
                axis_rx_tready <= '1';
            else
                if (axis_rx_tlast = '1') then
                    if (lFilledSlots = (G_FILLED_SLOTS_MAX - 1)) then
                        -- When all slots are filled then signal upstream no more
                        -- slots left.
                        axis_rx_tready <= '0';
                    else
                        -- Signal ready when slots are still open
                        axis_rx_tready <= '1';
                    end if;
                else
                    if (lFilledSlots < G_FILLED_SLOTS_AFULL) then
                        -- Signal ready when slots have opened up
                        axis_rx_tready <= '1';
                    end if;
                end if;
                case (StateVariable) is
                    when InitialiseSt =>

                        -- Wait for packet after initialization
                        StateVariable         <= ProcessPacketSt;
                        lPacketAddressCounter <= (others => '0');
                        lPacketAddress        <= (others => '0');
                        lPacketSlotID         <= (others => '0');
                        lPacketDataWrite      <= '0';
                        lInPacket             <= '0';

                    when ProcessPacketSt =>
                        lPacketAddress <= lPacketAddressCounter;
                        if (lPacketSlotSet = '1') then
                            -- If the previous slot was set then point to next slot.
                            lPacketSlotID <= unsigned(lPacketSlotID) + 1;
                        end if;

                        if ((lInPacket = '1') or -- Already processing a packet
                                (       -- First Time processing a packet or 64 byte packet
                                    (lInPacket = '0') and -- First Time processing a packet or 64 byte packet 
                                    (   -- First Time processing a packet or 64 byte packet
                                        (axis_rx_tvalid = '1') and -- Check the valid
                                        (axis_rx_tuser /= '1')
                                    )   -- First Time processing a packet or 64 byte packet
                                )       -- First Time processing a packet or 64 byte packet 
                               ) then
                            -- Write the packet by passing the tvalid signal
                            lPacketDataWrite <= axis_rx_tvalid;
                            --Send the ARP Response
                            -- Pass all data
                            lPacketData      <= axis_rx_tdata;
                            --  Save the packet for processing
                            if ((axis_rx_tlast = '1') and (axis_rx_tvalid = '1')) then
                                -- This is the very last 64 byte packet data
                                -- Go to next slot
                                lPacketSlotType                <= axis_rx_tvalid;
                                if (axis_rx_tuser = '1') then
                                    -- There was an error
                                    StateVariable <= InitialiseSt;
                                else
                                    StateVariable <= ProcessPacketSt;
                                end if;
                                -- If this is the last segment then restart the packet address
                                lInPacket                      <= '0';
                                lPacketSlotSet                 <= '1';
                                --
                                lPacketAddressCounter          <= (others => '0');
                                lPacketByteEnable(0)           <= '1';
                                lPacketByteEnable(63 downto 1) <= axis_rx_tkeep(63 downto 1);
                            else
                                -- This is a longer than 64 byte packet
                                lInPacket                      <= '1';
                                -- tkeep(0) is always 1 when writing data is valid 
                                lPacketByteEnable(0)           <= '0';
                                lPacketByteEnable(63 downto 1) <= axis_rx_tkeep(63 downto 1);
                                if (axis_rx_tvalid = '1') then
                                    lPacketAddressCounter <= unsigned(lPacketAddressCounter) + 1;
                                end if;
                                lPacketSlotSet                 <= '0';
                                -- Keep processing packets
                                StateVariable                  <= ProcessPacketSt;
                            end if;
                        else
                            lPacketDataWrite <= '0';
                            lPacketSlotType  <= '0';
                            lPacketSlotSet   <= '0';

                        end if;

                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process SynchStateProc;

end architecture rtl;
