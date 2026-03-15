-- ============================================================
-- File       : property_checker.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Runtime property checks for arbiter outputs.
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity property_checker is
    port(
        clk, cmd : in std_logic;
        req, gnt : in std_logic_vector(0 to 2);
        fails    : out std_logic_vector(0 to 3) := "0000"
    );
end property_checker;

architecture bhv of property_checker is
    signal save_req    : std_logic_vector(0 to 2) := "000";
    signal cmd_pending : std_logic := '0';
    signal count       : integer range 0 to 3 := 0;
begin

process(clk)
begin
    if rising_edge(clk) then
        fails <= "0000";

        if cmd = '1' then
            save_req    <= req;
            cmd_pending <= '1';
            count       <= 1;

        elsif cmd_pending = '1' then
            if count < 3 then
                count <= count + 1;
            end if;

            if count = 2 then
                if gnt /= "001" and gnt /= "010" and gnt /= "100" then
                    fails(0) <= '1';
                end if;

                if (gnt and save_req) = "000" then
                    fails(2) <= '1';
                end if;
            end if;

            if count = 3 then
                cmd_pending <= '0';
                count       <= 0;
            end if;
        end if;

        if cmd_pending = '0' and gnt /= "000" then
            fails(1) <= '1';
        end if;

        fails(3) <= '0';
    end if;
end process;

end bhv;

