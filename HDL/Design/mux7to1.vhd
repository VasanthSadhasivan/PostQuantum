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

entity mux7to1 is
    Port (input1    : in port_t;
          input2    : in port_t;
          input3    : in port_t;
          input4    : in port_t;
          input5    : in port_t;
          input6    : in port_t;
          input7    : in port_t;
          sel       : in std_logic_vector(2 downto 0);
          output    : out port_t );
end mux7to1;

architecture Behavioral of mux7to1 is

begin
    main: process(sel, input1, input2)
    begin
        case sel is 
            when "000" =>
                output <= input1;
            when "001" =>
                output <= input2;
            when "010" =>
                output <= input3;
            when "011" =>
                output <= input4;
            when "100" =>
                output <= input5;
            when "101" =>
                output <= input6;
            when "110" =>
                output <= input7;
            when others =>
                output <= input1;
        end case;
    end process;
end Behavioral;
