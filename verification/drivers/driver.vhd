-- ============================================================
-- File       : driver.vhd
-- Created    : Nov 2025
-- Project    : Functional Verification of an Arbiter Design
-- Description: Command/request stimulus driver for directed and
--              semi-randomized arbitration request sequencing.
-- ============================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity driver is
    port(
        clk : in  std_logic;
        cmd : out std_logic;
        req : out std_logic_vector(0 to 2)
    );
end entity;

architecture bhv of driver is
    type state_t is (IDLE, REQ_SET, CMD_PULSE, CLEANUP);
    signal state   : state_t := IDLE;
    signal counter : integer range 1 to 7 := 1;
    signal req_reg : std_logic_vector(0 to 2) := "001";
begin

process(clk)
begin
    if rising_edge(clk) then
        -- defaults
        cmd <= '0';
        req <= "000";

        case state is

            when IDLE =>
                req_reg <= std_logic_vector(to_unsigned(counter, 3));
                state   <= REQ_SET;

            when REQ_SET =>
                req <= req_reg;         -- stable BEFORE cmd
                state <= CMD_PULSE;

            when CMD_PULSE =>
                req <= req_reg;
                cmd <= '1';             -- one-cycle pulse
                state <= CLEANUP;

            when CLEANUP =>
                counter <= (counter mod 7) + 1;
                state <= IDLE;

        end case;
    end if;
end process;

end bhv;

