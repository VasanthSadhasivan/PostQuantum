----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 11:27:29 PM
-- Design Name: 
-- Module Name: uniform_core - Behavioral
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

entity icdf is
    Port (
        uniform_number  : in coefficient_t;
        gaussian_number : out coefficient_t
    );
end icdf;

architecture Behavioral of icdf is

    
begin
    fsm : process(uniform_number)
    begin
        if uniform_number < to_unsigned(1481, BIT_WIDTH) then
            gaussian_number <= to_unsigned(10, BIT_WIDTH);
        elsif uniform_number < to_unsigned(3781, BIT_WIDTH) then
            gaussian_number <= to_unsigned(9, BIT_WIDTH);
        elsif uniform_number < to_unsigned(8881, BIT_WIDTH) then
            gaussian_number <= to_unsigned(8, BIT_WIDTH);
        elsif uniform_number < to_unsigned(19221, BIT_WIDTH) then
            gaussian_number <= to_unsigned(7, BIT_WIDTH);
        elsif uniform_number < to_unsigned(38441, BIT_WIDTH) then
            gaussian_number <= to_unsigned(6, BIT_WIDTH);
        elsif uniform_number < to_unsigned(71101, BIT_WIDTH) then
            gaussian_number <= to_unsigned(5, BIT_WIDTH);
        elsif uniform_number < to_unsigned(121931, BIT_WIDTH) then
            gaussian_number <= to_unsigned(4, BIT_WIDTH);
        elsif uniform_number < to_unsigned(194341, BIT_WIDTH) then
            gaussian_number <= to_unsigned(3, BIT_WIDTH);
        elsif uniform_number < to_unsigned(288751, BIT_WIDTH) then
            gaussian_number <= to_unsigned(2, BIT_WIDTH);
        elsif uniform_number < to_unsigned(401441, BIT_WIDTH) then
            gaussian_number <= to_unsigned(1, BIT_WIDTH);
        elsif uniform_number < to_unsigned(647641, BIT_WIDTH) then
            gaussian_number <= to_unsigned(0, BIT_WIDTH);
        elsif uniform_number < to_unsigned(760321, BIT_WIDTH) then
            gaussian_number <= to_unsigned(1, BIT_WIDTH);
        elsif uniform_number < to_unsigned(854741, BIT_WIDTH) then
            gaussian_number <= to_unsigned(2, BIT_WIDTH);
        elsif uniform_number < to_unsigned(927141, BIT_WIDTH) then
            gaussian_number <= to_unsigned(3, BIT_WIDTH);
        elsif uniform_number < to_unsigned(977981, BIT_WIDTH) then
            gaussian_number <= to_unsigned(4, BIT_WIDTH);
        elsif uniform_number < to_unsigned(1010641, BIT_WIDTH) then
            gaussian_number <= to_unsigned(5, BIT_WIDTH);
        elsif uniform_number < to_unsigned(1029851, BIT_WIDTH) then
            gaussian_number <= to_unsigned(6, BIT_WIDTH);
        elsif uniform_number < to_unsigned(1040201, BIT_WIDTH) then
            gaussian_number <= to_unsigned(7, BIT_WIDTH);
        elsif uniform_number < to_unsigned(1045301, BIT_WIDTH) then
            gaussian_number <= to_unsigned(8, BIT_WIDTH);
        elsif uniform_number < to_unsigned(1047601, BIT_WIDTH) then
            gaussian_number <= to_unsigned(9, BIT_WIDTH);
        else
            gaussian_number <= to_unsigned(10, BIT_WIDTH);
        end if;
    end process;
end Behavioral;
