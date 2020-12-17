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

entity reg_file is
    Port ( clk          : in STD_LOGIC;
           in_value_0   : in port_t;
           in_value_1   : in port_t;
           reg_file_sel_0    : in STD_LOGIC_VECTOR(3 downto 0);
           reg_file_sel_1    : in STD_LOGIC_VECTOR(3 downto 0);
           rw_0         : in STD_LOGIC;
           rw_1         : in STD_LOGIC;
           out_0        : out port_t;
           out_1        : out port_t);
end reg_file;


architecture Behavioral of reg_file is

signal output_reg_array : port_array_t := (others=>(others=>(others=>'0')));

begin   
    rw_process : process(clk, rw_0, rw_1, reg_file_sel_0, reg_file_sel_1)
    begin
        if rising_edge(clk) then
            if rw_0 = '1' and rw_1 = '1' then
                if reg_file_sel_0 /= reg_file_sel_1 then
                     output_reg_array(to_integer(unsigned(reg_file_sel_0))) <= in_value_0;
                     output_reg_array(to_integer(unsigned(reg_file_sel_1))) <= in_value_1;
                else
                     output_reg_array(to_integer(unsigned(reg_file_sel_0))) <= output_reg_array(to_integer(unsigned(reg_file_sel_0)));
                     output_reg_array(to_integer(unsigned(reg_file_sel_1))) <= output_reg_array(to_integer(unsigned(reg_file_sel_1)));
                end if;
            elsif rw_0 = '1' then
                output_reg_array(to_integer(unsigned(reg_file_sel_0))) <= in_value_0;
            elsif rw_1 = '1' then
                output_reg_array(to_integer(unsigned(reg_file_sel_1))) <= in_value_1;
            end if;
            
            out_0 <= output_reg_array(to_integer(unsigned(reg_file_sel_0)));
            out_1 <= output_reg_array(to_integer(unsigned(reg_file_sel_1)));
        end if;
    end process;
end Behavioral;