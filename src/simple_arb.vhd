-- ============================================================
-- File       : simple_arb.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Baseline fixed-priority arbiter (R1 > R2 > R3).
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity simple_arb is
    port(  cmd,clk,rst_n : in std_logic;
           req         : in std_logic_vector(0 to 2);
           gnt         : out std_logic_vector(0 to 2));
end simple_arb;

architecture rtl of simple_arb is
    signal gnt_temp : std_logic_vector(0 to 2) := "000";

begin

    process(clk, rst_n)
        variable next_gnt : std_logic_vector(0 to 2);
    begin
        if rst_n = '0' then
            gnt_temp <= "000";
            gnt <= "000";
        elsif rising_edge(clk) then
            next_gnt := "000";

            if cmd = '1' then
                case req is
                    when "001" => next_gnt := "001";
                    when "010" => next_gnt := "010";
                    when "011" => next_gnt := "001";
                    when "100" => next_gnt := "100";
                    when "101" => next_gnt := "001";
                    when "110" => next_gnt := "010";
                    when "111" => next_gnt := "001";
                    when others => next_gnt := "000";
                end case;
            end if;

            gnt_temp <= next_gnt;
            gnt <= next_gnt;
        end if;
    end process;

end rtl;