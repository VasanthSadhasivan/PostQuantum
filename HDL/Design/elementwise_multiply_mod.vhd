library work;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_types.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity elementwise_multiply_mod is
  Port (
        input   : in port_t;
        output  : out port_t
       );
end elementwise_multiply_mod;

architecture Behavioral of elementwise_multiply_mod is

component modular_reduction_q is
    Port ( input : in double_coefficient_t;
           output : out coefficient_t);
end component;

signal input_mult : double_port_t;

begin

    main: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH) - 1) generate
        input_mult(i) <= NUM_STAGES_INV*input(i);
        modulus: modular_reduction_q 
        port map (
            input => input_mult(i),
            output => output(i)
        );
    end generate main;
    
    

end Behavioral;
