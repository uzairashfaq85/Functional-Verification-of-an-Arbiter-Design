-- ============================================================
-- File       : protocol_checker1.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Compatibility wrapper preserving legacy entity
--              name `protocol_checker1`.
-- ============================================================

library IEEE;
use IEEE.std_logic_1164.all;

entity protocol_checker1 is
    port(
        clk, cmd : in std_logic;
        req : in std_logic_vector(0 to 2);
        protocol_violation : out std_logic := '0'
    );
end entity;

architecture wrapper of protocol_checker1 is
begin
    u_protocol_checker : entity work.protocol_checker
        port map (
            clk => clk,
            cmd => cmd,
            req => req,
            protocol_violation => protocol_violation
        );
end wrapper;
