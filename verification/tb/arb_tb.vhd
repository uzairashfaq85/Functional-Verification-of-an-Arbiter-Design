-- ============================================================
-- File       : arb_tb.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Structural integration testbench wrapper for
--              immediate compile/run with legacy top name `arb_tb`.
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.stop;

entity arb_tb is
end entity arb_tb;

architecture bhv of arb_tb is
    signal clk, rst_n : std_logic := '0';
    signal cmd : std_logic;
    signal req, gnt : std_logic_vector(0 to 2);
    signal fails : std_logic_vector(0 to 3);
    signal protocol_violation : std_logic;
    signal n1, n2, n3 : signed(0 to 1);
begin

    clk <= not clk after 10 ns;

    u_arb : entity work.arb
        port map (
            clk   => clk,
            rst_n => rst_n,
            cmd   => cmd,
            req   => req,
            n1    => n1,
            n2    => n2,
            n3    => n3,
            gnt   => gnt
        );

    u_driver : entity work.driver
        port map (
            clk => clk,
            cmd => cmd,
            req => req
        );

    u_property : entity work.property_checker
        port map (
            clk   => clk,
            cmd   => cmd,
            req   => req,
            gnt   => gnt,
            fails => fails
        );

    u_protocol : entity work.protocol_checker
        port map (
            clk => clk,
            cmd => cmd,
            req => req,
            protocol_violation => protocol_violation
        );

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

    sim_proc : process
    begin
        rst_n <= '0';
        wait for 40 ns;
        rst_n <= '1';
        wait for 1200 ns;
        stop;
        wait;
    end process;

end bhv;
