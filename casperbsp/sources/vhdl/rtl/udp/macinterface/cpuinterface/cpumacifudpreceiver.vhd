--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : cpumacifudpreceiver - rtl                                -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The cpumacifudpreceiver module receives UDP/IP data from -
--                    the CPU interface.It uses RX 2K ringbuffers.             -
-- Dependencies     : macifudpreceiver                                         -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpumacifudpreceiver is
    generic(
        G_SLOT_WIDTH         : natural := 4;
        G_AXIS_DATA_WIDTH    : natural := 512;
        -- The address width is log2(2048/8))=11 bits wide
        G_ADDR_WIDTH         : natural := 11
    );
    port(
        axis_clk                       : in  STD_LOGIC;
        aximm_clk                      : in  STD_LOGIC;
        axis_reset                     : in  STD_LOGIC;
        -- Setup information
        reg_mac_address                : in  STD_LOGIC_VECTOR(47 downto 0);
        reg_udp_port                   : in  STD_LOGIC_VECTOR(15 downto 0);
        reg_udp_port_mask              : in  STD_LOGIC_VECTOR(15 downto 0);
        reg_promiscous_mode            : in  STD_LOGIC;
        reg_local_ip_address           : in  STD_LOGIC_VECTOR(31 downto 0);
        -- Packet Readout in addressed bus format
        data_read_enable               : in  STD_LOGIC;
        data_read_data                 : out STD_LOGIC_VECTOR(7 downto 0);
        -- The Byte Enable is as follows
        -- Bit (0) Byte Enables
        -- Bit (1) Maps to TLAST (To terminate the data stream).		
        data_read_byte_enable          : out STD_LOGIC_VECTOR(1 downto 0);
        data_read_address              : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        ringbuffer_slot_id             : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        ringbuffer_slot_clear          : in  STD_LOGIC;
        ringbuffer_slot_status         : out STD_LOGIC;
        ringbuffer_number_slots_filled : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        --Inputs from AXIS bus of the MAC side
        axis_rx_tdata                  : in  STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
        axis_rx_tvalid                 : in  STD_LOGIC;
        axis_rx_tuser                  : in  STD_LOGIC;
        axis_rx_tkeep                  : in  STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
        axis_rx_tlast                  : in  STD_LOGIC
    );
end entity cpumacifudpreceiver;

architecture rtl of cpumacifudpreceiver is
    constant    G_CPU_DATA_WIDTH     : natural := 8;
    constant    G_INGRESS_ADDR_WIDTH : natural := 5;

    component cpumacifethernetreceiver is
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
            axis_clk               : in  STD_LOGIC;
            axis_reset             : in  STD_LOGIC;
            -- Local Server port range mask
            ServerPortRange        : in  STD_LOGIC_VECTOR(15 downto 0);
            -- Setup information
            ReceiverMACAddress     : in  STD_LOGIC_VECTOR(47 downto 0);
            ReceiverIPAddress      : in  STD_LOGIC_VECTOR(31 downto 0);
            ReceiverPromiscousMode : in  STD_LOGIC;
            -- Packet Readout in addressed bus format
            RingBufferSlotID       : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotSet      : out STD_LOGIC;
            RingBufferDataWrite    : out STD_LOGIC;
            -- Enable[0] is a special bit (we assume always 1 when packet is valid)
            -- we use it to save TLAST
            RingBufferDataEnable   : out STD_LOGIC_VECTOR(63 downto 0);
            RingBufferDataOut      : out STD_LOGIC_VECTOR(511 downto 0);
            RingBufferAddress      : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            --Inputs from AXIS bus of the MAC side
            axis_rx_tdata          : in  STD_LOGIC_VECTOR(511 downto 0);
            axis_rx_tvalid         : in  STD_LOGIC;
            axis_rx_tuser          : in  STD_LOGIC;
            axis_rx_tkeep          : in  STD_LOGIC_VECTOR(63 downto 0);
            axis_rx_tlast          : in  STD_LOGIC
        );
    end component cpumacifethernetreceiver;

    -- TODO
    -- Watch out for enable signals and TLAST as this maybe skewed during resize
    -- TODO
    -- Simulate enable TLAST resize mapping.
    component cpuifreceiverpacketringbuffer is
        generic(
            G_SLOT_WIDTH  : natural := 4;
            constant G_RX_ADDR_WIDTH : natural := 5;
            constant G_TX_ADDR_WIDTH : natural := 11;
            constant G_RX_DATA_WIDTH : natural := 512;
            constant G_TX_DATA_WIDTH : natural := 8            
            );
        port(
            RxClk                  : in  STD_LOGIC;
            TxClk                  : in  STD_LOGIC;
            Reset                  : in  STD_LOGIC;
            -- Reception port
            RxPacketByteEnable     : in  STD_LOGIC_VECTOR((G_RX_DATA_WIDTH / 8) - 1 downto 0);
            RxPacketDataWrite      : in  STD_LOGIC;
            RxPacketData           : in  STD_LOGIC_VECTOR(G_RX_DATA_WIDTH - 1 downto 0);
            RxPacketAddress        : in  STD_LOGIC_VECTOR(G_RX_ADDR_WIDTH - 1 downto 0);
            RxPacketSlotSet        : in  STD_LOGIC;
            RxPacketSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RxPacketSlotStatus     : out STD_LOGIC;
            -- Transmission port
            TxPacketReadByteEnable : out STD_LOGIC_VECTOR((G_TX_DATA_WIDTH / 8) downto 0);
            TxPacketDataOut        : out STD_LOGIC_VECTOR(G_TX_DATA_WIDTH - 1 downto 0);
            TxPacketReadAddress    : in  STD_LOGIC_VECTOR(G_TX_ADDR_WIDTH - 1 downto 0);
            TxPacketDataRead       : in  STD_LOGIC;
            TxPacketSlotClear      : in  STD_LOGIC;
            TxPacketSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            TxPacketSlotStatus     : out STD_LOGIC
        );
        end component cpuifreceiverpacketringbuffer;
--    component ila_cpu_rx is
--        port(
--            clk    : in STD_LOGIC;
--            probe0 : in STD_LOGIC_VECTOR(0 to 0);
--            probe1 : in STD_LOGIC_VECTOR(7 downto 0);
--            probe2 : in STD_LOGIC_VECTOR(1 downto 0);
--            probe3 : in STD_LOGIC_VECTOR(10 downto 0);
--            probe4 : in STD_LOGIC_VECTOR(3 downto 0);
--            probe5 : in STD_LOGIC_VECTOR(0 to 0);
--            probe6 : in STD_LOGIC_VECTOR(0 to 0);
--            probe7 : in STD_LOGIC_VECTOR(3 downto 0);
--            probe8 : in STD_LOGIC_VECTOR(3 downto 0);
--            probe9 : in STD_LOGIC_VECTOR(0 downto 0);
--            probe10 : in STD_LOGIC_VECTOR(0 downto 0);
--            probe11 : in STD_LOGIC_VECTOR(63 downto 0);
--            probe12 : in STD_LOGIC_VECTOR(511 downto 0);
--            probe13 : in STD_LOGIC_VECTOR(4 downto 0);
--            probe14 : in STD_LOGIC_VECTOR(0 downto 0);
--            probe15 : in STD_LOGIC_VECTOR(0 downto 0);
--            probe16 : in STD_LOGIC_VECTOR(3 downto 0);
--            probe17 : in STD_LOGIC_VECTOR(3 downto 0)
--        );
--    end component ila_cpu_rx;    

    signal IngressRingBufferDataEnable : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
    signal IngressRingBufferDataWrite  : STD_LOGIC;
    signal IngressRingBufferDataOut    : STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
    signal IngressRingBufferAddress    : STD_LOGIC_VECTOR(G_INGRESS_ADDR_WIDTH  - 1 downto 0);
    signal IngressRingBufferSlotSet    : STD_LOGIC;
    signal IngressRingBufferSlotID     : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal IngressRingBufferSlotStatus : STD_LOGIC;
    signal lFilledSlots                : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotClearBuffer            : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotClear                  : STD_LOGIC;
    signal lSlotSetBuffer              : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotSet                    : STD_LOGIC;
    --Debug
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
            else
                lSlotSetBuffer   <= lSlotSetBuffer(G_SLOT_WIDTH - 2 downto 0) & IngressRingBufferSlotSet;
                lSlotClearBuffer <= lSlotClearBuffer(G_SLOT_WIDTH - 2 downto 0) & ringbuffer_slot_clear;
                -- Slot clear is late processed
                if (lSlotClearBuffer = b"0001") then
                    lSlotClear <= '1';
                else
                    lSlotClear <= '0';
                end if;
                -- Slot set is early processed
                if (lSlotSetBuffer = b"0001") then
                    lSlotSet <= '1';
                else
                    lSlotSet <= '0';
                end if;

            end if;
        end if;
    end process SlotSetClearProc;

    --Generate the number of slots filled using the axis_clk
    --Synchronize it with the slow Ingress slot set
    -- Send the number of slots filled to the CPU for status update
    ringbuffer_number_slots_filled <= std_logic_vector(lFilledSlots);

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

    RXCPURBi : cpuifreceiverpacketringbuffer
        generic map(
            G_SLOT_WIDTH  => G_SLOT_WIDTH,
            G_TX_ADDR_WIDTH => G_ADDR_WIDTH,
            G_RX_ADDR_WIDTH => G_INGRESS_ADDR_WIDTH,
            G_TX_DATA_WIDTH => G_CPU_DATA_WIDTH,
            G_RX_DATA_WIDTH => G_AXIS_DATA_WIDTH
        )
        port map(
            TxClk                  => aximm_clk,
            RxClk                  => axis_clk,
            Reset                  => axis_reset,
            RxPacketByteEnable     => IngressRingBufferDataEnable,
            RxPacketDataWrite      => IngressRingBufferDataWrite,
            RxPacketData           => IngressRingBufferDataOut,
            RxPacketAddress        => IngressRingBufferAddress,
            RxPacketSlotSet        => IngressRingBufferSlotSet,
            RxPacketSlotID         => IngressRingBufferSlotID,
            RxPacketSlotStatus     => IngressRingBufferSlotStatus,
            -- Transmission port   => data_write_address,
            TxPacketReadByteEnable => ldata_read_byte_enable,
            TxPacketDataOut        => ldata_read_data,
            TxPacketReadAddress    => data_read_address,
            TxPacketDataRead       => data_read_enable,
            TxPacketSlotClear      => ringbuffer_slot_clear,
            TxPacketSlotID         => ringbuffer_slot_id,
            TxPacketSlotStatus     => lringbuffer_slot_status
        );

    RXRECEIVERi : cpumacifethernetreceiver
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_INGRESS_ADDR_WIDTH
        )
        port map(
            axis_clk               => axis_clk,
            axis_reset             => axis_reset,
            ServerPortRange        => reg_udp_port_mask,
            ReceiverMACAddress     => reg_mac_address,
            ReceiverIPAddress      => reg_local_ip_address,
            ReceiverPromiscousMode => reg_promiscous_mode,
            RingBufferSlotID       => IngressRingBufferSlotID,
            RingBufferSlotSet      => IngressRingBufferSlotSet,
            RingBufferDataWrite    => IngressRingBufferDataWrite,
            RingBufferDataEnable   => IngressRingBufferDataEnable,
            RingBufferDataOut      => IngressRingBufferDataOut,
            RingBufferAddress      => IngressRingBufferAddress,
            axis_rx_tdata          => axis_rx_tdata,
            axis_rx_tvalid         => axis_rx_tvalid,
            axis_rx_tuser          => axis_rx_tuser,
            axis_rx_tkeep          => axis_rx_tkeep,
            axis_rx_tlast          => axis_rx_tlast
        );

--        CPURXILAi : ila_cpu_rx
--            port map(
--                clk       => axis_clk,
--                probe0(0) => data_read_enable,
--                probe1    => ldata_read_data,
--                probe2    => ldata_read_byte_enable,
--                probe3    => data_read_address,
--                probe4    => ringbuffer_slot_id,
--                probe5(0) => ringbuffer_slot_clear,
--                probe6(0) => lringbuffer_slot_status,
--                probe7    => std_logic_vector(lFilledSlots),
--                probe8    => IngressRingBufferSlotID,
--                probe9(0) => IngressRingBufferSlotSet,
--                probe10(0)=> IngressRingBufferDataWrite,
--                probe11   => IngressRingBufferDataEnable,
--                probe12   => IngressRingBufferDataOut,
--                probe13   => IngressRingBufferAddress,
--                probe14(0)=> lSlotClear,
--                probe15(0)=> lSlotSet,                            
--                probe16   => lSlotClearBuffer,
--                probe17   => lSlotSetBuffer                            
--                );        
end architecture rtl;
