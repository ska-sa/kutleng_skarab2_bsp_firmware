library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethernetcore_mm_v1_0_S00_AXI is
    generic(
        -- Users to add parameters here
        C_SLOT_WIDTH       : natural := 4;
        -- User parameters ends
        -- Do not modify the parameters beyond this line
        -- Width of S_AXI data bus
        C_S_AXI_DATA_WIDTH : integer := 32;
        -- Width of S_AXI address bus
        C_S_AXI_ADDR_WIDTH : integer := 7
    );
    port(
        -- Users to add ports here
        gmac_reg_phy_control_h                 : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_control_l                 : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_mac_address                   : out STD_LOGIC_VECTOR(47 downto 0);
        gmac_reg_local_ip_address              : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_gateway_ip_address            : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_multicast_ip_address          : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_multicast_ip_mask             : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_udp_port                      : out STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_udp_port_mask                 : out STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_mac_enable                    : out STD_LOGIC;
        gmac_reg_mac_promiscous_mode           : out STD_LOGIC;
        gmac_reg_counters_reset                : out STD_LOGIC;
        gmac_reg_core_type                     : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_status_h                  : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_status_l                  : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_packet_rate                : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_packet_count               : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_valid_rate                 : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_valid_count                : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_overflow_count             : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_afull_count                : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_packet_rate                : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_packet_count               : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_valid_rate                 : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_valid_count                : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_overflow_count             : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_almost_full_count          : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_bad_packet_count           : in  STD_LOGIC_VECTOR(31 downto 0);
        --
        gmac_reg_arp_size                      : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_word_size                  : in  STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_rx_word_size                  : in  STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_tx_buffer_max_size            : in  STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_rx_buffer_max_size            : in  STD_LOGIC_VECTOR(15 downto 0);
        gmac_tx_ringbuffer_slot_id             : out STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
        gmac_tx_ringbuffer_slot_set            : out STD_LOGIC;
        gmac_tx_ringbuffer_slot_status         : in  STD_LOGIC;
        gmac_tx_ringbuffer_number_slots_filled : in  STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
        gmac_rx_ringbuffer_slot_id             : out STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
        gmac_rx_ringbuffer_slot_clear          : out STD_LOGIC;
        gmac_rx_ringbuffer_slot_status         : in  STD_LOGIC;
        gmac_rx_ringbuffer_number_slots_filled : in  STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
        -- User ports ends
        -- Do not modify the ports beyond this line
        -- Global Clock Signal
        S_AXI_ACLK                             : in  std_logic;
        -- Global Reset Signal. This Signal is Active LOW
        S_AXI_ARESETN                          : in  std_logic;
        -- Write address (issued by master, accepted by Slave)
        S_AXI_AWADDR                           : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
        -- Write channel Protection type. This signal indicates the
        -- privilege and security level of the transaction, and whether
        -- the transaction is a data access or an instruction access.
        S_AXI_AWPROT                           : in  std_logic_vector(2 downto 0);
        -- Write address valid. This signal indicates that the master signaling
        -- valid write address and control information.
        S_AXI_AWVALID                          : in  std_logic;
        -- Write address ready. This signal indicates that the slave is ready
        -- to accept an address and associated control signals.
        S_AXI_AWREADY                          : out std_logic;
        -- Write data (issued by master, accepted by Slave) 
        S_AXI_WDATA                            : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
        -- Write strobes. This signal indicates which byte lanes hold
        -- valid data. There is one write strobe bit for each eight
        -- bits of the write data bus.    
        S_AXI_WSTRB                            : in  std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
        -- Write valid. This signal indicates that valid write
        -- data and strobes are available.
        S_AXI_WVALID                           : in  std_logic;
        -- Write ready. This signal indicates that the slave
        -- can accept the write data.
        S_AXI_WREADY                           : out std_logic;
        -- Write response. This signal indicates the status
        -- of the write transaction.
        S_AXI_BRESP                            : out std_logic_vector(1 downto 0);
        -- Write response valid. This signal indicates that the channel
        -- is signaling a valid write response.
        S_AXI_BVALID                           : out std_logic;
        -- Response ready. This signal indicates that the master
        -- can accept a write response.
        S_AXI_BREADY                           : in  std_logic;
        -- Read address (issued by master, accepted by Slave)
        S_AXI_ARADDR                           : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
        -- Protection type. This signal indicates the privilege
        -- and security level of the transaction, and whether the
        -- transaction is a data access or an instruction access.
        S_AXI_ARPROT                           : in  std_logic_vector(2 downto 0);
        -- Read address valid. This signal indicates that the channel
        -- is signaling valid read address and control information.
        S_AXI_ARVALID                          : in  std_logic;
        -- Read address ready. This signal indicates that the slave is
        -- ready to accept an address and associated control signals.
        S_AXI_ARREADY                          : out std_logic;
        -- Read data (issued by slave)
        S_AXI_RDATA                            : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
        -- Read response. This signal indicates the status of the
        -- read transfer.
        S_AXI_RRESP                            : out std_logic_vector(1 downto 0);
        -- Read valid. This signal indicates that the channel is
        -- signaling the required read data.
        S_AXI_RVALID                           : out std_logic;
        -- Read ready. This signal indicates that the master can
        -- accept the read data and response information.
        S_AXI_RREADY                           : in  std_logic
    );
end ethernetcore_mm_v1_0_S00_AXI;

architecture arch_imp of ethernetcore_mm_v1_0_S00_AXI is

    -- AXI4LITE signals
    signal axi_awaddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    signal axi_awready : std_logic;
    signal axi_wready  : std_logic;
    signal axi_bresp   : std_logic_vector(1 downto 0);
    signal axi_bvalid  : std_logic;
    signal axi_araddr  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    signal axi_arready : std_logic;
    signal axi_rdata   : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal axi_rresp   : std_logic_vector(1 downto 0);
    signal axi_rvalid  : std_logic;

    -- Example-specific design signals
    -- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    -- ADDR_LSB is used for addressing 32/64 bit registers/memories
    -- ADDR_LSB = 2 for 32 bits (n downto 2)
    -- ADDR_LSB = 3 for 64 bits (n downto 3)
    constant ADDR_LSB          : integer := (C_S_AXI_DATA_WIDTH / 32) + 1;
    constant OPT_MEM_ADDR_BITS : integer := 4;
    ------------------------------------------------
    ---- Signals for user logic register space example
    --------------------------------------------------
    ---- Number of Slave Registers 32
    signal slv_reg0            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg1            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg2            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg3            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg4            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg5            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg6            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg7            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg8            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg9            : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg10           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg11           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg12           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg13           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg14           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg15           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg16           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg17           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg18           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg19           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg20           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg21           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg22           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg23           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg24           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg25           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg26           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg27           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg28           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg29           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg30           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg31           : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal slv_reg_rden        : std_logic;
    signal slv_reg_wren        : std_logic;
    signal reg_data_out        : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
    signal aw_en               : std_logic;

begin
    -- I/O Connections assignments

    S_AXI_AWREADY                 <= axi_awready;
    S_AXI_WREADY                  <= axi_wready;
    S_AXI_BRESP                   <= axi_bresp;
    S_AXI_BVALID                  <= axi_bvalid;
    S_AXI_ARREADY                 <= axi_arready;
    S_AXI_RDATA                   <= axi_rdata;
    S_AXI_RRESP                   <= axi_rresp;
    S_AXI_RVALID                  <= axi_rvalid;
    -- Implement axi_awready generation
    -- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    -- de-asserted when reset is low.
    gmac_reg_phy_control_h        <= slv_reg14;
    gmac_reg_phy_control_l        <= slv_reg15;
    gmac_reg_counters_reset       <= slv_reg30(0);
    gmac_reg_mac_address          <= slv_reg3(15 downto 0) & slv_reg4;
    gmac_reg_local_ip_address     <= slv_reg5;
    gmac_reg_gateway_ip_address   <= slv_reg6;
    gmac_reg_multicast_ip_address <= slv_reg7;
    gmac_reg_multicast_ip_mask    <= slv_reg8;
    gmac_reg_udp_port             <= slv_reg11(15 downto 0);
    gmac_reg_udp_port_mask        <= slv_reg11(31 downto 16);
    gmac_reg_mac_enable           <= slv_reg10(0);
    gmac_reg_mac_promiscous_mode  <= slv_reg10(1);

    gmac_tx_ringbuffer_slot_id    <= slv_reg9(16 + C_SLOT_WIDTH - 1 downto 16);
    gmac_tx_ringbuffer_slot_set   <= slv_reg9(16 + C_SLOT_WIDTH);
    gmac_rx_ringbuffer_slot_id    <= slv_reg9(C_SLOT_WIDTH - 1 downto 0);
    gmac_rx_ringbuffer_slot_clear <= slv_reg9(C_SLOT_WIDTH);

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_awready <= '0';
                aw_en       <= '1';
            else
                if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
                    -- slave is ready to accept write address when
                    -- there is a valid write address and write data
                    -- on the write address and data bus. This design 
                    -- expects no outstanding transactions. 
                    axi_awready <= '1';
                elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then
                    aw_en       <= '1';
                    axi_awready <= '0';
                else
                    axi_awready <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Implement axi_awaddr latching
    -- This process is used to latch the address when both 
    -- S_AXI_AWVALID and S_AXI_WVALID are valid. 

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_awaddr <= (others => '0');
            else
                if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and aw_en = '1') then
                    -- Write Address latching
                    axi_awaddr <= S_AXI_AWADDR;
                end if;
            end if;
        end if;
    end process;

    -- Implement axi_wready generation
    -- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    -- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
    -- de-asserted when reset is low. 

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_wready <= '0';
            else
                if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1' and aw_en = '1') then
                    -- slave is ready to accept write data when 
                    -- there is a valid write address and write data
                    -- on the write address and data bus. This design 
                    -- expects no outstanding transactions.           
                    axi_wready <= '1';
                else
                    axi_wready <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Implement memory mapped register select and write logic generation
    -- The write data is accepted and written to memory mapped registers when
    -- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    -- select byte enables of slave registers while writing.
    -- These registers are cleared when reset (active low) is applied.
    -- Slave register write enable is asserted when valid address and data are available
    -- and the slave is ready to accept the write address and write data.
    slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID;

    process(S_AXI_ACLK)
        variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                slv_reg0  <= (others => '0');
                slv_reg1  <= (others => '0');
                slv_reg2  <= (others => '0');
                slv_reg3  <= (others => '0');
                slv_reg4  <= (others => '0');
                slv_reg5  <= (others => '0');
                slv_reg6  <= (others => '0');
                slv_reg7  <= (others => '0');
                slv_reg8  <= (others => '0');
                slv_reg9  <= (others => '0');
                slv_reg10 <= (others => '0');
                slv_reg11 <= (others => '0');
                slv_reg12 <= (others => '0');
                slv_reg13 <= (others => '0');
                slv_reg14 <= (others => '0');
                slv_reg15 <= (others => '0');
                slv_reg16 <= (others => '0');
                slv_reg17 <= (others => '0');
                slv_reg18 <= (others => '0');
                slv_reg19 <= (others => '0');
                slv_reg20 <= (others => '0');
                slv_reg21 <= (others => '0');
                slv_reg22 <= (others => '0');
                slv_reg23 <= (others => '0');
                slv_reg24 <= (others => '0');
                slv_reg25 <= (others => '0');
                slv_reg26 <= (others => '0');
                slv_reg27 <= (others => '0');
                slv_reg28 <= (others => '0');
                slv_reg29 <= (others => '0');
                slv_reg30 <= (others => '0');
                slv_reg31 <= (others => '0');
            else
                loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
                if (slv_reg_wren = '1') then
                    case loc_addr is
                        when b"00000" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 0
                                    slv_reg0(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"00001" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 1
                                    slv_reg1(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"00010" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 2
                                    slv_reg2(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"00011" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 3
                                    slv_reg3(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"00100" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 4
                                    slv_reg4(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"00101" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 5
                                    slv_reg5(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"00110" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 6
                                    slv_reg6(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"00111" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 7
                                    slv_reg7(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"01000" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 8
                                    slv_reg8(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"01001" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 9
                                    slv_reg9(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"01010" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 10
                                    slv_reg10(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"01011" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 11
                                    slv_reg11(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"01100" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 12
                                    slv_reg12(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"01101" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 13
                                    slv_reg13(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"01110" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 14
                                    slv_reg14(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"01111" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 15
                                    slv_reg15(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"10000" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 16
                                    slv_reg16(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"10001" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 17
                                    slv_reg17(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"10010" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 18
                                    slv_reg18(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"10011" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 19
                                    slv_reg19(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"10100" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 20
                                    slv_reg20(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"10101" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 21
                                    slv_reg21(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"10110" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 22
                                    slv_reg22(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"10111" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 23
                                    slv_reg23(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"11000" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 24
                                    slv_reg24(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"11001" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 25
                                    slv_reg25(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"11010" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 26
                                    slv_reg26(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"11011" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 27
                                    slv_reg27(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"11100" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 28
                                    slv_reg28(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"11101" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 29
                                    slv_reg29(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"11110" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 30
                                    slv_reg30(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when b"11111" =>
                            for byte_index in 0 to (C_S_AXI_DATA_WIDTH / 8 - 1) loop
                                if (S_AXI_WSTRB(byte_index) = '1') then
                                    -- Respective byte enables are asserted as per write strobes                   
                                    -- slave registor 31
                                    slv_reg31(byte_index * 8 + 7 downto byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 downto byte_index * 8);
                                end if;
                            end loop;
                        when others =>
                            slv_reg0  <= slv_reg0;
                            slv_reg1  <= slv_reg1;
                            slv_reg2  <= slv_reg2;
                            slv_reg3  <= slv_reg3;
                            slv_reg4  <= slv_reg4;
                            slv_reg5  <= slv_reg5;
                            slv_reg6  <= slv_reg6;
                            slv_reg7  <= slv_reg7;
                            slv_reg8  <= slv_reg8;
                            slv_reg9  <= slv_reg9;
                            slv_reg10 <= slv_reg10;
                            slv_reg11 <= slv_reg11;
                            slv_reg12 <= slv_reg12;
                            slv_reg13 <= slv_reg13;
                            slv_reg14 <= slv_reg14;
                            slv_reg15 <= slv_reg15;
                            slv_reg16 <= slv_reg16;
                            slv_reg17 <= slv_reg17;
                            slv_reg18 <= slv_reg18;
                            slv_reg19 <= slv_reg19;
                            slv_reg20 <= slv_reg20;
                            slv_reg21 <= slv_reg21;
                            slv_reg22 <= slv_reg22;
                            slv_reg23 <= slv_reg23;
                            slv_reg24 <= slv_reg24;
                            slv_reg25 <= slv_reg25;
                            slv_reg26 <= slv_reg26;
                            slv_reg27 <= slv_reg27;
                            slv_reg28 <= slv_reg28;
                            slv_reg29 <= slv_reg29;
                            slv_reg30 <= slv_reg30;
                            slv_reg31 <= slv_reg31;
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- Implement write response logic generation
    -- The write response and response valid signals are asserted by the slave 
    -- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
    -- This marks the acceptance of address and indicates the status of 
    -- write transaction.

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_bvalid <= '0';
                axi_bresp  <= "00";     --need to work more on the responses
            else
                if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0') then
                    axi_bvalid <= '1';
                    axi_bresp  <= "00";
                elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then --check if bready is asserted while bvalid is high)
                    axi_bvalid <= '0';  -- (there is a possibility that bready is always asserted high)
                end if;
            end if;
        end if;
    end process;

    -- Implement axi_arready generation
    -- axi_arready is asserted for one S_AXI_ACLK clock cycle when
    -- S_AXI_ARVALID is asserted. axi_awready is 
    -- de-asserted when reset (active low) is asserted. 
    -- The read address is also latched when S_AXI_ARVALID is 
    -- asserted. axi_araddr is reset to zero on reset assertion.

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_arready <= '0';
                axi_araddr  <= (others => '1');
            else
                if (axi_arready = '0' and S_AXI_ARVALID = '1') then
                    -- indicates that the slave has acceped the valid read address
                    axi_arready <= '1';
                    -- Read Address latching 
                    axi_araddr  <= S_AXI_ARADDR;
                else
                    axi_arready <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Implement axi_arvalid generation
    -- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
    -- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
    -- data are available on the axi_rdata bus at this instance. The 
    -- assertion of axi_rvalid marks the validity of read data on the 
    -- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
    -- is deasserted on reset (active low). axi_rresp and axi_rdata are 
    -- cleared to zero on reset (active low).  
    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then
            if S_AXI_ARESETN = '0' then
                axi_rvalid <= '0';
                axi_rresp  <= "00";
            else
                if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
                    -- Valid read data is available at the read data bus
                    axi_rvalid <= '1';
                    axi_rresp  <= "00"; -- 'OKAY' response
                elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
                    -- Read data is accepted by the master
                    axi_rvalid <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Implement memory mapped register select and read logic generation
    -- Slave register read enable is asserted when valid address is available
    -- and the slave is ready to accept the read address.
    slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid);

    process(gmac_reg_core_type, gmac_reg_tx_buffer_max_size, gmac_reg_rx_buffer_max_size, gmac_reg_tx_word_size, gmac_reg_rx_word_size, slv_reg3, slv_reg4, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9, slv_reg10, slv_reg11, gmac_reg_phy_status_h, gmac_reg_phy_status_l, slv_reg14, slv_reg15, gmac_reg_tx_packet_count, gmac_reg_tx_packet_rate, gmac_reg_tx_valid_count, gmac_reg_tx_overflow_count, gmac_reg_tx_afull_count, gmac_reg_rx_packet_rate, gmac_reg_rx_packet_count, gmac_reg_rx_valid_rate, gmac_reg_arp_size, gmac_reg_rx_valid_count, gmac_reg_tx_valid_rate, gmac_reg_rx_overflow_count, gmac_reg_rx_bad_packet_count, gmac_reg_rx_almost_full_count, slv_reg30, slv_reg31, axi_araddr)
        variable loc_addr : std_logic_vector(OPT_MEM_ADDR_BITS downto 0);
    begin
        -- Address decoding for reading registers
        loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
        case loc_addr is
            when b"00000" =>
                ----------------------------------------------------------------
                -- Register Address:0x0000                                    --
                -- Register Name:Core Type                                    --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[07:00]:type[7:0]:8-bit Ethernet Type = 0x05       -- 
                -- Register[15:08]:rev[7:0] :8-bit Core Version  = 0x10       -- 
                -- Register[23:16]:CPU_RX_ENABLED[16]='1'Enabled,'0'Disabled  -- 
                -- Register[31:24]:CPU_TX_ENABLED[24]='1'Enabled,'0'Disabled  -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_core_type;

            when b"00001" =>
                ----------------------------------------------------------------
                -- Register Address:0x0004                                    --
                -- Register Name:Transmit and Receive Available Bytes         --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_BUF_MAX[31:16]:RX_BUF_MAX[15:00]        -- 
                ----------------------------------------------------------------                                    
                reg_data_out <= gmac_reg_tx_buffer_max_size & gmac_reg_rx_buffer_max_size;
            when b"00010" =>
                ----------------------------------------------------------------
                -- Register Address:0x0008                                    --
                -- Register Name:Transmit and Receive Bytes Per Word          --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_WORD_SIZE[31:16]:RX_WORD_SIZE[15:00]    -- 
                ----------------------------------------------------------------                                    
                reg_data_out <= gmac_reg_tx_word_size & gmac_reg_rx_word_size;
            when b"00011" =>
                ----------------------------------------------------------------
                -- Register Address:0x000C                                    --
                -- Register Name:Transmit and Receive Bytes Per Word          --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_WORD_SIZE[31:16]:RX_WORD_SIZE[15:00]    -- 
                ----------------------------------------------------------------                                    
                reg_data_out <= slv_reg3;
            when b"00100" =>
                reg_data_out <= slv_reg4;
            when b"00101" =>
                reg_data_out <= slv_reg5;
            when b"00110" =>
                reg_data_out <= slv_reg6;
            when b"00111" =>
                reg_data_out <= slv_reg7;
            when b"01000" =>
                reg_data_out <= slv_reg8;
            when b"01001" =>
                ----------------------------------------------------------------
                -- Register Address:0x0024                                    --
                -- Register Name:Transmit and Receive Ring Buffer Manipulation--
                -- Register Mode:Read Write                                   --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[28:28]:TX_SLOT_STATUS                             -- 
                -- Register[27:24]:TX_SLOT_NUMBER_SLOTS_OCCUPIED[3:0]         -- 
                -- Register[20:20]:TX_SLOT_SET                                -- 
                -- Register[19:16]:TX_SLOT_ID[3:0]                            -- 
                -- Register[12:12]:RX_SLOT_STATUS                             -- 
                -- Register[11:08]:RX_SLOT_NUMBER_SLOTS_OCCUPIED[3:0]         -- 
                -- Register[04:04]:RX_SLOT_CLEAR                              -- 
                -- Register[03:00]:RX_SLOT_ID[3:0]                            -- 
                ----------------------------------------------------------------                                    
                reg_data_out(28)           <= gmac_tx_ringbuffer_slot_status;
                reg_data_out(27 downto 24) <= gmac_tx_ringbuffer_number_slots_filled;
                --tx_slot_set
                reg_data_out(20)           <= slv_reg9(20);
                -- tx_slot_id
                reg_data_out(19 downto 16) <= slv_reg9(19 downto 16);
                reg_data_out(12)           <= gmac_rx_ringbuffer_slot_status;
                reg_data_out(11 downto 8)  <= gmac_rx_ringbuffer_number_slots_filled;
                -- rx_slot_clear
                reg_data_out(4)            <= slv_reg9(4);
                -- rx_slot_id
                reg_data_out(3 downto 0)   <= slv_reg9(3 downto 0);
            when b"01010" =>
                reg_data_out <= slv_reg10;
            when b"01011" =>
                reg_data_out <= slv_reg11;
            when b"01100" =>
                ----------------------------------------------------------------
                -- Register Address:0x0030                                    --
                -- Register Name:PHY Status Register                          --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:PHY_STATUS[63:32]                          -- 
                ----------------------------------------------------------------                    
                reg_data_out <= gmac_reg_phy_status_h;
            when b"01101" =>
                ----------------------------------------------------------------
                -- Register Address:0x0034                                    --
                -- Register Name:PHY Status Register                          --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:PHY_STATUS[31:00]                          -- 
                ----------------------------------------------------------------                    
                reg_data_out <= gmac_reg_phy_status_l;

            when b"01110" =>
                reg_data_out <= slv_reg14;
            when b"01111" =>
                reg_data_out <= slv_reg15;
            when b"10000" =>
                ----------------------------------------------------------------
                -- Register Address:0x0040                                    --
                -- Register Name:ARP Cache Size                               --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:ARP_SIZE[31:00]                            -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_arp_size;
            when b"10001" =>
                ----------------------------------------------------------------
                -- Register Address:0x0044                                    --
                -- Register Name:Transmit Packet Rate                         --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_PKT_RATE[31:00]                         -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_tx_packet_rate;
            when b"10010" =>
                ----------------------------------------------------------------
                -- Register Address:0x0048                                    --
                -- Register Name:Transmit Packet Count                        --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_PKT_CNT[31:00]                          -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_tx_packet_count;
            when b"10011" =>
                ----------------------------------------------------------------
                -- Register Address:0x004C                                    --
                -- Register Name:Transmit Valid Rate                          --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_VALID_RATE[31:00]                       -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_tx_valid_rate;
            when b"10100" =>
                ----------------------------------------------------------------
                -- Register Address:0x0050                                    --
                -- Register Name:Transmit Valid Count                         --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_VALID_CNT[31:00]                        -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_tx_valid_count;
            when b"10101" =>
                ----------------------------------------------------------------
                -- Register Address:0x0054                                    --
                -- Register Name:Transmit Overflow Count                      --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_OVERFLOW_CNT[31:00]                     -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_tx_overflow_count;
            when b"10110" =>
                ----------------------------------------------------------------
                -- Register Address:0x0058                                    --
                -- Register Name:Transmit Almost Full Count                   --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:TX_AFULL_CNT[31:00]                        -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_tx_afull_count;
            when b"10111" =>
                ----------------------------------------------------------------
                -- Register Address:0x005C                                    --
                -- Register Name:Receive Packet Rate                          --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:RX_PKT_RATE[31:00]                        -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_rx_packet_rate;
            when b"11000" =>
                ----------------------------------------------------------------
                -- Register Address:0x0060                                    --
                -- Register Name:Receive Packet Count                         --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:RX_PKT_CNT[31:00]                          -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_rx_packet_count;
            when b"11001" =>
                ----------------------------------------------------------------
                -- Register Address:0x0064                                    --
                -- Register Name:Receive Valid Rate                           --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:RX_VALID_RATE[31:00]                       -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_rx_valid_rate;
            when b"11010" =>
                ----------------------------------------------------------------
                -- Register Address:0x0068                                    --
                -- Register Name:Receive Valid Count                          --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:RX_VALID_CNT[31:00]                        -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_rx_valid_count;
            when b"11011" =>
                ----------------------------------------------------------------
                -- Register Address:0x006C                                    --
                -- Register Name:Receive Overflow Count                       --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:RX_OVERFLOW_CNT[31:00]                     -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_rx_overflow_count;
            when b"11100" =>
                ----------------------------------------------------------------
                -- Register Address:0x0070                                    --
                -- Register Name:Receive Almost Full Count                    --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:RX_AFULL_CNT[31:00]                        -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_rx_almost_full_count;
            when b"11101" =>
                ----------------------------------------------------------------
                -- Register Address:0x0074                                    --
                -- Register Name:Receive Bad Packet Count                     --
                -- Register Mode:Read Only                                    --
                -- Register Bit Fields:                                       --
                ----------------------------------------------------------------    
                -- Bit Range      :Mapping  : Description                     --
                ----------------------------------------------------------------    
                -- Register[31:00]:RX_BAD_PACKET_CNT[31:00]                   -- 
                ----------------------------------------------------------------    
                reg_data_out <= gmac_reg_rx_bad_packet_count;
            when b"11110" =>
                reg_data_out <= slv_reg30;
            when b"11111" =>
                reg_data_out <= slv_reg31;
            when others =>
                reg_data_out <= (others => '0');
        end case;
    end process;

    -- Output register or memory read data
    process(S_AXI_ACLK) is
    begin
        if (rising_edge(S_AXI_ACLK)) then
            if (S_AXI_ARESETN = '0') then
                axi_rdata <= (others => '0');
            else
                if (slv_reg_rden = '1') then
                    -- When there is a valid read address (S_AXI_ARVALID) with 
                    -- acceptance of read address by the slave (axi_arready), 
                    -- output the read dada 
                    -- Read address mux
                    axi_rdata <= reg_data_out; -- register read data
                end if;
            end if;
        end if;
    end process;

    -- Add user logic here

    -- User logic ends

end arch_imp;
