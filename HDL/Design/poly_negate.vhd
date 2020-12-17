----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 03:43:48 PM
-- Design Name: 
-- Module Name: poly_add - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity poly_negate is
    Port (clk     : in std_logic;
          poly   : in port_t;
          output  : out port_t);
end poly_negate;

architecture Behavioral of poly_negate is

begin

    main: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH) - 1) generate
        process(clk)
        begin
            if rising_edge(clk) then
                if poly(i) /= to_unsigned(0, BIT_WIDTH) then
                    output(i) <= MODULO - poly(i);
                else
                    output(i) <= to_unsigned(0, BIT_WIDTH);
                end if;
            end if;
		end process;
    end generate main;

end Behavioral;
