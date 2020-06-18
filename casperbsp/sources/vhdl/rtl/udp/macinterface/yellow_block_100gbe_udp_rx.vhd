-- ********************************************************************************************************************************************************************
-- Module: yellow_block_100gbe_udp_rx.vhd
-- Author: Henno Kriel
-- Date: 10 May 2020
-- Institute: SARAO
-- 
-- Description:
-- This block attaches to the a AXI streaming transmitter, in this case the XILINX 100G Ethernet CMAC RX port.
-- It decodes the incomming data and the first valid AXI cycle is checked to see if the packets mataches the MAC, IP & UDP port of this 100GbE Yellow Block.
-- If it does not, the AXI data is ignored.
-- If it does, the UDP payload is stored, realigned to the output 512 bit bus and shoved into a dual clock FIFO, with the end of frame flag as bit 513 (from 1)
-- As soon as the FIFO is not empty, the FIFO data is clocked out (typically by the Simulink sys_clk) and placed on the 100GbE RX yellow block interface.
-- Flow control is not supported - if the user fall behind, the FIFO will over run on the write side and that will assert yellow_block_rx_overrun. 
-- ********************************************************************************************************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity yellow_block_100gbe_udp_rx is
  generic(
    FABRIC_MAC : STD_LOGIC_VECTOR(47 downto 0);  -- From 100Gbe Yellow Block Mask Parameters: Own / Fabric MAC Address
    FABRIC_IP : STD_LOGIC_VECTOR(31 downto 0);   -- From 100Gbe Yellow Block Mask Parameters: Own / Fabric IP Address
    FABRIC_PORT : STD_LOGIC_VECTOR(15 downto 0)  -- From 100Gbe Yellow Block Mask Parameters: Own / Fabric UDP Port 
  );
  port(
    --Inputs from AXI bus of the Xilinx CMAC RX side
    -- MAC received data (packet in) for UDP checking and processing 
    max_rx_axi_clk           : in  STD_LOGIC;
    axis_rx_tdata            : in  STD_LOGIC_VECTOR(511 downto 0);
    axis_rx_tvalid           : in  STD_LOGIC;
    axis_rx_tuser            : in  STD_LOGIC;
    axis_rx_tkeep            : in  STD_LOGIC_VECTOR(63 downto 0);
    axis_rx_tlast            : in  STD_LOGIC;
    -- Outputs to 100GbE Yellow Block RX interface
    -- MAC received data (UDP Packet in) with UDP payload stripped and sent to yellow block 100G RX Data interface aligned to 512..0 word
    yellow_block_user_clk    : in  STD_LOGIC;
    yellow_block_rx_data     : out  STD_LOGIC_VECTOR(511 downto 0);
    yellow_block_rx_valid    : out  STD_LOGIC;
    yellow_block_rx_eof      : out  STD_LOGIC;
    yellow_block_rx_overrun  : out STD_LOGIC
  );
end entity yellow_block_100gbe_udp_rx;

architecture rtl of yellow_block_100gbe_udp_rx is

  -- Packet header field constants
  -- Packet Type VLAN=0x8100 
  constant C_VLAN_TYPE      : std_logic_vector(15 downto 0)       := X"8100";
  -- Packet Type DVLAN=0x88A8 
  constant C_DVLAN_TYPE     : std_logic_vector(15 downto 0)       := X"88A8";
  -- IPV4 Type=0x0800 
  constant C_IPV4_TYPE         : std_logic_vector(15 downto 0)       := X"0800";
  -- IP Version and Header Length =0x45 
  constant C_IPV_IHL           : std_logic_vector(7 downto 0)        := X"45";
  -- UDP Protocol =0x06   
  constant C_UDP_PROTOCOL      : std_logic_vector(7 downto 0)        := X"11";
  -- Tuples registers
  
  -- Ethernet packet header parameters mapped to bit offsets
  alias lDestinationMACAddress : std_logic_vector(47 downto 0) is axis_rx_tdata(47 downto 0);
  alias lSourceMACAddress      : std_logic_vector(47 downto 0) is axis_rx_tdata(95 downto 48);
  alias lEtherType             : std_logic_vector(15 downto 0) is axis_rx_tdata(111 downto 96);
  alias lIPVIHL                : std_logic_vector(7  downto 0) is axis_rx_tdata(119 downto 112);
  alias lDSCPECN               : std_logic_vector(7  downto 0) is axis_rx_tdata(127 downto 120);
  alias lTotalLength           : std_logic_vector(15 downto 0) is axis_rx_tdata(143 downto 128);
  alias lIdentification        : std_logic_vector(15 downto 0) is axis_rx_tdata(159 downto 144);
  alias lFlagsOffset           : std_logic_vector(15 downto 0) is axis_rx_tdata(175 downto 160);
  alias lTimeToLeave           : std_logic_vector(7  downto 0) is axis_rx_tdata(183 downto 176);
  alias lProtocol              : std_logic_vector(7  downto 0) is axis_rx_tdata(191 downto 184);
  alias lHeaderChecksum        : std_logic_vector(15 downto 0) is axis_rx_tdata(207 downto 192);
  alias lSourceIPAddress       : std_logic_vector(31 downto 0) is axis_rx_tdata(239 downto 208);
  alias lDestinationIPAddress  : std_logic_vector(31 downto 0) is axis_rx_tdata(271 downto 240);
  alias lSourceUDPPort         : std_logic_vector(15 downto 0) is axis_rx_tdata(287 downto 272);
  alias lDestinationUDPPort    : std_logic_vector(15 downto 0) is axis_rx_tdata(303 downto 288);
  alias lUDPDataStreamLength   : std_logic_vector(15 downto 0) is axis_rx_tdata(319 downto 304);
  alias lUDPCheckSum           : std_logic_vector(15 downto 0) is axis_rx_tdata(335 downto 320);

  -- internal signals
  signal multiCyclePacket         : std_logic;
  signal payloadDataToFifoWrWrEn  : std_logic;
  signal payloadDataToFifoWr      : std_logic_vector(512 downto 0);
  signal fifo_empty               : std_logic;
  signal fifo_rd_data             : std_logic_vector(512 downto 0);
  signal valid_udp_packet         : std_logic;
  signal axis_rx_tvalidR          : std_logic;
  signal axis_rx_tdataR           : std_logic_vector(511 downto 0);
  signal axis_rx_tlastR           : std_logic;
  signal axis_rx_tdata_last_valid : std_logic_vector(511 downto 0);
  signal valid_udp_packetR        : std_logic;
  signal s_axis_tready            : std_logic;
  signal fifo_rd_en               : std_logic;
  signal fifo_full                : std_logic;
  signal yellow_block_rx_eof_int  : std_logic;
  signal yellow_block_rx_data_int : std_logic_vector(511 downto 0);

  -- helper function to swap bytes - CMAC AXI is mapped first byte starts at 7:0 and last byte 511:504
  -- simulink yellow block has first byte at 511:504 and last byte at 7:0
  function byteswap(DataIn : in std_logic_vector)
  return std_logic_vector is
      variable RData48 : std_logic_vector(47 downto 0);
      variable RData32 : std_logic_vector(31 downto 0);
      variable RData24 : std_logic_vector(23 downto 0);
      variable RData16 : std_logic_vector(15 downto 0);
  begin
      if (DataIn'length = RData48'length) then
          RData48(7 downto 0)   := DataIn((47 + DataIn'right) downto (40 + DataIn'right));
          RData48(15 downto 8)  := DataIn((39 + DataIn'right) downto (32 + DataIn'right));
          RData48(23 downto 16) := DataIn((31 + DataIn'right) downto (24 + DataIn'right));
          RData48(31 downto 24) := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
          RData48(39 downto 32) := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
          RData48(47 downto 40) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
          return std_logic_vector(RData48);
      end if;
      if (DataIn'length = RData32'length) then
          RData32(7 downto 0)   := DataIn((31 + DataIn'right) downto (24 + DataIn'right));
          RData32(15 downto 8)  := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
          RData32(23 downto 16) := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
          RData32(31 downto 24) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
          return std_logic_vector(RData32);
      end if;
      if (DataIn'length = RData24'length) then
          RData24(7 downto 0)   := DataIn((23 + DataIn'right) downto (16 + DataIn'right));
          RData24(15 downto 8)  := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
          RData24(23 downto 16) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
          return std_logic_vector(RData24);
      end if;
      if (DataIn'length = RData16'length) then
          RData16(7 downto 0)  := DataIn((15 + DataIn'right) downto (8 + DataIn'right));
          RData16(15 downto 8) := DataIn((7 + DataIn'right) downto (0 + DataIn'right));
          return std_logic_vector(RData16);
      end if;
  end byteswap;

  -- components used
  -- Clock domain crossing fifo between CMAC RX AXI and 100GbE yellow block RX interface
  --component async_fifo_513b_512deep IS
  component async_fifo_513b_16deep IS -- Make sure RX rate > TX rate!
    port (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(512 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(512 DOWNTO 0);
      full : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      almost_empty : OUT STD_LOGIC;
      wr_rst_busy : OUT STD_LOGIC;
      rd_rst_busy : OUT STD_LOGIC
    );
  end component async_fifo_513b_16deep; -- Make sure RX rate > TX rate!
  --end component async_fifo_513b_512deep; -- Initial bandwidth test

  -- Clock domain crossing synchronizer between CMAC RX AXI and 100GbE yellow block RX interface
  component async is
    generic (
      --Define width of the datapath
      BUS_WIDTH : natural range 1 to 64 := 64 -- Max 64 bits
    
    );
    port(
      RST : in STD_LOGIC;
      CLK : in STD_LOGIC;
      BUS_IN : IN STD_LOGIC_VECTOR(BUS_WIDTH-1 DOWNTO 0);
      BUS_OUT : OUT STD_LOGIC_VECTOR(BUS_WIDTH-1 DOWNTO 0)
    );    
  end component async;

begin

  -- Incomminf CMAC RX packet handling
  -- Check that the incomming frame matches our MAC, IP, UDP Port 
  valid_udp_packet <= '1' when ((lProtocol = C_UDP_PROTOCOL and lIPVIHL = C_IPV_IHL and byteswap(lEtherType) = C_IPV4_TYPE and byteswap(lDestinationMACAddress) = FABRIC_MAC and byteswap(lDestinationIPAddress) = FABRIC_IP and byteswap(lDestinationUDPPort) = FABRIC_PORT and axis_rx_tvalid = '1')) else '0';
  
  -- if the packet matches all the critera then strip off the UDP payload, and realign it to 511:0 for 100 GbE yellow block RX_DATA
  pack_valid_udp_packet_into_fifo : process(max_rx_axi_clk)
    begin
      if rising_edge(max_rx_axi_clk) then
        -- defaults
        valid_udp_packetR <= valid_udp_packet;
        axis_rx_tdataR <= axis_rx_tdata;
        axis_rx_tvalidR <= axis_rx_tvalid;
        axis_rx_tlastR <= axis_rx_tlast;           
        payloadDataToFifoWrWrEn <= '0';

        -- Valid packet processing starts
        -- Packet is a single cycle (packet size <= 64 bytes)
        if ((multiCyclePacket = '0') and (axis_rx_tlastR = '1') and (valid_udp_packetR = '1')) then
          payloadDataToFifoWr(175 downto 0) <= axis_rx_tdataR(511 downto 336);                            
          payloadDataToFifoWr(511 downto 176) <= (others => '0');
          payloadDataToFifoWr(512) <= '1'; -- end of frame
          multiCyclePacket <= '0';
          payloadDataToFifoWrWrEn <= '1';
        end if;
        -- Start of multi-cycle packet (packet size > 64 bytes)
        if ((multiCyclePacket = '0') and (axis_rx_tlastR = '0') and (valid_udp_packetR = '1')) then
          axis_rx_tdata_last_valid (175 downto 0) <= axis_rx_tdataR(511 downto 336);                                                      
          payloadDataToFifoWr <= (others => '0');
          payloadDataToFifoWr(512) <= '0'; -- end of frame
          payloadDataToFifoWrWrEn <= '0';
          multiCyclePacket <= '1';
        end if;
        -- busy with multi-cylce packet
        if ((multiCyclePacket = '1') and (axis_rx_tlastR = '0') and (axis_rx_tvalidR = '1')) then
          axis_rx_tdata_last_valid (175 downto 0) <= axis_rx_tdataR(511 downto 336);
          payloadDataToFifoWr (175 downto 0) <= axis_rx_tdata_last_valid (175 downto 0);
          payloadDataToFifoWr(511 downto 176) <= axis_rx_tdataR(511-176 downto 0);
          payloadDataToFifoWr(512) <= '0'; -- end of frame
          multiCyclePacket <= '1';
          payloadDataToFifoWrWrEn <= '1';
        end if;
        -- done with multi-cycle packet (AXI tlast asserted)
        if ((multiCyclePacket = '1') and (axis_rx_tlastR = '1') and (axis_rx_tvalidR = '1')) then
          payloadDataToFifoWr (175 downto 0) <= axis_rx_tdata_last_valid (175 downto 0);
          payloadDataToFifoWr(511 downto 176) <= axis_rx_tdataR(511-176 downto 0);                            
          payloadDataToFifoWr(512) <= '1'; -- end of frame
          multiCyclePacket <= '0';
          payloadDataToFifoWrWrEn <= '1';
        end if;
        -- Valid packet processing ends

    end if;
  end process pack_valid_udp_packet_into_fifo;


  -- Clock domain crossing: AXI FIFO to store incomming validated UDP payload + control signals (from mac rx clock) to Simulink user clk
  --mac_rx_packet_fifo_inst: async_fifo_513b_512deep 
  mac_rx_packet_fifo_inst: async_fifo_513b_16deep 
    port map (
      -- MAC RX Side Clock domain - FIFO Write side into FIFO: Validated UDP payload + control
      wr_clk => max_rx_axi_clk,
      rst => '0',
      wr_en => payloadDataToFifoWrWrEn,
      full => fifo_full,
      din => payloadDataToFifoWr(512 downto 0), -- payloadDataToFifoWr(512) = End Of Frame
      -- Simulink Side Clock domain - FIFO Read Side out of FIFO: Validated UDP payload + control
      rd_clk => yellow_block_user_clk,
      empty => fifo_empty,
      rd_en => fifo_rd_en and not fifo_empty,
      dout(511 downto 0) => yellow_block_rx_data_int,
      dout(512) => yellow_block_rx_eof_int
    );

  -- generate 100GbE yellow block signals
  yellow_block_rx_data <= yellow_block_rx_data_int;
  yellow_block_rx_eof <= yellow_block_rx_eof_int and not fifo_empty;

  -- as soon as the FIFO has data in, spew it out to the 100GbE yellow block RX interface
  gen_gbe_rx_valid : process(yellow_block_user_clk)
    begin
      if rising_edge(yellow_block_user_clk) then            
        fifo_rd_en <= not(fifo_empty);       
      end if;
    end process gen_gbe_rx_valid;
  yellow_block_rx_valid <= fifo_rd_en and not fifo_empty; 

  -- CDC for fifo_full to yellow_block_rx_overrun
  async_yellow_block_rx_overrun_inst: async
    generic map(
             BUS_WIDTH => 1
         )
    port map (
        RST => '0',
        CLK => yellow_block_user_clk,
        BUS_IN(0) => fifo_full,
        BUS_OUT(0) => yellow_block_rx_overrun
    );

end architecture rtl;