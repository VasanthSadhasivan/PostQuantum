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
          mode_buffer_write         : out std_logic;
          valid                     : out std_logic;
          ntt_reset                 : out std_logic;
          ntt_write                 : out std_logic;
          ntt_start                 : out std_logic;
          ntt_index                 : out index_t := (others => '0');
          ntt_valid                 : in std_logic;
          intt_reset                : out std_logic;
          intt_write                : out std_logic;
          intt_start                : out std_logic;
          intt_index                : out index_t := (others => '0');
          intt_valid                : in std_logic;
          polyreduce_start          : out std_logic;
          polyreduce_write          : out std_logic;
          polyreduce_reset          : out std_logic;         
          polyreduce_index          : out index_t := (others => '0');       
          polyreduce_done           : in std_logic;       
          rom_output_mux_sel        : out std_logic_vector(1 downto 0) := (others => '0');
          phi_rom_index             : out index_t := (others => '0');
          iphi_rom_index            : out index_t := (others => '0');
          poly_0_buffer_read_index  : out index_t := (others => '0');
          poly_1_buffer_read_index  : out index_t := (others => '0');
          output_buffer_write_index : out index_t := (others => '0');
          output_buffer_write       : out std_logic
          );
end rlwe_core_control_unit;

architecture Behavioral of rlwe_core_control_unit is
    TYPE STATE_TYPE IS (idle,
                        mode_store,
                        mode_buffer_wait,
                        start_process,
                        non_transform_process,
                        non_transform_output_process,
                        done,
                        transform_process,
                        transform_store_input,
                        transform_start_process,
                        transform_wait_process,
                        transform_output_process,
                        transform_output_store_process);
                        
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
                    ntt_index <= to_unsigned(255, INDEX_BIT_WIDTH);
                    intt_index <= to_unsigned(255, INDEX_BIT_WIDTH);
                    polyreduce_index <= to_unsigned(255, INDEX_BIT_WIDTH);
                    phi_rom_index <= to_unsigned(255, INDEX_BIT_WIDTH);
                    iphi_rom_index <= to_unsigned(255, INDEX_BIT_WIDTH);
                    output_buffer_write_index <= (others => '0');
                    state <= mode_buffer_wait;
                when mode_buffer_wait =>
                    state <= start_process;
                when start_process =>
                    if mode_buffer = "000" or mode_buffer = "001" or mode_buffer = "010" or mode_buffer = "011" or mode_buffer = "100" then
                        state <= non_transform_process;
                    else
                        state <= transform_process;
                    end if;
                when non_transform_process =>
                    poly_0_buffer_read_index <= poly_0_buffer_read_index + 1;
                    poly_1_buffer_read_index <= poly_0_buffer_read_index + 1;
                    if iphi_rom_index > 0 and phi_rom_index > 0 then
                        iphi_rom_index <= iphi_rom_index - 1;
                        phi_rom_index <= phi_rom_index - 1;
                    end if;
                    state <= non_transform_output_process;
                when non_transform_output_process => 
                    if to_integer(poly_1_buffer_read_index) = POLYNOMIAL_LENGTH then
                        state <= done;
                    else
                        output_buffer_write_index <= output_buffer_write_index + 1;
                        state <= non_transform_process;
                    end if;
                when done =>
                    state <= idle;
                when transform_process =>
                    poly_1_buffer_read_index <= poly_1_buffer_read_index + 1;
                    state <= transform_store_input;
                when transform_store_input =>
                    if to_integer(poly_1_buffer_read_index) = POLYNOMIAL_LENGTH then
                        state <= transform_start_process;
                    else
                        ntt_index <= ntt_index - 1;
                        intt_index <= intt_index - 1;
                        polyreduce_index <= polyreduce_index - 1;
                        state <= transform_process;
                    end if;
                when transform_start_process =>
                    ntt_index <= to_unsigned(255, INDEX_BIT_WIDTH);
                    intt_index <= to_unsigned(255, INDEX_BIT_WIDTH);
                    polyreduce_index <= to_unsigned(255, INDEX_BIT_WIDTH);
                    state <= transform_wait_process;
                when transform_wait_process =>
                    if (ntt_valid = '1' and mode_buffer="101") or (intt_valid = '1' and mode_buffer="110") or (polyreduce_done = '1' and mode_buffer="111") then
                        state <= transform_output_process;
                    else
                        state <= transform_wait_process;
                    end if;
                when transform_output_process =>
                    if ntt_index > 0 and intt_index > 0 and polyreduce_index > 0 then
                        ntt_index <= ntt_index - 1;
                        intt_index <= intt_index - 1;
                        polyreduce_index <= polyreduce_index - 1;
                    end if;
                    state <= transform_output_store_process;
                when transform_output_store_process =>
                    if to_integer(output_buffer_write_index) = POLYNOMIAL_LENGTH-1 then
                        state <= done;
                    else
                        output_buffer_write_index <= output_buffer_write_index + 1;
                        state <= transform_output_process;
                    end if;
                when others =>
                    state <= idle;
            end case;
        end if;
    end process;
    
    combinational : process(state, mode_buffer)
    begin
        case state is
            when idle =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
            when mode_store =>
                mode_buffer_write   <= '1';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
            when mode_buffer_wait =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
            when start_process =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '1';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '1';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '1';
                valid               <= '0';
                output_buffer_write <= '0';
            when non_transform_process =>
                mode_buffer_write   <= '0';
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
                
                if mode_buffer = "010" then 
                    rom_output_mux_sel  <= "00";
                elsif mode_buffer = "011" then
                    rom_output_mux_sel  <= "01";
                elsif mode_buffer = "100" then
                    rom_output_mux_sel  <= "10";
                else
                    rom_output_mux_sel  <= "00";
                end if;
            when non_transform_output_process =>
                mode_buffer_write   <= '0';
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '1';
                
                if mode_buffer = "010" then 
                    rom_output_mux_sel  <= "00";
                elsif mode_buffer = "011" then
                    rom_output_mux_sel  <= "01";
                elsif mode_buffer = "100" then
                    rom_output_mux_sel  <= "10";
                else
                    rom_output_mux_sel  <= "00";
                end if;
            when done =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '1';
                output_buffer_write <= '0';
            when transform_process =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
            when transform_store_input =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '1';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '1';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '1';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
            when transform_start_process =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
                
                if mode_buffer = "110" then 
                    ntt_start           <= '0';
                    intt_start          <= '1';
                    polyreduce_start    <= '0';
                elsif mode_buffer = "101" then 
                    ntt_start           <= '1';
                    intt_start          <= '0';
                    polyreduce_start    <= '0';
                elsif mode_buffer = "111" then
                    ntt_start           <= '0';
                    intt_start          <= '0';
                    polyreduce_start    <= '1';
                end if;
            when transform_wait_process =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
            when transform_output_process =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '0';
            when transform_output_store_process =>
                mode_buffer_write   <= '0';
                rom_output_mux_sel  <= "00";
                ntt_reset           <= '0';
                ntt_write           <= '0';
                ntt_start           <= '0';
                intt_reset          <= '0';
                intt_write          <= '0';
                intt_start          <= '0';
                polyreduce_start    <= '0';
                polyreduce_write    <= '0';
                polyreduce_reset    <= '0';
                valid               <= '0';
                output_buffer_write <= '1';
        end case;
    end process;

end Behavioral;
