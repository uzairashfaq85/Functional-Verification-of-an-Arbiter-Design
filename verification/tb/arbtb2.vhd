-- ============================================================
-- File       : arbtb2.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: DUT + checker integration testbench with clean
--              protocol-compliant command stimuli.
-- ============================================================

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;
use std.env.stop;

entity arbtb2 is
end;

architecture bhv of arbtb2 is

    signal clk, cmd, rst_n : std_logic := '0';
    signal protocol_violation : std_logic;
    signal req, gnt  : std_logic_vector(0 to 2) := "000";
    signal fails     : std_logic_vector(0 to 3);
    signal n1,n2,n3  : signed (0 to 1);

begin

    ------------------------------------------------------------
    -- Clock and reset
    ------------------------------------------------------------
    clk   <= not clk after 10 ns;

    ------------------------------------------------------------
    -- DUT
    ------------------------------------------------------------
    m_arbiter : entity work.arb1(Behavioral)
        port map (
            clk   => clk,
            cmd   => cmd,
            rst_n => rst_n,
            req   => req,
            n1    => n1,
            n2    => n2,
            n3    => n3,
            gnt   => gnt
        );

    ------------------------------------------------------------
    -- Checkers
    ------------------------------------------------------------
    m_property_checker : entity work.property_checker(bhv)
        port map (clk, cmd, req, gnt, fails);

    m_protocol_checker : entity work.protocol_checker(bhv)
        port map (clk, cmd, req, protocol_violation);

    monitor_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '1' then
                assert fails = "0000"
                    report "Property checker failure detected"
                    severity error;
                assert protocol_violation = '0'
                    report "Protocol violation detected"
                    severity error;
            end if;
        end if;
    end process;

    ------------------------------------------------------------
    -- CLEAN STIMULUS
    ------------------------------------------------------------
    stim_proc : process
    begin
        rst_n <= '0';
        cmd <= '0';
        req <= "000";
        wait for 4 * 10 ns;
        rst_n <= '1';
        wait for 2 * 10 ns;

        ------------------------------------------------
        -- Helper macro pattern (conceptual)
        ------------------------------------------------
        -- cmd=1 for 1 cycle
        -- req valid only during cmd
        -- 4 idle cycles afterward
        ------------------------------------------------

        -- R1
        wait until rising_edge(clk);
        cmd <= '1'; req <= "001";
        wait until rising_edge(clk);
        cmd <= '0'; req <= "000";
        wait for 4 * 10 ns;

        -- R2
        wait until rising_edge(clk);
        cmd <= '1'; req <= "010";
        wait until rising_edge(clk);
        cmd <= '0'; req <= "000";
        wait for 4 * 10 ns;

        -- R3
        wait until rising_edge(clk);
        cmd <= '1'; req <= "100";
        wait until rising_edge(clk);
        cmd <= '0'; req <= "000";
        wait for 4 * 10 ns;

        -- R1 & R2
        wait until rising_edge(clk);
        cmd <= '1'; req <= "011";
        wait until rising_edge(clk);
        cmd <= '0'; req <= "000";
        wait for 4 * 10 ns;

        -- R1 & R3
        wait until rising_edge(clk);
        cmd <= '1'; req <= "101";
        wait until rising_edge(clk);
        cmd <= '0'; req <= "000";
        wait for 4 * 10 ns;

        -- R2 & R3
        wait until rising_edge(clk);
        cmd <= '1'; req <= "110";
        wait until rising_edge(clk);
        cmd <= '0'; req <= "000";
        wait for 4 * 10 ns;

        -- All
        wait until rising_edge(clk);
        cmd <= '1'; req <= "111";
        wait until rising_edge(clk);
        cmd <= '0'; req <= "000";
        wait for 6 * 10 ns;

        stop;
        wait;
    end process;

end bhv;

