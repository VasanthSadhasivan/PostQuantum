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

entity main_control_unit is
    Port (
        clk                     : in std_logic;
        start                   : in std_logic;
        reset                   : in std_logic;
        instruction             : in instruction_t;
        valid                   : out std_logic;
        reg_file_sel_0          : out std_logic_vector(3 downto 0);
        reg_file_sel_1          : out std_logic_vector(3 downto 0);
        reg_file_rw_0           : out std_logic;
        reg_file_rw_1           : out std_logic;
        reg_file_in_0_sel       : out std_logic;
        reg_file_in_1_sel       : out std_logic;
        uniform_gen             : out std_logic;
        uniform_reset           : out std_logic;
        uniform_valid           : in std_logic;
        gaussian_gen            : out std_logic;
        gaussian_reset          : out std_logic;
        gaussian_valid          : in std_logic;
        rlwe_core_poly_1_sel    : out std_logic;
        rlwe_core_mode          : out std_logic_vector(2 downto 0);
        rlwe_core_start         : out std_logic;
        rlwe_core_reset         : out std_logic;
        rlwe_core_valid         : in std_logic;
        output_test             : out std_logic
    );
end main_control_unit;

architecture Behavioral of main_control_unit is

    TYPE STATE_TYPE IS (idle, 
                        decode, 
                        arith_only_init,
                        random_only_init,
                        storage_only_writeback,
                        arith_and_random_init,
                        storage_and_random_init,
                        arith_only_op,
                        random_only_writeback,
                        arith_and_random_op,
                        arith_only_writeback,
                        done);
                        
    signal state    : STATE_TYPE;
    
    signal op_1     : std_logic_vector(3 downto 0);
    signal op_2     : std_logic_vector(1 downto 0);
    signal rx_1     : std_logic_vector(3 downto 0);
    signal ry       : std_logic_vector(3 downto 0);
    signal rx_2     : std_logic_vector(3 downto 0);
    
    -- Helper Signals --
    signal inst_is_arith    : std_logic;
    signal inst_is_storage  : std_logic;
    signal inst_is_random   : std_logic;
    
begin

    rx_2 <= std_logic_vector(instruction(3 downto 0));
    op_2 <= std_logic_vector(instruction(5 downto 4));
    ry <= std_logic_vector(instruction(9 downto 6));
    rx_1 <= std_logic_vector(instruction(13 downto 10));
    op_1 <= std_logic_vector(instruction(17 downto 14));
    
    helper_signal_driver : process(op_1, op_2)
    begin
        if op_1 /= "0000" and op_1 /= "1000" then
            inst_is_arith <= '1';
        else
            inst_is_arith <= '0';
        end if;
        
        if op_1 = "1000" then
            inst_is_storage <= '1';
        else
            inst_is_storage <= '0';
        end if;
        
        if op_2 = "01" or op_2 = "10" then
            inst_is_random <= '1';
        else
            inst_is_random <= '0';
        end if;
    end process;

    fsm : process(clk, reset)
    begin
        if reset = '1'  then
            state <= idle;
        elsif rising_edge(clk) then
            case state is
                when idle => 
                    if start = '1' then
                        state <= decode;
                    else
                        state <= idle;
                    end if;
                when decode =>
                    if inst_is_arith = '1' and inst_is_random = '0' then
                        state <= arith_only_init;
                    elsif inst_is_arith = '0' and inst_is_storage = '0' and inst_is_random= '1' then
                        state <= random_only_init;
                    elsif inst_is_storage = '1' and inst_is_random = '0' then
                        state <= storage_only_writeback;
                    elsif inst_is_arith = '1' and inst_is_random= '1' then
                        state <= arith_and_random_init;
                    elsif inst_is_storage = '1' and inst_is_random = '1' then
                        state <= storage_and_random_init;
                    else
                        state <= decode;
                    end if;
                when arith_only_init =>
                    state <= arith_only_op;
                when random_only_init =>
                    if gaussian_valid = '1' or uniform_valid = '1' then
                        state <= random_only_writeback;
                    else
                        state <= random_only_init;
                    end if;
                when storage_only_writeback =>
                    state <= done;
                when arith_and_random_init =>
                    if gaussian_valid = '1' or uniform_valid = '1' then
                        state <= arith_and_random_op;
                    else
                        state <= arith_and_random_init;
                    end if;
                when storage_and_random_init =>
                    if gaussian_valid = '1' or uniform_valid = '1' then
                        state <= random_only_writeback;
                    else
                        state <= storage_and_random_init;
                    end if;
                when arith_only_op =>
                    if rlwe_core_valid = '1' then
                        state <= arith_only_writeback;
                    else
                        state <= arith_only_op;
                    end if;
                when random_only_writeback =>
                    state <= done;
                when arith_and_random_op =>
                    if rlwe_core_valid = '1' then
                        state <= arith_only_writeback;
                    else
                        state <= arith_and_random_op;
                    end if;
                when arith_only_writeback =>
                    state <= done;
                when done =>
                    state <= idle;
            end case;
        end if;
    end process;

    combinational : process(state, op_1, op_2, rx_1, rx_2, ry)
    begin
        case state is
            when idle =>
                valid                   <= '0';
                reg_file_sel_0          <= "0000";
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '0';
                reg_file_in_1_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '1';
                gaussian_gen            <= '0';
                gaussian_reset          <= '1';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '1';
                output_test             <= '0';
            when decode =>
                valid                   <= '0';
                reg_file_sel_0          <= "0000";
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '0';
                reg_file_in_1_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '1';
                gaussian_gen            <= '0';
                gaussian_reset          <= '1';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '1';
                output_test             <= '0';
            when arith_only_init =>
                valid                   <= '0';
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '0';
                reg_file_in_1_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '0';
                output_test             <= '0';
                
                if op_1 = "0010" or op_1 = "0101" then
                    reg_file_sel_0          <= rx_1;
                    reg_file_sel_1          <= rx_1;
                else
                    reg_file_sel_0          <= rx_1;
                    reg_file_sel_1          <= ry;
                end if;
            when random_only_init =>
                valid                   <= '0';
                reg_file_sel_0          <= "0000";
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '0';
                reg_file_in_1_sel       <= '0';
                uniform_reset           <= '0';
                gaussian_reset          <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '0';
                output_test             <= '0';
                
                case op_2 is
                    when "01" =>
                        uniform_gen             <= '0';
                        gaussian_gen            <= '1';
                    when "10" =>
                        uniform_gen             <= '1';
                        gaussian_gen            <= '0';
                    when others =>
                        uniform_gen             <= '0';
                        gaussian_gen            <= '0';
                end case;
            when storage_only_writeback =>
                valid                   <= '0';
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '1';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '1';
                reg_file_in_1_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '0';
                output_test             <= '1';
                
                reg_file_sel_0          <= rx_1;
            when arith_and_random_init =>
                valid                   <= '0';
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '0';
                reg_file_in_1_sel       <= '0';
                uniform_reset           <= '0';
                gaussian_reset          <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '0';
                output_test             <= '0';
                
                case op_2 is
                    when "01" =>
                        uniform_gen             <= '0';
                        gaussian_gen            <= '1';
                    when "10" =>
                        uniform_gen             <= '1';
                        gaussian_gen            <= '0';
                    when others =>
                        uniform_gen             <= '0';
                        gaussian_gen            <= '0';
                end case;
                
                if op_1 = "0010" or op_1 = "0101" then
                    reg_file_sel_0          <= rx_1;
                    reg_file_sel_1          <= rx_1;
                else
                    reg_file_sel_0          <= rx_1;
                    reg_file_sel_1          <= ry;
                end if;
            when storage_and_random_init =>
                valid                   <= '0';
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '1';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '1';
                reg_file_in_1_sel       <= '0';
                uniform_reset           <= '0';
                gaussian_reset          <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '0';
                output_test             <= '0';
                
                reg_file_sel_0          <= rx_1;
                case op_2 is
                    when "01" =>
                        uniform_gen             <= '0';
                        gaussian_gen            <= '1';
                    when "10" =>
                        uniform_gen             <= '1';
                        gaussian_gen            <= '0';
                    when others =>
                        uniform_gen             <= '0';
                        gaussian_gen            <= '0';
                end case;
            when arith_only_op =>
                valid                   <= '0';
                reg_file_sel_0          <= "0000";
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '0';
                reg_file_in_1_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                rlwe_core_start         <= '1';
                rlwe_core_reset         <= '0';
                output_test             <= '0';
                
                if op_1 = "0010" or op_1 = "0101" then
                    rlwe_core_poly_1_sel    <= '0';
                else
                    rlwe_core_poly_1_sel    <= '1';
                end if;
                
                if op_1 = "0001" or op_1 = "0010" then
                    rlwe_core_mode          <= "000";
                elsif op_1 = "0011" then
                    rlwe_core_mode          <= "010";
                elsif op_1 = "0100" or op_1 = "0101" then
                    rlwe_core_mode          <= "001";
                elsif op_1 = "0110" then 
                    rlwe_core_mode          <= "011";
                elsif op_1 = "0111" then
                    rlwe_core_mode          <= "100";
                else
                    rlwe_core_mode          <= "000";
                end if;
            when random_only_writeback =>
                valid                   <= '0';
                reg_file_sel_0          <= "0000";
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '1';
                reg_file_in_0_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '0';
                output_test             <= '1';
                
                case op_2 is 
                    when "01" =>
                        reg_file_in_1_sel       <= '1';
                    when "10" =>
                        reg_file_in_1_sel       <= '0';
                    when others =>
                        reg_file_in_1_sel       <= '0';
                end case;
                reg_file_sel_1          <= rx_2;
            when arith_and_random_op =>
                valid                   <= '0';
                reg_file_sel_0          <= "0000";
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '1';
                reg_file_in_0_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                rlwe_core_start         <= '1';
                rlwe_core_reset         <= '0';
                output_test             <= '0';
                
                case op_2 is 
                    when "01" =>
                        reg_file_in_1_sel       <= '1';
                    when "10" =>
                        reg_file_in_1_sel       <= '0';
                    when others =>
                        reg_file_in_1_sel       <= '0';
                end case;
                reg_file_sel_1          <= rx_2;
                
                
                if op_1 = "0010" or op_1 = "0101" then
                    rlwe_core_poly_1_sel    <= '0';
                else
                    rlwe_core_poly_1_sel    <= '1';
                end if;
                
                if op_1 = "0001" or op_1 = "0010" then
                    rlwe_core_mode          <= "000";
                elsif op_1 = "0011" then
                    rlwe_core_mode          <= "010";
                elsif op_1 = "0100" or op_1 = "0101" then
                    rlwe_core_mode          <= "001";
                elsif op_1 = "0110" then 
                    rlwe_core_mode          <= "011";
                elsif op_1 = "0111" then
                    rlwe_core_mode          <= "100";
                else
                    rlwe_core_mode          <= "000";
                end if;
            when arith_only_writeback =>
                valid                   <= '0';
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '1';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '1';
                reg_file_in_1_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '0';
                output_test             <= '1';
                
                reg_file_sel_0          <= rx_1;
            when done =>
                valid                   <= '1';
                reg_file_sel_0          <= "0000";
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '0';
                reg_file_in_1_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '0';
                output_test             <= '0';
            when others =>
                valid                   <= '0';
                reg_file_sel_0          <= "0000";
                reg_file_sel_1          <= "0000";
                reg_file_rw_0           <= '0';
                reg_file_rw_1           <= '0';
                reg_file_in_0_sel       <= '0';
                reg_file_in_1_sel       <= '0';
                uniform_gen             <= '0';
                uniform_reset           <= '1';
                gaussian_gen            <= '0';
                gaussian_reset          <= '1';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_reset         <= '1';
                output_test             <= '0';
        end case;
    end process;

end Behavioral;
