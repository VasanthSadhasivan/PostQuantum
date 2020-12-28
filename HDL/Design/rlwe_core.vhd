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
    Port (clk               : in std_logic;
          mode              : in std_logic_vector(2 downto 0);
          start             : in std_logic;
          reset             : in std_logic;
          poly_mult_valid   : in std_logic;
          valid             : out std_logic;
          poly_mult_reset   : out std_logic;
          poly_mult_start   : out std_logic;
          output_sel        : out std_logic_vector(2 downto 0));
end component;

component poly_mult is
    Port (clk     : in std_logic;
          reset   : in std_logic; 
          poly_0   : in port_t;
          poly_1   : in port_t;
          start   : in std_logic;
          output  : out port_t;
          valid   : out std_logic);
end component;

component poly_add is
    Port (clk     : in std_logic;
          poly_0   : in port_t;
          poly_1   : in port_t;
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

component decoder is
    Port (clk     : in std_logic;
          poly_0   : in port_t;
          output  : out port_t);
end component;

signal poly_mult_valid          : std_logic                     := '0';
signal poly_mult_reset          : std_logic                     := '0';
signal poly_mult_start          : std_logic                     := '0';
signal output_sel               : std_logic_vector(2 downto 0)  :=(others => '0');

signal poly_add_output          : port_t                        := (others => (others => '0'));
signal poly_mult_output         : port_t                        := (others => (others => '0'));
signal poly_negate_output       : port_t                        := (others => (others => '0'));
signal poly_scalar_mult_output  : port_t                        := (others => (others => '0'));
signal poly_decoded_output      : port_t                        := (others => (others => '0'));

signal poly_0_buffer            : port_t                        := (others => (others => '0'));
signal poly_1_buffer            : port_t                        := (others => (others => '0'));
signal mode_buffer              : std_logic_vector(2 downto 0)  := (others => '0');
signal output_buffer            : port_t                        := (others => (others => '0'));

begin

    control_unit: rlwe_core_control_unit
    port map (
        clk             => clk,
        mode            => mode_buffer,
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
        poly_0  => poly_0_buffer,
        poly_1  => poly_1_buffer,
        start   => poly_mult_start,
        output  => poly_mult_output,
        valid   => poly_mult_valid
    );
    
    adder: poly_add
    port map (
        clk     => clk,
        poly_0  => poly_0_buffer,
        poly_1  => poly_1_buffer,
        output  => poly_add_output
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
        scalar  => poly_0_buffer(0),
        poly    => poly_1_buffer,
        output  => poly_scalar_mult_output
    );
    
    decrypt_decoder: decoder
    port map (
        clk     => clk,
        poly_0  => poly_1_buffer,
        output  => poly_decoded_output
    );
        
    input_buffer : process(clk)
    begin
        if rising_edge(clk) then
            if write = '1' then
                poly_0_buffer(to_integer(write_index))  <= poly_0;
                poly_1_buffer(to_integer(write_index))  <= poly_1;
            end if;
        end if;
    end process;
    
    mode_buffer_write : process(clk)
    begin
        if rising_edge(clk) then
            if start = '1' then
                mode_buffer                 <= mode;
            end if;
        end if;
    end process;
    
    output_buffer_process : process(clk)
    begin
        if rising_edge(clk) then
            if read_index < POLYNOMIAL_LENGTH then
                output <= output_buffer(to_integer(read_index));
            else
                output <= output_buffer(POLYNOMIAL_LENGTH - 1);
            end if;
        end if;
    end process;
        
    output_mux : process(clk, output_sel, poly_mult_output, poly_add_output, poly_negate_output, poly_scalar_mult_output, poly_decoded_output)
    begin
        if rising_edge(clk) then
            if output_sel = "000" then
                output_buffer <= poly_add_output;
            elsif output_sel = "001" then
                output_buffer <= poly_mult_output;
            elsif output_sel = "010" then
                output_buffer <= poly_negate_output;
            elsif output_sel = "011" then
                output_buffer <= poly_scalar_mult_output;
            else 
                output_buffer <= poly_decoded_output;
            end if;
        end if;
    end process;

end Behavioral;
