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

entity reg_file_output_mux is
    Port ( clk      : in STD_LOGIC;
           input_0  : in coefficient_t;
           input_1  : in coefficient_t;
           input_2  : in coefficient_t;
           input_3  : in coefficient_t;
           input_4  : in coefficient_t;
           input_5  : in coefficient_t;
           input_6  : in coefficient_t;
           input_7  : in coefficient_t;
           input_8  : in coefficient_t;
           input_9  : in coefficient_t;
           input_10 : in coefficient_t;
           input_11 : in coefficient_t;
           input_12 : in coefficient_t;
           input_13 : in coefficient_t;
           input_14 : in coefficient_t;
           input_15 : in coefficient_t;
           sel      : in STD_LOGIC_VECTOR(3 downto 0);
           output   : out coefficient_t);
end reg_file_output_mux;

architecture Behavioral of reg_file_output_mux is

signal delayed_select : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

begin
    slect_line_flop : process(clk)
    begin
        if rising_edge(clk) then
            delayed_select <= sel;
        end if;
    end process;
    
    decoder : process ( delayed_select, 
                        input_0, 
                        input_1, 
                        input_2, 
                        input_3, 
                        input_4,
                        input_5,
                        input_6,
                        input_7,
                        input_8,
                        input_9,
                        input_10,
                        input_11,
                        input_12,
                        input_13,
                        input_14,
                        input_15)
    begin
        case delayed_select is
            when "0000" =>
                output <= input_0;
            when "0001" =>
                output <= input_1;
            when "0010" =>
                output <= input_2;
            when "0011" =>
                output <= input_3;
            when "0100" =>
                output <= input_4;
            when "0101" =>
                output <= input_5;
            when "0110" =>
                output <= input_6;
            when "0111" =>
                output <= input_7;
            when "1000" =>
                output <= input_8;
            when "1001" =>
                output <= input_9;
            when "1010" =>
                output <= input_10;
            when "1011" =>
                output <= input_11;
            when "1100" =>
                output <= input_12;
            when "1101" =>
                output <= input_13;
            when "1110" =>
                output <= input_14;
            when "1111" =>
                output <= input_15;
            when others =>
                output <= input_15;
        end case;
    end process;
end Behavioral;