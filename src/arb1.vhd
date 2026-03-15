-- ============================================================
-- File       : arb1.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: 3-requester arbiter with fairness counters and
--              2-cycle response latency after valid cmd.
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity arb1 is
    port (
        clk   : in  std_logic;
        cmd   : in  std_logic;
        rst_n : in  std_logic;		
        req   : in  std_logic_vector(0 to 2);
        N1, N2, N3 : out signed(0 to 1);
        gnt   : out std_logic_vector(0 to 2)
    );
end arb1;

architecture Behavioral of arb1 is
    signal selected_gnt : std_logic_vector(0 to 2) := "000";
    signal pipeline     : integer range 0 to 3 := 0;

begin

process (clk, rst_n)
    variable N11 : signed(0 to 1) := (others => '0');
    variable N22 : signed(0 to 1) := (others => '0');
    variable N33 : signed(0 to 1) := (others => '0');
begin

    if rst_n = '0' then
        N11 := (others => '0');
        N22 := (others => '0');
        N33 := (others => '0');
        selected_gnt <= "000";
        pipeline <= 0;
        gnt <= "000";
    elsif rising_edge(clk) then
        if pipeline = 0 and cmd = '1' then
            case req is
                when "011" =>
                    if N11 > N22 then
                        selected_gnt <= "010";
                        N22 := N22 + 1;
                        N11 := N11 - 1;
                    else
                        selected_gnt <= "001";
                        N11 := N11 + 1;
                        N22 := N22 - 1;
                    end if;
                when "101" =>
                    if N11 > N33 then
                        selected_gnt <= "100";
                        N33 := N33 + 1;
                        N11 := N11 - 1;
                    else
                        selected_gnt <= "001";
                        N11 := N11 + 1;
                        N33 := N33 - 1;
                    end if;
                when "110" =>
                    if N22 > N33 then
                        selected_gnt <= "100";
                        N33 := N33 + 1;
                        N22 := N22 - 1;
                    else
                        selected_gnt <= "010";
                        N22 := N22 + 1;
                        N33 := N33 - 1;
                    end if;
                when "111" =>
                    if (N11 <= N22) and (N11 <= N33) then
                        selected_gnt <= "001";
                        N11 := N11 + 1;
                        N22 := N22 - 1;
                        N33 := N33 - 1;
                    elsif (N22 <= N11) and (N22 <= N33) then
                        selected_gnt <= "010";
                        N22 := N22 + 1;
                        N11 := N11 - 1;
                        N33 := N33 - 1;
                    else
                        selected_gnt <= "100";
                        N33 := N33 + 1;
                        N11 := N11 - 1;
                        N22 := N22 - 1;
                    end if;
                when "001" => selected_gnt <= "001";
                when "010" => selected_gnt <= "010";
                when "100" => selected_gnt <= "100";
                when others =>
                    selected_gnt <= "000";
            end case;
            pipeline <= 1;
        end if;

        case pipeline is
            when 1 =>
                pipeline <= 2;
            when 2 =>
                gnt <= selected_gnt;
                pipeline <= 3;
            when 3 =>
                gnt <= "000";
                pipeline <= 0;
            when others =>
                null;
        end case;
    end if;

    N1 <= N11;
    N2 <= N22;
    N3 <= N33;

end process;

end Behavioral;
