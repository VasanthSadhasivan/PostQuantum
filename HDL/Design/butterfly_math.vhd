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

entity butterfly_math is
    Port ( x_i      :   in  unsigned (BIT_WIDTH-1 downto 0);
           x_i_corr :   in  unsigned (BIT_WIDTH-1 downto 0);
           w        :   in  unsigned (BIT_WIDTH-1 downto 0);
           y_i      :   out unsigned (BIT_WIDTH-1 downto 0);
           y_i_corr :   out unsigned (BIT_WIDTH-1 downto 0)
          );
end butterfly_math;

architecture Behavioral of butterfly_math is

component modular_reduction_q is
    Port ( input :  in  unsigned (BIT_WIDTH-1 downto 0);
           output : out unsigned (BIT_WIDTH-1 downto 0)
          );
end component;

signal multiplication1      : unsigned (BIT_WIDTH*2-1 downto 0) := to_unsigned(0, BIT_WIDTH*2);
signal multiplication_mod1  : unsigned (BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal addition1            : unsigned (BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal addition_mod1        : unsigned (BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);

signal multiplication_mod2  : unsigned (BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal addition2            : unsigned (BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal addition2_temp       : unsigned (BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal addition_mod2        : unsigned (BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);

begin
    inner_modulus1: modular_reduction_q
    port map (
      input =>  multiplication1(BIT_WIDTH-1 downto 0),
      output => multiplication_mod1  
    );
    
    outer_modulus1: modular_reduction_q
    port map (
      input =>  addition1,
      output => addition_mod1
    );
    
    y_i <=  addition_mod1;
    
    multiplication1 <= x_i_corr * w;
    
    addition1 <= x_i + multiplication_mod1;


    outer_modulus2: modular_reduction_q
    port map (
      input =>  addition2,
      output => addition_mod2
    );
    
    y_i_corr <=  addition_mod2;
    
    addition2_temp <= x_i - multiplication_mod1;
    addition2 <= addition2_temp when (addition2_temp(BIT_WIDTH-1) = '0') else addition2_temp + to_unsigned(MODULO, BIT_WIDTH);

end Behavioral;
