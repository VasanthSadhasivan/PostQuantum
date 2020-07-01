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


entity input_index_reversal is
  Port (
        input   : in port_t;
        output  : out port_t
       );
end input_index_reversal;

architecture Behavioral of input_index_reversal is

signal reversed_indeces : port_t;

begin

    main: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH) - 1) generate
        reverse_bits: for j in 0 to NUM_STAGES - 1 generate
            reversed_indeces(i)(j downto j) <= to_unsigned(i, BIT_WIDTH)(NUM_STAGES - 1 - j downto NUM_STAGES - 1 - j);
        end generate reverse_bits;
		output(i) <= input(to_integer(reversed_indeces(i)(NUM_STAGES - 1 downto 0)));
    end generate main;

end Behavioral;
