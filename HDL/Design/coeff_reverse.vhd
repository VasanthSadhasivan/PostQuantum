----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 12:07:40 AM
-- Design Name: 
-- Module Name: coeff_reverse - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.my_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity coeff_reverse is
    Port (  input   : in port_t;
            output  : out port_t );
end coeff_reverse;

architecture Behavioral of coeff_reverse is
signal reversed_indeces : port_t;

begin
    main: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH) - 1) generate
        reversed_indeces(i) <= to_unsigned(POLYNOMIAL_LENGTH - 1 - i, BIT_WIDTH);
		output(i) <= input(to_integer(reversed_indeces(i)));
    end generate main;
end Behavioral;
