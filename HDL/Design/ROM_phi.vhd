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


                            
entity ROM_phi is
  Port (
         phi : out port_t);
end ROM_phi;



architecture Behavioral of ROM_phi is

/*signal main_data : port_t := read_mem_file("../imports/ROM_scripts/phi_ram.hex");*/
begin
    phi <= read_mem_file("phi_ram.hex");
end Behavioral;
