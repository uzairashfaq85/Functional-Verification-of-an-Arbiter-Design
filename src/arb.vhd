-- ============================================================
-- File       : arb.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Compatibility wrapper preserving legacy entity
--              name `arb` and mapping to `arb1` implementation.
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity arb is
    port (
        clk   : in  std_logic;
        cmd   : in  std_logic;
        rst_n : in  std_logic;
        req   : in  std_logic_vector(0 to 2);
        N1, N2, N3 : out signed(0 to 1);
        gnt   : out std_logic_vector(0 to 2)
    );
end arb;

architecture wrapper of arb is
begin
    u_arb1 : entity work.arb1
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
end wrapper;
