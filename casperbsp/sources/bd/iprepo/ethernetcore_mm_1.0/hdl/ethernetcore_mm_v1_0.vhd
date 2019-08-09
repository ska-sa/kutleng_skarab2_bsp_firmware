library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ethernetcore_mm_v1_0 is
    generic(
        -- Users to add parameters here

        -- User parameters ends
        -- Do not modify the parameters beyond this line

        -- Parameters of Axi Slave Bus Interface S00_AXI
        C_S00_AXI_DATA_WIDTH    : integer          := 32;
        C_S00_AXI_ADDR_WIDTH    : integer          := 7;
        -- Parameters of Axi Slave Bus Interface S01_AXI
        C_S01_AXI_ID_WIDTH      : integer          := 1;
        C_S01_AXI_DATA_WIDTH    : integer          := 32;
        C_S01_AXI_ADDR_WIDTH    : integer          := 10;
        C_S01_AXI_AWUSER_WIDTH  : integer          := 0;
        C_S01_AXI_ARUSER_WIDTH  : integer          := 0;
        C_S01_AXI_WUSER_WIDTH   : integer          := 0;
        C_S01_AXI_RUSER_WIDTH   : integer          := 0;
        C_S01_AXI_BUSER_WIDTH   : integer          := 0;
        -- Parameters of Axi Slave Bus Interface S_AXI_INTR
        C_S_AXI_INTR_DATA_WIDTH : integer          := 32;
        C_S_AXI_INTR_ADDR_WIDTH : integer          := 5;
        C_NUM_OF_INTR           : integer          := 1;
        C_INTR_SENSITIVITY      : std_logic_vector := x"FFFFFFFF";
        C_INTR_ACTIVE_STATE     : std_logic_vector := x"FFFFFFFF";
        C_IRQ_SENSITIVITY       : integer          := 1;
        C_IRQ_ACTIVE_STATE      : integer          := 1
    );
    port(
        -- Users to add ports here
        gmac_reg_phy_control_h        : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_control_l        : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_mac_address          : out STD_LOGIC_VECTOR(47 downto 0);
        gmac_reg_local_ip_address     : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_gateway_ip_address   : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_multicast_ip_address : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_multicast_ip_mask    : out STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_udp_port             : out STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_udp_port_mask        : out STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_mac_enable           : out STD_LOGIC;
        gmac_reg_mac_promiscous_mode  : out STD_LOGIC;
        gmac_reg_counters_reset       : out STD_LOGIC;
        gmac_reg_core_type            : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_status_h         : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_phy_status_l         : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_packet_rate       : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_packet_count      : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_valid_rate        : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_valid_count       : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_overflow_count    : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_afull_count       : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_packet_rate       : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_packet_count      : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_valid_rate        : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_valid_count       : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_overflow_count    : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_almost_full_count : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_rx_bad_packet_count  : in  STD_LOGIC_VECTOR(31 downto 0);
        --
        gmac_reg_arp_size             : in  STD_LOGIC_VECTOR(31 downto 0);
        gmac_reg_tx_word_size         : in  STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_rx_word_size         : in  STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_tx_buffer_max_size   : in  STD_LOGIC_VECTOR(15 downto 0);
        gmac_reg_rx_buffer_max_size   : in  STD_LOGIC_VECTOR(15 downto 0);
        -- User ports ends
        -- Do not modify the ports beyond this line

        -- Ports of Axi Slave Bus Interface S00_AXI
        s00_axi_aclk                  : in  std_logic;
        s00_axi_aresetn               : in  std_logic;
        s00_axi_awaddr                : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
        s00_axi_awprot                : in  std_logic_vector(2 downto 0);
        s00_axi_awvalid               : in  std_logic;
        s00_axi_awready               : out std_logic;
        s00_axi_wdata                 : in  std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
        s00_axi_wstrb                 : in  std_logic_vector((C_S00_AXI_DATA_WIDTH / 8) - 1 downto 0);
        s00_axi_wvalid                : in  std_logic;
        s00_axi_wready                : out std_logic;
        s00_axi_bresp                 : out std_logic_vector(1 downto 0);
        s00_axi_bvalid                : out std_logic;
        s00_axi_bready                : in  std_logic;
        s00_axi_araddr                : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
        s00_axi_arprot                : in  std_logic_vector(2 downto 0);
        s00_axi_arvalid               : in  std_logic;
        s00_axi_arready               : out std_logic;
        s00_axi_rdata                 : out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
        s00_axi_rresp                 : out std_logic_vector(1 downto 0);
        s00_axi_rvalid                : out std_logic;
        s00_axi_rready                : in  std_logic;
        -- Ports of Axi Slave Bus Interface S01_AXI
        s01_axi_aclk                  : in  std_logic;
        s01_axi_aresetn               : in  std_logic;
        s01_axi_awid                  : in  std_logic_vector(C_S01_AXI_ID_WIDTH - 1 downto 0);
        s01_axi_awaddr                : in  std_logic_vector(C_S01_AXI_ADDR_WIDTH - 1 downto 0);
        s01_axi_awlen                 : in  std_logic_vector(7 downto 0);
        s01_axi_awsize                : in  std_logic_vector(2 downto 0);
        s01_axi_awburst               : in  std_logic_vector(1 downto 0);
        s01_axi_awlock                : in  std_logic;
        s01_axi_awcache               : in  std_logic_vector(3 downto 0);
        s01_axi_awprot                : in  std_logic_vector(2 downto 0);
        s01_axi_awqos                 : in  std_logic_vector(3 downto 0);
        s01_axi_awregion              : in  std_logic_vector(3 downto 0);
        s01_axi_awuser                : in  std_logic_vector(C_S01_AXI_AWUSER_WIDTH - 1 downto 0);
        s01_axi_awvalid               : in  std_logic;
        s01_axi_awready               : out std_logic;
        s01_axi_wdata                 : in  std_logic_vector(C_S01_AXI_DATA_WIDTH - 1 downto 0);
        s01_axi_wstrb                 : in  std_logic_vector((C_S01_AXI_DATA_WIDTH / 8) - 1 downto 0);
        s01_axi_wlast                 : in  std_logic;
        s01_axi_wuser                 : in  std_logic_vector(C_S01_AXI_WUSER_WIDTH - 1 downto 0);
        s01_axi_wvalid                : in  std_logic;
        s01_axi_wready                : out std_logic;
        s01_axi_bid                   : out std_logic_vector(C_S01_AXI_ID_WIDTH - 1 downto 0);
        s01_axi_bresp                 : out std_logic_vector(1 downto 0);
        s01_axi_buser                 : out std_logic_vector(C_S01_AXI_BUSER_WIDTH - 1 downto 0);
        s01_axi_bvalid                : out std_logic;
        s01_axi_bready                : in  std_logic;
        s01_axi_arid                  : in  std_logic_vector(C_S01_AXI_ID_WIDTH - 1 downto 0);
        s01_axi_araddr                : in  std_logic_vector(C_S01_AXI_ADDR_WIDTH - 1 downto 0);
        s01_axi_arlen                 : in  std_logic_vector(7 downto 0);
        s01_axi_arsize                : in  std_logic_vector(2 downto 0);
        s01_axi_arburst               : in  std_logic_vector(1 downto 0);
        s01_axi_arlock                : in  std_logic;
        s01_axi_arcache               : in  std_logic_vector(3 downto 0);
        s01_axi_arprot                : in  std_logic_vector(2 downto 0);
        s01_axi_arqos                 : in  std_logic_vector(3 downto 0);
        s01_axi_arregion              : in  std_logic_vector(3 downto 0);
        s01_axi_aruser                : in  std_logic_vector(C_S01_AXI_ARUSER_WIDTH - 1 downto 0);
        s01_axi_arvalid               : in  std_logic;
        s01_axi_arready               : out std_logic;
        s01_axi_rid                   : out std_logic_vector(C_S01_AXI_ID_WIDTH - 1 downto 0);
        s01_axi_rdata                 : out std_logic_vector(C_S01_AXI_DATA_WIDTH - 1 downto 0);
        s01_axi_rresp                 : out std_logic_vector(1 downto 0);
        s01_axi_rlast                 : out std_logic;
        s01_axi_ruser                 : out std_logic_vector(C_S01_AXI_RUSER_WIDTH - 1 downto 0);
        s01_axi_rvalid                : out std_logic;
        s01_axi_rready                : in  std_logic;
        -- Ports of Axi Slave Bus Interface S_AXI_INTR
        s_axi_intr_aclk               : in  std_logic;
        s_axi_intr_aresetn            : in  std_logic;
        s_axi_intr_awaddr             : in  std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH - 1 downto 0);
        s_axi_intr_awprot             : in  std_logic_vector(2 downto 0);
        s_axi_intr_awvalid            : in  std_logic;
        s_axi_intr_awready            : out std_logic;
        s_axi_intr_wdata              : in  std_logic_vector(C_S_AXI_INTR_DATA_WIDTH - 1 downto 0);
        s_axi_intr_wstrb              : in  std_logic_vector((C_S_AXI_INTR_DATA_WIDTH / 8) - 1 downto 0);
        s_axi_intr_wvalid             : in  std_logic;
        s_axi_intr_wready             : out std_logic;
        s_axi_intr_bresp              : out std_logic_vector(1 downto 0);
        s_axi_intr_bvalid             : out std_logic;
        s_axi_intr_bready             : in  std_logic;
        s_axi_intr_araddr             : in  std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH - 1 downto 0);
        s_axi_intr_arprot             : in  std_logic_vector(2 downto 0);
        s_axi_intr_arvalid            : in  std_logic;
        s_axi_intr_arready            : out std_logic;
        s_axi_intr_rdata              : out std_logic_vector(C_S_AXI_INTR_DATA_WIDTH - 1 downto 0);
        s_axi_intr_rresp              : out std_logic_vector(1 downto 0);
        s_axi_intr_rvalid             : out std_logic;
        s_axi_intr_rready             : in  std_logic;
        irq                           : out std_logic
    );
end ethernetcore_mm_v1_0;

architecture arch_imp of ethernetcore_mm_v1_0 is

    -- component declaration
    component ethernetcore_mm_v1_0_S00_AXI is
        generic(
            C_S_AXI_DATA_WIDTH : integer := 32;
            C_S_AXI_ADDR_WIDTH : integer := 7
        );
        port(
            gmac_reg_phy_control_h        : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_control_l        : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_mac_address          : out STD_LOGIC_VECTOR(47 downto 0);
            gmac_reg_local_ip_address     : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_gateway_ip_address   : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_multicast_ip_address : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_multicast_ip_mask    : out STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_udp_port             : out STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_udp_port_mask        : out STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_mac_enable           : out STD_LOGIC;
            gmac_reg_mac_promiscous_mode  : out STD_LOGIC;
            gmac_reg_counters_reset       : out STD_LOGIC;
            gmac_reg_core_type            : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_status_h         : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_phy_status_l         : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_packet_rate       : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_packet_count      : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_valid_rate        : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_valid_count       : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_overflow_count    : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_afull_count       : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_packet_rate       : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_packet_count      : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_valid_rate        : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_valid_count       : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_overflow_count    : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_almost_full_count : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_rx_bad_packet_count  : in  STD_LOGIC_VECTOR(31 downto 0);
            --
            gmac_reg_arp_size             : in  STD_LOGIC_VECTOR(31 downto 0);
            gmac_reg_tx_word_size         : in  STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_rx_word_size         : in  STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_tx_buffer_max_size   : in  STD_LOGIC_VECTOR(15 downto 0);
            gmac_reg_rx_buffer_max_size   : in  STD_LOGIC_VECTOR(15 downto 0);
            S_AXI_ACLK                    : in  std_logic;
            S_AXI_ARESETN                 : in  std_logic;
            S_AXI_AWADDR                  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
            S_AXI_AWPROT                  : in  std_logic_vector(2 downto 0);
            S_AXI_AWVALID                 : in  std_logic;
            S_AXI_AWREADY                 : out std_logic;
            S_AXI_WDATA                   : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_WSTRB                   : in  std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
            S_AXI_WVALID                  : in  std_logic;
            S_AXI_WREADY                  : out std_logic;
            S_AXI_BRESP                   : out std_logic_vector(1 downto 0);
            S_AXI_BVALID                  : out std_logic;
            S_AXI_BREADY                  : in  std_logic;
            S_AXI_ARADDR                  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
            S_AXI_ARPROT                  : in  std_logic_vector(2 downto 0);
            S_AXI_ARVALID                 : in  std_logic;
            S_AXI_ARREADY                 : out std_logic;
            S_AXI_RDATA                   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_RRESP                   : out std_logic_vector(1 downto 0);
            S_AXI_RVALID                  : out std_logic;
            S_AXI_RREADY                  : in  std_logic
        );
    end component ethernetcore_mm_v1_0_S00_AXI;

    component ethernetcore_mm_v1_0_S01_AXI is
        generic(
            C_S_AXI_ID_WIDTH     : integer := 1;
            C_S_AXI_DATA_WIDTH   : integer := 32;
            C_S_AXI_ADDR_WIDTH   : integer := 10;
            C_S_AXI_AWUSER_WIDTH : integer := 0;
            C_S_AXI_ARUSER_WIDTH : integer := 0;
            C_S_AXI_WUSER_WIDTH  : integer := 0;
            C_S_AXI_RUSER_WIDTH  : integer := 0;
            C_S_AXI_BUSER_WIDTH  : integer := 0
        );
        port(
            S_AXI_ACLK     : in  std_logic;
            S_AXI_ARESETN  : in  std_logic;
            S_AXI_AWID     : in  std_logic_vector(C_S_AXI_ID_WIDTH - 1 downto 0);
            S_AXI_AWADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
            S_AXI_AWLEN    : in  std_logic_vector(7 downto 0);
            S_AXI_AWSIZE   : in  std_logic_vector(2 downto 0);
            S_AXI_AWBURST  : in  std_logic_vector(1 downto 0);
            S_AXI_AWLOCK   : in  std_logic;
            S_AXI_AWCACHE  : in  std_logic_vector(3 downto 0);
            S_AXI_AWPROT   : in  std_logic_vector(2 downto 0);
            S_AXI_AWQOS    : in  std_logic_vector(3 downto 0);
            S_AXI_AWREGION : in  std_logic_vector(3 downto 0);
            S_AXI_AWUSER   : in  std_logic_vector(C_S_AXI_AWUSER_WIDTH - 1 downto 0);
            S_AXI_AWVALID  : in  std_logic;
            S_AXI_AWREADY  : out std_logic;
            S_AXI_WDATA    : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_WSTRB    : in  std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
            S_AXI_WLAST    : in  std_logic;
            S_AXI_WUSER    : in  std_logic_vector(C_S_AXI_WUSER_WIDTH - 1 downto 0);
            S_AXI_WVALID   : in  std_logic;
            S_AXI_WREADY   : out std_logic;
            S_AXI_BID      : out std_logic_vector(C_S_AXI_ID_WIDTH - 1 downto 0);
            S_AXI_BRESP    : out std_logic_vector(1 downto 0);
            S_AXI_BUSER    : out std_logic_vector(C_S_AXI_BUSER_WIDTH - 1 downto 0);
            S_AXI_BVALID   : out std_logic;
            S_AXI_BREADY   : in  std_logic;
            S_AXI_ARID     : in  std_logic_vector(C_S_AXI_ID_WIDTH - 1 downto 0);
            S_AXI_ARADDR   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
            S_AXI_ARLEN    : in  std_logic_vector(7 downto 0);
            S_AXI_ARSIZE   : in  std_logic_vector(2 downto 0);
            S_AXI_ARBURST  : in  std_logic_vector(1 downto 0);
            S_AXI_ARLOCK   : in  std_logic;
            S_AXI_ARCACHE  : in  std_logic_vector(3 downto 0);
            S_AXI_ARPROT   : in  std_logic_vector(2 downto 0);
            S_AXI_ARQOS    : in  std_logic_vector(3 downto 0);
            S_AXI_ARREGION : in  std_logic_vector(3 downto 0);
            S_AXI_ARUSER   : in  std_logic_vector(C_S_AXI_ARUSER_WIDTH - 1 downto 0);
            S_AXI_ARVALID  : in  std_logic;
            S_AXI_ARREADY  : out std_logic;
            S_AXI_RID      : out std_logic_vector(C_S_AXI_ID_WIDTH - 1 downto 0);
            S_AXI_RDATA    : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_RRESP    : out std_logic_vector(1 downto 0);
            S_AXI_RLAST    : out std_logic;
            S_AXI_RUSER    : out std_logic_vector(C_S_AXI_RUSER_WIDTH - 1 downto 0);
            S_AXI_RVALID   : out std_logic;
            S_AXI_RREADY   : in  std_logic
        );
    end component ethernetcore_mm_v1_0_S01_AXI;

    component ethernetcore_mm_v1_0_S_AXI_INTR is
        generic(
            C_S_AXI_DATA_WIDTH  : integer          := 32;
            C_S_AXI_ADDR_WIDTH  : integer          := 5;
            C_NUM_OF_INTR       : integer          := 1;
            C_INTR_SENSITIVITY  : std_logic_vector := x"FFFFFFFF";
            C_INTR_ACTIVE_STATE : std_logic_vector := x"FFFFFFFF";
            C_IRQ_SENSITIVITY   : integer          := 1;
            C_IRQ_ACTIVE_STATE  : integer          := 1
        );
        port(
            S_AXI_ACLK    : in  std_logic;
            S_AXI_ARESETN : in  std_logic;
            S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
            S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
            S_AXI_AWVALID : in  std_logic;
            S_AXI_AWREADY : out std_logic;
            S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
            S_AXI_WVALID  : in  std_logic;
            S_AXI_WREADY  : out std_logic;
            S_AXI_BRESP   : out std_logic_vector(1 downto 0);
            S_AXI_BVALID  : out std_logic;
            S_AXI_BREADY  : in  std_logic;
            S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
            S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
            S_AXI_ARVALID : in  std_logic;
            S_AXI_ARREADY : out std_logic;
            S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
            S_AXI_RRESP   : out std_logic_vector(1 downto 0);
            S_AXI_RVALID  : out std_logic;
            S_AXI_RREADY  : in  std_logic;
            irq           : out std_logic
        );
    end component ethernetcore_mm_v1_0_S_AXI_INTR;

begin

    -- Instantiation of Axi Bus Interface S00_AXI
    ethernetcore_mm_v1_0_S00_AXI_inst : ethernetcore_mm_v1_0_S00_AXI
        generic map(
            C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
        )
        port map(
            gmac_reg_phy_control_h        => gmac_reg_phy_control_h,
            gmac_reg_phy_control_l        => gmac_reg_phy_control_l,
            gmac_reg_mac_address          => gmac_reg_mac_address,
            gmac_reg_local_ip_address     => gmac_reg_local_ip_address,
            gmac_reg_gateway_ip_address   => gmac_reg_gateway_ip_address,
            gmac_reg_multicast_ip_address => gmac_reg_multicast_ip_address,
            gmac_reg_multicast_ip_mask    => gmac_reg_multicast_ip_mask,
            gmac_reg_udp_port             => gmac_reg_udp_port,
            gmac_reg_udp_port_mask        => gmac_reg_udp_port_mask,
            gmac_reg_mac_enable           => gmac_reg_mac_enable,
            gmac_reg_mac_promiscous_mode  => gmac_reg_mac_promiscous_mode,
            gmac_reg_counters_reset       => gmac_reg_counters_reset,
            gmac_reg_core_type            => gmac_reg_core_type,
            gmac_reg_phy_status_h         => gmac_reg_phy_status_h,
            gmac_reg_phy_status_l         => gmac_reg_phy_status_l,
            gmac_reg_tx_packet_rate       => gmac_reg_tx_packet_rate,
            gmac_reg_tx_packet_count      => gmac_reg_tx_packet_count,
            gmac_reg_tx_valid_rate        => gmac_reg_tx_valid_rate,
            gmac_reg_tx_valid_count       => gmac_reg_tx_valid_count,
            gmac_reg_tx_overflow_count    => gmac_reg_tx_overflow_count,
            gmac_reg_tx_afull_count       => gmac_reg_tx_afull_count,
            gmac_reg_rx_packet_rate       => gmac_reg_rx_packet_rate,
            gmac_reg_rx_packet_count      => gmac_reg_rx_packet_count,
            gmac_reg_rx_valid_rate        => gmac_reg_rx_valid_rate,
            gmac_reg_rx_valid_count       => gmac_reg_rx_valid_count,
            gmac_reg_rx_overflow_count    => gmac_reg_rx_overflow_count,
            gmac_reg_rx_almost_full_count => gmac_reg_rx_almost_full_count,
            gmac_reg_rx_bad_packet_count  => gmac_reg_rx_bad_packet_count,
            --                           => --                           ,
            gmac_reg_arp_size             => gmac_reg_arp_size,
            gmac_reg_tx_word_size         => gmac_reg_tx_word_size,
            gmac_reg_rx_word_size         => gmac_reg_rx_word_size,
            gmac_reg_tx_buffer_max_size   => gmac_reg_tx_buffer_max_size,
            gmac_reg_rx_buffer_max_size   => gmac_reg_rx_buffer_max_size,
            S_AXI_ACLK                    => s00_axi_aclk,
            S_AXI_ARESETN                 => s00_axi_aresetn,
            S_AXI_AWADDR                  => s00_axi_awaddr,
            S_AXI_AWPROT                  => s00_axi_awprot,
            S_AXI_AWVALID                 => s00_axi_awvalid,
            S_AXI_AWREADY                 => s00_axi_awready,
            S_AXI_WDATA                   => s00_axi_wdata,
            S_AXI_WSTRB                   => s00_axi_wstrb,
            S_AXI_WVALID                  => s00_axi_wvalid,
            S_AXI_WREADY                  => s00_axi_wready,
            S_AXI_BRESP                   => s00_axi_bresp,
            S_AXI_BVALID                  => s00_axi_bvalid,
            S_AXI_BREADY                  => s00_axi_bready,
            S_AXI_ARADDR                  => s00_axi_araddr,
            S_AXI_ARPROT                  => s00_axi_arprot,
            S_AXI_ARVALID                 => s00_axi_arvalid,
            S_AXI_ARREADY                 => s00_axi_arready,
            S_AXI_RDATA                   => s00_axi_rdata,
            S_AXI_RRESP                   => s00_axi_rresp,
            S_AXI_RVALID                  => s00_axi_rvalid,
            S_AXI_RREADY                  => s00_axi_rready
        );

    -- Instantiation of Axi Bus Interface S01_AXI
    ethernetcore_mm_v1_0_S01_AXI_inst : ethernetcore_mm_v1_0_S01_AXI
        generic map(
            C_S_AXI_ID_WIDTH     => C_S01_AXI_ID_WIDTH,
            C_S_AXI_DATA_WIDTH   => C_S01_AXI_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH   => C_S01_AXI_ADDR_WIDTH,
            C_S_AXI_AWUSER_WIDTH => C_S01_AXI_AWUSER_WIDTH,
            C_S_AXI_ARUSER_WIDTH => C_S01_AXI_ARUSER_WIDTH,
            C_S_AXI_WUSER_WIDTH  => C_S01_AXI_WUSER_WIDTH,
            C_S_AXI_RUSER_WIDTH  => C_S01_AXI_RUSER_WIDTH,
            C_S_AXI_BUSER_WIDTH  => C_S01_AXI_BUSER_WIDTH
        )
        port map(
            S_AXI_ACLK     => s01_axi_aclk,
            S_AXI_ARESETN  => s01_axi_aresetn,
            S_AXI_AWID     => s01_axi_awid,
            S_AXI_AWADDR   => s01_axi_awaddr,
            S_AXI_AWLEN    => s01_axi_awlen,
            S_AXI_AWSIZE   => s01_axi_awsize,
            S_AXI_AWBURST  => s01_axi_awburst,
            S_AXI_AWLOCK   => s01_axi_awlock,
            S_AXI_AWCACHE  => s01_axi_awcache,
            S_AXI_AWPROT   => s01_axi_awprot,
            S_AXI_AWQOS    => s01_axi_awqos,
            S_AXI_AWREGION => s01_axi_awregion,
            S_AXI_AWUSER   => s01_axi_awuser,
            S_AXI_AWVALID  => s01_axi_awvalid,
            S_AXI_AWREADY  => s01_axi_awready,
            S_AXI_WDATA    => s01_axi_wdata,
            S_AXI_WSTRB    => s01_axi_wstrb,
            S_AXI_WLAST    => s01_axi_wlast,
            S_AXI_WUSER    => s01_axi_wuser,
            S_AXI_WVALID   => s01_axi_wvalid,
            S_AXI_WREADY   => s01_axi_wready,
            S_AXI_BID      => s01_axi_bid,
            S_AXI_BRESP    => s01_axi_bresp,
            S_AXI_BUSER    => s01_axi_buser,
            S_AXI_BVALID   => s01_axi_bvalid,
            S_AXI_BREADY   => s01_axi_bready,
            S_AXI_ARID     => s01_axi_arid,
            S_AXI_ARADDR   => s01_axi_araddr,
            S_AXI_ARLEN    => s01_axi_arlen,
            S_AXI_ARSIZE   => s01_axi_arsize,
            S_AXI_ARBURST  => s01_axi_arburst,
            S_AXI_ARLOCK   => s01_axi_arlock,
            S_AXI_ARCACHE  => s01_axi_arcache,
            S_AXI_ARPROT   => s01_axi_arprot,
            S_AXI_ARQOS    => s01_axi_arqos,
            S_AXI_ARREGION => s01_axi_arregion,
            S_AXI_ARUSER   => s01_axi_aruser,
            S_AXI_ARVALID  => s01_axi_arvalid,
            S_AXI_ARREADY  => s01_axi_arready,
            S_AXI_RID      => s01_axi_rid,
            S_AXI_RDATA    => s01_axi_rdata,
            S_AXI_RRESP    => s01_axi_rresp,
            S_AXI_RLAST    => s01_axi_rlast,
            S_AXI_RUSER    => s01_axi_ruser,
            S_AXI_RVALID   => s01_axi_rvalid,
            S_AXI_RREADY   => s01_axi_rready
        );

    -- Instantiation of Axi Bus Interface S_AXI_INTR
    ethernetcore_mm_v1_0_S_AXI_INTR_inst : ethernetcore_mm_v1_0_S_AXI_INTR
        generic map(
            C_S_AXI_DATA_WIDTH  => C_S_AXI_INTR_DATA_WIDTH,
            C_S_AXI_ADDR_WIDTH  => C_S_AXI_INTR_ADDR_WIDTH,
            C_NUM_OF_INTR       => C_NUM_OF_INTR,
            C_INTR_SENSITIVITY  => C_INTR_SENSITIVITY,
            C_INTR_ACTIVE_STATE => C_INTR_ACTIVE_STATE,
            C_IRQ_SENSITIVITY   => C_IRQ_SENSITIVITY,
            C_IRQ_ACTIVE_STATE  => C_IRQ_ACTIVE_STATE
        )
        port map(
            S_AXI_ACLK    => s_axi_intr_aclk,
            S_AXI_ARESETN => s_axi_intr_aresetn,
            S_AXI_AWADDR  => s_axi_intr_awaddr,
            S_AXI_AWPROT  => s_axi_intr_awprot,
            S_AXI_AWVALID => s_axi_intr_awvalid,
            S_AXI_AWREADY => s_axi_intr_awready,
            S_AXI_WDATA   => s_axi_intr_wdata,
            S_AXI_WSTRB   => s_axi_intr_wstrb,
            S_AXI_WVALID  => s_axi_intr_wvalid,
            S_AXI_WREADY  => s_axi_intr_wready,
            S_AXI_BRESP   => s_axi_intr_bresp,
            S_AXI_BVALID  => s_axi_intr_bvalid,
            S_AXI_BREADY  => s_axi_intr_bready,
            S_AXI_ARADDR  => s_axi_intr_araddr,
            S_AXI_ARPROT  => s_axi_intr_arprot,
            S_AXI_ARVALID => s_axi_intr_arvalid,
            S_AXI_ARREADY => s_axi_intr_arready,
            S_AXI_RDATA   => s_axi_intr_rdata,
            S_AXI_RRESP   => s_axi_intr_rresp,
            S_AXI_RVALID  => s_axi_intr_rvalid,
            S_AXI_RREADY  => s_axi_intr_rready,
            irq           => irq
        );

        -- Add user logic here

        -- User logic ends

end arch_imp;
