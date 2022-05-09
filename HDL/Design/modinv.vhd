----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2022 07:56:13 AM
-- Design Name: 
-- Module Name: modinv - Behavioral
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

entity modinv is
    Port (
        clk     : in STD_LOGIC;
        a       : in coefficient_t;
        start   : in STD_LOGIC;
        reset   : in STD_LOGIC;
        output  : out coefficient_t;
        done    : out STD_LOGIC;
        error   : out STD_LOGIC
    );
end modinv;

architecture Behavioral of modinv is

component egcd is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           a : in coefficient_t;
           b : in coefficient_t;
           x : out coefficient_t;
           y : out coefficient_t;
           a1 : out coefficient_t;
           done : out STD_LOGIC);
end component;

component modinv_control_unit is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           egcd_done : in STD_LOGIC;
           egcd_start : out STD_LOGIC;
           egcd_reset : out STD_LOGIC;
           done : out STD_LOGIC;
           error : out STD_LOGIC);
end component;

component coeff_buffer is
    Port ( clk : in STD_LOGIC;
           write : in STD_LOGIC;
           input : in coefficient_t;
           output : out coefficient_t);
end component;

component modular_reduction_q is
    Port ( input : in double_coefficient_t;
           output : out coefficient_t);
end component;

signal egcd_start   : std_logic := '0';
signal egcd_reset   : std_logic := '0';
signal egcd_done    : std_logic := '0';
signal egcd_x       : coefficient_t := (others => '0');
signal egcd_x_double: double_coefficient_t := (others => '0');
signal mod_input    : double_coefficient_t := (others => '0');
signal max          : double_coefficient_t := (others => '1');

begin
    max <= (others => '1');
    
    egcd_x_double <= unsigned(to_signed(to_integer(signed(egcd_x)), 2*BIT_WIDTH));
    
    mod_input_driver: process(egcd_x_double, max)
    begin
        if signed(egcd_x_double) < 0 then
            mod_input <= to_unsigned(MODULO - to_integer((max + 1 - egcd_x_double)), 2*BIT_WIDTH);
        else 
            mod_input <= egcd_x_double;
        end if;
    end process;
    
    egcd_module: egcd
    port map (
        clk     => clk,
        start   => egcd_start,
        reset   => egcd_reset,
        a       => a,
        b       => to_unsigned(MODULO, BIT_WIDTH),
        x       => egcd_x,
        y       => open,
        a1      => open,
        done    => egcd_done
    );
    
    mod_block: modular_reduction_q
    port map (
        input   => mod_input,
        output  => output
    );
    
    cu: modinv_control_unit
    port map (
        clk           => clk,
        start         => start,
        reset         => reset,
        egcd_done     => egcd_done,
        egcd_start    => egcd_start,
        egcd_reset    => egcd_reset,
        done          => done,
        error         => open
    );

end Behavioral;
