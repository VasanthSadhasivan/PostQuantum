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

entity rlwe_mode_buffer is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC;
           input        : in std_logic_vector(2 downto 0); 
           output       : out std_logic_vector(2 downto 0));
end rlwe_mode_buffer;

architecture Behavioral of rlwe_mode_buffer is

signal data : std_logic_vector(2 downto 0) := (others => '0');

begin
    main: process(clk)
    begin
        if rising_edge(clk) then
            output <= data;
            if write = '1' then
                data <= input;
            end if;
        end if;
    end process;

end Behavioral;
