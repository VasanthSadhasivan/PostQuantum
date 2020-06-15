----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 05:24:27 PM
-- Design Name: 
-- Module Name: rlwe_core - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 4 modes of operation:
--      1. mode = 0 --> polynomial addition
--      1. mode = 1 --> polynomial multiplication
--      1. mode = 2 --> polynomial coefficient wise negation
--      1. mode = 3 --> polynomial coefficient wise scalar multiplication
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

entity rlwe_core is
    Port (clk   : in std_logic;
          start : in std_logic;
          reset : in std_logic;
          mode  : in std_logic_vector(1 downto 0);
          poly1 : in port_t;
          poly2 : in port_t;
          output: out port_t;
          valid : out std_logic
           );
end rlwe_core;

architecture Behavioral of rlwe_core is

component rlwe_core_control_unit is
    Port (clk               : in std_logic;
          mode              : in std_logic_vector(1 downto 0);
          start             : in std_logic;
          reset             : in std_logic;
          poly_mult_valid   : in std_logic;
          valid             : out std_logic;
          poly_mult_reset   : out std_logic;
          poly_mult_start   : out std_logic;
          output_sel        : out std_logic_vector(1 downto 0));
end component;

component poly_mult is
    Port (clk     : in std_logic;
          reset   : in std_logic; 
          poly1   : in port_t;
          poly2   : in port_t;
          start   : in std_logic;
          output  : out port_t;
          valid   : out std_logic);
end component;

component poly_add is
    Port (clk     : in std_logic;
          poly1   : in port_t;
          poly2   : in port_t;
          output  : out port_t);
end component;

component poly_negate is
    Port (clk     : in std_logic;
          poly   : in port_t;
          output  : out port_t);
end component;

component poly_scalar_mult is
    Port ( clk : in STD_LOGIC;
           scalar : in unsigned(BIT_WIDTH-1 downto 0);
           poly : in port_t;
           output : out port_t);
end component;

signal poly_mult_valid  : std_logic;
signal poly_mult_reset  : std_logic;
signal poly_mult_start  : std_logic;
signal output_sel       : std_logic_vector(1 downto 0);

signal poly_add_output          : port_t;
signal poly_mult_output         : port_t;
signal poly_negate_output       : port_t;
signal poly_scalar_mult_output  : port_t;

begin

    control_unit: rlwe_core_control_unit
    port map (
        clk             => clk,
        mode            => mode,
        start           => start,
        reset           => reset,
        poly_mult_valid => poly_mult_valid,
        valid           => valid,
        poly_mult_reset => poly_mult_reset,
        poly_mult_start => poly_mult_start,
        output_sel      => output_sel
    );

    multipler: poly_mult
    port map (
        clk     => clk,
        reset   => reset,
        poly1   => poly1,
        poly2   => poly2,
        start   => poly_mult_start,
        output  => poly_mult_output,
        valid   => poly_mult_valid
    );
    
    adder: poly_add
    port map (
        clk     => clk,
        poly1   => poly1,
        poly2   => poly2,
        output  => poly_add_output
    );
    
    negate: poly_negate
    port map (
        clk     => clk,
        poly    => poly1,
        output  => poly_negate_output
    );
    
    scalar_mult: poly_scalar_mult
    port map (
        clk     => clk,
        scalar  => poly2(0),
        poly    => poly1,
        output  => poly_scalar_mult_output
    );
    
    
    output_mux : process(output_sel, poly_mult_output, poly_add_output, poly_negate_output)
    begin
        if output_sel = "00" then
            output <= poly_add_output;
        elsif output_sel = "01" then
            output <= poly_mult_output;
        elsif output_sel = "10" then
            output <= poly_negate_output;
        else
            output <= poly_scalar_mult_output;
        end if;
    end process;


end Behavioral;
