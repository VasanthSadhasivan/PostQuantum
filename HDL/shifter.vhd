----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/30/2019 07:20:19 PM
-- Design Name: 
-- Module Name: shifter - Behavioral
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

use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shifter is
    Port ( n : in unsigned (BIT_WIDTH-1 downto 0);
           shift_by : in unsigned (BIT_WIDTH-1 downto 0);
           output : out unsigned (BIT_WIDTH-1 downto 0));
end shifter;

architecture Behavioral of shifter is

signal shift_by_integer : integer;

begin
    shift_by_integer <= to_integer(shift_by);
    
    process(shift_by)
    begin
        output <= shift_left(n, shift_by_integer);
    end process;
end Behavioral;
