----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 11:27:29 PM
-- Design Name: 
-- Module Name: uniform_core - Behavioral
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

entity uniform_control_unit is
    Port (
        clk                     : in std_logic;
        reset                   : in std_logic;
        start                   : in std_logic;
        data_reg                : out unsigned(19 downto 0) := to_unsigned(1, 20);
        data_buffer_write_index : out index_t := (others => '0');
        data_buffer_write       : out std_logic;
        valid                   : out std_logic
    );
end uniform_control_unit;

architecture Behavioral of uniform_control_unit is

    TYPE STATE_TYPE IS (idle,
                        gen, 
                        write,
                        done);
                        
    signal state : STATE_TYPE := idle;
    
begin

    fsm : process(clk, reset)
    begin
        if reset = '1'  then
            state       <= idle;
            data_reg    <= to_unsigned(1, 20);
        elsif rising_edge(clk) then
            case state is
                when idle =>
                    if start = '1' then
                        data_buffer_write_index <= (others => '0');
                        state <= gen;
                    else
                        state <= idle;
                    end if;
                when gen =>
                    state <= write;
                when write =>
                    if data_buffer_write_index < POLYNOMIAL_LENGTH - 1 then
                        data_reg(18 downto 0)   <= data_reg(19 downto 1);
                        data_reg(19)            <= data_reg(19) xnor data_reg(2);
                        data_buffer_write_index <= data_buffer_write_index + 1;
                        state                   <= gen;
                    else
                        state <= done;
                    end if;
                when done =>
                    state <= idle;
            end case;
        end if;
    end process;
    
combinational : process(state)
    begin
        case state is
            when idle =>
                data_buffer_write   <= '0';
                valid               <= '0';
            when gen =>
                data_buffer_write   <= '0';
                valid               <= '0';
            when write =>
                data_buffer_write   <= '1';
                valid               <= '0';
            when done =>
                data_buffer_write   <= '0';
                valid               <= '1';
        end case;
    end process;
end Behavioral;
