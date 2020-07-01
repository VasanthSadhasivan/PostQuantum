library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity pointwise_multiplier is
  Port (
            in1     : in port_t;
            in2     : in port_t;
            clk     : in std_logic;
            output  : out port_t);
end pointwise_multiplier;

architecture Behavioral of pointwise_multiplier is

component modular_reduction_q is
    Port ( input : in unsigned (BIT_WIDTH-1 downto 0);
           output : out unsigned (BIT_WIDTH-1  downto 0));
end component;

signal output_double : double_port_t;

begin

    main: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH) - 1) generate
        process(clk)
        begin
            if rising_edge(clk) then
                output_double(i) <= in1(i)*in2(i);
            end if;
		end process;
		
		modulus: modular_reduction_q 
        port map (
            input => output_double(i)(BIT_WIDTH-1 downto 0),
            output => output(i)
        );
    end generate main;
end Behavioral;
