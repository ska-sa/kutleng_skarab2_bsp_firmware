--=============================================================================-
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : udpdatapacker_jh - rtl                                      -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module performs data streaming over UDP             -
--                                                                             -
-- Dependencies     : dualportpacketringbuffer                                 -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity udpdatapacker_jh is
    generic(
        G_SLOT_WIDTH      : natural := 4;  -- log2(Number of slots in the circular buffer)
        G_AXIS_DATA_WIDTH : natural := 512;
        G_ARP_CACHE_ASIZE : natural := 9;
        G_ARP_DATA_WIDTH  : natural := 32; -- The address width is log2(2048/(512/8))=5 bits wide
        G_ADDR_WIDTH      : natural := 8;  -- log2(Number of words in each circular buffer slot)
        G_INCLUDE_ILA : boolean := false
    );
    port(
        axis_clk                       : in  STD_LOGIC;
        axis_app_clk                   : in  STD_LOGIC;
        axis_reset                     : in  STD_LOGIC;
        EthernetMACAddress             : in  STD_LOGIC_VECTOR(47 downto 0);
        LocalIPAddress                 : in  STD_LOGIC_VECTOR(31 downto 0);
        LocalIPNetmask                 : in  STD_LOGIC_VECTOR(31 downto 0);
        GatewayIPAddress               : in  STD_LOGIC_VECTOR(31 downto 0);
        MulticastIPAddress             : in  STD_LOGIC_VECTOR(31 downto 0);
        MulticastIPNetmask             : in  STD_LOGIC_VECTOR(31 downto 0);
        EthernetMACEnable              : in  STD_LOGIC;
        TXOverflowCount                : out STD_LOGIC_VECTOR(31 downto 0);
        TXAFullCount                   : out STD_LOGIC_VECTOR(31 downto 0);
        ServerUDPPort                  : in  STD_LOGIC_VECTOR(15 downto 0);
        ARPReadDataEnable              : out STD_LOGIC;
        ARPReadData                    : in  STD_LOGIC_VECTOR((G_ARP_DATA_WIDTH * 2) - 1 downto 0);
        ARPReadAddress                 : out STD_LOGIC_VECTOR(G_ARP_CACHE_ASIZE - 1 downto 0);
        -- Packet Readout in addressed bus format
        SenderRingBufferSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        SenderRingBufferSlotClear      : in  STD_LOGIC;
        SenderRingBufferSlotStatus     : out STD_LOGIC;
        SenderRingBufferSlotTypeStatus : out STD_LOGIC;
        SenderRingBufferSlotsFilled    : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        SenderRingBufferDataRead       : in  STD_LOGIC;
        -- Enable[0] is a special bit (we assume always 1 when packet is valid)
        -- we use it to save TLAST
        SenderRingBufferDataEnable     : out STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
        SenderRingBufferData           : out STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
        SenderRingBufferAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
        -- 
        ClientIPAddress                : in  STD_LOGIC_VECTOR(31 downto 0);
        ClientUDPPort                  : in  STD_LOGIC_VECTOR(15 downto 0);
        --UDPPacketLength                : in  STD_LOGIC_VECTOR(15 downto 0);
        axis_tuser                     : in  STD_LOGIC;
        axis_tdata                     : in  STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
        axis_tvalid                    : in  STD_LOGIC;
        axis_tready                    : out STD_LOGIC;
        axis_tkeep                     : in  STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
        axis_tlast                     : in  STD_LOGIC
    );
end entity udpdatapacker_jh;

architecture rtl of udpdatapacker_jh is
    COMPONENT axis_data_fifo_0
      PORT (
        s_axis_aresetn : IN STD_LOGIC;
        s_axis_aclk : IN STD_LOGIC;
        s_axis_tvalid : IN STD_LOGIC;
        s_axis_tready : OUT STD_LOGIC;
        s_axis_tdata : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
        s_axis_tkeep : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
        s_axis_tlast : IN STD_LOGIC;
        s_axis_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        m_axis_aclk : IN STD_LOGIC;
        m_axis_tvalid : OUT STD_LOGIC;
        m_axis_tready : IN STD_LOGIC;
        m_axis_tdata : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
        m_axis_tkeep : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
        m_axis_tlast : OUT STD_LOGIC;
        m_axis_tuser : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
      );
    END COMPONENT;
    
    component axioffseter
    generic(
        G_AXIS_DATA_WIDTH : natural := 512;
        G_OFFSET_BYTES : natural := 42
    );
    port(
        axis_clk     : in  STD_LOGIC;
        axis_rst     : in  STD_LOGIC;
        axis_tuser   : in  STD_LOGIC;
        axis_tdata   : in  STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
        axis_tvalid  : in  STD_LOGIC;
        axis_tready  : out STD_LOGIC;
        axis_tkeep   : in  STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
        axis_tlast   : in  STD_LOGIC;

        axim_tuser   : out STD_LOGIC;
        axim_tdata   : out STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
        axim_tvalid  : out STD_LOGIC;
        axim_tready  : in  STD_LOGIC;
        axim_tkeep   : out STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
        axim_tlast   : out STD_LOGIC
    );
    end component;
    
    COMPONENT dest_address_fifo
    PORT (
        rst : IN STD_LOGIC;
        wr_clk : IN STD_LOGIC;
        rd_clk : IN STD_LOGIC;
        din : IN STD_LOGIC_VECTOR(47 DOWNTO 0);
        wr_en : IN STD_LOGIC;
        rd_en : IN STD_LOGIC;
        dout : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
        full : OUT STD_LOGIC;
        empty : OUT STD_LOGIC
    );
    END COMPONENT;
    
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

    type UDPDataPackerSM_t is (
        InitialiseSt,                   -- On the reset state
        WriteUdpPayloadFirstWordSt,
        BeginOrProcessUDPPacketStreamSt,
        WriteUdpPayloadSt,
        ComputeIPChecksumSt,
        ComputeIPChecksum2St,
        WriteHeadersSt,
        CloseBufferSt
    );
    signal StateVariable              : UDPDataPackerSM_t                   := InitialiseSt;
    constant C_DWORD_MAX              : natural                             := (16 - 1);
    constant C_FILLED_SLOT_MAX        : unsigned(G_SLOT_WIDTH - 1 downto 0) := (others => '1');
    signal C_RESPONSE_UDP_LENGTH      : std_logic_vector(15 downto 0)       := X"0012"; -- Always 8 bytes more than data size 
    signal C_RESPONSE_IPV4_LENGTH     : std_logic_vector(15 downto 0)       := X"0026"; -- Always 20 more than UDP length
    constant C_RESPONSE_ETHER_TYPE    : std_logic_vector(15 downto 0)       := X"0800";
    constant C_RESPONSE_IPV4IHL       : std_logic_vector(7 downto 0)        := X"45";
    constant C_RESPONSE_DSCPECN       : std_logic_vector(7 downto 0)        := X"00";
    constant C_RESPONSE_FLAGS_OFFSET  : std_logic_vector(15 downto 0)       := X"4000";
    constant C_RESPONSE_TIME_TO_LIVE : std_logic_vector(7 downto 0)        := X"40";
    constant C_RESPONSE_UDP_PROTOCOL  : std_logic_vector(7 downto 0)        := X"11";
    constant C_UDP_HEADER_LENGTH      : unsigned(15 downto 0)               := X"0008";
    constant C_IP_HEADER_LENGTH       : unsigned(15 downto 0)               := X"0014";
    constant C_IP_IDENTIFICATION      : std_logic_vector(15 downto 0)               := X"8411"; --X"8413";--X"8411";--X"e298";--
    
    -- Tuples registers
    signal lPacketData                : std_logic_vector(511 downto 0);
    signal lSourceMACAddress           : std_logic_vector(47 downto 0);
    signal lSourceIPAddress            : std_logic_vector(31 downto 0);
    signal lDestinationIPAddress       : std_logic_vector(31 downto 0);
    signal lDestinationUDPPort         : std_logic_vector(15 downto 0);
    signal lSourceUDPPort              : std_logic_vector(15 downto 0);
    signal lUDPCheckSum                : std_logic_vector(15 downto 0);
    signal lIPHDRCheckSum             : unsigned(16 downto 0);
    signal iIPHeaderChecksum          : std_logic_vector(15 downto 0);
    signal ServerMACAddress           : std_logic_vector(47 downto 0);
    signal lPreIPHDRCheckSum          : unsigned(17 downto 0);
    signal lServerMACAddress          : std_logic_vector(47 downto 0);
    signal lServerIPAddress           : std_logic_vector(31 downto 0);
    signal lServerUDPPort             : std_logic_vector(15 downto 0);
    signal lClientIPAddress           : std_logic_vector(31 downto 0);
    signal SourceIPAddress            : std_logic_vector(31 downto 0);
    signal DestinationIPAddress       : std_logic_vector(31 downto 0);
    signal lClientUDPPort             : std_logic_vector(15 downto 0);
    signal lProtocolErrorStatus       : std_logic;
    signal lPacketByteEnable          : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
    signal lPacketDataWrite           : STD_LOGIC;
    signal lPacketAddress             : unsigned(G_ADDR_WIDTH - 1 downto 0);
    signal lPacketSlotSet             : STD_LOGIC;
    signal lPacketSlotID              : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lDPacketSlotID             : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lPacketSlotType            : STD_LOGIC;
    signal lPacketSlotStatus          : STD_LOGIC;
    signal lPacketSlotTypeStatus      : STD_LOGIC;
    signal lDestinationIPMulticast    : std_logic;
    signal lLocalIPAddress            : std_logic_vector(31 downto 0);
    signal lLocalIPNetmask            : std_logic_vector(31 downto 0);
    signal lUDPPacketLength           : std_logic_vector(15 downto 0);
    signal lTXOverflowCount           : unsigned(31 downto 0);
    signal lTXAFullCount              : unsigned(31 downto 0);
    signal lIPChecksum19                : std_logic_vector(18 downto 0);--(16 downto 0);
    signal lIPChecksum16                : std_logic_vector(15 downto 0);
    signal lIsMulticast               : std_logic;
    
    signal axis_reset_n : std_logic;
    
    signal fifo_axis_tvalid : std_logic;
    signal fifo_axis_tready : std_logic;
    signal fifo_axis_tdata  : std_logic_vector(G_AXIS_DATA_WIDTH - 1 downto 0);
    signal fifo_axis_tkeep  : std_logic_vector((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
    signal fifo_axis_tlast  : std_logic;
    signal fifo_axis_tuser  : std_logic;
    
    signal dest_address_vld : std_logic;
    signal dest_ip_port_in : std_logic_vector(47 downto 0);
    signal dest_address_fetch : std_logic;
    signal dest_ip_port_fifo_out : std_logic_vector(47 downto 0);
    signal dest_ip_fifo_out : std_logic_vector(31 downto 0);
    signal dest_port_fifo_out : std_logic_vector(15 downto 0);

    
    signal offset_axis_tvalid : std_logic;
    signal offset_axis_tready : std_logic;
    signal offset_axis_tdata  : std_logic_vector(G_AXIS_DATA_WIDTH - 1 downto 0);
    signal offset_axis_tkeep  : std_logic_vector((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
    signal offset_axis_tlast  : std_logic;
    signal offset_axis_tuser  : std_logic;
    
    signal ip_checksum_precomp : std_logic_vector(18 downto 0);
    signal lUDPLength : unsigned(15 downto 0);
    signal lIPLength : unsigned(15 downto 0);
    
    signal lFirstWord : std_logic_vector(175 downto 0); -- store the first word so it can be written at the end.


       function byteswap(DataIn : in unsigned)
    return unsigned is
        variable RData48 : unsigned(47 downto 0);
        variable RData32 : unsigned(31 downto 0);
        variable RData24 : unsigned(23 downto 0);
        variable RData16 : unsigned(15 downto 0);
        variable RData8  : unsigned(7  downto 0);
    begin
        if (DataIn'length = RData48'length) then
            RData48(7 downto 0)   := DataIn((47 + DataIn'right) downto (40 + DataIn'right));
            RData48(15 downto 8)  := DataIn((39 + DataIn'right) downto (32 + DataIn'right));
            RData48(23 downto 16) := DataIn((31 + DataIn'right) downto (24 + DataIn'right));
            RData48(31 downto 24) := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData48(39 downto 32) := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData48(47 downto 40) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return unsigned(RData48);
        end if;
        if (DataIn'length = RData32'length) then
            RData32(7 downto 0)   := DataIn((31 + DataIn'right) downto (24 + DataIn'right));
            RData32(15 downto 8)  := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData32(23 downto 16) := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData32(31 downto 24) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return unsigned(RData32);
        end if;
        if (DataIn'length = RData24'length) then
            RData24(7 downto 0)   := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
            RData24(15 downto 8)  := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData24(23 downto 16) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return unsigned(RData24);
        end if;
        if (DataIn'length = RData16'length) then
            RData16(7 downto 0)  := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
            RData16(15 downto 8) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
            return unsigned(RData16);
        end if;
        if (DataIn'length = RData8'length) then
            return unsigned(DataIn);
        end if;
    end byteswap;

    function byteswap(DataIn : in std_logic_vector)
    return std_logic_vector is
    begin
        return std_logic_vector(byteswap(unsigned(DataIn)));    
    end byteswap;

    function log2ceil(DataIn: unsigned) return integer is
        variable n : integer := 0;
    begin
        for n in DataIn'length downto 1 loop
            if DataIn(n-1) = '1' then
                return n;
            end if;
        end loop;
        return 0;
    end function log2ceil;

    signal lFilledSlots     : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotClearBuffer : STD_LOGIC_VECTOR(1 downto 0);
    signal lSlotClear       : STD_LOGIC;
    signal lSlotSetBuffer   : STD_LOGIC_VECTOR(1 downto 0);
    signal lSlotSet         : STD_LOGIC;
    signal FixedSlotID      : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal lSlotID          : STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
    signal ClearDisable     : STD_LOGIC;
    signal lClear           : STD_LOGIC;
    signal UseFixedSlotID   : STD_LOGIC;
    signal state_val : std_logic_vector(2 downto 0);

    component vio_packer is
        port(
            clk        : in  STD_LOGIC;
            probe_out0 : out STD_LOGIC_VECTOR(0 downto 0); -- Clear disable
            probe_out1 : out STD_LOGIC_VECTOR(0 downto 0); -- Use Fixed Slot ID
            probe_out2 : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component vio_packer;

    COMPONENT ila_0
    PORT (
      clk : IN STD_LOGIC;
      probe0 : IN STD_LOGIC_VECTOR(63 DOWNTO 0); 
      probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe2 : IN STD_LOGIC_VECTOR(511 DOWNTO 0); 
      probe3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0); 
      probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
      probe5 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
      probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      probe7 : IN STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
    END COMPONENT;
begin

    -- For active low flags
    axis_reset_n <= (not axis_reset);

    -- Write the user-provided destination IP/port to internal buffersonly when the input t_last goes high
    dest_address_vld <= axis_tvalid and axis_tlast;
    -- Concatenate IP and Port for ease of FIFO-ing
    dest_ip_port_in <= ClientIPAddress & ClientUDPPort;
    -- Read destination IP/port from internal buffers whenever a word is finished coming out of the
    -- payload data extender.
    dest_address_fetch <= offset_axis_tlast and offset_axis_tvalid;
    
    -- Slice and dice ip/port for easy access;
    dest_ip_fifo_out <= dest_ip_port_fifo_out(47 downto 16);
    dest_port_fifo_out <= dest_ip_port_fifo_out(15 downto 0);

    
    data_fifo_i : axis_data_fifo_0
      PORT MAP (
        s_axis_aresetn => axis_reset_n,
        s_axis_aclk => axis_app_clk,
        s_axis_tvalid => axis_tvalid,
        s_axis_tready => axis_tready,
        s_axis_tdata => axis_tdata,
        s_axis_tkeep => axis_tkeep,
        s_axis_tlast => axis_tlast,
        s_axis_tuser(0) => axis_tuser,
        --
        m_axis_aclk => axis_clk,
        m_axis_tvalid => fifo_axis_tvalid,
        m_axis_tready => fifo_axis_tready,
        m_axis_tdata => fifo_axis_tdata,
        m_axis_tkeep => fifo_axis_tkeep,
        m_axis_tlast => fifo_axis_tlast,
        m_axis_tuser(0) => fifo_axis_tuser
      );
      
  dest_ip_port_fifo_i : dest_address_fifo
      PORT MAP (
        rst => axis_reset,
        wr_clk => axis_app_clk,
        rd_clk => axis_clk,
        din => dest_ip_port_in,
        wr_en => dest_address_vld,
        rd_en => dest_address_fetch,
        dout => dest_ip_port_fifo_out,
        full => open,
        empty => open
  );
    
    udpoffseter_i : axioffseter
      PORT MAP (
        axis_clk     => axis_clk,
        axis_rst     => axis_reset,
        axis_tuser   => fifo_axis_tuser,
        axis_tdata   => fifo_axis_tdata,
        axis_tvalid  => fifo_axis_tvalid,
        axis_tready  => fifo_axis_tready,
        axis_tkeep   => fifo_axis_tkeep,
        axis_tlast   => fifo_axis_tlast,

        axim_tuser   => offset_axis_tuser,
        axim_tdata   => offset_axis_tdata,
        axim_tvalid  => offset_axis_tvalid,
        axim_tready  => offset_axis_tready,
        axim_tkeep   => offset_axis_tkeep,
        axim_tlast   => offset_axis_tlast
    );

    ClearDisable <= '0';
    UseFixedSlotID <= '0';
    FixedSlotID <= (others => '0');
    lClear <= '0' when (ClearDisable = '1') else SenderRingBufferSlotClear;

    lSlotID <= FixedSlotID when (UseFixedSlotID = '1') else SenderRingBufferSlotID;

    TXOverflowCount <= std_logic_vector(lTXOverflowCount);
    TXAFullCount    <= std_logic_vector(lTXAFullCount);
    -- These slot clear and set operations are slow and must be spaced atleast
    -- 2 clock cycles apart for a conflict not to exist
    -- These will work well for long packets (not the case where only 64 byte packets are sent)
    SlotSetClearProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                lSlotClear <= '0';
                lSlotSet   <= '0';
            else
                lSlotSetBuffer   <= lSlotSetBuffer(1) & lPacketSlotSet;
                lSlotClearBuffer <= lSlotClearBuffer(1) & SenderRingBufferSlotClear;
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

    --Generate the number of slots filled using the axis_clk
    --Synchronize it with the slow Ingress slot set
    -- Send the number of slots filled to the CPU for status update
    SenderRingBufferSlotsFilled <= std_logic_vector(lFilledSlots);

    FilledSlotCounterProc : process(axis_clk)begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                lFilledSlots <= (others => '0');
            else
                if ((lSlotClear = '0') and (lSlotSet = '1')) then
                    if (lFilledSlots /= C_FILLED_SLOT_MAX) then
                        -- Saturating add
                        lFilledSlots <= lFilledSlots + 1;
                    end if;
                elsif ((lSlotClear = '1') and (lSlotSet = '0')) then
                    if (lFilledSlots /= 0) then
                        -- Saturating subtract
                        lFilledSlots <= lFilledSlots - 1;
                    end if;
                else
                    -- Its a neutral operation
                    lFilledSlots <= lFilledSlots;
                end if;
            end if;
        end if;
    end process FilledSlotCounterProc;

    DSRBi : dualportpacketringbuffer
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH,
            G_DATA_WIDTH => G_AXIS_DATA_WIDTH
        )
        port map(
            RxClk                  => axis_clk,
            TxClk                  => axis_clk,
            -- Transmission port
            TxPacketByteEnable     => SenderRingBufferDataEnable,
            TxPacketDataRead       => SenderRingBufferDataRead,
            TxPacketData           => SenderRingBufferData,
            TxPacketAddress        => SenderRingBufferAddress,
            TxPacketSlotClear      => lClear, --SenderRingBufferSlotClear,
            TxPacketSlotID         => lSlotID, --SenderRingBufferSlotID,
            TxPacketSlotStatus     => SenderRingBufferSlotStatus,
            TxPacketSlotTypeStatus => SenderRingBufferSlotTypeStatus,
            -- Reception port
            RxPacketByteEnable     => lPacketByteEnable,
            RxPacketDataWrite      => lPacketDataWrite,
            RxPacketData           => lPacketData,
            RxPacketAddress        => std_logic_vector(lPacketAddress),
            RxPacketSlotSet        => lPacketSlotSet,
            RxPacketSlotID         => std_logic_vector(lDPacketSlotID),
            RxPacketSlotType       => lPacketSlotType,
            RxPacketSlotStatus     => lPacketSlotStatus,
            RxPacketSlotTypeStatus => lPacketSlotTypeStatus
        );
        
    ila_gen: if G_INCLUDE_ILA = true generate
        ringbuf_ila_i : ila_0
            PORT MAP (
                clk => axis_clk,
                probe0 => lPacketByteEnable, 
                probe1(0) => lPacketDataWrite, 
                probe2 => lPacketData, 
                probe3 => std_logic_vector(lPacketAddress), 
                probe4(0) => lPacketSlotSet, 
                probe5 => std_logic_vector(lDPacketSlotID), 
                probe6(0) => lPacketSlotType,
                probe7 => state_val
            );
  
        ringbuf_ila2_i : ila_0
            PORT MAP (
                clk => axis_clk,
                probe0 => (others => '0'), 
                probe1(0) => lPacketDataWrite, 
                probe2 => (others => '0'), 
                probe3 => std_logic_vector(lPacketAddress), 
                probe4(0) => lPacketSlotStatus, 
                probe5 => std_logic_vector(lDPacketSlotID), 
                probe6(0) => lPacketSlotTypeStatus,
                probe7 => (others => '0')
            );
  
        ringbuf_txila_i : ila_0
            PORT MAP (
                clk => axis_clk,
                probe0(15 downto 0) => std_logic_vector(lUDPLength),
                probe0(63 downto 16) => (others => '0'),
                probe1(0) => lClear, 
                probe2 => (others => '0'), 
                probe3 => SenderRingBufferAddress, 
                probe4(0) => lPacketSlotSet, 
                probe5 => lSlotID, 
                probe6(0) => SenderRingBufferDataRead,
                probe7 => (others => '0')
            );
    end generate ila_gen;

    -- Precompute the sum of all the static fields in the IP header.
    -- remaining dynamic fields are:
    --    Total Length (UDP Payload + UDP Header Length (8) + IP header length (20))
    --    Source IP
    --    Destination IP

       -- TODO check this evaluates correctly with carry bits, etc.
       ip_checksum_precomp <=
       std_logic_vector(unsigned(C_RESPONSE_IPV4IHL & C_RESPONSE_DSCPECN )
       + unsigned("000" & (C_IP_IDENTIFICATION))
       + unsigned("000" & (C_RESPONSE_FLAGS_OFFSET))
       + unsigned("000" & (C_RESPONSE_TIME_TO_LIVE & C_RESPONSE_UDP_PROTOCOL)));
       
       lIPChecksum16 <= not std_logic_vector(unsigned(lIPChecksum19(15 downto 0)) + unsigned(lIPChecksum19(18 downto 16)));


    ----------------------------------------------------------------------------
    --                   Packet Forwarding State Machine                      --   
    ----------------------------------------------------------------------------
    -- This module is a line rate data packetising and forwarding statemachine--
    -- The module requires only sixteen (16) clock cycles (waste of about 1024--
    -- byte slots) to calculate or recalculate IP framing checksum and        --
    -- construct framing header from input parameters.                        --
    -- The module will recalculate the framing if only the addressing or the  --
    -- packet length information has changed.                                 --
    -- During operation the module expects the first data to be less than 22  --
    -- bytes long and the first 42 bytes to be empty in order to put the      --
    -- Ethernet/IP/UDP framming data on the initial 42 bytes.                 --       
    --    Hint:                                                               --       
    --        When sending 19,20,21,22 byte packets the CMAC will be over     --  
    --        saturated and will have to throttle the tready signal downstream--  
    --        at 50% duty cycle as it will have to generate an FCS frame on   --
    --        the LBUS interface. This applies to all packet where TLAST is   --
    --        asserted and the last 4 bytes also contain valid data, as in    --
    --        these cases an FCS wrap around on the LBUS will occur.          --
    ---------------------------------------------------------------------------- 

    SynchStateProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                StateVariable <= InitialiseSt;
                lUDPCheckSum           <= (others => '0');
                state_val <= "000";
                lDPacketSlotID <= (others => '0');
                lPacketSlotID <= (others => '0');
            else
                lDPacketSlotID <= lPacketSlotID;
                case (StateVariable) is

                    when InitialiseSt =>
state_val <= "001";
                        -- Wait for packet after initialization
                        StateVariable             <= BeginOrProcessUDPPacketStreamSt;
                        lPacketSlotID             <= (others => '0');
         --               lPacketAddress            <= (others => '0');
                        -- Disable all data output
          --              lPacketByteEnable         <= (others => '0');
                        -- Reset the packet data to null
          --              lPacketData               <= (others => '0');
                        lPacketDataWrite          <= '0';
                        lPacketSlotSet            <= '0';
                        lPacketSlotType           <= '0';
                        lProtocolErrorStatus      <= '0';
                        offset_axis_tready        <= '0';
                        ARPReadDataEnable         <= '0';
                        ARPReadAddress            <= (others => '0');
                        lDestinationIPMulticast   <= '0';
                        iIPHeaderChecksum         <= (others => '0');
                        lTXOverflowCount          <= (others => '0');
                        lTXAFullCount             <= (others => '0');
           --             lUDPLength                <= (others => '0');
          --              lIPLength                 <= (others => '0');

                    when BeginOrProcessUDPPacketStreamSt =>
                    state_val <= "010";
                        lUDPLength                 <= (others => '0');
                        lIPLength                 <= (others => '0');
                        -- Reset the packet address
                        lPacketAddress            <= (others => '0');
                        -- Default slot set to null
                        lPacketSlotSet            <= '0';
                        lPacketDataWrite          <= '0';
                        offset_axis_tready <= '1';                                                     
                        if ((offset_axis_tvalid = '1') and (EthernetMACEnable = '1')) then
                                -- Got the tvalid  and the mac is enabled
                             --   StateVariable <= WriteUdpPayloadFirstWordSt;
                                                        -- Write the packet addressing data
                            lPacketDataWrite               <= offset_axis_tvalid;
                            lPacketData                    <= offset_axis_tdata;
                            lPacketByteEnable(0)           <= offset_axis_tlast;
                            lPacketSlotType                <= offset_axis_tlast;
                            lPacketByteEnable(63 downto 1) <= offset_axis_tkeep(63 downto 1);
                            -- Point to next address when data is valid from source
                            lUDPLength <= X"001e"; -- Assume this word is 64 bytes, 34 of which are headers on top of UDP
                            lIPLength <= X"0032"; --Assume this word is 64 bytes, 14 of which are headers on top of IP 
                            lPacketAddress <= (others => '0');
                            lFirstWord <= offset_axis_tdata(511 downto 336); -- store the first word so we can write it again when we have the headers
                            StateVariable <= WriteUdpPayloadSt;
                        end if;
                                           
                    when WriteUdpPayloadSt =>
                                        state_val <= "011";

                        -- Resume packet consumption
                        offset_axis_tready               <= '1';
                        -- Write the packet addressing data
                        lPacketDataWrite               <= offset_axis_tvalid;
                        lPacketData                    <= offset_axis_tdata;
                        -- Pass through the packet enable (tkeep)
                        -- Enable(0) is special for TLAST mapping
                        lPacketByteEnable(0)           <= offset_axis_tlast;
                        lPacketSlotType                <= offset_axis_tlast;
                        lPacketByteEnable(63 downto 1) <= offset_axis_tkeep(63 downto 1);
                        -- Point to next address when data is valid from source
                        if (offset_axis_tvalid = '1') then
                            -- Assumes that we keep bytes from LSB up to MSB-n
                            lUDPLength <= lUDPLength + log2ceil(unsigned(offset_axis_tkeep)); -- count the number of bytes we are writing
                            lIPLength <= lIPLength + log2ceil(unsigned(offset_axis_tkeep));
                            lPacketAddress <= lPacketAddress + 1;
                        end if;
                        -- If this is the last data word, we need to capture header-fields
                        -- start populating the headers
                        if ((offset_axis_tvalid = '1') and (offset_axis_tlast = '1')) then
                            if (dest_ip_fifo_out and lLocalIPNetmask) = (lLocalIPAddress and lLocalIPNetmask) then
                                -- If the target IP address is within the IP netmask,send data to that IP address.
                                --lDestinationIPAddress  <= byteswap(dest_ip_fifo_out);
                                lDestinationIPAddress  <= dest_ip_fifo_out;
                                lIsMulticast <= '0';
                            elsif dest_ip_fifo_out(31 downto 31-3) = "111" then
                                -- Multicast IP.
                                lIsMulticast <= '1';
                                --lDestinationIPAddress  <= byteswap(dest_ip_fifo_out);
                                                                lDestinationIPAddress  <= dest_ip_fifo_out;

                            else
                                -- If the target IP address is outside of the netmask, send data to the gateway IP.
                                --lDestinationIPAddress <= byteswap(GatewayIPAddress);
                                                              lDestinationIPAddress <= GatewayIPAddress;

                                lIsMulticast <= '0';
                            end if;
                            --lSourceIPAddress       <= byteswap(SourceIPAddress);
                            --lDestinationUDPPort    <= byteswap(dest_port_fifo_out);
                            --lSourceUDPPort         <= byteswap(ServerUDPPort);
                            --lSourceMACAddress      <= byteswap(EthernetMACAddress);
                            lSourceIPAddress       <= (SourceIPAddress);
                            lDestinationUDPPort    <= (dest_port_fifo_out);
                            lSourceUDPPort         <= (ServerUDPPort);
                            lSourceMACAddress      <= (EthernetMACAddress);
                            -- Lookup MAC, but if this is a multicast packet we will ignore the result
                            ARPReadAddress         <= dest_ip_fifo_out(G_ARP_CACHE_ASIZE - 1 downto 0);
                            ARPReadDataEnable      <= '1';
                            -- No more reading
                            offset_axis_tready <= '0';
                            StateVariable <= ComputeIPChecksumSt;
                        end if;

                    when ComputeIPChecksumSt =>
                                                            state_val <= "100";
                        lPacketDataWrite <= '0';
                        lIPChecksum19 <= std_logic_vector(unsigned(ip_checksum_precomp) +
                            (lIPLength) +
                            ("000" & unsigned(lDestinationIPAddress(15 downto 0))) + 
                            ("000" & unsigned(lDestinationIPAddress(31 downto 16))) +
                            ("000" & unsigned(lSourceIPAddress(15 downto 0))) +
                            ("000" & unsigned(lSourceIPAddress(31 downto 16))));
                        StateVariable <= WriteHeadersSt;
                        

                    when WriteHeadersSt =>
                                                            state_val <= "101";

                        lPacketAddress <= (others => '0');
                        --lPacketByteEnable <= X"000003fffffffffe"; -- write 42 bytes. zero LSB because that's used for end-of-frame
                        lPacketDataWrite <= '1';
                        --- Use ARP lookup or generate MAC address depending on multicast
                        if (lIsMulticast = '0') then
                            lPacketData(6*8  - 1 downto 0*8) <= ARPReadData(47 downto 0);
                        else
                            lPacketData(6*8  - 1 downto 0*8) <= "0000000100000000010111100" & lDestinationIPAddress(22 downto 0);
                        end if;
                        lPacketData(12*8 - 1 downto 6*8) <= X"020202020202";--lSourceMACAddress;
                        lPacketData(14*8 - 1 downto 12*8) <= byteswap(C_RESPONSE_ETHER_TYPE);
                        lPacketData(112 + 1*8  - 1 downto 112 + 0*8) <= byteswap(C_RESPONSE_IPV4IHL);
                        lPacketData(112 + 2*8  - 1 downto 112 + 1*8) <= byteswap(C_RESPONSE_DSCPECN);
                        lPacketData(112 + 4*8  - 1 downto 112 + 2*8) <= std_logic_vector(byteswap(lIPLength));
                        lPacketData(112 + 6*8  - 1 downto 112 + 4*8) <= byteswap(C_IP_IDENTIFICATION);
                        lPacketData(112 + 8*8  - 1 downto 112 + 6*8) <= byteswap(C_RESPONSE_FLAGS_OFFSET);
                        lPacketData(112 + 9*8  - 1 downto 112 + 8*8) <= byteswap(C_RESPONSE_TIME_TO_LIVE);
                        lPacketData(112 + 10*8 - 1 downto 112 + 9*8) <= byteswap(C_RESPONSE_UDP_PROTOCOL);
                        lPacketData(112 + 12*8 - 1 downto 112 + 10*8) <= byteswap(lIPChecksum16);
                        lPacketData(112 + 16*8 - 1 downto 112 + 12*8) <= byteswap(lSourceIPAddress);
                        lPacketData(112 + 20*8 - 1 downto 112 + 16*8) <= byteswap(lDestinationIPAddress);
                        lPacketData(272 + 2*8  - 1 downto 272 + 0*8) <= byteswap(lSourceUDPPort);
                        lPacketData(272 + 4*8  - 1 downto 272 + 2*8) <= byteswap(lDestinationUDPPort);
                        lPacketData(272 + 6*8  - 1 downto 272 + 4*8) <= std_logic_vector(byteswap(lUDPLength));
                        lPacketData(272 + 8*8  - 1 downto 272 + 6*8) <= byteswap(lUDPChecksum);
                        lPacketData(511 downto 336) <= lFirstWord;
                        lPacketByteEnable <= X"fffffffffffffffe"; -- write 42 bytes. zero LSB because that's used for end-of-frame

                        StateVariable <= CloseBufferSt;

                    when CloseBufferSt =>
                                                            state_val <= "110";
                        lPacketDataWrite <= '0';
                        -- Point to next slot ID
                        lPacketSlotType                <= '1';
                        if (offset_axis_tuser = '0') then
                            -- Only process packets who have no errors 
                            lPacketSlotSet <= '1';
                            if (lPacketSlotStatus = '1') then
                                lTXOverflowCount <= lTXOverflowCount + 1;
                                lTXAFullCount    <= lTXAFullCount + 1;
                            end if;
                            -- Point to next slot ID
                            lPacketSlotID  <= lPacketSlotID + 1;
                        end if;
                        -- Search for new packets
                        StateVariable <= BeginOrProcessUDPPacketStreamSt;
                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process SynchStateProc;

end architecture rtl;
