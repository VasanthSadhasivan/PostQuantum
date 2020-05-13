library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity pointwise_multiplier is
  Port (
            in1     : in port_t;
            in2     : in port_t; 
            output  : out port_t);
end pointwise_multiplier;

architecture Behavioral of pointwise_multiplier is

begin
    main: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH) - 1) generate
		output(i) <= in1(i)*in2(i);
    end generate main;
end Behavioral;
