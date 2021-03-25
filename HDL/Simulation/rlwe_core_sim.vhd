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
    Port (clk           : in std_logic;
          start         : in std_logic;
          reset         : in std_logic;
          mode          : in std_logic_vector(2 downto 0);
          poly_0        : in coefficient_t;
          poly_1        : in coefficient_t;
          write_index   : in index_t;
          write         : in std_logic;
          read_index    : in index_t;
          output        : out coefficient_t;
          valid         : out std_logic
           );
    end component;

    file file_VECTORS   : text;
    file file_RESULTS   : text;
  
	signal CLK          : std_logic := '0';
    signal start        : std_logic := '0';
    signal valid        : std_logic;
    signal reset        : std_logic := '0';
    signal mode         : std_logic_vector(2 downto 0) := "110";
    signal poly_0_port  : port_t := (others => (others => '0'));
    signal poly_0       : coefficient_t := (others => '0');
    signal poly_1_port  : port_t := (others => (others => '0'));
    signal poly_1       : coefficient_t := (others => '0');
    signal write_index  : index_t := (others => '0');
    signal write        : std_logic := '0';
    signal read_index   : index_t := (others => '0');
    signal output       : coefficient_t := (others => '0');
    signal right_output_port : port_t := (others => (others => '0'));
    signal output_retrieved_port : port_t := (others => (others => '0'));
    
	constant CLK_period : time := 10 ns;

  begin
  
        core: rlwe_core PORT MAP (
            clk     => CLK,
            start   => start,
            reset   => reset,
            mode    => mode,
            poly_0   => poly_0,
            poly_1   => poly_1,
            write_index => write_index,
            write => write,
            read_index => read_index,
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
            variable input_vector1   : unsigned(64-1 downto 0);
            variable input_vector2   : unsigned(64-1 downto 0);
            variable output_vector   : unsigned(64-1 downto 0);
        begin
            while not endfile(input_file) loop
                readline(input_file, input_line);
                readline(output_file, output_line);
                input_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    hread(input_line, input_vector1);
                    hread(input_line, input_vector2);
                    hread(output_line, output_vector);
                    poly_0_port(i)        <= input_vector1(BIT_WIDTH-1 downto 0);
                    poly_1_port(i)        <= input_vector2(BIT_WIDTH-1 downto 0);
                    right_output_port(i) <= output_vector(BIT_WIDTH-1 downto 0);
                    report "Input Vector 1: " & to_hstring(input_vector1);
                    report "Input Vector 2: " & to_hstring(input_vector2);
                    report "Output Vector: " & to_hstring(output_vector);
                end loop;
                
                pass_input_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    wait for CLK_period;
                    poly_0      <= poly_0_port(i);
                    poly_1      <= poly_1_port(i);
                    write       <= '1';
                    write_index <= to_unsigned(i, log2(POLYNOMIAL_LENGTH)+1);
                end loop;
                
                reset <= '1';
                start <= '0';
                wait for CLK_period;
                reset <= '0';
                start <= '1';
                wait for CLK_period;
                wait on valid until valid = '1';
                wait on valid until valid = '0';
                
                read_output_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    read_index    <= to_unsigned(i, log2(POLYNOMIAL_LENGTH)+1);
                    wait for CLK_period;
                    wait for CLK_period;
                    output_retrieved_port(i)    <= output;
                end loop;
                wait for CLK_period;
                report "-----TEST BENCH RESULTS-----";
                
                if right_output_port = output_retrieved_port then
                    report "Output Matches";
                else
                    report "Output Incorrect";
                    compare_output_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                        if output_retrieved_port(i) /= right_output_port(i) then
                            report "At Index " & integer'image(i) & " Difference Exists";
                        end if;
                    end loop;
                end if;
                
            end loop;
            
            wait;
        end process;
end Behavioral;
