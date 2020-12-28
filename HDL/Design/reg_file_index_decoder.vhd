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

entity reg_file_index_decoder is
    Port ( reg_file_arith_index     : in index_t;
           reg_file_random_index    : in index_t;
           in_arith_reg             : in STD_LOGIC;
           in_random_reg            : in STD_LOGIC;
           index                    : out index_t);
end reg_file_index_decoder;

architecture Behavioral of reg_file_index_decoder is

begin   
    decoder : process (reg_file_arith_index, reg_file_random_index, in_arith_reg, in_random_reg)
    begin
        if in_arith_reg = '1' then
            index <= reg_file_arith_index;
        elsif in_random_reg = '1' then
            index <= reg_file_random_index;
        else
            index <= reg_file_arith_index;
        end if;
    end process;
end Behavioral;