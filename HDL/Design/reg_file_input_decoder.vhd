----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2020 02:46:02 PM
-- Design Name: 
-- Module Name: reg_file - Behavioral
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

entity reg_file_input_decoder is
    Port ( write_0          : in STD_LOGIC;
           in_value_0       : in coefficient_t;
           write_1          : in STD_LOGIC;
           in_value_1       : in coefficient_t;
           reg_file_sel_0   : in STD_LOGIC_VECTOR(3 downto 0);
           reg_file_sel_1   : in STD_LOGIC_VECTOR(3 downto 0);
           index            : in STD_LOGIC_VECTOR(3 downto 0);
           write            : out STD_LOGIC;
           output           : out coefficient_t);
end reg_file_input_decoder;

architecture Behavioral of reg_file_input_decoder is

begin   
    decoder : process (write_0, write_1, in_value_0, in_value_1, reg_file_sel_0, reg_file_sel_1)
    begin
        if (reg_file_sel_0 = index and write_0 = '1') then
            output  <= in_value_0;
            write  <= '1';
        elsif (reg_file_sel_1 = index and write_1 = '1') then
            output  <= in_value_1;
            write  <= '1';
        else
            output  <= in_value_0;
            write  <= '0';
        end if;
    end process;
end Behavioral;