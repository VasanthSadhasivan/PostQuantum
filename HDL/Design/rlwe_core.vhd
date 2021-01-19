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
--      1. mode = 4 --> polynomial coefficient rlwe decode
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
    Port (clk           : in std_logic;
          start         : in std_logic;
          reset         : in std_logic;
          mode          : in std_logic_vector(2 downto 0);
          poly_0        : in coefficient_t;
          poly_1        : in coefficient_t;
          write_index   : in index_t;
          write         : in std_logic;
          read_index    : in index_t;
          output        : out coefficient_t;
          valid         : out std_logic
           );
end rlwe_core;

architecture Behavioral of rlwe_core is


component rlwe_core_control_unit is
    Port (clk                       : in std_logic;
          mode_buffer               : in std_logic_vector(2 downto 0);
          start                     : in std_logic;
          reset                     : in std_logic;
          poly_mult_valid           : in std_logic;
          mode_buffer_write         : out std_logic;
          valid                     : out std_logic;
          poly_mult_reset           : out std_logic;
          poly_mult_start           : out std_logic;
          poly_0_buffer_read_index  : out index_t;
          poly_1_buffer_read_index  : out index_t;
          poly_mult_read_index      : out index_t;
          poly_mult_write_index     : out index_t;
          output_buffer_write_index : out index_t;
          output_buffer_write       : out std_logic;
          poly_mult_write           : out std_logic
          );
end component;

component poly_mult is
    Port (clk           : in std_logic;
          reset         : in std_logic; 
          poly_0        : in coefficient_t;
          poly_1        : in coefficient_t;
          start         : in std_logic;
          write         : in std_logic;
          write_index   : in index_t;
          read_index    : in index_t;
          output        : out coefficient_t;
          valid         : out std_logic);
end component;

component poly_add is
    Port (clk     : in std_logic;
          poly_0   : in coefficient_t;
          poly_1   : in coefficient_t;
          output  : out coefficient_t);
end component;

component poly_negate is
    Port (clk     : in std_logic;
          poly   : in coefficient_t;
          output  : out coefficient_t);
end component;

component poly_scalar_mult is
    Port ( clk : in STD_LOGIC;
           scalar : in coefficient_t;
           poly : in coefficient_t;
           output : out coefficient_t);
end component;

component decoder is
    Port (clk     : in std_logic;
          poly_0   : in coefficient_t;
          output  : out coefficient_t);
end component;

component buff is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC;
           write_index  : in index_t;
           read_index   : in index_t;
           input        : in coefficient_t; 
           output       : out coefficient_t);
end component;

component rlwe_mode_buffer is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC;
           input        : in std_logic_vector(2 downto 0); 
           output       : out std_logic_vector(2 downto 0));
end component;

component poly_0_0_reg is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC; 
           index        : in index_t;
           input        : in coefficient_t; 
           output       : out coefficient_t);
end component;

signal poly_mult_valid              : std_logic                     := '0';
signal poly_mult_reset              : std_logic                     := '0';
signal poly_mult_start              : std_logic                     := '0';

signal poly_add_output              : coefficient_t                 := (others => '0');
signal poly_mult_output             : coefficient_t                 := (others => '0');
signal poly_negate_output           : coefficient_t                 := (others => '0');
signal poly_scalar_mult_output      : coefficient_t                 := (others => '0');
signal poly_decoded_output          : coefficient_t                 := (others => '0');

signal poly_0_buffer                : coefficient_t                 := (others => '0');
signal poly_1_buffer                : coefficient_t                 := (others => '0');
signal mode_buffer                  : std_logic_vector(2 downto 0)  := (others => '0');
signal output_buffer_input          : coefficient_t                 := (others => '0');

signal poly_0_buffer_read_index     : index_t                       := (others => '0');
signal poly_1_buffer_read_index     : index_t                       := (others => '0');

signal poly_mult_read_index         : index_t                       := (others => '0');
signal poly_mult_write_index        : index_t                       := (others => '0');
signal poly_mult_write              : std_logic                     := '0';

signal output_buffer_write          : std_logic                     := '0';
signal output_buffer_write_index    : index_t                       := (others => '0');

signal mode_buffer_write            : std_logic                     := '0';

signal scalar_buffer                : coefficient_t                 := (others => '0');

begin
        
    poly_0_buffer_component : buff
    port map (
        clk         => clk,
        write       => write,
        write_index => write_index,
        read_index  => poly_0_buffer_read_index,
        input       => poly_0,
        output      => poly_0_buffer
    );
    
    poly_1_buffer_component : buff
    port map (
        clk         => clk,
        write       => write,
        write_index => write_index,
        read_index  => poly_1_buffer_read_index,
        input       => poly_1,
        output      => poly_1_buffer
    );
    
    rlwe_mode_buffer_component : rlwe_mode_buffer
    port map (
        clk         => clk,
        write       => mode_buffer_write,
        input       => mode,
        output      => mode_buffer
    );
    
    scalar_buffer_component : poly_0_0_reg
    port map (
        clk     => clk,
        write   => write,
        input   => poly_0,
        index   => write_index,
        output  => scalar_buffer
    );
    
    control_unit: rlwe_core_control_unit
    port map (
        clk                         => clk, 
        mode_buffer                 => mode_buffer, 
        start                       => start, 
        reset                       => reset, 
        poly_mult_valid             => poly_mult_valid, 
        mode_buffer_write           => mode_buffer_write, 
        valid                       => valid, 
        poly_mult_reset             => poly_mult_reset, 
        poly_mult_start             => poly_mult_start, 
        poly_0_buffer_read_index    => poly_0_buffer_read_index, 
        poly_1_buffer_read_index    => poly_1_buffer_read_index, 
        poly_mult_read_index        => poly_mult_read_index, 
        poly_mult_write_index       => poly_mult_write_index, 
        output_buffer_write_index   => output_buffer_write_index, 
        output_buffer_write         => output_buffer_write, 
        poly_mult_write             => poly_mult_write
    );
    
    adder: poly_add
    port map (
        clk     => clk,
        poly_0  => poly_0_buffer,
        poly_1  => poly_1_buffer,
        output  => poly_add_output
    );

    multipler: poly_mult
    port map (
        clk         => clk,
        reset       => reset,
        poly_0      => poly_0_buffer,
        poly_1      => poly_1_buffer,
        read_index  => poly_mult_read_index,
        write_index => poly_mult_write_index,
        write       => poly_mult_write,
        start       => poly_mult_start,
        output      => poly_mult_output,
        valid       => poly_mult_valid
    );
    
    negate: poly_negate
    port map (
        clk     => clk,
        poly    => poly_1_buffer,
        output  => poly_negate_output
    );
    
    scalar_mult: poly_scalar_mult
    port map (
        clk     => clk,
        scalar  => scalar_buffer,
        poly    => poly_1_buffer,
        output  => poly_scalar_mult_output
    );
    
    decrypt_decoder: decoder
    port map (
        clk     => clk,
        poly_0  => poly_1_buffer,
        output  => poly_decoded_output
    );
    
    output_buffer_component : buff
    port map (
        clk         => clk,
        write       => output_buffer_write,
        write_index => output_buffer_write_index,
        read_index  => read_index,
        input       => output_buffer_input,
        output      => output
        
    );
        
    output_mux : process(mode_buffer, poly_mult_output, poly_add_output, poly_negate_output, poly_scalar_mult_output, poly_decoded_output)
    begin
        if mode_buffer = "000" then
            output_buffer_input <= poly_add_output;
        elsif mode_buffer = "001" then
            output_buffer_input <= poly_mult_output;
        elsif mode_buffer = "010" then
            output_buffer_input <= poly_negate_output;
        elsif mode_buffer = "011" then
            output_buffer_input <= poly_scalar_mult_output;
        else 
            output_buffer_input <= poly_decoded_output;
        end if;
    end process;

end Behavioral;
