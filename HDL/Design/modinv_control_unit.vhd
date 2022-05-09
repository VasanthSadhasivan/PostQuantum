----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2022 07:59:35 AM
-- Design Name: 
-- Module Name: modinv_control_unit - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modinv_control_unit is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           egcd_done : in STD_LOGIC;
           egcd_start : out STD_LOGIC;
           egcd_reset : out STD_LOGIC;
           done : out STD_LOGIC;
           error : out STD_LOGIC);
end modinv_control_unit;

architecture Behavioral of modinv_control_unit is

    TYPE STATE_TYPE IS (idle,
                        start_state, 
                        mod_calc,
                        done_state );
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
                        state <= start_state;
                    else
                        state <= idle;
                    end if;
                when start_state =>
                    if egcd_done = '1' then
                        state <= mod_calc;
                    else
                        state <= start_state;
                    end if;
                when mod_calc =>
                    state <= done_state;
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
                egcd_start  <= '0'; 
                egcd_reset  <= '1';
                done        <= '0';
                error       <= '0';
            when start_state =>
                egcd_start  <= '1'; 
                egcd_reset  <= '0';
                done        <= '0';
                error       <= '0';
            when mod_calc =>
                egcd_start  <= '0'; 
                egcd_reset  <= '0';
                done        <= '0';
                error       <= '0';
            when done_state =>
                egcd_start  <= '0'; 
                egcd_reset  <= '0';
                done        <= '1';
                error       <= '0';
        end case;
    end process;
end Behavioral;
