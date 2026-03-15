-- ============================================================
-- File       : arb_seu.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Arbiter variant with SEU fault injection and
--              one-hot countermeasure signaling.
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity arb_seu is
    port (
        clk        : in  std_logic;
        rst_n      : in  std_logic;
        cmd        : in  std_logic;
        req        : in  std_logic_vector(0 to 2);

        -- SEU control (from TB)
        seu_inject : in  std_logic;
        seu_mask   : in  std_logic_vector(0 to 2);

        gnt        : out std_logic_vector(0 to 2);
        seu_error  : out std_logic
    );
end arb_seu;

architecture rtl of arb_seu is

    signal selected_gnt : std_logic_vector(0 to 2) := "000";
    signal gnt_temp_seu : std_logic_vector(0 to 2) := "000";
    signal pipeline     : integer range 0 to 3 := 0;

begin

    ------------------------------------------------------------
    -- Arbiter core
    ------------------------------------------------------------
    process(clk)
        variable grant_now : std_logic_vector(0 to 2);
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                selected_gnt <= "000";
                gnt_temp_seu <= "000";
                pipeline <= 0;

            else
                if pipeline = 0 and cmd = '1' then
                    case req is
                        when "001" => selected_gnt <= "001";
                        when "010" => selected_gnt <= "010";
                        when "100" => selected_gnt <= "100";
                        when "011" => selected_gnt <= "001";
                        when "101" => selected_gnt <= "001";
                        when "110" => selected_gnt <= "010";
                        when "111" => selected_gnt <= "001";
                        when others => selected_gnt <= "000";
                    end case;
                    pipeline <= 1;
                end if;

                case pipeline is
                    when 1 =>
                        pipeline <= 2;
                    when 2 =>
                        if seu_inject = '1' then
                            grant_now := selected_gnt xor seu_mask;
                        else
                            grant_now := selected_gnt;
                        end if;
                        gnt_temp_seu <= grant_now;
                        pipeline <= 3;
                    when 3 =>
                        gnt_temp_seu <= "000";
                        pipeline <= 0;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    gnt <= gnt_temp_seu;

    ------------------------------------------------------------
    -- Countermeasure: one-hot checker
    ------------------------------------------------------------
    seu_error <= '1' when (
        gnt_temp_seu /= "000" and
        gnt_temp_seu /= "001" and
        gnt_temp_seu /= "010" and
        gnt_temp_seu /= "100"
    ) else '0';

end rtl;

