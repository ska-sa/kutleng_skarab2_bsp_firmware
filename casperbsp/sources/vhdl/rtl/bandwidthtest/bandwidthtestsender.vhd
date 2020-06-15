--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : macifudpsender - rtl                                     -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : The macifudpsender module sends UDP/IP data streams, it  -
--                    saves the streams on a packetringbuffer.                 -
--                    TODO                                                     -
--                    Improve handling and framing of UDP data,without needing -
--                    to mirror the UDP data settings. Must calculate CRC,etc  -
--                                                                             -
-- Dependencies     : N/A                                                      -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bandwidthtestsender is
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
end entity bandwidthtestsender;

architecture rtl of bandwidthtestsender is

    type AxisUDPSenderSM_t is (
        InitialiseSt,                   -- On the reset state
        CheckSlotSt,
        NextSlotSt,
        ProcessPacketSt,
        ClearSlotSt
    );
    signal StateVariable      : AxisUDPSenderSM_t := InitialiseSt;
    -- Tuples registers
    signal lRingBufferSlotID  : unsigned(G_SLOT_WIDTH - 1 downto 0);
    signal lRingBufferAddress : unsigned(G_ADDR_WIDTH - 1 downto 0);
    signal ltvalid            : std_logic;
    signal ldtvalid           : std_logic;

begin
    RingBufferSlotID  <= std_logic_vector(lRingBufferSlotID);
    RingBufferAddress <= std_logic_vector(lRingBufferAddress);
    FilledSlotsProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            axis_tx_tpriority <= RingBufferSlotsFilled;
        end if;
    end process FilledSlotsProc;

    TValidProc : process(StateVariable, ltvalid, ldtvalid)
    begin
        if (((StateVariable = ProcessPacketSt) and (ltvalid = '1') and (ldtvalid = '1')) or ((StateVariable = NextSlotSt) and (ltvalid = '1'))) then
            axis_tx_tvalid <= '1';
        else
            axis_tx_tvalid <= '0';
        end if;
    end process TValidProc;

    LValidProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (ltvalid = '1') then
                ldtvalid <= '1';
            else
                ldtvalid <= '0';
            end if;
        end if;
    end process LValidProc;

    SynchStateProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_reset = '1') then
                -- Initialize SM on reset
                StateVariable <= InitialiseSt;
            else
                case (StateVariable) is
                    when InitialiseSt =>
                        -- Wait for packet after initialization
                        StateVariable       <= CheckSlotSt;
                        ltvalid             <= '0';
                        axis_tx_tlast       <= '0';
                        lRingBufferAddress  <= (others => '0');
                        RingBufferDataRead  <= '0';
                        RingBufferSlotClear <= '0';
                        lRingBufferSlotID   <= (others => '0');

                    when CheckSlotSt =>
                        lRingBufferAddress <= (others => '0');
                        if (RingBufferSlotStatus = '1') then
                            -- The current slot has data 
                            -- Pull the data 
                            RingBufferDataRead <= '1';
                            StateVariable      <= ProcessPacketSt;
                        else
                            RingBufferDataRead <= '0';
                            StateVariable      <= CheckSlotSt;
                        end if;

                    when NextSlotSt =>
                        -- Go to next Slot
                        lRingBufferSlotID   <= lRingBufferSlotID + 1;
                        lRingBufferAddress  <= (others => '0');
                        ltvalid             <= '0';
                        axis_tx_tlast       <= '0';
                        axis_tx_tdata       <= (others => '0');
                        axis_tx_tkeep       <= (others => '0');
                        RingBufferSlotClear <= '0';
                        RingBufferDataRead  <= '0';
                        StateVariable       <= CheckSlotSt;

                    when ProcessPacketSt =>
                        if (axis_tx_tready = '1') then
                            ltvalid                    <= '1';
                            axis_tx_tdata              <= RingBufferDataIn;
                            axis_tx_tkeep(63 downto 1) <= RingBufferDataEnable(63 downto 1);
                            lRingBufferAddress         <= lRingBufferAddress + 1;

                            if (RingBufferDataEnable(0) = '1') then
                                axis_tx_tlast       <= RingBufferSlotTypeStatus;
                                axis_tx_tkeep(0)    <= RingBufferDataEnable(0);
                                -- This is the last one
                                -- Clear the current slot
                                RingBufferSlotClear <= '1';
                                -- Go to next slot
                                StateVariable       <= NextSlotSt;
                            else
                                -- More data to flow
                                axis_tx_tlast       <= '0';
                                axis_tx_tkeep(0)    <= not RingBufferDataEnable(0);
                                -- read next address
                                -- Keep reading the slot till ready
                                RingBufferSlotClear <= '0';
                                RingBufferDataRead  <= '1';
                                StateVariable       <= ProcessPacketSt;
                            end if;
                        end if;
                    when others =>
                        StateVariable <= InitialiseSt;
                end case;
            end if;
        end if;
    end process SynchStateProc;

end architecture rtl;
