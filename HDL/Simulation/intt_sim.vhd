library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity intt_sim is
end intt_sim;

architecture Behavioral of intt_sim is

    component intt is
        Port (  clk     : in std_logic;
                reset   : in std_logic;
                input   : in port_t;   
                start   : in std_logic;
                output  : out port_t;  
                valid   : out std_logic);
    end component intt;

    file file_VECTORS   : text;
    file file_RESULTS   : text;
  
    signal reset        : std_logic;
    signal input        : port_t;
    signal start        : std_logic;
    signal output       : port_t;
    signal right_output : port_t;
    signal valid        : std_logic;
	signal CLK          : std_logic := '0';

	constant CLK_period : time := 10 ns;

  begin
  
        transform: intt PORT MAP (
            clk => CLK,
            reset => reset,
            input => input,
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
            file input_file         : TEXT open READ_MODE is "input.txt";
            file output_file        : TEXT open READ_MODE is "output.txt";
            variable input_vector   : unsigned(BIT_WIDTH-1 downto 0);
            variable output_vector   : unsigned(BIT_WIDTH-1 downto 0);
        begin
            while not endfile(input_file) loop
                --readline(input_file, input_line);
                readline(input_file, output_line);
                --readline(output_file, output_line);
                readline(output_file, input_line);
                input_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    hread(input_line, input_vector);
                    hread(output_line, output_vector);
                    input(i)        <= input_vector;
                    right_output(i) <= output_vector;
                    report "Input Vector: " & to_hstring(input_vector);
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
