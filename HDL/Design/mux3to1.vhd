----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2020 06:24:21 PM
-- Design Name: 
-- Module Name: mux2to1 - Behavioral
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

entity mux3to1 is
    Port (input1    : in port_t;
          input2    : in port_t;
          input3    : in port_t;
          sel       : in std_logic_vector(1 downto 0);
          output    : out port_t );
end mux3to1;

architecture Behavioral of mux3to1 is

begin
    main: process(sel, input1, input2)
    begin
        if sel = "00" then
            output <= input1;
        elsif sel = "01" then
            output <= input2;
        else
            output <= input3;
        end if;
    end process;
end Behavioral;
