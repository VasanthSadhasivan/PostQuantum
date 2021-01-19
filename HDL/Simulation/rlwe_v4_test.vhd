library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rlwe_v4_test is
end rlwe_v4_test;

architecture Behavioral of rlwe_v4_test is

    component rlwe_main is
        Port (clk                       : in std_logic;
              start                     : in std_logic;
              reset                     : in std_logic;
              instruction               : in instruction_op_t;
              input_buffer_write        : in std_logic;
              input_buffer_write_index  : in index_t;
              input                     : in coefficient_t;
              output                    : out coefficient_t;
              output_buffer_read_index  : in index_t;
              valid                     : out std_logic);
    end component;
    
    signal DONTCHECK                : unsigned(BIT_WIDTH-1 downto 0)    := "0100010001000100010001";
    signal DONTCHECKINT             : index_t                           := (others => '0');
  
	signal CLK                      : std_logic                         := '0';
    signal start                    : std_logic                         := '0';
    signal reset                    : std_logic                         := '0';
    signal instruction              : instruction_t                     := (others => '0');
    signal input_buffer_write       : std_logic                         := '0';
    signal input_buffer_write_index : index_t                           := (others => '0');
    signal input                    : coefficient_t                     := (others => '0');
    signal output_signal                   : coefficient_t                     := (others => '0');
    signal output_buffer_read_index : index_t                           := (others => '0');
    signal valid                    : std_logic                         := '0';
    
    signal input_expected           : port_t                            := (others => (others => '0'));
    signal output_retrieved         : port_t                            := (others => (others => '0'));
    signal output_expected          : port_t                            := (others => (others => '0'));
    
	constant CLK_period             : time                              := 10 ns;

  begin
  
        rlwe_arch: rlwe_main PORT MAP (
            clk                       => clk,
            start                     => start,
            reset                     => reset,
            instruction               => instruction,
            input_buffer_write        => input_buffer_write,
            input_buffer_write_index  => input_buffer_write_index,
            input                     => input,
            output                    => output_signal,
            output_buffer_read_index  => output_buffer_read_index,
            valid                     => valid
        );

		CLK_process : process
		begin
			CLK <= '0';
			wait for CLK_period/2;
			CLK <= '1'; 
			wait for CLK_period/2;
		end process;
		
		
        main: process
            variable input_line_data    : line;
            variable input_line_inst    : line;
            variable output_line        : line;
            file input_file_data        : TEXT open READ_MODE is "rlwe_v4_keyinit_input.txt";
            file input_file_inst        : TEXT open READ_MODE is "rlwe_v4_keyinit_inst.txt";
            file output_file            : TEXT open READ_MODE is "rlwe_v4_keyinit_output.txt";
            variable input_vector_data  : unsigned(64-1 downto 0);
            variable input_vector_inst  : instruction_t;
            variable output_vector_exp  : unsigned(64-1 downto 0);
            variable counter            : integer;
        begin
            counter := 1;
            
            wait for CLK_period;
            reset <= '1';
            start <= '0';
            
            while not endfile(input_file_data) loop
                readline(input_file_data, input_line_data);
                readline(input_file_inst, input_line_inst);
                readline(output_file, output_line);
                
                hread(input_line_inst, input_vector_inst);

                input_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    hread(input_line_data, input_vector_data);
                    hread(output_line, output_vector_exp);
                    output_expected(i)  <= output_vector_exp(BIT_WIDTH-1 downto 0);
                    input_expected(i)   <= input_vector_data(BIT_WIDTH-1 downto 0);
                end loop;
                

                pass_input_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    wait for CLK_period;
                    input                       <= input_expected(i);
                    input_buffer_write          <= '1';
                    input_buffer_write_index    <= to_unsigned(i, log2(POLYNOMIAL_LENGTH)+1);
                end loop;
                wait for CLK_period;
                input_buffer_write <= '0';
                instruction <= input_vector_inst;
                
                wait for CLK_period;
                reset       <= '0';
                start       <= '1';
                wait for CLK_period;
                wait for CLK_period;
                wait for CLK_period;
                start       <= '0';
                wait on valid until valid = '1';
                wait on valid until valid = '0';
                read_output_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                output_buffer_read_index    <= to_unsigned(i, log2(POLYNOMIAL_LENGTH)+1);
                    output_buffer_read_index    <= to_unsigned(i, log2(POLYNOMIAL_LENGTH)+1);
                    wait for CLK_period;
                    wait for CLK_period;
                    output_retrieved(i)         <= output_signal;
                end loop;
                
                wait for CLK_period;
                
                report "-----TEST BENCH RESULTS-----";
                if output_expected = output_retrieved or output_expected(to_integer(DONTCHECKINT)) = DONTCHECK then
                    report "Test " & integer'image(counter) & " Output Matches";
                else
                    report "Test " & integer'image(counter) & " Output Incorrect";
                    
                    report "Expected:";
                    compare_output1: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                        write(output,to_hstring(output_expected(i)) & " ");
                    end loop;
                    report "";
                    report "Retrieved:";
                    compare_output2: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                        write(output,to_hstring(output_retrieved(i)) & " ");
                    end loop;
                end if;
                
                wait for CLK_period;
                counter := counter + 1;
            end loop;
        end process;
end Behavioral;
