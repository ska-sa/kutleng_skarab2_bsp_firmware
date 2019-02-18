--------------------------------------------------------------------------------
-- Legal & Copyright:   (c) 2018 Kutleng Engineering Technologies (Pty) Ltd    - 
--                                                                             -
-- This program is the proprietary software of Kutleng Engineering Technologies-
-- and/or its licensors, and may only be used, duplicated, modified or         -
-- distributed pursuant to the terms and conditions of a separate, written     -
-- license agreement executed between you and Kutleng (an "Authorized License")-
-- Except as set forth in an Authorized License, Kutleng grants no license     -
-- (express or implied), right to use, or waiver of any kind with respect to   -
-- the Software, and Kutleng expressly reserves all rights in and to the       -
-- Software and all intellectual property rights therein.  IF YOU HAVE NO      -
-- AUTHORIZED LICENSE, THEN YOU HAVE NO RIGHT TO USE THIS SOFTWARE IN ANY WAY, -
-- AND SHOULD IMMEDIATELY NOTIFY KUTLENG AND DISCONTINUE ALL USE OF THE        -
-- SOFTWARE.                                                                   -
--                                                                             -
-- Except as expressly set forth in the Authorized License,                    -
--                                                                             -
-- 1.     This program, including its structure, sequence and organization,    -
-- constitutes the valuable trade secrets of Kutleng, and you shall use all    -
-- reasonable efforts to protect the confidentiality thereof,and to use this   -
-- information only in connection with South African Radio Astronomy           -
-- Observatory (SARAO) products.                                               -
--                                                                             -
-- 2.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE SOFTWARE IS PROVIDED     -
-- "AS IS" AND WITH ALL FAULTS AND KUTLENG MAKES NO PROMISES, REPRESENTATIONS  -
-- OR WARRANTIES, EITHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE, WITH       -
-- RESPECT TO THE SOFTWARE.  KUTLENG SPECIFICALLY DISCLAIMS ANY AND ALL IMPLIED-
-- WARRANTIES OF TITLE, MERCHANTABILITY, NONINFRINGEMENT, FITNESS FOR A        -
-- PARTICULAR PURPOSE, LACK OF VIRUSES, ACCURACY OR COMPLETENESS, QUIET        -
-- ENJOYMENT, QUIET POSSESSION OR CORRESPONDENCE TO DESCRIPTION. YOU ASSUME THE-
-- ENJOYMENT, QUIET POSSESSION USE OR PERFORMANCE OF THE SOFTWARE.             -
--                                                                             -
-- 3.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL KUTLENG OR -
-- ITS LICENSORS BE LIABLE FOR (i) CONSEQUENTIAL, INCIDENTAL, SPECIAL, INDIRECT-
-- , OR EXEMPLARY DAMAGES WHATSOEVER ARISING OUT OF OR IN ANY WAY RELATING TO  -
-- YOUR USE OF OR INABILITY TO USE THE SOFTWARE EVEN IF KUTLENG HAS BEEN       -
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGES; OR (ii) ANY AMOUNT IN EXCESS OF -
-- THE AMOUNT ACTUALLY PAID FOR THE SOFTWARE ITSELF OR ZAR R1, WHICHEVER IS    -
-- GREATER. THESE LIMITATIONS SHALL APPLY NOTWITHSTANDING ANY FAILURE OF       -
-- ESSENTIAL PURPOSE OF ANY LIMITED REMEDY.                                    -
-- --------------------------------------------------------------------------- -
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS                    -
-- PART OF THIS FILE AT ALL TIMES.                                             -
--=============================================================================-
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : prconfigcontroller - rtl                                 -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The partial reconfiguration controller module receives   -
--                    commands and frames for partial reconfiguration and      -
--                    writes to the ICAPE3.                                    -
--                    The module checks for errors using IP and UDP checksums  -
--                    It responds with a DWORD status that contains all the    -
--                    necessary errors or status of the partial reconfiguration-
--                    operation.                                               -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prconfigcontroller is
    generic(
        G_SLOT_WIDTH      : natural                          := 4;
        G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
        -- The address width is log2(2048/(512/8))=5 bits wide
        G_ADDR_WIDTH      : natural                          := 5
    );
    port(
        --312.50MHz system clock
        axis_clk          : in  STD_LOGIC;
        -- 95 MHz ICAP clock
        icap_clk          : in  STD_LOGIC;
        -- Module reset
        -- Must be synchronized internally for each clock domain
        axis_reset        : in  STD_LOGIC;
        -- Setup information
        ServerMACAddress  : in  STD_LOGIC_VECTOR(47 downto 0);
        ServerIPAddress   : in  STD_LOGIC_VECTOR(31 downto 0);
        --Inputs from AXIS bus of the MAC side
        axis_rx_tdata     : in  STD_LOGIC_VECTOR(511 downto 0);
        axis_rx_tvalid    : in  STD_LOGIC;
        axis_rx_tuser     : in  STD_LOGIC;
        axis_rx_tkeep     : in  STD_LOGIC_VECTOR(63 downto 0);
        axis_rx_tlast     : in  STD_LOGIC;
        --Outputs to AXIS bus MAC side 
        axis_tx_tpriority : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
        axis_tx_tdata     : out STD_LOGIC_VECTOR(511 downto 0);
        axis_tx_tvalid    : out STD_LOGIC;
        axis_tx_tready    : in  STD_LOGIC;
        axis_tx_tkeep     : out STD_LOGIC_VECTOR(63 downto 0);
        axis_tx_tlast     : out STD_LOGIC;
        ICAP_PRDONE       : in  std_logic;
        ICAP_PRERROR      : in  std_logic;
        ICAP_AVAIL        : in  std_logic;
        ICAP_CSIB         : out std_logic;
        ICAP_RDWRB        : out std_logic;
        ICAP_DataOut      : in  std_logic_vector(31 downto 0);
        ICAP_DataIn       : out std_logic_vector(31 downto 0)
    );
end entity prconfigcontroller;

architecture rtl of prconfigcontroller is
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
            --SenderMACAddress         : in  STD_LOGIC_VECTOR(47 downto 0);
            --SenderIPAddress          : in  STD_LOGIC_VECTOR(31 downto 0);
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

    component macifudpreceiver is
        generic(
            G_SLOT_WIDTH      : natural                          := 4;
            G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
            -- The address width is log2(2048/(512/8))=5 bits wide
            G_ADDR_WIDTH      : natural                          := 5
        );
        port(
            axis_clk                 : in  STD_LOGIC;
            axis_reset               : in  STD_LOGIC;
            -- Setup information
            ReceiverMACAddress       : in  STD_LOGIC_VECTOR(47 downto 0);
            ReceiverIPAddress        : in  STD_LOGIC_VECTOR(31 downto 0);
            -- Packet Readout in addressed bus format
            RingBufferSlotID         : in  STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotClear      : in  STD_LOGIC;
            RingBufferSlotStatus     : out STD_LOGIC;
            RingBufferSlotTypeStatus : out STD_LOGIC;
            RingBufferSlotsFilled    : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferDataRead       : in  STD_LOGIC;
            -- Enable[0] is a special bit (we assume always 1 when packet is valid)
            -- we use it to save TLAST
            RingBufferDataEnable     : out STD_LOGIC_VECTOR(63 downto 0);
            RingBufferDataOut        : out STD_LOGIC_VECTOR(511 downto 0);
            RingBufferAddress        : in  STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            --Inputs from AXIS bus of the MAC side
            axis_rx_tdata            : in  STD_LOGIC_VECTOR(511 downto 0);
            axis_rx_tvalid           : in  STD_LOGIC;
            axis_rx_tuser            : in  STD_LOGIC;
            axis_rx_tkeep            : in  STD_LOGIC_VECTOR(63 downto 0);
            axis_rx_tlast            : in  STD_LOGIC
        );
    end component macifudpreceiver;

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
            ServerUDPPort              : in  STD_LOGIC_VECTOR(15 downto 0);
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
            ICAP_Readback               : in  STD_LOGIC_VECTOR(31 downto 0)
        );
    end component protocolresponderprconfigsm;

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

    component icapwritersm is
        generic(
            G_SLOT_WIDTH : natural := 4;
            --G_UDP_SERVER_PORT : natural range 0 to ((2**16) - 1) := 5;
            -- The address width is log2(2048/(512/8))=5 bits wide
            G_ADDR_WIDTH : natural := 5
        );
        port(
            icap_clk                 : in  STD_LOGIC;
            icap_reset               : in  STD_LOGIC;
            -- Packet Write in addressed bus format
            -- Packet Readout in addressed bus format
            RingBufferSlotID         : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            RingBufferSlotClear      : out STD_LOGIC;
            RingBufferSlotStatus     : in  STD_LOGIC;
            RingBufferSlotTypeStatus : in  STD_LOGIC;
            RingBufferDataRead       : out STD_LOGIC;
            -- Enable[0] is a special bit (we assume always 1 when packet is valid)
            -- we use it to save TLAST
            RingBufferDataEnable     : in  STD_LOGIC_VECTOR(3 downto 0);
            RingBufferDataIn         : in  STD_LOGIC_VECTOR(31 downto 0);
            RingBufferAddress        : out STD_LOGIC_VECTOR(G_ADDR_WIDTH - 1 downto 0);
            -- Handshaking signals
            -- Status signal to show when the packet sender is busy
            SenderBusy               : in  STD_LOGIC;
            -- ICAP Writer Response
            ICAPWriteDone            : out STD_LOGIC;
            ICAPWriteResponseSent    : in  STD_LOGIC;
            ICAPIPIdentification     : out STD_LOGIC_VECTOR(15 downto 0);
            ICAPProtocolID           : out STD_LOGIC_VECTOR(15 downto 0);
            ICAPProtocolSequence     : out STD_LOGIC_VECTOR(31 downto 0);
            --Inputs from AXIS bus of the MAC side
            --ICAPE3 interface
            ICAP_CSIB                : out STD_LOGIC;
            ICAP_RDWRB               : out STD_LOGIC;
            ICAP_AVAIL               : in  STD_LOGIC;
            ICAP_DataIn              : out STD_LOGIC_VECTOR(31 downto 0);
            ICAP_DataOut             : in  STD_LOGIC_VECTOR(31 downto 0);
            ICAP_Readback            : out STD_LOGIC_VECTOR(31 downto 0)           
        );
    end component icapwritersm;

    constant C_DATA_WIDTH                     : natural := 512;
    constant G_ICAP_RB_ADDR_WIDTH             : natural := 7;
    signal SenderRingBufferSlotID             : std_logic_vector(G_SLOT_WIDTH - 1 downto 0);
    signal SenderRingBufferSlotClear          : std_logic;
    signal SenderRingBufferSlotStatus         : std_logic;
    signal SenderRingBufferSlotTypeStatus     : std_logic;
    signal SenderRingBufferSlotsFilled        : std_logic_vector(G_SLOT_WIDTH - 1 downto 0);
    signal SenderRingBufferDataRead           : std_logic;
    signal SenderRingBufferDataEnable         : std_logic_vector(63 downto 0);
    signal SenderRingBufferDataIn             : std_logic_vector(511 downto 0);
    signal SenderRingBufferAddress            : std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
    signal lSenderFilledSlots                 : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lSynchSenderRingBufferSlotSet      : std_logic;
    signal SynchSenderRingBufferSlotSet       : std_logic_vector(3 downto 0);
    signal SenderRingBufferPacketSlotSet      : std_logic;
    signal SenderRingBufferPacketByteEnable   : std_logic_vector((C_DATA_WIDTH / 8) - 1 downto 0);
    signal SenderRingBufferPacketDataWrite    : std_logic;
    signal SenderRingBufferPacketData         : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal SenderRingBufferPacketAddress      : std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
    signal SenderRingBufferPacketSlotID       : std_logic_vector(G_SLOT_WIDTH - 1 downto 0);
    signal SenderRingBufferPacketSlotType     : std_logic;
    signal SenderRingBufferPacketSlotStatus   : std_logic;
    signal ClientMACAddress                   : std_logic_vector(47 downto 0);
    signal ClientIPAddress                    : std_logic_vector(31 downto 0);
    signal ClientUDPPort                      : std_logic_vector(15 downto 0);
    signal SenderBusy                         : std_logic;
    signal ProtocolError                      : std_logic;
    signal ProtocolErrorClear                 : std_logic;
    signal ICAPWriteDone                      : std_logic;
    signal ICAPWriteResponseSent              : std_logic;
    signal icap_reset                         : std_logic;
    signal licap_reset                        : std_logic;
    signal ReceiverRingBufferSlotClear        : std_logic;
    signal ReceiverRingBufferSlotID           : std_logic_vector(G_SLOT_WIDTH - 1 downto 0);
    signal ReceiverRingBufferSlotStatus       : std_logic;
    signal ReceiverRingBufferSlotTypeStatus   : std_logic;
    signal ReceiverRingBufferSlotsFilled      : std_logic_vector(G_SLOT_WIDTH - 1 downto 0);
    signal ReceiverRingBufferDataRead         : std_logic;
    signal ReceiverRingBufferDataEnable       : std_logic_vector(63 downto 0);
    signal ReceiverRingBufferDataOut          : std_logic_vector(511 downto 0);
    signal ReceiverRingBufferAddress          : std_logic_vector(G_ADDR_WIDTH - 1 downto 0);
    signal ICAPWriterRingBufferSlotID         : std_logic_vector(G_SLOT_WIDTH - 1 downto 0);
    signal ICAPWriterRingBufferSlotClear      : std_logic;
    signal ICAPWriterRingBufferSlotStatus     : std_logic;
    signal ICAPWriterRingBufferSlotTypeStatus : std_logic;
    signal ICAPWriterRingBufferDataRead       : std_logic;
    signal ICAPWriterRingBufferDataEnable     : std_logic_vector(3 downto 0);
    signal ICAPWriterRingBufferDataIn         : std_logic_vector(31 downto 0);
    signal ICAPWriterRingBufferAddress        : std_logic_vector(G_ICAP_RB_ADDR_WIDTH - 1 downto 0);
    signal ICAPRingBufferDataWrite            : std_logic;
    signal ICAPRingBufferData                 : std_logic_vector(31 downto 0);
    signal ICAPRingBufferAddress              : std_logic_vector(G_ICAP_RB_ADDR_WIDTH - 1 downto 0);
    signal ICAPRingBufferSlotID               : std_logic_vector(G_SLOT_WIDTH - 1 downto 0);
    signal ICAPRingBufferSlotSet              : std_logic;
    signal ICAPRingBufferSlotStatus           : std_logic;
    signal ICAPRingBufferByteEnable           : std_logic_vector(3 downto 0);
    signal ICAPRingBufferSlotType             : std_logic;
    signal ProtocolErrorID                    : std_logic_vector(31 downto 0);
    signal ProtocolIPIdentification           : std_logic_vector(15 downto 0);
    signal ProtocolID                         : std_logic_vector(15 downto 0);
    signal ProtocolSequence                   : std_logic_vector(31 downto 0);
    signal ICAPIPIdentification               : std_logic_vector(15 downto 0);
    signal ICAPProtocolID                     : std_logic_vector(15 downto 0);
    signal ICAPProtocolSequence               : std_logic_vector(31 downto 0);
    signal ICAP_Readback                      : std_logic_vector(31 downto 0);           
begin
    ----------------------------------------------------------------------------
    --                        Reset Synchronization                            -
    ----------------------------------------------------------------------------
    ResetSynchronizationProc : process(icap_clk)
    begin
        if rising_edge(icap_clk) then
            licap_reset <= axis_reset;
            icap_reset  <= licap_reset;
        end if;
    end process ResetSynchronizationProc;

    ----------------------------------------------------------------------------
    --                           Receive path                                  -
    ----------------------------------------------------------------------------

    UDPReceiver_i : macifudpreceiver
        generic map(
            G_SLOT_WIDTH      => G_SLOT_WIDTH,
            G_UDP_SERVER_PORT => G_UDP_SERVER_PORT,
            G_ADDR_WIDTH      => G_ADDR_WIDTH
        )
        port map(
            axis_clk                 => axis_clk,
            axis_reset               => axis_reset,
            ReceiverMACAddress       => ServerMACAddress,
            ReceiverIPAddress        => ServerIPAddress,
            RingBufferSlotID         => ReceiverRingBufferSlotID,
            RingBufferSlotClear      => ReceiverRingBufferSlotClear,
            RingBufferSlotStatus     => ReceiverRingBufferSlotStatus,
            RingBufferSlotTypeStatus => ReceiverRingBufferSlotTypeStatus,
            RingBufferSlotsFilled    => ReceiverRingBufferSlotsFilled,
            RingBufferDataRead       => ReceiverRingBufferDataRead,
            RingBufferDataEnable     => ReceiverRingBufferDataEnable,
            RingBufferDataOut        => ReceiverRingBufferDataOut,
            RingBufferAddress        => ReceiverRingBufferAddress,
            axis_rx_tdata            => axis_rx_tdata,
            axis_rx_tvalid           => axis_rx_tvalid,
            axis_rx_tuser            => axis_rx_tuser,
            axis_rx_tkeep            => axis_rx_tkeep,
            axis_rx_tlast            => axis_rx_tlast
        );

    ProtocolCheck_i : protocolchecksumprconfigsm
        generic map(
            G_SLOT_WIDTH         => G_SLOT_WIDTH,
            G_ICAP_RB_ADDR_WIDTH => G_ICAP_RB_ADDR_WIDTH,
            G_ADDR_WIDTH         => G_ADDR_WIDTH
        )
        port map(
            axis_clk                       => axis_clk,
            axis_reset                     => axis_reset,
            ClientMACAddress               => ClientMACAddress,
            ClientIPAddress                => ClientIPAddress,
            ClientUDPPort                  => ClientUDPPort,
            -- Packet Write in addressed bus format
            -- Packet Readout in addressed bus format
            FilterRingBufferSlotID         => ReceiverRingBufferSlotID,
            FilterRingBufferSlotClear      => ReceiverRingBufferSlotClear,
            FilterRingBufferSlotStatus     => ReceiverRingBufferSlotStatus,
            FilterRingBufferSlotTypeStatus => ReceiverRingBufferSlotTypeStatus,
            FilterRingBufferDataRead       => ReceiverRingBufferDataRead,
            -- Enable[0] is a special bit (we assume always 1 when packet is valid)
            -- we use it to save TLAST
            FilterRingBufferByteEnable     => ReceiverRingBufferDataEnable,
            FilterRingBufferDataIn         => ReceiverRingBufferDataOut,
            FilterRingBufferAddress        => ReceiverRingBufferAddress,
            -- Packet Readout in addressed bus format
            ICAPRingBufferSlotID           => ICAPRingBufferSlotID,
            ICAPRingBufferSlotSet          => ICAPRingBufferSlotSet,
            ICAPRingBufferSlotStatus       => ICAPRingBufferSlotStatus,
            ICAPRingBufferDataWrite        => ICAPRingBufferDataWrite,
            -- Enable[0] is a special bit (we assume always 1 when packet is valid)
            -- we use it to save TLAST
            ICAPRingBufferByteEnable       => ICAPRingBufferByteEnable,
            ICAPRingBufferDataOut          => ICAPRingBufferData,
            ICAPRingBufferAddress          => ICAPRingBufferAddress,
            -- Handshaking signals
            -- Status signal to show when the packet sender is busy
            SenderBusy                     => SenderBusy,
            -- Protocol Error
            ProtocolError                  => ProtocolError,
            ProtocolErrorClear             => ProtocolErrorClear,
            ProtocolErrorID                => ProtocolErrorID,
            ProtocolIPIdentification       => ProtocolIPIdentification,
            ProtocolID                     => ProtocolID,
            ProtocolSequence               => ProtocolSequence
        );
    ----------------------------------------------------------------------------
    --                           ICAP Section                                  -
    ----------------------------------------------------------------------------

    ICAPRingBuffer_i : dualportpacketringbuffer
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ICAP_RB_ADDR_WIDTH,
            G_DATA_WIDTH => 32
        )
        port map(
            RxClk                  => axis_clk,
            TxClk                  => icap_clk,
            -- Reception port
            RxPacketByteEnable     => ICAPRingBufferByteEnable,
            RxPacketDataWrite      => ICAPRingBufferDataWrite,
            RxPacketData           => ICAPRingBufferData,
            RxPacketAddress        => ICAPRingBufferAddress,
            RxPacketSlotSet        => ICAPRingBufferSlotSet,
            RxPacketSlotID         => ICAPRingBufferSlotID,
            RxPacketSlotType       => ICAPRingBufferSlotType,
            RxPacketSlotStatus     => ICAPRingBufferSlotStatus,
            RxPacketSlotTypeStatus => open,
            -- Transmission port
            TxPacketByteEnable     => ICAPWriterRingBufferDataEnable,
            TxPacketDataRead       => ICAPWriterRingBufferDataRead,
            TxPacketData           => ICAPWriterRingBufferDataIn,
            TxPacketAddress        => ICAPWriterRingBufferAddress,
            TxPacketSlotClear      => ICAPWriterRingBufferSlotClear,
            TxPacketSlotID         => ICAPWriterRingBufferSlotID,
            TxPacketSlotStatus     => ICAPWriterRingBufferSlotStatus,
            TxPacketSlotTypeStatus => ICAPWriterRingBufferSlotTypeStatus
        );

    ICAPWRSM_i : icapwritersm
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => 7
        )
        port map(
            icap_clk                 => icap_clk,
            icap_reset               => icap_reset,
            RingBufferSlotID         => ICAPWriterRingBufferSlotID,
            RingBufferSlotClear      => ICAPWriterRingBufferSlotClear,
            RingBufferSlotStatus     => ICAPWriterRingBufferSlotStatus,
            RingBufferSlotTypeStatus => ICAPWriterRingBufferSlotTypeStatus,
            RingBufferDataRead       => ICAPWriterRingBufferDataRead,
            RingBufferDataEnable     => ICAPWriterRingBufferDataEnable,
            RingBufferDataIn         => ICAPWriterRingBufferDataIn,
            RingBufferAddress        => ICAPWriterRingBufferAddress,
            -- Handshaking signals
            -- Status signal to show when the packet sender is busy
            SenderBusy               => SenderBusy,
            -- ICAP Writer Response
            ICAPWriteDone            => ICAPWriteDone,
            ICAPWriteResponseSent    => ICAPWriteResponseSent,
            ICAPIPIdentification     => ICAPIPIdentification,
            ICAPProtocolID           => ICAPProtocolID,
            ICAPProtocolSequence     => ICAPProtocolSequence,
            --ICAPE3 Interface            
            ICAP_CSIB                => ICAP_CSIB,
            ICAP_RDWRB               => ICAP_RDWRB,
            ICAP_AVAIL               => ICAP_AVAIL,
            ICAP_DataIn              => ICAP_DataIn,
            ICAP_DataOut             => ICAP_DataOut,
            ICAP_Readback            => ICAP_ReadBack            
        );

    ----------------------------------------------------------------------------
    --                           Transmit path                                 -
    ----------------------------------------------------------------------------
    SenderFilledSlotCounterProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            SynchSenderRingBufferSlotSet <= SynchSenderRingBufferSlotSet(2 downto 0) & SenderRingBufferPacketSlotSet;
            if (SynchSenderRingBufferSlotSet = "0111") then
                -- Catch the SlotSet signal from the slow icap_clk.
                -- This is a CDC signal 
                lSynchSenderRingBufferSlotSet <= '1';
            else
                lSynchSenderRingBufferSlotSet <= '0';
            end if;

            if (axis_reset = '1') then
                lSenderFilledSlots <= (others => '0');
            else
                if ((SenderRingBufferSlotClear = '0') and (lSynchSenderRingBufferSlotSet = '1')) then
                    lSenderFilledSlots <= lSenderFilledSlots + 1;
                elsif ((SenderRingBufferSlotClear = '1') and (lSynchSenderRingBufferSlotSet = '0')) then
                    lSenderFilledSlots <= lSenderFilledSlots - 1;
                else
                    -- Its a neutral operation
                    lSenderFilledSlots <= lSenderFilledSlots;
                end if;
            end if;
        end if;
    end process SenderFilledSlotCounterProc;

    SenderRingBufferSlotsFilled <= std_logic_vector(lSenderFilledSlots);

    UDPSender_i : macifudpsender
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH
        )
        port map(
            axis_clk                 => axis_clk,
            axis_reset               => axis_reset,
            RingBufferSlotID         => SenderRingBufferSlotID,
            RingBufferSlotClear      => SenderRingBufferSlotClear,
            RingBufferSlotStatus     => SenderRingBufferSlotStatus,
            RingBufferSlotTypeStatus => SenderRingBufferSlotTypeStatus,
            RingBufferSlotsFilled    => SenderRingBufferSlotsFilled,
            RingBufferDataRead       => SenderRingBufferDataRead,
            RingBufferDataEnable     => SenderRingBufferDataEnable,
            RingBufferDataIn         => SenderRingBufferDataIn,
            RingBufferAddress        => SenderRingBufferAddress,
            axis_tx_tpriority        => axis_tx_tpriority,
            axis_tx_tdata            => axis_tx_tdata,
            axis_tx_tvalid           => axis_tx_tvalid,
            axis_tx_tready           => axis_tx_tready,
            axis_tx_tkeep            => axis_tx_tkeep,
            axis_tx_tlast            => axis_tx_tlast
        );

    TXRingBuffer_i : dualportpacketringbuffer
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH,
            G_DATA_WIDTH => 512
        )
        port map(
            TxClk                  => axis_clk,
            RxClk                  => icap_clk,
            -- Transmission port
            TxPacketByteEnable     => SenderRingBufferDataEnable,
            TxPacketDataRead       => SenderRingBufferDataRead,
            TxPacketData           => SenderRingBufferDataIn,
            TxPacketAddress        => SenderRingBufferAddress,
            TxPacketSlotClear      => SenderRingBufferSlotClear,
            TxPacketSlotID         => SenderRingBufferSlotID,
            TxPacketSlotStatus     => SenderRingBufferSlotStatus,
            TxPacketSlotTypeStatus => SenderRingBufferSlotTypeStatus,
            -- Reception port
            RxPacketByteEnable     => SenderRingBufferPacketByteEnable,
            RxPacketDataWrite      => SenderRingBufferPacketDataWrite,
            RxPacketData           => SenderRingBufferPacketData,
            RxPacketAddress        => SenderRingBufferPacketAddress,
            RxPacketSlotSet        => SenderRingBufferPacketSlotSet,
            RxPacketSlotID         => SenderRingBufferPacketSlotID,
            RxPacketSlotType       => SenderRingBufferPacketSlotType,
            RxPacketSlotStatus     => SenderRingBufferPacketSlotStatus,
            RxPacketSlotTypeStatus => open
        );

    TXResponder_i : protocolresponderprconfigsm
        generic map(
            G_SLOT_WIDTH => G_SLOT_WIDTH,
            G_ADDR_WIDTH => G_ADDR_WIDTH
        )
        port map(
            icap_clk                   => icap_clk,
            icap_reset                 => icap_reset,
            -- Source IP Addressing information
            ServerMACAddress           => ServerMACAddress,
            ServerIPAddress            => ServerIPAddress,
            ServerUDPPort              => std_logic_vector(to_unsigned(G_UDP_SERVER_PORT, 16)),
            -- Response IP Addressing information
            --TODO--
            -- Source all addressing data 
            ClientMACAddress           => ClientMACAddress,
            ClientIPAddress            => ClientIPAddress,
            ClientUDPPort              => ClientUDPPort,
            -- Packet Readout in addressed bus format
            SenderRingBufferSlotID     => SenderRingBufferPacketSlotID,
            SenderRingBufferSlotSet    => SenderRingBufferPacketSlotSet,
            SenderRingBufferSlotType   => SenderRingBufferPacketSlotType,
            SenderRingBufferDataWrite  => SenderRingBufferPacketDataWrite,
            -- Enable[0] is a special bit (we assume always 1 when packet is valid)
            -- we use it to save TLAST
            SenderRingBufferDataEnable => SenderRingBufferPacketByteEnable,
            SenderRingBufferDataOut    => SenderRingBufferPacketData,
            SenderRingBufferAddress    => SenderRingBufferPacketAddress,
            -- Handshaking signals
            -- Status signal to show when the packet sender is busy
            SenderBusy                 => SenderBusy,
            -- Protocol Error 
            ProtocolError              => ProtocolError,
            ProtocolErrorClear         => ProtocolErrorClear,
            ProtocolErrorID            => ProtocolErrorID,
            ProtocolIPIdentification   => ProtocolIPIdentification,
            ProtocolID                 => ProtocolID,
            ProtocolSequence           => ProtocolSequence,
            -- ICAP Writer Response
            ICAPWriteDone              => ICAPWriteDone,
            ICAPWriteResponseSent      => ICAPWriteResponseSent,
            ICAPIPIdentification       => ICAPIPIdentification,
            ICAPProtocolID             => ICAPProtocolID,
            ICAPProtocolSequence       => ICAPProtocolSequence,
            --ICAPE3 interface
            ICAP_PRDONE                => ICAP_PRDONE,
            ICAP_PRERROR               => ICAP_PRERROR,
            ICAP_Readback              => ICAP_ReadBack            
        );

end architecture rtl;
