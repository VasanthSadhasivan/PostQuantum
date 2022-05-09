----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/15/2022 10:46:22 PM
-- Design Name: 
-- Module Name: coeff_buffer - Behavioral
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

entity coeff_buffer is
    Port ( clk : in STD_LOGIC;
           write : in STD_LOGIC;
           input : in coefficient_t;
           output : out coefficient_t);
end coeff_buffer;


architecture Behavioral of coeff_buffer is


begin
    main: process(clk)
    begin
        if rising_edge(clk) then
            if write = '1' then
                output <= input;
            end if;
        end if;
    end process;

end Behavioral;
