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

entity modular_reduction_q is
    Port ( input : in unsigned (BIT_WIDTH-1 downto 0);
           output : out unsigned (BIT_WIDTH-1  downto 0));
end modular_reduction_q;

architecture Behavioral of modular_reduction_q is

signal multiplied_value : unsigned(BIT_WIDTH*2-1 downto 0) := to_unsigned(0, BIT_WIDTH*2);
signal shifted_value : unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal subtracted_value : unsigned(BIT_WIDTH*2-1 downto 0) := to_unsigned(0, BIT_WIDTH*2);

begin
    multiplied_value <= input * BARRET_REDUCTION_CONSTANT;
    shifted_value <= shift_right(multiplied_value(BIT_WIDTH-1 downto 0), 2*to_integer(BARRET_REDUCTION_K));
    subtracted_value <= input - shifted_value*MODULO;
    output <= subtracted_value(BIT_WIDTH-1 downto 0) when (subtracted_value(BIT_WIDTH-1 downto 0) < MODULO) else (subtracted_value(BIT_WIDTH-1 downto 0) - MODULO);
end Behavioral;
