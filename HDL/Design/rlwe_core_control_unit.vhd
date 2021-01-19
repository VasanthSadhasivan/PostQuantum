----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 06:01:10 PM
-- Design Name: 
-- Module Name: rlwe_core_control_unit - Behavioral
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

entity rlwe_core_control_unit is
    Port (clk                       : in std_logic;
          mode_buffer               : in std_logic_vector(2 downto 0);
          start                     : in std_logic;
          reset                     : in std_logic;
          poly_mult_valid           : in std_logic;
          mode_buffer_write         : out std_logic;
          valid                     : out std_logic;
          poly_mult_reset           : out std_logic;
          poly_mult_start           : out std_logic;
          poly_0_buffer_read_index  : out index_t := (others => '0');
          poly_1_buffer_read_index  : out index_t := (others => '0');
          poly_mult_read_index      : out index_t := (others => '0');
          poly_mult_write_index     : out index_t := (others => '0');
          output_buffer_write_index : out index_t := (others => '0');
          output_buffer_write       : out std_logic;
          poly_mult_write           : out std_logic
          );
end rlwe_core_control_unit;

architecture Behavioral of rlwe_core_control_unit is
    TYPE STATE_TYPE IS (idle,
                        mode_store,
                        mode_buffer_wait,
                        start_process,
                        non_mult_process,
                        non_mult_output_process,
                        done,
                        mult_process,
                        mult_store_input,
                        mult_start_process,
                        mult_wait_process,
                        mult_output_process,
                        mult_output_store_process);
                        
    SIGNAL state   : STATE_TYPE;
    
begin

    fsm : process(clk, reset)
    begin
        if reset = '1'  then
            state <= idle;
        elsif rising_edge(clk) then
            case state is
                when idle => 
                    if start = '1' then
                        state <= mode_store;
                    else
                        state <= idle;
                    end if;
                when mode_store =>
                    poly_0_buffer_read_index <= (others => '0');
                    poly_1_buffer_read_index <= (others => '0');
                    poly_mult_read_index <= (others => '0');
                    poly_mult_write_index <= (others => '0');
                    output_buffer_write_index <= (others => '0');
                    state <= mode_buffer_wait;
                when mode_buffer_wait =>
                    state <= start_process;
                when start_process =>
                    if mode_buffer = "001" then
                        state <= mult_process;
                    else
                        state <= non_mult_process;
                    end if;
                when non_mult_process =>
                    poly_0_buffer_read_index <= poly_0_buffer_read_index + 1;
                    poly_1_buffer_read_index <= poly_0_buffer_read_index + 1;
                    state <= non_mult_output_process;
                when non_mult_output_process => 
                    if to_integer(poly_1_buffer_read_index) = POLYNOMIAL_LENGTH then
                        state <= done;
                    else
                        output_buffer_write_index <= output_buffer_write_index + 1;
                        state <= non_mult_process;
                    end if;
                when done =>
                    state <= idle;
                when mult_process =>
                    poly_0_buffer_read_index <= poly_0_buffer_read_index + 1;
                    poly_1_buffer_read_index <= poly_1_buffer_read_index + 1;
                    state <= mult_store_input;
                when mult_store_input =>
                    if to_integer(poly_1_buffer_read_index) = POLYNOMIAL_LENGTH then
                        state <= mult_start_process;
                    else
                        poly_mult_write_index <= poly_mult_write_index + 1;
                        state <= mult_process;
                    end if;
                when mult_start_process =>
                    state <= mult_wait_process;
                when mult_wait_process =>
                    if poly_mult_valid = '1' then
                        state <= mult_output_process;
                    else
                        state <= mult_wait_process;
                    end if;
                when mult_output_process =>
                    poly_mult_read_index <= poly_mult_read_index + 1;
                    state <= mult_output_store_process;
                when mult_output_store_process =>
                    if to_integer(poly_mult_read_index) = POLYNOMIAL_LENGTH then
                        state <= done;
                    else
                        output_buffer_write_index <= output_buffer_write_index + 1;
                        state <= mult_output_process;
                    end if;
                when others =>
                    state <= idle;
            end case;
        end if;
    end process;
    
    combinational : process(state)
    begin
        case state is
            when idle =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when mode_store =>
                mode_buffer_write   <= '1';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when mode_buffer_wait =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when start_process =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '1';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when non_mult_process =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when non_mult_output_process =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '1';
                poly_mult_write     <= '0';
            when done =>
                mode_buffer_write   <= '0';
                valid               <= '1';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when mult_process =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when mult_store_input =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '1';
            when mult_start_process =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '1';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when mult_wait_process =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when mult_output_process =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '0';
                poly_mult_write     <= '0';
            when mult_output_store_process =>
                mode_buffer_write   <= '0';
                valid               <= '0';
                poly_mult_reset     <= '0';
                poly_mult_start     <= '0';
                output_buffer_write <= '1';
                poly_mult_write     <= '0';
        end case;
    end process;

end Behavioral;
