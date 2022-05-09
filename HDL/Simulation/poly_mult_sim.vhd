library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity poly_mult_sim is
end poly_mult_sim;

architecture Behavioral of poly_mult_sim is

    component poly_mult is
        Port (clk     : in std_logic;
              reset   : in std_logic; 
              poly_0   : in port_t;
              poly_1   : in port_t;
              start   : in std_logic;
              output  : out port_t;
              valid   : out std_logic);
    end component;

    file file_VECTORS   : text;
    file file_RESULTS   : text;
  
    signal reset        : std_logic;
    signal input1        : port_t;
    signal input2        : port_t;
    signal start        : std_logic;
    signal output       : port_t;
    signal right_output : port_t;
    signal valid        : std_logic;
	signal CLK          : std_logic := '0';

	constant CLK_period : time := 10 ns;

  begin
  
        multiplier: poly_mult PORT MAP (
            clk => CLK,
            reset => reset,
            poly_0 => input1,
            poly_1 => input2,
            start => start,
            output => output,
            valid => valid
        );

		CLK_process : process
		begin
			CLK <= '0';
			wait for CLK_period/2;
			CLK <= '1'; 
			wait for CLK_period/2;
		end process;
		
		
        feed_input: process
            variable input_line     : line;
            variable output_line    : line;
            file input_file         : TEXT open READ_MODE is "poly_mult_sim_input.txt";
            file output_file        : TEXT open READ_MODE is "poly_mult_sim_output.txt";
            variable input_vector1   : unsigned(BIT_WIDTH-1 downto 0);
            variable input_vector2   : unsigned(BIT_WIDTH-1 downto 0);
            variable output_vector   : unsigned(BIT_WIDTH-1 downto 0);
        begin
            while not endfile(input_file) loop
                readline(input_file, input_line);
                --readline(input_file, output_line);
                readline(output_file, output_line);
                --readline(output_file, input_line);
                input_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    hread(input_line, input_vector1);
                    hread(input_line, input_vector2);
                    hread(output_line, output_vector);
                    input1(i)        <= input_vector1;
                    input2(i)        <= input_vector2;
                    right_output(i) <= output_vector;
                    report "Input Vector 1: " & to_hstring(input_vector1);
                    report "Input Vector 2: " & to_hstring(input_vector1);
                    report "Output Vector: " & to_hstring(output_vector);
                end loop;
            end loop;
            
            wait;
        end process;
        
        verify_output: process
        begin
            wait on valid until valid = '1';
            wait for CLK_period;
            
            report "-----TEST BENCH RESULTS-----";
            
            if right_output = output then
                report "Output Matches";
            else
                report "Output Incorrect";
            end if;
        end process;
        
        main: process
        begin
            wait for 1 ns;
            
            reset <= '1';
            start <= '0';
            wait for CLK_period;
            
            reset <= '0';
            start <= '1';
            wait for CLK_period;
            
            wait;
        end process;
end Behavioral;
