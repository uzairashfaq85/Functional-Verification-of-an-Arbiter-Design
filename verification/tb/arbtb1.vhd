-- ============================================================
-- File       : arbtb1.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Directed stimulus testbench for `arb1` fairness
--              behavior and contention scenarios.
-- ============================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use std.env.stop;

ENTITY arbtb1 IS
END arbtb1;

ARCHITECTURE behavior OF arbtb1 IS

    COMPONENT arb1
        PORT(
            clk   : IN  std_logic;
            cmd   : IN  std_logic;
            rst_n : IN  std_logic;
            req   : IN  std_logic_vector(0 to 2);
            N1    : OUT signed(0 to 1);
            N2    : OUT signed(0 to 1);
            N3    : OUT signed(0 to 1);
            gnt   : OUT std_logic_vector(0 to 2)
        );
    END COMPONENT;

    -- Signals
    signal clk   : std_logic := '0';
    signal cmd   : std_logic := '0';
    signal rst_n : std_logic := '0';
    signal req   : std_logic_vector(0 to 2) := "000";
    signal gnt   : std_logic_vector(0 to 2);
    signal N1,N2,N3 : signed(0 to 1);

    constant clk_period : time := 10 ns;

BEGIN

    -- DUT
    uut: arb1
        port map (
            clk   => clk,
            cmd   => cmd,
            rst_n => rst_n,
            req   => req,
            N1    => N1,
            N2    => N2,
            N3    => N3,
            gnt   => gnt
        );

    -- Clock
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus (EDGE-ALIGNED)
    stim_proc : process
    begin
        ------------------------------------------------
        -- Reset
        ------------------------------------------------
        rst_n <= '0';
        cmd   <= '0';
        req   <= "000";
        wait for 2 * clk_period;

        wait until rising_edge(clk);
        rst_n <= '1';

        ------------------------------------------------
        -- 1) Single requester P1
        ------------------------------------------------
        wait until rising_edge(clk);
        cmd <= '1';
        req <= "001";

        wait until rising_edge(clk);
        cmd <= '0';
        req <= "000";

        wait for 3 * clk_period;

        ------------------------------------------------
        -- 2) Single requester P2
        ------------------------------------------------
        wait until rising_edge(clk);
        cmd <= '1';
        req <= "010";

        wait until rising_edge(clk);
        cmd <= '0';
        req <= "000";

        wait for 3 * clk_period;

        ------------------------------------------------
        -- 3) Single requester P3
        ------------------------------------------------
        wait until rising_edge(clk);
        cmd <= '1';
        req <= "100";

        wait until rising_edge(clk);
        cmd <= '0';
        req <= "000";

        wait for 3 * clk_period;

        ------------------------------------------------
        -- 4) Two-request contention P1 & P2
        ------------------------------------------------
        for i in 0 to 3 loop
            wait until rising_edge(clk);
            cmd <= '1';
            req <= "011";

            wait until rising_edge(clk);
            cmd <= '0';
            req <= "000";

            wait for 3 * clk_period;
        end loop;

        ------------------------------------------------
        -- 5) Two-request contention P1 & P3
        ------------------------------------------------
        for i in 0 to 3 loop
            wait until rising_edge(clk);
            cmd <= '1';
            req <= "101";

            wait until rising_edge(clk);
            cmd <= '0';
            req <= "000";

            wait for 3 * clk_period;
        end loop;

        ------------------------------------------------
        -- 6) Two-request contention P2 & P3
        ------------------------------------------------
        for i in 0 to 3 loop
            wait until rising_edge(clk);
            cmd <= '1';
            req <= "110";

            wait until rising_edge(clk);
            cmd <= '0';
            req <= "000";

            wait for 3 * clk_period;
        end loop;

        ------------------------------------------------
        -- 7) Three-request contention
        ------------------------------------------------
        for i in 0 to 5 loop
            wait until rising_edge(clk);
            cmd <= '1';
            req <= "111";

            wait until rising_edge(clk);
            cmd <= '0';
            req <= "000";

            wait for 3 * clk_period;
        end loop;

        ------------------------------------------------
        -- End simulation
        ------------------------------------------------
        stop;
        wait;
    end process;

END behavior;

