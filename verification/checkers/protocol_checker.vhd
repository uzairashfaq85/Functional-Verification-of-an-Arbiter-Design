-- ============================================================
-- File       : protocol_checker.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Protocol monitor for cmd pulse and request validity.
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity protocol_checker is
    port(
        clk, cmd : in std_logic;
        req : in std_logic_vector(0 to 2);
        protocol_violation : out std_logic := '0'
    );
end entity;

architecture bhv of protocol_checker is
    signal last_cmd : std_logic := '0';
    signal v1, v2   : std_logic := '0';
begin

process(clk)
begin
    if rising_edge(clk) then
        v1 <= '0';
        v2 <= '0';

        if cmd = '1' and last_cmd = '1' then
            v1 <= '1';
        end if;

        if cmd = '1' and req = "000" then
            v2 <= '1';
        end if;

        last_cmd <= cmd;
    end if;
end process;

protocol_violation <= v1 or v2;

end bhv;

