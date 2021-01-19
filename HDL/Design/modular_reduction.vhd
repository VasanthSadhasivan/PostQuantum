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
    Port ( input : in double_coefficient_t;
           output : out coefficient_t);
end modular_reduction_q;

architecture Behavioral of modular_reduction_q is

signal multiplied_value : unsigned(BIT_WIDTH*3-1 downto 0) := (others => '0');
signal shifted_value : unsigned(BIT_WIDTH-1 downto 0) := (others => '0');
signal shifted_value_test : unsigned(BIT_WIDTH*3-2*BARRET_REDUCTION_K-1 downto 0) := (others => '0');
signal subtracted_value : unsigned(2*BIT_WIDTH-1 downto 0) := (others => '0');
signal subtracted_value_test : unsigned(6*BIT_WIDTH-2*BARRET_REDUCTION_K-1 downto 0) := (others => '0');
signal output_test : unsigned(BIT_WIDTH-1 downto 0) := (others => '0');
signal output_original : unsigned(BIT_WIDTH-1 downto 0) := (others => '0');
signal output_diff : std_logic := '0';
signal zero_pad : unsigned(4*BIT_WIDTH-2*BARRET_REDUCTION_K-1 downto 0) := (others => '0');
attribute mark_debug : string;
attribute mark_debug of output_diff : signal is "true";
begin
    zero_pad <= (others => '0');
    multiplied_value <= input * BARRET_REDUCTION_CONSTANT;
    shifted_value_test <= shift_right(multiplied_value, 2*BARRET_REDUCTION_K)(BIT_WIDTH*3-2*BARRET_REDUCTION_K-1 downto 0);
    subtracted_value_test <= zero_pad & input - shifted_value_test*MODULO;
    output <= output_test;
    output_test <= subtracted_value_test(BIT_WIDTH-1 downto 0) when (to_integer(subtracted_value_test(BIT_WIDTH-1 downto 0)) < MODULO) else (subtracted_value_test(BIT_WIDTH-1 downto 0) - MODULO);

end Behavioral;
