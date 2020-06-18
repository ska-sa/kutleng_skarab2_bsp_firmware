-- A simple module to take an AXI data stream and insert
-- some number of zero bytes in front of it.
-- Useful for (eg) creating space in a data stream for
-- downstream header insertion

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axioffseter is
    generic(
        G_AXIS_DATA_WIDTH : natural := 512;
        G_OFFSET_BYTES : natural := 42;
        G_INCLUDE_ILA : boolean := false
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

end entity axioffseter;

architecture rtl of axioffseter is
    COMPONENT axioffseter_ila    
    PORT (
        clk : IN STD_LOGIC;
        probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe2 : IN STD_LOGIC_VECTOR(511 DOWNTO 0); 
        probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe4 : IN STD_LOGIC_VECTOR(63 DOWNTO 0); 
        probe5 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe6 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
    END COMPONENT;

    signal din_l   : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH - (8*G_OFFSET_BYTES)) - 1 downto 0);
    --signal din_hz  : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH - (8*G_OFFSET_BYTES)) - 1 downto 0);
    signal din_h   : STD_LOGIC_VECTOR((8*G_OFFSET_BYTES) - 1 downto 0);
    signal din_hz   : STD_LOGIC_VECTOR((8*G_OFFSET_BYTES) - 1 downto 0);

    signal keepin_l   : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - G_OFFSET_BYTES - 1 downto 0);
    signal keepin_h   : STD_LOGIC_VECTOR(G_OFFSET_BYTES - 1 downto 0);
    signal keepin_hz  : STD_LOGIC_VECTOR(G_OFFSET_BYTES - 1 downto 0);

    signal user_inz : STD_LOGIC;

    signal dout_l  : STD_LOGIC_VECTOR((8*G_OFFSET_BYTES) - 1 downto 0);
    signal dout_h  : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH - (8*G_OFFSET_BYTES)) - 1 downto 0);
    signal keepout_h  : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - G_OFFSET_BYTES - 1 downto 0);
    signal keepout_l  : STD_LOGIC_VECTOR(G_OFFSET_BYTES - 1 downto 0);
    signal valid_out : STD_LOGIC;
    signal last_out : STD_LOGIC;
    signal user_out : STD_LOGIC;
    signal dout : STD_LOGIC_VECTOR(G_AXIS_DATA_WIDTH - 1 downto 0);
    signal keepout : STD_LOGIC_VECTOR((G_AXIS_DATA_WIDTH / 8) - 1 downto 0);
    signal ready_out : STD_LOGIC;


    type OffsetterState_t is (
        ResetState,
        PassthroughState,
        SendLastState
    );
    signal OffsetterState : OffsetterState_t := ResetState;
begin

    din_l <= axis_tdata((G_AXIS_DATA_WIDTH - (8*G_OFFSET_BYTES)) - 1 downto 0);
    din_h <= axis_tdata(G_AXIS_DATA_WIDTH - 1 downto G_AXIS_DATA_WIDTH - (8*G_OFFSET_BYTES));
    keepin_l  <= axis_tkeep((G_AXIS_DATA_WIDTH / 8) - G_OFFSET_BYTES - 1 downto 0);
    keepin_h  <= axis_tkeep((G_AXIS_DATA_WIDTH / 8) - 1 downto (G_AXIS_DATA_WIDTH / 8) - G_OFFSET_BYTES);

    dout(G_AXIS_DATA_WIDTH - 1 downto (8*G_OFFSET_BYTES)) <= dout_h;
    dout((8*G_OFFSET_BYTES) - 1 downto 0) <= dout_l;
    keepout((G_AXIS_DATA_WIDTH / 8) - 1 downto G_OFFSET_BYTES) <= keepout_h;
    keepout(G_OFFSET_BYTES - 1 downto 0) <= keepout_l;
    axim_tdata <= dout;
    axim_tkeep <= keepout;
    axim_tvalid <= valid_out;
    axim_tlast <= last_out;
    axim_tuser <= user_out;
    axis_tready <= ready_out and axim_tready; -- Pass upstream back-pressure without delay 

    DelayerProc: process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if ((axis_tvalid = '1') and (axim_tready = '1') and (ready_out = '1')) then
                din_hz  <= din_h;
                keepin_hz  <= keepin_h;
                user_inz <= axis_tuser;
            end if;
        end if;
    end process;

    OffsetterStateProc : process(axis_clk)
    begin
        if rising_edge(axis_clk) then
            if (axis_rst = '1') then
                OffsetterState <= ResetState;
            else
                -- defaults
                ready_out <= '1';
                user_out <= axis_tuser;
                valid_out <= axis_tvalid;
                last_out <= '0';
                case (OffsetterState) is
                    when ResetState =>
                        -- After a reset, or after an end of frame
                        -- Wait for the next valid word, and then zeropad it
                        dout_h <= din_l;
                        dout_l <= (others => '0');
                        keepout_h <= keepin_l;
                        keepout_l <= (others => '1');
                        if ((axis_tvalid = '1') and (axim_tready = '1')) then
                            -- Special case if first word is also the last
                            if (axis_tlast = '1') then
                                -- If we have a complete word after padding,
                                -- send it and go back to the initial state
                                if (unsigned(keepin_h) = 0) then
                                    last_out <= '1';
                                    OffsetterState <= ResetState;
                                else
                                    -- Otherwise, we need an extra cycle
                                    -- to send whatever partial word is left
                                    last_out <= '0';
                                    OffsetterState <= SendLastState;
                                    ready_out <= '0'; 
                                end if;
                            end if;
                            OffsetterState <= PassthroughState;
                        end if;
                    when PassthroughState =>
                        dout_h <= din_l;
                        dout_l <= din_hz;
                        keepout_h <= keepin_l;
                        keepout_l <= keepin_hz;
                        if (axis_tvalid = '1' and axis_tlast = '1' and axim_tready = '1') then
                            -- When the last strobe comes, if
                            -- we have a complete word after padding,
                            -- send it and go back to the initial state
                            if (unsigned(keepin_h) = 0) then
                                last_out <= '1';
                                OffsetterState <= ResetState;
                            else
                                -- Otherwise, we need an extra cycle
                                -- to send whatever partial word is left
                                last_out <= '0';
                                OffsetterState <= SendLastState;
                                ready_out <= '0'; 
                            end if;
                        end if;
                    when SendLastState =>
                        dout_h <= (others => '0');
                        dout_l <= din_hz;
                        keepout_h <= (others => '0');
                        keepout_l <= keepin_hz;
                        valid_out <= '1';
                        last_out <= '1';
                        user_out <= user_inz;
                        if (axim_tready = '1') then
                            OffsetterState <= ResetState;
                        end if;
                    when others =>
                        OffsetterState <= ResetState;
                end case;
            end if;
        end if;
    end process;
    
    
    ila_gen: if G_INCLUDE_ILA = true generate
        axim_ila_inst : axioffseter_ila
            PORT MAP (
                clk => axis_clk,
                probe0(0) => user_out, 
                probe1(0) => valid_out, 
                probe2 => dout, 
                probe3(0) => axim_tready, 
                probe4 => keepout, 
                probe5(0) => last_out,
                probe6(0) => axis_rst
            );
        axis_ila_inst : axioffseter_ila
            PORT MAP (
                clk => axis_clk,
                probe0(0) => axis_tuser, 
                probe1(0) => axis_tvalid, 
                probe2 => axis_tdata, 
                probe3(0) => ready_out, 
                probe4 => axis_tkeep, 
                probe5(0) => axis_tlast,
                probe6(0) => axis_rst
            );
    end generate ila_gen;

end architecture;
