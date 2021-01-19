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
        clk                         : in std_logic;
        start                       : in std_logic;
        reset                       : in std_logic;
        instruction_buffer          : in instruction_t;
        instruction_buffer_rw       : out std_logic;
        input_buffer_read_index     : out index_t   := (others => '0');
        valid                       : out std_logic;
        reg_file_sel_0              : out std_logic_vector(3 downto 0);
        reg_file_sel_1_in_0         : out std_logic_vector(3 downto 0);
        reg_file_sel_1_in_1         : out std_logic_vector(3 downto 0);
        reg_file_sel_1_sel          : out std_logic;
        reg_file_write_0            : out std_logic;
        reg_file_write_1            : out std_logic;
        reg_file_arith_index        : out index_t   := (others => '0');
        reg_file_random_index       : out index_t   := (others => '0');
        in_arith_reg                : out std_logic;
        in_random_reg                : out std_logic;
        reg_file_in_0_sel           : out std_logic;
        reg_file_in_1_sel           : out std_logic;
        uniform_gen                 : out std_logic;
        uniform_reset               : out std_logic;
        uniform_read_index          : out index_t   := (others => '0');
        uniform_valid               : in std_logic;
        gaussian_gen                : out std_logic;
        gaussian_reset              : out std_logic;
        gaussian_read_index         : out index_t   := (others => '0');
        gaussian_valid              : in std_logic;
        rlwe_core_poly_1_sel        : out std_logic;
        rlwe_core_mode              : out std_logic_vector(2 downto 0);
        rlwe_core_start             : out std_logic;
        rlwe_core_write             : out std_logic;
        rlwe_core_write_index       : out index_t   := (others => '0');
        rlwe_core_read_index        : out index_t   := (others => '0');
        rlwe_core_reset             : out std_logic;
        rlwe_core_valid             : in std_logic;
        output_buffer_write         : out std_logic;
        output_buffer_write_index   : out index_t   := (others => '0')
    );
end main_control_unit;

architecture Behavioral of main_control_unit is

    TYPE INIT_STATE_TYPE IS (   idle,
                                store_instruction, 
                                decode,
                                stall,
                                done);
                                
    TYPE OP_1_STATE_TYPE IS (   arith_only,
                                arith_rlwe_core_write,
                                arith_rlwe_core_start_op,
                                arith_rlwe_core_output,
                                arith_reg_writeback,
                                arith_done,
                                arith_idle,
                                storage_only,
                                storage_reg_writeback);
                                
    TYPE OP_2_STATE_TYPE IS (   random_only,
                                random_read,
                                random_reg_writeback,
                                random_done,
                                random_idle);
    
                        
    signal init_state           : INIT_STATE_TYPE    := idle;
    signal op_1_state           : OP_1_STATE_TYPE    := arith_idle;
    signal op_2_state           : OP_2_STATE_TYPE    := random_idle;
    
    signal op_1_state_start     : std_logic_vector(1 downto 0) := "00";
    signal op_2_state_start     : std_logic := '0';
    
    signal op_1                 : std_logic_vector(3 downto 0);
    signal op_2                 : std_logic_vector(1 downto 0);
    signal rx_1                 : std_logic_vector(3 downto 0);
    signal ry                   : std_logic_vector(3 downto 0);
    signal rx_2                 : std_logic_vector(3 downto 0);
    
    -- Helper Signals --
    signal inst_is_arith        : std_logic;
    signal inst_is_storage      : std_logic;
    signal inst_is_random       : std_logic;
    signal inst_is_gaussian     : std_logic;
    signal inst_is_uniform      : std_logic;
    signal inst_is_immediate    : std_logic;
    
begin

    rx_2 <= std_logic_vector(instruction_buffer(3 downto 0));
    op_2 <= std_logic_vector(instruction_buffer(5 downto 4));
    ry   <= std_logic_vector(instruction_buffer(9 downto 6));
    rx_1 <= std_logic_vector(instruction_buffer(13 downto 10));
    op_1 <= std_logic_vector(instruction_buffer(17 downto 14));
    
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
            if op_2 = "01" then
                inst_is_gaussian    <= '1';
                inst_is_uniform     <= '0';
            else
                inst_is_gaussian    <= '0';
                inst_is_uniform     <= '1';
            end if;
        else
            inst_is_gaussian    <= '0';
            inst_is_uniform     <= '0';
            inst_is_random <= '0';
        end if;
        
        if op_1 = "0010" or op_1 = "0101" then
            inst_is_immediate <= '1';
        else
            inst_is_immediate <= '0';
        end if;
    end process;

    fsm : process(clk, reset)
    begin
        if reset = '1'  then
            init_state <= idle;
            op_1_state <= arith_idle;
            op_2_state <= random_idle;
        elsif rising_edge(clk) then
            case init_state is
                when idle =>
                    if start = '1' then
                        init_state <= store_instruction;
                    else
                        init_state <= idle;
                    end if;
                when store_instruction =>
                    init_state <= decode;
                    input_buffer_read_index <= (others => '0');
                    reg_file_arith_index <= (others => '0');
                    reg_file_random_index <= (others => '0');
                    rlwe_core_read_index <= (others => '0');
                    rlwe_core_write_index <= (others => '0');
                    uniform_read_index <= (others => '0');
                    gaussian_read_index <= (others => '0');
                    output_buffer_write_index <= (others => '0');
                when decode =>
                    init_state <= stall;
                when stall =>
                    if op_1_state = arith_idle and op_2_state = random_idle then
                        init_state <= done;
                    else
                        init_state <= stall;
                    end if;
                when done =>
                    init_state <= idle;
            end case;
            
            case op_1_state is
                when arith_idle =>
                    if op_1_state_start = "00" then
                        op_1_state <= arith_idle;
                    elsif op_1_state_start = "01" then
                        op_1_state <= arith_only;
                    elsif op_1_state_start = "10" then
                        op_1_state <= storage_only;
                    end if;
                when arith_only =>
                    input_buffer_read_index <= input_buffer_read_index + 1;
                    reg_file_arith_index <= reg_file_arith_index + 1;
                    op_1_state <= arith_rlwe_core_write;
                when arith_rlwe_core_write =>
                    if input_buffer_read_index = POLYNOMIAL_LENGTH and reg_file_arith_index = POLYNOMIAL_LENGTH then
                        op_1_state <= arith_rlwe_core_start_op;
                        reg_file_arith_index <= (others => '0');
                    else
                        op_1_state <= arith_only;
                        rlwe_core_write_index <= rlwe_core_write_index + 1;
                    end if;
                when arith_rlwe_core_start_op =>
                    if rlwe_core_valid = '1' then
                        op_1_state <= arith_rlwe_core_output;
                    else
                        op_1_state <= arith_rlwe_core_start_op;
                    end if;
                when arith_rlwe_core_output =>
                    rlwe_core_read_index <= rlwe_core_read_index + 1;
                    op_1_state <= arith_reg_writeback;
                when arith_reg_writeback =>
                    if rlwe_core_read_index = POLYNOMIAL_LENGTH then
                        op_1_state <= arith_done;
                    else
                        output_buffer_write_index <= output_buffer_write_index + 1;
                        reg_file_arith_index <= reg_file_arith_index + 1;
                        op_1_state <= arith_rlwe_core_output;
                    end if;
                when arith_done =>
                    op_1_state <= arith_idle;
                when storage_only =>
                    op_1_state <= storage_reg_writeback;
                    input_buffer_read_index <= input_buffer_read_index + 1;
                when storage_reg_writeback =>
                    if input_buffer_read_index = POLYNOMIAL_LENGTH then
                        op_1_state <= arith_done;
                    else
                        op_1_state <= storage_only;
                        output_buffer_write_index <= output_buffer_write_index + 1;
                        reg_file_arith_index <= reg_file_arith_index + 1;
                    end if;
            end case;
            
            case op_2_state is
                when random_idle =>
                    if op_2_state_start = '1' then
                        op_2_state <= random_only;
                    else
                        op_2_state <= random_idle;
                    end if;
                when random_only =>
                    if inst_is_gaussian = '1' then
                        if gaussian_valid = '1' then
                            op_2_state <= random_read;
                        else
                            op_2_state <= random_only;
                        end if;
                    elsif inst_is_uniform = '1' then
                        if uniform_valid = '1' then
                            op_2_state <= random_read;
                        else
                            op_2_state <= random_only;
                        end if;
                    else
                        op_2_state <= random_only;
                    end if;
                when random_read =>
                    if op_1_state = arith_rlwe_core_write or op_1_state = arith_rlwe_core_output then
                        op_2_state <= random_read;
                    else
                        op_2_state <= random_reg_writeback;
                        if inst_is_gaussian = '1' then
                            gaussian_read_index <= gaussian_read_index + 1;
                        elsif inst_is_uniform = '1' then
                            uniform_read_index <= uniform_read_index + 1;
                        else 
                            gaussian_read_index <= gaussian_read_index + 1;
                        end if;
                    end if;
                when random_reg_writeback =>
                    if inst_is_gaussian = '1' then
                        if gaussian_read_index = POLYNOMIAL_LENGTH then
                            op_2_state <= random_done;
                        else
                            op_2_state <= random_read;
                            reg_file_random_index <= reg_file_random_index + 1;
                        end if;
                    elsif inst_is_uniform = '1' then
                        if uniform_read_index = POLYNOMIAL_LENGTH then
                            op_2_state <= random_done;
                        else
                            op_2_state <= random_read;
                            reg_file_random_index <= reg_file_random_index + 1;
                        end if;
                    end if;
                when random_done =>
                    op_2_state <= random_idle;
                end case;
        end if;
    end process;

    combinational : process(inst_is_uniform, inst_is_gaussian, inst_is_immediate, inst_is_arith, inst_is_storage, inst_is_random, init_state, op_1_state, op_2_state, op_1, op_2, rx_1, rx_2, ry)
    begin
        case init_state is
            when idle =>
                instruction_buffer_rw   <= '1';
                valid                   <= '0';
                op_1_state_start        <= "00";
                op_2_state_start        <= '0';
            when store_instruction =>
                instruction_buffer_rw   <= '0';
                valid                   <= '0';
                op_1_state_start        <= "00";
                op_2_state_start        <= '0';
            when decode =>
                instruction_buffer_rw   <= '0';
                valid                   <= '0';
                
                if inst_is_arith = '1' then
                    op_1_state_start <= "01";
                elsif inst_is_storage = '1' then
                    op_1_state_start <= "10";
                else
                    op_1_state_start <= "00";
                end if;
                
                if inst_is_random = '1' then
                    op_2_state_start <= '1';
                else
                    op_2_state_start <= '0';
                end if;
            when stall =>
                instruction_buffer_rw   <= '0';
                valid                   <= '0';
                op_1_state_start        <= "00";
                op_2_state_start        <= '0';
            when done =>
                instruction_buffer_rw   <= '0';
                valid                   <= '1';
                op_1_state_start        <= "00";
                op_2_state_start        <= '0';
        end case;
        
        case op_1_state is
            when arith_idle =>
                reg_file_sel_0          <= "0000";
                reg_file_sel_1_in_1     <= "0000";
                reg_file_sel_1_sel      <= '0';
                reg_file_write_0        <= '0';
                reg_file_in_0_sel       <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_write         <= '0';
                rlwe_core_reset         <= '1';
                output_buffer_write     <= '0';
                in_arith_reg            <= '0';
            when arith_only =>
                reg_file_sel_0          <= rx_1;
                reg_file_sel_1_sel      <= '1';
                reg_file_write_0        <= '0';
                reg_file_in_0_sel       <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_write         <= '0';
                rlwe_core_reset         <= '0';
                output_buffer_write     <= '0';
                in_arith_reg            <= '1';
                
                if op_1 = "0010" or op_1 = "0101" then
                    reg_file_sel_1_in_1 <= rx_1;
                else
                    reg_file_sel_1_in_1 <= ry;
                end if;
            when arith_rlwe_core_write =>
                reg_file_sel_0          <= "0000";
                reg_file_sel_1_in_1     <= "0000";
                reg_file_sel_1_sel      <= '0';
                reg_file_write_0        <= '0';
                reg_file_in_0_sel       <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_write         <= '1';
                rlwe_core_reset         <= '0';
                output_buffer_write     <= '0';
                in_arith_reg            <= '0';

                if inst_is_immediate = '1' then
                    rlwe_core_poly_1_sel    <= '0';
                else
                    rlwe_core_poly_1_sel    <= '1';
                end if;
            when arith_rlwe_core_start_op =>
                reg_file_sel_0          <= "0000";
                reg_file_sel_1_in_1     <= "0000";
                reg_file_sel_1_sel      <= '0';
                reg_file_write_0        <= '0';
                reg_file_in_0_sel       <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_start         <= '1';
                rlwe_core_write         <= '0';
                rlwe_core_reset         <= '0';
                output_buffer_write     <= '0';
                in_arith_reg            <= '0';

                 if op_1 = "0001" or op_1 = "0010" then
                    rlwe_core_mode  <= "000";
                elsif op_1 = "0011" then
                    rlwe_core_mode  <= "010";
                elsif op_1 = "0100" or op_1 = "0101" then
                    rlwe_core_mode  <= "001";
                elsif op_1 = "0110" then
                    rlwe_core_mode  <= "011";
                elsif op_1 = "0111" then
                    rlwe_core_mode  <= "100";
                else
                    rlwe_core_mode  <= "000";
                end if;
            when arith_rlwe_core_output =>
                reg_file_sel_0          <= "0000";
                reg_file_sel_1_in_1     <= "0000";
                reg_file_sel_1_sel      <= '0';
                reg_file_write_0        <= '0';
                reg_file_in_0_sel       <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_write         <= '0';
                rlwe_core_reset         <= '0';
                output_buffer_write     <= '0';
                in_arith_reg            <= '0';
            when arith_reg_writeback =>
                reg_file_sel_0          <= rx_1;
                reg_file_sel_1_in_1     <= "0000";
                reg_file_sel_1_sel      <= '0';
                reg_file_write_0        <= '1';
                reg_file_in_0_sel       <= '1';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_write         <= '0';
                rlwe_core_reset         <= '0';
                output_buffer_write     <= '1';
                in_arith_reg            <= '1';
            when arith_done =>
                reg_file_sel_0          <= "0000";
                reg_file_sel_1_in_1     <= "0000";
                reg_file_sel_1_sel      <= '0';
                reg_file_write_0        <= '0';
                reg_file_in_0_sel       <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_write         <= '0';
                rlwe_core_reset         <= '0';
                output_buffer_write     <= '0';
                in_arith_reg            <= '0';
            when storage_only =>
                reg_file_sel_0          <= "0000";
                reg_file_sel_1_in_1     <= "0000";
                reg_file_sel_1_sel      <= '0';
                reg_file_write_0        <= '0';
                reg_file_in_0_sel       <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_write         <= '0';
                rlwe_core_reset         <= '0';
                output_buffer_write     <= '0';
                in_arith_reg            <= '0';
            when storage_reg_writeback =>
                reg_file_sel_0          <= rx_1;
                reg_file_sel_1_in_1     <= "0000";
                reg_file_sel_1_sel      <= '0';
                reg_file_write_0        <= '1';
                reg_file_in_0_sel       <= '0';
                rlwe_core_poly_1_sel    <= '0';
                rlwe_core_mode          <= "000";
                rlwe_core_start         <= '0';
                rlwe_core_write         <= '0';
                rlwe_core_reset         <= '0';
                output_buffer_write     <= '1';
                in_arith_reg            <= '1';
        end case;
            
        case op_2_state is
            when random_idle =>
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                reg_file_sel_1_in_0     <= "0000";
                reg_file_in_1_sel       <= '0';
                reg_file_write_1        <= '0';
                in_random_reg           <= '0';
            when random_only =>
                uniform_gen             <= '1';
                uniform_reset           <= '0';
                gaussian_gen            <= '1';
                gaussian_reset          <= '0';
                reg_file_sel_1_in_0     <= "0000";
                reg_file_in_1_sel       <= '0';
                reg_file_write_1        <= '0';
                in_random_reg           <= '0';
                
                if inst_is_gaussian = '1' then
                    gaussian_gen    <= '1';
                    uniform_gen     <= '0';
                elsif inst_is_uniform = '1' then
                    gaussian_gen    <= '0';
                    uniform_gen     <= '1';
                else
                    gaussian_gen    <= '1';
                    uniform_gen     <= '0';
                end if;
            when random_read =>
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                reg_file_sel_1_in_0     <= "0000";
                reg_file_in_1_sel       <= '0';
                reg_file_write_1        <= '0';
                in_random_reg           <= '0';
            when random_reg_writeback =>
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                reg_file_sel_1_in_0     <= rx_2;
                reg_file_write_1        <= '1';
                in_random_reg           <= '1';
                
                if inst_is_gaussian = '1' then
                    reg_file_in_1_sel   <= '1';
                elsif inst_is_uniform = '1' then
                    reg_file_in_1_sel   <= '0';
                else
                    reg_file_in_1_sel   <= '0';
                end if;
            when random_done =>
                uniform_gen             <= '0';
                uniform_reset           <= '0';
                gaussian_gen            <= '0';
                gaussian_reset          <= '0';
                reg_file_sel_1_in_0     <= "0000";
                reg_file_in_1_sel       <= '0';
                reg_file_write_1        <= '0';
                in_random_reg           <= '0';
        end case;
    end process;

end Behavioral;
