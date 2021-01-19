----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/BIT_WIDTH-1/2019 09:07:08 PM
-- Design Name: 
-- Module Name: ROM_twiddle_factors - Behavioral
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
library work;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.my_types.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ROM_iphi is
  Port (
        clk     : in std_logic;
        index   : in index_t;
        output  : out coefficient_t
        );
end ROM_iphi;

architecture Behavioral of ROM_iphi is

signal iphi : port_t := (others => (others => '0'));
begin
    iphi <= read_mem_file("phi_inv_ram.hex");
    
    main : process (clk)
    begin
        if rising_edge(clk) then
            output <= iphi(to_integer(index));
        end if;
    end process;
end Behavioral;
