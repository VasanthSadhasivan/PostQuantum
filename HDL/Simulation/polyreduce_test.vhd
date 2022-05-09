library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity polyreduce_test is
end polyreduce_test;

architecture Behavioral of polyreduce_test is

    component polyreduce is
        Port ( clk : in STD_LOGIC;
               poly_1 : in coefficient_t;
               poly_2 : in coefficient_t;
               write_index : in index_t;
               write : in STD_LOGIC;
               start : in STD_LOGIC;
               reset : in STD_LOGIC;
               read_index : in index_t;
               output : out coefficient_t;
               done : out STD_LOGIC);
    end component;
      
	signal CLK                      : std_logic                         := '0';
    signal poly_1                   : coefficient_t                     := (others => '0');
    signal poly_2                   : coefficient_t                     := (others => '0');
    signal write_index              : index_t                           := (others => '0');
    signal write                    : std_logic                         := '0';
    signal start                    : std_logic                         := '0';
    signal reset                    : std_logic                         := '0';
    signal read_index               : index_t                           := (others => '0');
    signal output                   : coefficient_t                     := (others => '0');
    signal done                    : std_logic                          := '0';
    
    signal poly1_port               : port_t                            := (others => (others => '0'));
    signal poly2_port               : port_t                            := (others => (others => '0'));
    signal output_retrieved         : port_t                            := (others => (others => '0'));
    signal output_expected          : port_t                            := (others => (others => '0'));
    
	constant CLK_period             : time                              := 20 ns;

  begin
  
        reduce: polyreduce PORT MAP (
            clk         => clk        ,
            poly_1      => poly_1     ,
            poly_2      => poly_2     ,
            write_index => write_index,
            write       => write      ,
            start       => start      ,
            reset       => reset      ,
            read_index  => read_index ,
            output      => output     ,
            done        => done       
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
            file input_file         : TEXT open READ_MODE is "polyreduce_sim_input.txt";
            file output_file        : TEXT open READ_MODE is "polyreduce_sim_output.txt";
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
                    poly1_port(i)           <= input_vector1(BIT_WIDTH-1 downto 0);
                    poly2_port(i)           <= input_vector2(BIT_WIDTH-1 downto 0);
                    output_expected(i)      <= output_vector(BIT_WIDTH-1 downto 0);
                    report "Input Vector 1: " & to_hstring(input_vector1);
                    report "Input Vector 2: " & to_hstring(input_vector2);
                    report "Output Vector: " & to_hstring(output_vector);
                end loop;
                
                pass_input_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    wait for CLK_period;
                    poly_1      <= poly1_port(i);
                    poly_2      <= poly2_port(i);
                    write       <= '1';
                    write_index <= to_unsigned(i, log2(POLYNOMIAL_LENGTH)+1);
                end loop;
                
                write <= '0';
                reset <= '1';
                start <= '0';
                wait for CLK_period;
                reset <= '0';
                start <= '1';
                wait for CLK_period;
                wait on done until done = '1';
                
                read_output_data_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                    read_index    <= to_unsigned(i, log2(POLYNOMIAL_LENGTH)+1);
                    wait for CLK_period;
                    wait for CLK_period;
                    output_retrieved(i)    <= output;
                end loop;
                wait for CLK_period;
                report "-----TEST BENCH RESULTS-----";
                
                if output_expected = output_retrieved then
                    report "Output Matches";
                else
                    report "Output Incorrect";
                    compare_output_loop: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)-1) loop
                        if output_retrieved(i) /= output_expected(i) then
                            report "At Index " & integer'image(i) & " Difference Exists";
                            report "Retrieved Value " & integer'image(to_integer(output_retrieved(i))) & " And Expected " & integer'image(to_integer(output_expected(i)));
                        end if;
                        if output_retrieved(i) = output_expected(i) then
                            report "At Index " & integer'image(i) & " Equals";
                            report "Retrieved Value " & integer'image(to_integer(output_retrieved(i))) & " And Expected " & integer'image(to_integer(output_expected(i)));
                        end if;
                    end loop;
                end if;
                
                wait on done until done = '0';

                
            end loop;
            
            wait;
        end process;
end Behavioral;
