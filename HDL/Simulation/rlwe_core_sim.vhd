library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rlwe_core_sim is
end rlwe_core_sim;

architecture Behavioral of rlwe_core_sim is

    component rlwe_core is
        Port (clk   : in std_logic;
              start : in std_logic;
              reset : in std_logic;
              mode  : in std_logic_vector(1 downto 0);
              poly1 : in port_t;
              poly2 : in port_t;
              output: out port_t;
              valid : out std_logic
               );
    end component;

    file file_VECTORS   : text;
    file file_RESULTS   : text;
  
	signal CLK          : std_logic := '0';
    signal start        : std_logic := '0';
    signal valid        : std_logic;
    signal reset        : std_logic := '0';
    signal mode         : std_logic_vector(1 downto 0) := "10";
    signal poly1        : port_t;
    signal poly2        : port_t;
    signal output       : port_t;
    signal right_output : port_t;
    
	constant CLK_period : time := 10 ns;

  begin
  
        core: rlwe_core PORT MAP (
            clk     => CLK,
            start   => start,
            reset   => reset,
            mode    => mode,
            poly1   => poly1,
            poly2   => poly2,
            output  => output,
            valid   => valid
        );

		CLK_process : process
		begin
			CLK <= '0';
			wait for CLK_period/2;
			CLK <= '1'; 
			wait for CLK_period/2;
		end process;
		
		
        main: process
            variable input_line     : line;
            variable output_line    : line;
            file input_file         : TEXT open READ_MODE is "rlwe_core_sim_input.txt";
            file output_file        : TEXT open READ_MODE is "rlwe_core_sim_output.txt";
            variable input_vector1   : unsigned(BIT_WIDTH-1 downto 0);
            variable input_vector2   : unsigned(BIT_WIDTH-1 downto 0);
            variable output_vector   : unsigned(BIT_WIDTH-1 downto 0);
        begin
            while not endfile(input_file) loop
                readline(input_file, input_line);
                readline(output_file, output_line);
                input_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    hread(input_line, input_vector1);
                    hread(input_line, input_vector2);
                    hread(output_line, output_vector);
                    poly1(i)        <= input_vector1;
                    poly2(i)        <= input_vector2;
                    right_output(i) <= output_vector;
                    report "Input Vector 1: " & to_hstring(input_vector1);
                    report "Input Vector 2: " & to_hstring(input_vector1);
                    report "Output Vector: " & to_hstring(output_vector);
                end loop;
                
                reset <= '1';
                start <= '0';
                wait for CLK_period;
                reset <= '0';
                start <= '1';
                wait for CLK_period;
                wait on valid until valid = '1';
                wait for CLK_period;                
                report "-----TEST BENCH RESULTS-----";
                if right_output = output then
                    report "Output Matches";
                else
                    report "Output Incorrect";
                end if;
                
            end loop;
            
            wait;
        end process;
end Behavioral;
