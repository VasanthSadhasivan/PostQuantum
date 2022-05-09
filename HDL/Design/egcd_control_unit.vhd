----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/16/2022 10:46:28 AM
-- Design Name: 
-- Module Name: egcd_control_unit - Behavioral
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

entity egcd_control_unit is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           done : out STD_LOGIC;
           b1 : in coefficient_t;
           x1_input_sel : out STD_LOGIC;
           y1_input_sel : out STD_LOGIC;
           b1_input_sel : out STD_LOGIC;
           x_input_sel : out STD_LOGIC;
           y_input_sel : out STD_LOGIC;
           a1_input_sel : out STD_LOGIC;
           x1_write : out STD_LOGIC;
           y1_write : out STD_LOGIC;
           b1_write : out STD_LOGIC;
           x_write: out STD_LOGIC;
           y_write: out STD_LOGIC;
           a1_write : out STD_LOGIC);
end egcd_control_unit;

architecture Behavioral of egcd_control_unit is

    TYPE STATE_T IS (   idle,
                        calculate1, 
                        calculate2,
                        writeback,
                        done_state);

    signal state    : STATE_T    := idle;

begin

    fsm : process(clk, reset)
    begin
        if reset = '1'  then
            state <= idle;
        elsif rising_edge(clk) then
            case state is
                when idle =>
                    if start = '1' then
                        state <= calculate1;
                    else
                        state <= idle;
                    end if;
                when calculate1 =>
                    state <= calculate2;
                when calculate2 =>
                    if b1 = to_unsigned(0, BIT_WIDTH) then
                        state <= done_state;
                    else
                        state <= writeback;
                    end if;
                when writeback =>
                    state <= calculate2;
                when done_state =>
                    if reset = '1' then
                        state <= idle;
                    else
                        state <= done_state;
                    end if;
            end case;
        end if;
    end process;
    
    combinational : process(state)
    begin
        case state is
            when idle =>
                done            <= '0';
                x1_input_sel    <= '1';
                y1_input_sel    <= '1';
                b1_input_sel    <= '1';
                x_input_sel     <= '1';
                y_input_sel     <= '1';
                a1_input_sel    <= '1';
                x1_write        <= '1';
                y1_write        <= '1';
                b1_write        <= '1';
                x_write         <= '1';
                y_write         <= '1';
                a1_write        <= '1';
            when calculate1 =>
                done            <= '0';
                x1_input_sel    <= '0';
                y1_input_sel    <= '0';
                b1_input_sel    <= '0';
                x_input_sel     <= '0';
                y_input_sel     <= '0';
                a1_input_sel    <= '0';
                x1_write        <= '0';
                y1_write        <= '0';
                b1_write        <= '0';
                x_write         <= '0';
                y_write         <= '0';
                a1_write        <= '0';
            when calculate2 =>
                done            <= '0';
                x1_input_sel    <= '0';
                y1_input_sel    <= '0';
                b1_input_sel    <= '0';
                x_input_sel     <= '0';
                y_input_sel     <= '0';
                a1_input_sel    <= '0';
                x1_write        <= '0';
                y1_write        <= '0';
                b1_write        <= '0';
                x_write         <= '0';
                y_write         <= '0';
                a1_write        <= '0';
            when writeback =>
                done            <= '0';
                x1_input_sel    <= '0';
                y1_input_sel    <= '0';
                b1_input_sel    <= '0';
                x_input_sel     <= '0';
                y_input_sel     <= '0';
                a1_input_sel    <= '0';
                x1_write        <= '1';
                y1_write        <= '1';
                b1_write        <= '1';
                x_write         <= '1';
                y_write         <= '1';
                a1_write        <= '1';
            when done_state =>
                done            <= '1';
                x1_input_sel    <= '0';
                y1_input_sel    <= '0';
                b1_input_sel    <= '0';
                x_input_sel     <= '0';
                y_input_sel     <= '0';
                a1_input_sel    <= '0';
                x1_write        <= '0';
                y1_write        <= '0';
                b1_write        <= '0';
                x_write         <= '0';
                y_write         <= '0';
                a1_write        <= '0';
        end case;
        
    end process;

end Behavioral;
