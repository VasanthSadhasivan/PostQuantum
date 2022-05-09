----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2020 03:31:07 PM
-- Design Name: 
-- Module Name: poly_scalar_mult - Behavioral
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

entity poly_scalar_mult is
    Port ( clk : in STD_LOGIC;
           scalar : in coefficient_t;
           poly : in coefficient_t;
           output : out coefficient_t);
end poly_scalar_mult;

architecture Behavioral of poly_scalar_mult is

component modular_reduction_q is
    Port ( input : in double_coefficient_t;
           output : out coefficient_t);
end component;

signal output_double : double_coefficient_t;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            output_double <= poly * scalar;
        end if;
    end process;

    modulus: modular_reduction_q 
    port map (
        input => output_double,
        output => output
    );
end Behavioral;
