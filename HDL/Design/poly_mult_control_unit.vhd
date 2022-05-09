----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 12:06:00 AM
-- Design Name: 
-- Module Name: poly_mult_control_unit - Behavioral
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
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity poly_mult_control_unit is
    Port ( 
            clk                         : in STD_LOGIC;
            
            poly_0_buffer_read_index    : out index_t := (others => '0');
            poly_1_buffer_read_index    : out index_t := (others => '0');
            phi_rom_index               : out index_t := (others => '0');
            
            ntt_0_rst                   : out STD_LOGIC;
            ntt_0_write                 : out STD_LOGIC;
            ntt_0_valid                 : in STD_LOGIC;
            ntt_0_index                 : out index_t := (others => '0');
            ntt_0_start                 : out STD_LOGIC;

            ntt_1_rst                   : out STD_LOGIC;
            ntt_1_write                 : out STD_LOGIC;
            ntt_1_start                 : out STD_LOGIC;
            ntt_1_valid                 : in STD_LOGIC;
            ntt_1_index                 : out index_t := (others => '0');
            
            intt_rst                    : out STD_LOGIC;
            intt_start                  : out STD_LOGIC;
            intt_write                  : out STD_LOGIC;
            intt_valid                  : in STD_LOGIC;
            intt_index                  : out index_t := (others => '0');

            iphi_rom_index              : out index_t := (others => '0');
            
            output_buffer_write         : out STD_LOGIC;
            output_buffer_write_index   : out index_t := (others => '0');
            
            valid                       : out STD_LOGIC;
            start                       : in STD_LOGIC;
            reset                       : in STD_LOGIC
            );
end poly_mult_control_unit;

architecture Behavioral of poly_mult_control_unit is
    TYPE STATE_TYPE IS (
                        idle,
                        reset_counters,
                        poly_buffer_output,
                        phi_multiply,
                        ntt_store,
                        ntt_start_process,
                        ntt_wait,
                        ntt_output,
                        ntt_multiply,
                        intt_store,
                        intt_start_process,
                        intt_wait_process,
                        intt_output,
                        iphi_multiply,
                        output_buffer_store,
                        done);
    SIGNAL state   : STATE_TYPE;
begin

    fsm : process(clk, reset)
    begin
        if(reset = '1') then
            state <= idle;
        elsif(rising_edge(clk)) then
            case state is
                when idle =>
                    if start = '1' then
                        poly_0_buffer_read_index     <= to_unsigned(255, INDEX_BIT_WIDTH);
                        poly_1_buffer_read_index     <= to_unsigned(255, INDEX_BIT_WIDTH);
                        ntt_0_index                  <= (others => '0');
                        ntt_1_index                  <= (others => '0');
                        intt_index                   <= (others => '0');
                        iphi_rom_index               <= to_unsigned(255, INDEX_BIT_WIDTH);
                        phi_rom_index                <= (others => '0');
                        output_buffer_write_index    <= (others => '0');
                        state <= reset_counters;
                    else
                        state <= idle;
                    end if;
                when reset_counters =>
                    state <= poly_buffer_output;
                when poly_buffer_output =>
                    state <= phi_multiply;
                when phi_multiply =>
                    phi_rom_index <= phi_rom_index + 1;
                    state <= ntt_store;
                when ntt_store =>
                    if to_integer(phi_rom_index) = POLYNOMIAL_LENGTH then
                        ntt_0_index <= (others => '0'); 
                        ntt_1_index <= (others => '0'); 
                        state       <= ntt_start_process;
                    else
                        ntt_0_index                 <= ntt_0_index + 1;
                        ntt_1_index                 <= ntt_1_index + 1;
                        poly_0_buffer_read_index    <= poly_0_buffer_read_index - 1;
                        poly_1_buffer_read_index    <= poly_1_buffer_read_index - 1;
                        state                       <= poly_buffer_output;
                    end if;
                when ntt_start_process =>
                    state <= ntt_wait;
                when ntt_wait =>
                    if ntt_0_valid = '1' and ntt_1_valid = '1' then
                        state <= ntt_output;
                    else
                        state <= ntt_wait;
                    end if;
                when ntt_output =>
                    state <= ntt_multiply;
                when ntt_multiply =>
                    ntt_0_index <= ntt_0_index + 1;
                    ntt_1_index <= ntt_1_index + 1;
                    state       <= intt_store;
                when intt_store =>
                    if to_integer(ntt_0_index) = POLYNOMIAL_LENGTH and to_integer(ntt_1_index) = POLYNOMIAL_LENGTH then
                        state       <= intt_start_process;
                    else
                        intt_index  <= intt_index + 1;
                        state       <= ntt_output;
                    end if;
                when intt_start_process =>
                    state <= intt_wait_process;
                when intt_wait_process =>
                    if intt_valid = '1' then
                        state <= intt_output;
                    else
                        state <= intt_wait_process;
                    end if;
                when intt_output =>
                    state <= iphi_multiply;
                when iphi_multiply =>
                    state <= output_buffer_store;
                when output_buffer_store =>
                    if to_integer(iphi_rom_index) = 0 and to_integer(intt_index) = 0 then
                        state                       <= done;
                    else
                        iphi_rom_index              <= iphi_rom_index - 1;
                        output_buffer_write_index   <= output_buffer_write_index + 1;
                        intt_index                  <= intt_index - 1;
                        state <= intt_output;
                    end if;
                when done =>
                    state <= idle;
            end case;   
        end if;
    end process;
    
    combinational: process(state)
    begin
        case state is 
            when idle =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when reset_counters =>
                ntt_0_rst                   <= '1';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '1';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '1';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when poly_buffer_output =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when phi_multiply =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when ntt_store =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '1';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '1';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when ntt_start_process =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '1';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '1';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when ntt_wait =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when ntt_output =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when ntt_multiply =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when intt_store =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '1';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when intt_start_process =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '1';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when intt_wait_process =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when intt_output =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when iphi_multiply =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '0';
            when output_buffer_store =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '1';
                valid                       <= '0';
            when done =>
                ntt_0_rst                   <= '0';
                ntt_0_write                 <= '0';
                ntt_0_start                 <= '0';
                ntt_1_rst                   <= '0';
                ntt_1_write                 <= '0';
                ntt_1_start                 <= '0';
                intt_rst                    <= '0';
                intt_start                  <= '0';
                intt_write                  <= '0';
                output_buffer_write         <= '0';
                valid                       <= '1';
        end case;
    end process;


end Behavioral;
