----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2020 02:47:29 PM
-- Design Name: 
-- Module Name: reg - Behavioral
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

entity poly_0_0_reg is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC; 
           index        : in index_t;
           input        : in coefficient_t; 
           output       : out coefficient_t);
end poly_0_0_reg;

architecture Behavioral of poly_0_0_reg is

signal data     : coefficient_t := (others => '0');

begin

    main: process(clk)
    begin
        if rising_edge(clk) then
            output <= data;
            if write = '1' and to_integer(index) = 0 then
                data <= input;
            end if;
        end if;
    end process;

end Behavioral;
