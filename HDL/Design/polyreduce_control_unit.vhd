----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2022 07:18:23 PM
-- Design Name: 
-- Module Name: polyreduce_control_unit - Behavioral
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

entity polyreduce_control_unit is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           poly_1 : in coefficient_t;
           poly_2 : in coefficient_t;
           poly_1_order : in index_t;
           poly_2_order : in index_t;
           poly_1_0th_output : in coefficient_t;
           deg_delt : in index_t;
           poly_1_input_sel : out std_logic;
           poly_1_write_index : out index_t;
           poly_1_write_index_sel : out std_logic;
           poly_1_write_sel : out std_logic;
           poly_1_write : out std_logic;
           poly_1_read_index_sel : out std_logic;
           poly_1_read_index : out index_t;
           poly_2_read_index : out index_t;
           ttr_input_sel : out std_logic_vector(1 downto 0);
           ttr_write_index : out index_t;
           ttr_write : out std_logic;
           ttr_read_index : out index_t;
           poly_1_order_write : out std_logic;
           poly_2_order_write : out std_logic;
           modinv_start : out std_logic;
           modinv_reset : out std_logic;
           modinv_done : in std_logic;
           modinv_buff_write : out std_logic;
           done : out STD_LOGIC
    );
end polyreduce_control_unit;

architecture Behavioral of polyreduce_control_unit is

    TYPE STATE_TYPE IS (idle,
                        clear_ttr,
                        poly_1_order_extractor,
                        poly_1_order_write_state,
                        poly_2_order_extractor,
                        poly_2_order_write_state,
                        poly_2_order_write_state_stall,
                        poly_same_order_check_start,
                        poly_same_order_check,
                        poly_1_shift,
                        write_ttr,
                        modinv_start_state,
                        write_modinv,
                        ttr_modinv_mult1,
                        ttr_modinv_write1,
                        ttr_modinv_mult2_stall,
                        ttr_modinv_mult2,
                        ttr_modinv_write2,
                        final_subtract,
                        final_subtract_write,
                        done_state
                        );
                        
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
                        state <= clear_ttr;
                        ttr_write_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                        poly_1_read_index <= POLYNOMIAL_LENGTH - to_unsigned(1, INDEX_BIT_WIDTH);
                        poly_2_read_index <= POLYNOMIAL_LENGTH - to_unsigned(1, INDEX_BIT_WIDTH);
                    end if;
                when clear_ttr =>
                    if ttr_write_index < POLYNOMIAL_LENGTH then
                        state <= clear_ttr;
                        ttr_write_index <= ttr_write_index + 1;
                    else
                        state <= poly_1_order_extractor;
                    end if;
                when poly_1_order_extractor =>
                    if poly_1_0th_output = to_unsigned(0, BIT_WIDTH) and poly_1_read_index = to_unsigned(0, INDEX_BIT_WIDTH) and poly_1 = to_unsigned(0, BIT_WIDTH)then
                        state <= done_state;
                    elsif poly_1 = to_unsigned(0, BIT_WIDTH) then
                        poly_1_read_index <= poly_1_read_index - 1;
                        state <= poly_1_order_extractor;
                    else
                        state <= poly_1_order_write_state;
                    end if;
                when poly_1_order_write_state =>
                    state <= poly_2_order_extractor;
                when poly_2_order_extractor =>
                    if poly_2 = to_unsigned(0, BIT_WIDTH) then 
                        poly_2_read_index <= poly_2_read_index - 1;
                        state <= poly_2_order_extractor;
                    else
                        state <= poly_2_order_write_state;
                    end if;
                when poly_2_order_write_state =>
                    state <= poly_2_order_write_state_stall;
                when poly_2_order_write_state_stall => 
                    if poly_1_order < poly_2_order then
                        state <= done_state;
                    elsif poly_1_order > poly_2_order then
                        ttr_write_index <= deg_delt;
                        poly_2_read_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                        state <= poly_1_shift;
                    else 
                        state <= poly_same_order_check_start;
                        poly_1_read_index <= poly_1_order;
                        poly_2_read_index <= poly_2_order;
                    end if;
                when poly_same_order_check_start =>
                    state <= poly_same_order_check;
                when poly_same_order_check =>
                    if poly_1 < poly_2 then
                        state <= done_state;
                    else
                        ttr_write_index <= deg_delt;
                        poly_2_read_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                        state <= poly_1_shift;
                    end if;
                when poly_1_shift =>
                    if ttr_write_index < POLYNOMIAL_LENGTH then
                        state <= write_ttr;
                    else 
                        state <= modinv_start_state;
                        poly_2_read_index <= poly_2_order;
                    end if;
                when write_ttr =>
                    state <= poly_1_shift;
                    ttr_write_index <= ttr_write_index + 1;
                    poly_2_read_index <= poly_2_read_index + 1;
                when modinv_start_state =>
                    if modinv_done = '0' then
                        state <= modinv_start_state;
                    else
                        state <= write_modinv;
                        ttr_read_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                        ttr_write_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                    end if;
                when write_modinv =>
                    state <= ttr_modinv_mult1;
                when ttr_modinv_mult1 =>
                    if ttr_read_index < POLYNOMIAL_LENGTH then
                        state <= ttr_modinv_write1;
                        ttr_read_index <= ttr_read_index + 1;
                    else
                        state <= ttr_modinv_mult2_stall;
                        poly_1_read_index <= poly_1_order;
                        ttr_read_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                        ttr_write_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                    end if;
                when ttr_modinv_write1 =>
                    ttr_write_index <= ttr_write_index + 1;
                    state <= ttr_modinv_mult1;
                when ttr_modinv_mult2_stall =>
                    state <= ttr_modinv_mult2;
                when ttr_modinv_mult2 =>
                    if ttr_read_index < POLYNOMIAL_LENGTH then
                        ttr_read_index <= ttr_read_index + 1;
                        state <= ttr_modinv_write2;
                    else
                        state <= final_subtract;
                        poly_1_write_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                        ttr_read_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                        poly_1_read_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                    end if;
                when ttr_modinv_write2 =>
                    state <= ttr_modinv_mult2;
                    ttr_write_index <= ttr_write_index + 1;
                when final_subtract =>
                    if poly_1_write_index < POLYNOMIAL_LENGTH then
                        state <= final_subtract_write;
                    else
                        ttr_write_index <= to_unsigned(0, INDEX_BIT_WIDTH);
                        poly_1_read_index <= POLYNOMIAL_LENGTH - to_unsigned(1, INDEX_BIT_WIDTH);
                        poly_2_read_index <= POLYNOMIAL_LENGTH - to_unsigned(1, INDEX_BIT_WIDTH);
                        state <= clear_ttr;
                    end if;
                when final_subtract_write =>
                    state <= final_subtract;
                    poly_1_write_index <= poly_1_write_index + 1;
                    ttr_read_index <= ttr_read_index + 1;
                    poly_1_read_index <= poly_1_read_index + 1;
                when done_state =>
                    state <= done_state;
             end case;
         end if;
     end process;
     
     combinational : process(state)
     begin
        case state is
            when idle =>
                poly_1_input_sel        <= '1';
                poly_1_write_index_sel  <= '1';
                poly_1_write_sel        <= '1';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '1';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when clear_ttr =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "11";
                ttr_write               <= '1';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when poly_1_order_extractor =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when poly_1_order_write_state =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '1';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when poly_2_order_extractor =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';                
            when poly_2_order_write_state =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '1';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';      
            when poly_2_order_write_state_stall =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when poly_same_order_check_start =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when poly_same_order_check =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when done_state =>
                poly_1_input_sel        <= '1';
                poly_1_write_index_sel  <= '1';
                poly_1_write_sel        <= '1';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '1';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '1';  
            when poly_1_shift =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';   
            when write_ttr =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '1';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when modinv_start_state =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '1';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';  
            when write_modinv =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '1';
                modinv_buff_write       <= '1';
                done                    <= '0';    
            when ttr_modinv_mult1 =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';   
            when ttr_modinv_write1 =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "01";
                ttr_write               <= '1';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';
            when ttr_modinv_mult2_stall =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';   
            when ttr_modinv_mult2 =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';       
            when ttr_modinv_write2 =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "10";
                ttr_write               <= '1';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';            
            when final_subtract =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '0';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';      
            when final_subtract_write =>
                poly_1_input_sel        <= '0';
                poly_1_write_index_sel  <= '0';
                poly_1_write_sel        <= '0';
                poly_1_write            <= '1';
                poly_1_read_index_sel   <= '0';
                ttr_input_sel           <= "00";
                ttr_write               <= '0';
                poly_1_order_write      <= '0';
                poly_2_order_write      <= '0';
                modinv_start            <= '0';
                modinv_reset            <= '0';
                modinv_buff_write       <= '0';
                done                    <= '0';    
        end case;
   end process;
                    
end Behavioral;
