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

entity buff is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC;
           write_index  : in index_t;
           read_index   : in index_t;
           input        : in coefficient_t; 
           output       : out coefficient_t);
end buff;

architecture Behavioral of buff is

signal data : port_t := (others => (others => '0'));
signal read_index_final : index_t := (others => '0');
begin
    main: process(clk)
    begin
        if rising_edge(clk) then
            output <= data(to_integer(read_index_final));
            if write = '1' then
                data(to_integer(write_index)) <= input;
            end if;
        end if;
    end process;
    
    read_index_final_driver: process(read_index)
    begin
        if read_index > to_unsigned(256, INDEX_BIT_WIDTH) then
            read_index_final <= to_unsigned(256, INDEX_BIT_WIDTH);
        else
            read_index_final <= read_index;
        end if;
    end process;

end Behavioral;
