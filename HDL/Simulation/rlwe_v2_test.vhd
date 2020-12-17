library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rlwe_v2_test is
end rlwe_v2_test;

architecture Behavioral of rlwe_v2_test is

    component rlwe_main is
        Port (clk           : in std_logic;
              start         : in std_logic;
              reset         : in std_logic;
              instruction   : in instruction_t;
              input         : out port_t;
              output        : out port_t;
              valid         : out std_logic;
              output_test   : out std_logic);
    end component;
    
    signal DONTCHECK    : unsigned(BIT_WIDTH-1 downto 0) := x"1111111111111111";
    signal DONTCHECKINT : integer := 0;
  
	signal CLK          : std_logic := '0';
    signal start        : std_logic := '0';
    signal reset        : std_logic := '0';
    signal instruction  : instruction_t := "000000000000000000";
    signal input        : port_t;
    signal output       : port_t;
    signal valid        : std_logic;
    signal output_test  : std_logic;
    
    signal output_expected : port_t;
    
	constant CLK_period : time := 10 ns;

  begin
  
        rlwe_arch: rlwe_main PORT MAP (
            clk           => clk,
            start         => start,
            reset         => reset,
            instruction   => instruction,
            input         => input,
            output        => output,
            valid         => valid,
            output_test   => output_test
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
            file input_file_data        : TEXT open READ_MODE is "rlwe_v2_decryption_input.txt";
            file input_file_inst        : TEXT open READ_MODE is "rlwe_v2_decryption_inst.txt";
            file output_file            : TEXT open READ_MODE is "rlwe_v2_decryption_output.txt";
            variable input_vector_data  : unsigned(BIT_WIDTH-1 downto 0);
            variable input_vector_inst  : instruction_t;
            variable output_vector_exp  : unsigned(BIT_WIDTH-1 downto 0);
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
                    output_expected(i) <= output_vector_exp;
                    input(i) <= input_vector_data;
                    --report "Input Vector Inst: " & to_hstring(input_vector_inst);
                    --report "Input Vector Data: " & to_hstring(input_vector_data);
                    --report "Output Vector: " & to_hstring(output_vector_exp);
                end loop;
                

                wait for CLK_period;
                reset <= '0';
                start <= '1';
                instruction <= input_vector_inst;
                wait for CLK_period;
                wait on output_test until output_test = '1';

                
                report "-----TEST BENCH RESULTS-----";
                if output_expected = output or output_expected(DONTCHECKINT) = DONTCHECK then
                    report "Test " & integer'image(counter) & " Output Matches";
                else
                    report "Test " & integer'image(counter) & " Output Incorrect";
                    report "1st Output Expected: " & to_hstring(output_expected(0));
                    report "1st Output Actual: " & to_hstring(output(0));
                end if;
                
                wait on valid until valid = '1';
                wait for CLK_period;
                counter := counter + 1;
            end loop;
        end process;
end Behavioral;
