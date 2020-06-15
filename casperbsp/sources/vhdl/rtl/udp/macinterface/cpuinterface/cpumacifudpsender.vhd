--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : cpumacifudpsender - rtl                                  -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The cpumacifudpsender module sends UDP/IP data from the  -
--                    CPU interface.It uses TX and 2K ringbuffers.             -
-- Dependencies     : cpumacifudpsender                                        -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpumacifudpsender is
    generic(
        G_SLOT_WIDTH      : natural := 4;
        G_AXIS_DATA_WIDTH : natural := 512;
        G_CPU_DATA_WIDTH  : natural := 8;
        -- The address width is log2(2048/8))=11 bits wide
        G_ADDR_WIDTH      : natural := 11
    );
    port(
        axis_clk                       : in  STD_LOGIC;
        aximm_clk                      : in  STD_LOGIC;
        axis_reset                     : in  STD_LOGIC;
        -- Packet Write in addressed bus format
        -- Packet Readout in addressed bus format
        data_write_enable              : in  STD_LOGIC;
        data_read_enable               : in  STD_LOGIC;
        data_write_data                : in  STD_LOGIC_VECTOR(G_CPU_DATA_WIDTH - 1 downto 0);
        -- The Byte Enable is as follows
        -- Bit (0) Byte Enables when it is '1' else
        -- Bit (1) Maps to TLAST (To terminate the data stream when it becomes '0').
        data_write_byte_enable         : in  STD_LOGIC_VECTOR((G_CPU_DATA_WIDTH / 8) downto 0);
        data_read_data                 : out STD_LOGIC_VECTOR(G_CPU_DATA_WIDTH - 1 downto 0);
        -- The Byte Enable is as follows
        -- Bit (0) Byte Enables when it is '1' else
        -- Bit (1) Maps to TLAST (To terminate the data stream when it becomes '0').
        data_read_byte_enable          : out STD_LOGIC_VECTOR((G_CPU_DATA_WIDTH / 8) downto 0);
        data_write_address             : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        data_read_address              : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        ringbuffer_slot_set            : in  STD_LOGIC;
        ringbuffer_slot_status         : out STD_LOGIC;
        ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        --Inputs from AXIS bus of the MAC side
        --Outputs to AXIS bus MAC side 
        axis_tx_tpriority              : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        axis_tx_tdata                  : out STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
        axis_tx_tvalid                 : out STD_LOGIC;
        axis_tx_tready                 : in  STD_LOGIC;
        axis_tx_tkeep                  : out STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
        axis_tx_tlast                  : out STD_LOGIC
    );
end entity cpumacifudpsender;

architecture rtl of cpumacifudpsender is
    -- TODO
    -- Watch out for enable signals and TLAST as this maybe skewed during resize
    -- TODO
    -- Simulate enable TLAST resize mapping.
    component cpuifsenderpacketringbuffer is
    generic(
        G_SLOT_WIDTH             : natural := 4;
        constant G_RX_ADDR_WIDTH : natural := 11;
        constant G_TX_ADDR_WIDTH : natural := 5;
        constant G_RX_DATA_WIDTH : natural := 8;
        constant G_TX_DATA_WIDTH : natural := 512
    );
    port(
        RxClk                  : in  STD_LOGIC;
        TxClk                  : in  STD_LOGIC;
        Reset                  : in  STD_LOGIC; 
        -- Transmission port
        TxPacketByteEnable     : out STD_LOGIC_VECTOR((G_TX_DATA_WIDTH / 8) - 1 downto 0);
        TxPacketDataRead       : in  STD_LOGIC;
        TxPacketData           : out STD_LOGIC_VECTOR(G_TX_DATA_WIDTH - 1 downto 0);
        TxPacketAddress        : in  STD_LOGIC_VECTOR(G_TX_ADDR_WIDTH - 1 downto 0);
        TxPacketSlotClear      : in  STD_LOGIC;
        TxPacketSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        TxPacketSlotStatus     : out STD_LOGIC;
        -- Reception port
        RxPacketByteEnable     : in  STD_LOGIC_VECTOR((G_RX_DATA_WIDTH / 8) downto 0);
        RxPacketData           : in  STD_LOGIC_VECTOR(G_RX_DATA_WIDTH - 1 downto 0);
        RxPacketAddress        : in  STD_LOGIC_VECTOR(G_RX_ADDR_WIDTH - 1 downto 0);
        RxPacketDataWrite      : in  STD_LOGIC;
        RxPacketReadByteEnable : out STD_LOGIC_VECTOR((G_RX_DATA_WIDTH / 8) downto 0);
        RxPacketDataRead       : in  STD_LOGIC;
        RxPacketDataOut        : out STD_LOGIC_VECTOR(G_RX_DATA_WIDTH - 1 downto 0);
        RxPacketReadAddress    : in  STD_LOGIC_VECTOR(G_RX_ADDR_WIDTH - 1 downto 0);
        RxPacketSlotSet        : in  STD_LOGIC;
        RxPacketSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        RxPacketSlotStatus     : out STD_LOGIC
    );
    end component cpuifsenderpacketringbuffer;

    component macifudpsender is
        generic(
            G_SLOT_WIDTH : natural := 4;
            --G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
            -- The address width is log2(2048/(512/8))=5 bits wide
            G_ADDR_WIDTH : natural := 5
        );
        port(
            axis_clk                 : in  STD_LOGIC;
            axis_reset               : in  STD_LOGIC;
            -- Setup information
            -- Packet Write in addressed bus format
            -- Packet Readout in addressed bus format
            RingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotClear      : out STD_LOGIC;
            RingBufferSlotStatus     : in  STD_LOGIC;
            RingBufferSlotTypeStatus : in  STD_LOGIC;
            RingBufferSlotsFilled    : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferDataRead       : out STD_LOGIC;
            -- Enable[0] is a special bit (we assume always 1 when packet is valid)
            -- we use it to save TLAST
            RingBufferDataEnable     : in  STD_LOGIC_VECTOR(63 downto 0);
            RingBufferDataIn         : in  STD_LOGIC_VECTOR(511 downto 0);
            RingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            --Inputs from AXIS bus of the MAC side
            --Outputs to AXIS bus MAC side 
            axis_tx_tpriority        : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            axis_tx_tdata            : out STD_LOGIC_VECTOR(511 downto 0);
            axis_tx_tvalid           : out STD_LOGIC;
            axis_tx_tready           : in  STD_LOGIC;
            axis_tx_tkeep            : out STD_LOGIC_VECTOR(63 downto 0);
            axis_tx_tlast            : out STD_LOGIC
        );
    end component macifudpsender;
    -- The egress width is 5 less the ingress width
    -- For normal MTU of 2048 ingress width = 10 (1024* 2 (16 bits))
    -- egress width  = 5 (32 * 64 (512 bits))
    constant G_EGRESS_ADDR_WIDTH          : NATURAL := (G_ADDR_WIDTH - 6);
    signal EgressRingBufferSlotID         : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal EgressRingBufferSlotClear      : STD_LOGIC;
    signal EgressRingBufferSlotStatus     : STD_LOGIC;
    signal EgressRingBufferSlotTypeStatus : STD_LOGIC;
    signal EgressRingBufferSlotsFilled    : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal EgressRingBufferDataRead       : STD_LOGIC;
    signal EgressRingBufferDataEnable     : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
    signal EgressRingBufferDataIn         : STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
    signal EgressRingBufferAddress        : STD_LOGIC_VECTOR(G_EGRESS_ADDR_WIDTH - 1 downto 0);
    signal lFilledSlots                   : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotClearBuffer               : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotClear                     : STD_LOGIC;
    signal lSlotSetBuffer                 : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotSet                       : STD_LOGIC;
--    component ila_cpu_tx is
--        port(
--            clk     : in STD_LOGIC;
--            probe0  : in STD_LOGIC_VECTOR(0 to 0);
--            probe1  : in STD_LOGIC_VECTOR(0 to 0);
--            probe2  : in STD_LOGIC_VECTOR(7 downto 0);
--            probe3  : in STD_LOGIC_VECTOR(1 downto 0);
--            probe4  : in STD_LOGIC_VECTOR(7 downto 0);
--            probe5  : in STD_LOGIC_VECTOR(1 downto 0);
--            probe6  : in STD_LOGIC_VECTOR(10 downto 0);
--            probe7  : in STD_LOGIC_VECTOR(10 downto 0);
--            probe8  : in STD_LOGIC_VECTOR(3 downto 0);
--            probe9  : in STD_LOGIC_VECTOR(0 to 0);
--            probe10 : in STD_LOGIC_VECTOR(0 to 0);
--            probe11 : in STD_LOGIC_VECTOR(3 downto 0);
--            probe12 : in STD_LOGIC_VECTOR(63 downto 0);
--            probe13 : in STD_LOGIC_VECTOR(0 downto 0);
--           probe14 : in STD_LOGIC_VECTOR(511 downto 0);
--            probe15 : in STD_LOGIC_VECTOR(4 downto 0);
--            probe16 : in STD_LOGIC_VECTOR(0 downto 0);
--            probe17 : in STD_LOGIC_VECTOR(3 downto 0);
--            probe18 : in STD_LOGIC_VECTOR(0 downto 0);
--            probe19 : in STD_LOGIC_VECTOR(0 downto 0);
--            probe20 : in STD_LOGIC_VECTOR(0 downto 0);
--            probe21 : in STD_LOGIC_VECTOR(3 downto 0);
--            probe22 : in STD_LOGIC_VECTOR(3 downto 0)
--        );
--    end component ila_cpu_tx;
           

    signal ldata_read_data             : STD_LOGIC_VECTOR(7 downto 0);
    signal ldata_read_byte_enable      : STD_LOGIC_VECTOR(1 downto 0);
    signal lringbuffer_slot_status     : STD_LOGIC;
begin
data_read_data <= ldata_read_data;
data_read_byte_enable <= ldata_read_byte_enable;
ringbuffer_slot_status <= lringbuffer_slot_status;
    --These slot clear and set operations are slow and must be spaced atleast
    -- 8 clock cycles apart for a conflict not to exist
    -- As these are controlled by the CPU this is not a problem
    SlotSetClearProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                lSlotClear <= '0';
                lSlotSet   <= '0';
		lSlotClearBuffer <= (others => '0');
		lSlotSetBuffer <= (others => '0');
            else
                lSlotClearBuffer <= lSlotClearBuffer(G_SLOT_WIDTH - 2 downto 0) & EgressRingBufferSlotClear;
                lSlotSetBuffer   <= lSlotSetBuffer(G_SLOT_WIDTH - 2 downto 0) & ringbuffer_slot_set;
                -- Slot clear is early processed
                if (lSlotClearBuffer = B"0001") then
                    lSlotClear <= '1';
                else
                    lSlotClear <= '0';
                end if;
                -- Slot set is late processed
                if (lSlotSetBuffer = B"0001") then
                    lSlotSet <= '1';
                else
                    lSlotSet <= '0';
                end if;

            end if;
        end if;
    end process SlotSetClearProc;

    --Generate the number of slots filled using the axis_clk
    --Synchronize it with the slow Egress slot set
    -- Send the number of slots filled to the CPU for status update
    ringbuffer_number_slots_filled <= std_logic_vector(lFilledSlots);
    EgressRingBufferSlotsFilled    <= std_logic_vector(lFilledSlots);

    FilledSlotCounterProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                lFilledSlots <= (others => '0');
            else
                if ((lSlotClear = '0') and (lSlotSet = '1')) then
                    if (lFilledSlots /= X"F") then
                        lFilledSlots <= lFilledSlots + 1;
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

    TXCPURBi : cpuifsenderpacketringbuffer
        generic map(
            G_SLOT_WIDTH  => G_SLOT_WIDTH,
            G_RX_ADDR_WIDTH => G_ADDR_WIDTH,
            G_TX_ADDR_WIDTH => G_EGRESS_ADDR_WIDTH,
            G_RX_DATA_WIDTH => G_CPU_DATA_WIDTH,
            G_TX_DATA_WIDTH => G_AXIS_DATA_WIDTH
        )
        port map(
            RxClk                   => aximm_clk,
            TxClk                   => axis_clk,
            Reset                   => axis_reset,
            RxPacketReadByteEnable  => ldata_read_byte_enable,
            RxPacketDataRead        => data_read_enable,
            RxPacketDataOut         => ldata_read_data,
            RxPacketReadAddress     => data_read_address,
            RxPacketByteEnable      => data_write_byte_enable,
            RxPacketDataWrite       => data_write_enable,
            RxPacketData            => data_write_data,
            RxPacketAddress         => data_write_address,
            RxPacketSlotSet         => ringbuffer_slot_set,
            RxPacketSlotID          => ringbuffer_slot_id,
            RxPacketSlotStatus      => lringbuffer_slot_status,
            TxPacketByteEnable      => EgressRingBufferDataEnable,
            TxPacketDataRead        => EgressRingBufferDataRead,
            TxPacketData            => EgressRingBufferDataIn,
            TxPacketAddress         => EgressRingBufferAddress,
            TxPacketSlotClear       => EgressRingBufferSlotClear,
            TxPacketSlotID          => EgressRingBufferSlotID,
            TxPacketSlotStatus      => EgressRingBufferSlotStatus
        );

    TXSENDERi : macifudpsender
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_EGRESS_ADDR_WIDTH
        )
        port map(
            axis_clk                 => axis_clk,
            axis_reset               => axis_reset,
            RingBufferSlotID         => EgressRingBufferSlotID,
            RingBufferSlotClear      => EgressRingBufferSlotClear,
            RingBufferSlotStatus     => EgressRingBufferSlotStatus,
            RingBufferSlotTypeStatus => EgressRingBufferSlotTypeStatus,
            RingBufferSlotsFilled    => EgressRingBufferSlotsFilled,
            RingBufferDataRead       => EgressRingBufferDataRead,
            RingBufferDataEnable     => EgressRingBufferDataEnable,
            RingBufferDataIn         => EgressRingBufferDataIn,
            RingBufferAddress        => EgressRingBufferAddress,
            axis_tx_tpriority        => axis_tx_tpriority,
            axis_tx_tdata            => axis_tx_tdata,
            axis_tx_tvalid           => axis_tx_tvalid,
            axis_tx_tready           => axis_tx_tready,
            axis_tx_tkeep            => axis_tx_tkeep,
            axis_tx_tlast            => axis_tx_tlast
        );
        
--        CPUTXILAi : ila_cpu_tx
--            port map(
--                clk        => axis_clk,
--                probe0(0)  => data_write_enable,
--                probe1(0)  => data_read_enable,
--                probe2     => data_write_data,
--                probe3     => data_write_byte_enable,
--                probe4     => ldata_read_data,
--                probe5     => ldata_read_byte_enable,
--                probe6     => data_write_address,
--                probe7     => data_read_address,
--                probe8     => ringbuffer_slot_id,
--                probe9(0)  => ringbuffer_slot_set,
--                probe10(0) => lringbuffer_slot_status,
--                probe11    => std_logic_vector(lFilledSlots),
--                probe12    => EgressRingBufferDataEnable,
--                probe13(0) => EgressRingBufferDataRead,
--                probe14    => EgressRingBufferDataIn,
--                probe15    => EgressRingBufferAddress,
--                probe16(0) => EgressRingBufferSlotClear,
--                probe17    => EgressRingBufferSlotID,
--                probe18(0) => EgressRingBufferSlotStatus,
--                probe19(0) => lSlotSet,
--                probe20(0) => lSlotClear,                                
--                probe21    => lSlotSetBuffer,
--                probe22    => lSlotClearBuffer                                
--            );         
end architecture rtl;
