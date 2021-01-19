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

entity poly_add is
    Port (clk     : in std_logic;
          poly_0   : in coefficient_t;
          poly_1   : in coefficient_t;
          output  : out coefficient_t);
end poly_add;

architecture Behavioral of poly_add is

component modular_reduction_q is
    Port ( input : in double_coefficient_t;
           output : out coefficient_t);
end component;

signal output_double    : double_coefficient_t;
signal zero_pad         : coefficient_t := (others => '0');
begin
    zero_pad <= (others => '0');

    main : process(clk)
    begin
        if rising_edge(clk) then
            output_double <= zero_pad & (poly_0 + poly_1);
        end if;
    end process;
    
	modulus: modular_reduction_q 
    port map (
        input => output_double,
        output => output
    );

end Behavioral;
