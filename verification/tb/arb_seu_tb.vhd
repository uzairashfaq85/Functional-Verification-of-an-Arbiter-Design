-- ============================================================
-- File       : arb_seu_tb.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Testbench for SEU-enabled arbiter variant.
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.stop;

entity arb_seu_tb is
end arb_seu_tb;

architecture bhv of arb_seu_tb is

    signal clk        : std_logic := '0';
    signal rst_n      : std_logic := '0';
    signal cmd        : std_logic := '0';
    signal req        : std_logic_vector(0 to 2) := "000";

    signal seu_inject : std_logic := '0';
    signal seu_mask   : std_logic_vector(0 to 2) := "000";

    signal gnt        : std_logic_vector(0 to 2);
    signal seu_error  : std_logic;
    signal seen_seu_error : std_logic := '0';

begin

    ------------------------------------------------------------
    -- Clock
    ------------------------------------------------------------
    clk <= not clk after 10 ns;

    ------------------------------------------------------------
    -- DUT
    ------------------------------------------------------------
    uut : entity work.arb_seu
        port map (
            clk        => clk,
            rst_n      => rst_n,
            cmd        => cmd,
            req        => req,
            seu_inject => seu_inject,
            seu_mask   => seu_mask,
            gnt        => gnt,
            seu_error  => seu_error
        );

    monitor_proc : process(clk)
    begin
        if rising_edge(clk) then
            if seu_error = '1' then
                seen_seu_error <= '1';
            end if;
        end if;
    end process;

    ------------------------------------------------------------
    -- Stimulus
    ------------------------------------------------------------
    stim_proc : process
    begin
        -- Reset
        rst_n <= '0';
        wait for 20 ns;
        rst_n <= '1';

        -- Valid request
        wait for 10 ns;
        req <= "011";
        cmd <= '1';

        wait for 20 ns;
        cmd <= '0';

        wait for 80 ns;
        assert seen_seu_error = '1'
            report "SEU injection was not detected"
            severity error;

        stop;
        wait;
    end process;

    ------------------------------------------------------------
    -- SEU injection at 50 ns (during grant)
    ------------------------------------------------------------
    seu_proc : process
    begin
        wait for 50 ns;
        seu_mask   <= "010";   -- flip bit 1
        seu_inject <= '1';

        wait for 20 ns;
        seu_inject <= '0';

        wait;
    end process;

end bhv;

