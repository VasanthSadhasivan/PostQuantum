library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity pointwise_multiplier is
  Port (
            in1     : in coefficient_t;
            in2     : in coefficient_t;
            clk     : in std_logic;
            output  : out coefficient_t);
end pointwise_multiplier;

architecture Behavioral of pointwise_multiplier is

component modular_reduction_q is
    Port ( input : in double_coefficient_t;
           output : out coefficient_t);
end component;

signal output_double : double_coefficient_t;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            output_double <= in1 * in2;
        end if;
	end process;
	
	modulus: modular_reduction_q 
    port map (
        input => output_double,
        output => output
    );
end Behavioral;
