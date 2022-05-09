----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2022 09:38:24 AM
-- Design Name: 
-- Module Name: fast_mod_control_unit - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fast_mod_control_unit is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           a : in coefficient_t;
           m : in coefficient_t;
           m_mult_multiplier : in coefficient_t;
           multiplier_write : out STD_LOGIC;
           m_write : out STD_LOGIC;
           a_write : out STD_LOGIC;
           multiplier_sel : out STD_LOGIC;
           a_sel : out STD_LOGIC;
           multiplier_output_sel : out STD_LOGIC;
           done : out STD_LOGIC);
end fast_mod_control_unit;

architecture Behavioral of fast_mod_control_unit is
    TYPE STATE_TYPE IS (idle,
                        outer_loop, 
                        inner_loop,
                        calc_inner,
                        calc_outer,
                        done_state);
    signal state : STATE_TYPE := idle;

begin

    fsm : process(clk, reset)
    begin
        if reset = '1'  then
            state <= idle;
        elsif rising_edge(clk) then
            case state is
                when idle =>
                    if start = '1' then
                        state <= outer_loop;
                    else
                        state <= idle;
                    end if;
                when outer_loop =>
                    if a >= m then
                        state <= inner_loop;
                    else
                        state <= done_state;
                    end if;
                when inner_loop =>
                    if a >= m_mult_multiplier then
                        state <= calc_inner;
                    else
                        state <= calc_outer;
                    end if;
                when calc_inner =>
                    state <= inner_loop;
                when calc_outer =>
                    state <= outer_loop;
                when done_state =>
                    state <= done_state;
            end case;
        end if;
    end process;
    
    combinational : process(state)
    begin
        case state is
            when idle =>
                multiplier_write        <= '1';
                m_write                 <= '1';
                a_write                 <= '1';
                multiplier_sel          <= '1';
                a_sel                   <= '1';
                multiplier_output_sel   <= '0';
                done                    <= '0';
            when outer_loop =>
                multiplier_write        <= '0';
                m_write                 <= '0';
                a_write                 <= '0';
                multiplier_sel          <= '0';
                a_sel                   <= '0';
                multiplier_output_sel   <= '0';
                done                    <= '0';
            when inner_loop =>
                multiplier_write        <= '0';
                m_write                 <= '0';
                a_write                 <= '0';
                multiplier_sel          <= '0';
                a_sel                   <= '0';
                multiplier_output_sel   <= '0';
                done                    <= '0';
            when calc_inner =>
                multiplier_write        <= '1';
                m_write                 <= '0';
                a_write                 <= '1';
                multiplier_sel          <= '0';
                a_sel                   <= '0';
                multiplier_output_sel   <= '0';
                done                    <= '0';
            when calc_outer =>
                multiplier_write        <= '1';
                m_write                 <= '0';
                a_write                 <= '0';
                multiplier_sel          <= '0';
                a_sel                   <= '0';
                multiplier_output_sel   <= '1';
                done                    <= '0';
            when done_state =>
                multiplier_write        <= '0';
                m_write                 <= '0';
                a_write                 <= '0';
                multiplier_sel          <= '0';
                a_sel                   <= '0';
                multiplier_output_sel   <= '0';
                done                    <= '1';
        end case;
    end process;
end Behavioral;
