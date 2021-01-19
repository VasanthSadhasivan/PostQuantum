library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity poly_mult is
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
end poly_mult;

architecture Behavioral of poly_mult is

component poly_mult_control_unit is
    Port ( 
            clk                         : in STD_LOGIC;
            
            poly_0_buffer_read_index    : out index_t := (others => '0');
            poly_1_buffer_read_index    : out index_t := (others => '0');
            phi_rom_index               : out index_t := (others => '0');
            
            ntt_0_rst                   : out STD_LOGIC;
            ntt_0_write                 : out STD_LOGIC;
            ntt_0_valid                 : in STD_LOGIC;
            ntt_0_index                 : out index_t := (others => '0');
            ntt_0_start                 : out STD_LOGIC;

            ntt_1_rst                   : out STD_LOGIC;
            ntt_1_write                 : out STD_LOGIC;
            ntt_1_start                 : out STD_LOGIC;
            ntt_1_valid                 : in STD_LOGIC;
            ntt_1_index                 : out index_t := (others => '0');
            
            intt_rst                    : out STD_LOGIC;
            intt_start                  : out STD_LOGIC;
            intt_write                  : out STD_LOGIC;
            intt_valid                  : in STD_LOGIC;
            intt_index                  : out index_t := (others => '0');

            iphi_rom_index              : out index_t := (others => '0');
            
            output_buffer_write         : out STD_LOGIC;
            output_buffer_write_index   : out index_t := (others => '0');
            
            valid                       : out STD_LOGIC;
            start                       : in STD_LOGIC;
            reset                       : in STD_LOGIC
            );
end component;

component intt is
  Port (clk     : in std_logic;
        reset   : in std_logic;
        input   : in coefficient_t;
        start   : in std_logic;
        write   : in std_logic;
        index   : in index_t;
        output  : out coefficient_t;
        valid   : out std_logic);
end component;

component ntt is
  Port (clk     : in std_logic;
        reset   : in std_logic;
        input   : in coefficient_t;
        write   : in std_logic;
        index   : in index_t;
        start   : in std_logic;
        output  : out coefficient_t;
        valid   : out std_logic);
end component;

component pointwise_multiplier is
  Port (in1     : in coefficient_t;
        in2     : in coefficient_t; 
        clk     : in std_logic;
        output  : out coefficient_t);
end component;

component ROM_phi is
  Port (
        clk     : in std_logic;
        index   : in index_t;
        output  : out coefficient_t
        );
end component;

component ROM_iphi is
  Port (
        clk     : in std_logic;
        index   : in index_t;
        output  : out coefficient_t
        );
end component;

component buff is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC;
           write_index  : in index_t;
           read_index   : in index_t;
           input        : in coefficient_t; 
           output       : out coefficient_t);
end component;

signal poly_0_buffer                : coefficient_t := (others => '0');
signal poly_0_buffer_read_index     : index_t := (others => '0');

signal poly_1_buffer                : coefficient_t := (others => '0');
signal poly_1_buffer_read_index     : index_t := (others => '0');

signal phi_rom_index                : index_t := (others => '0');
signal phi                          : coefficient_t;

signal ntt_0_input                  : coefficient_t;
signal ntt_0_valid                  : std_logic;
signal ntt_0_start                  : std_logic;
signal ntt_0_rst                    : std_logic;
signal ntt_0_write                  : std_logic;
signal ntt_0_index                  : index_t;

signal ntt_1_rst                    : std_logic;
signal ntt_1_start                  : std_logic;
signal ntt_1_valid                  : std_logic;
signal ntt_1_input                  : coefficient_t;
signal ntt_1_write                  : std_logic;
signal ntt_1_index                  : index_t;

signal pointwise_0_multiply_in_0    : coefficient_t;
signal pointwise_0_multiply_in_1    : coefficient_t;

signal iphi_rom_index               : index_t := (others => '0');
signal iphi                         : coefficient_t;

signal intt_start                   : std_logic;
signal intt_valid                   : std_logic;
signal intt_rst                     : std_logic;
signal intt_input                   : coefficient_t;
signal intt_output                  : coefficient_t;
signal intt_write                   : std_logic;
signal intt_index                   : index_t;

signal pointwise_multiply_output    : coefficient_t := (others => '0');

signal output_buffer_write          : std_logic;
signal output_buffer_write_index    : index_t;

begin
    controller: poly_mult_control_unit
    port map (
        clk                         => clk                      ,
        poly_0_buffer_read_index    => poly_0_buffer_read_index ,
        poly_1_buffer_read_index    => poly_1_buffer_read_index ,
        phi_rom_index               => phi_rom_index            ,
        ntt_0_rst                   => ntt_0_rst                ,
        ntt_0_write                 => ntt_0_write              ,
        ntt_0_valid                 => ntt_0_valid              ,
        ntt_0_index                 => ntt_0_index              ,
        ntt_0_start                 => ntt_0_start              ,
        ntt_1_rst                   => ntt_1_rst                ,
        ntt_1_write                 => ntt_1_write              ,
        ntt_1_start                 => ntt_1_start              ,
        ntt_1_valid                 => ntt_1_valid              ,
        ntt_1_index                 => ntt_1_index              ,
        intt_rst                    => intt_rst                 ,
        intt_start                  => intt_start               ,
        intt_write                  => intt_write               ,
        intt_valid                  => intt_valid               ,
        intt_index                  => intt_index               ,
        iphi_rom_index              => iphi_rom_index           ,
        output_buffer_write         => output_buffer_write      ,
        output_buffer_write_index   => output_buffer_write_index,
        valid                       => valid,
        start                       => start,
        reset                       => reset
    );
    
    poly_0_buffer_component : buff
    port map
    (
        clk         => clk,
        write       => write,
        write_index => write_index,
        read_index  => poly_0_buffer_read_index,
        input       => poly_0,
        output      => poly_0_buffer
    );
    
    poly_1_buffer_component : buff
    port map
    (
        clk         => clk,
        write       => write,
        write_index => write_index,
        read_index  => poly_1_buffer_read_index,
        input       => poly_1,
        output      => poly_1_buffer
    );

    output_phi: ROM_phi
    port map (
        clk     => clk,
        index   => phi_rom_index,
        output  => phi
    );    
    
    input_0_multiply: pointwise_multiplier
    port map (
        in1     => poly_0_buffer,
        in2     => phi,
        clk     => clk,
        output  => ntt_0_input
    );    
    
    input_1_multiply: pointwise_multiplier
    port map (
        in1     => poly_1_buffer,
        in2     => phi,
        clk     => clk,
        output  => ntt_1_input
    );

    transform_input_0: ntt
    port map (
      clk       => clk,
      reset     => reset,
      input     => ntt_0_input,
      start     => ntt_0_start,
      write     => ntt_0_write,
      index     => ntt_0_index,
      output    => pointwise_0_multiply_in_0,
      valid     => ntt_0_valid
    );
    
    transform_input_1: ntt
    port map (
      clk       => clk,
      reset     => reset,
      input     => ntt_1_input,
      start     => ntt_1_start,
      write     => ntt_1_write,
      index     => ntt_1_index,
      output    => pointwise_0_multiply_in_1,
      valid     => ntt_1_valid
    );

    transform_multiply: pointwise_multiplier
    port map (
        in1     => pointwise_0_multiply_in_0,
        in2     => pointwise_0_multiply_in_1,
        clk     => clk,
        output  => intt_input
    );

    transform_output: intt
    port map (
      clk       => clk,
      reset     => reset,
      input     => intt_input,
      start     => intt_start,
      write     => intt_write,
      index     => intt_index,
      output    => intt_output,
      valid     => intt_valid
    );
    
    output_iphi: ROM_iphi
    port map (
        clk     => clk,
        index   => iphi_rom_index,
        output  => iphi
    );
    
    output_multiply: pointwise_multiplier
    port map (
        in1     => intt_output,
        in2     => iphi,
        clk     => clk,
        output  => pointwise_multiply_output
    );
    
    output_buffer_component : buff
    port map
    (
        clk         => clk,
        write       => output_buffer_write,
        write_index => output_buffer_write_index,
        read_index  => read_index,
        input       => pointwise_multiply_output,
        output      => output
    );

end Behavioral;
