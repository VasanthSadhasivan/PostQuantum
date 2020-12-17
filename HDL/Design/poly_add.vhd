----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 03:43:48 PM
-- Design Name: 
-- Module Name: poly_add - Behavioral
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

entity poly_add is
    Port (clk     : in std_logic;
          poly_0   : in port_t;
          poly_1   : in port_t;
          output  : out port_t);
end poly_add;

architecture Behavioral of poly_add is

component modular_reduction_q is
    Port ( input : in unsigned (BIT_WIDTH-1 downto 0);
           output : out unsigned (BIT_WIDTH-1  downto 0));
end component;

signal output_double : port_t;

begin

    main: for i in 0 to to_integer(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH) - 1) generate
        process(clk)
        begin
            if rising_edge(clk) then
                output_double(i) <= poly_0(i) + poly_1(i);
            end if;
		end process;
		
		modulus: modular_reduction_q 
        port map (
            input => output_double(i)(BIT_WIDTH-1 downto 0),
            output => output(i)
        );
    end generate main;

end Behavioral;
