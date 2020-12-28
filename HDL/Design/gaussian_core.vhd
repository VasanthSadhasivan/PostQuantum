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

entity gaussian_core is
    Port (clk           : in std_logic;
          gen           : in std_logic;
          reset         : in std_logic;
          read_index    : in index_t;
          valid         : out std_logic;
          output        : out coefficient_t );
end gaussian_core;

architecture Behavioral of gaussian_core is

begin

    main_process : process(clk)
    begin
        if rising_edge(clk) then
            output <= to_unsigned(1, BIT_WIDTH);
        end if;
    end process;

    reset_process : process(reset)
    begin
        if reset = '1' then
            valid <= '0';
        else
            valid <= '1';
        end if;
    end process;
    
end Behavioral;
