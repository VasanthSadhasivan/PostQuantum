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

entity reg_file_ram is
    Port (  clk     : in STD_LOGIC;
            input   : in coefficient_t;
            addr    : in index_t;
            write   : in STD_LOGIC;
            output  : out coefficient_t);
end reg_file_ram;


architecture Behavioral of reg_file_ram is

signal ram_data : port_t := (others=>(others=>'0'));

begin   
    rw_process : process(clk)
    begin
        if rising_edge(clk) then
            output <= ram_data(to_integer(unsigned(addr)));

            if write = '1' then
                ram_data(to_integer(unsigned(addr))) <= input;
            end if;
            
        end if;
    end process;
end Behavioral;