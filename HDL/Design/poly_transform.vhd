library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity poly_transform is
    Port (clk           : in std_logic;
          reset         : in std_logic; 
          poly_0        : in coefficient_t;
          start         : in std_logic;
          write         : in std_logic;
          write_index   : in index_t;
          read_index    : in index_t;
          output        : out coefficient_t;
          valid         : out std_logic);
end poly_transform;

architecture Behavioral of poly_transform is

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

signal input_buffer_read_index      : index_t := (others => '0');
signal input_buffer_output          : coefficient_t := (others => '0');

signal ntt_reset                    : std_logic := '0';
signal ntt_start                    : std_logic := '0';
signal ntt_valid                    : std_logic := '0';
signal ntt_write                    : std_logic := '0';
signal ntt_index                    : index_t := (others => '0');
signal ntt_output                   : coefficient_t := (others => '0');

signal intt_reset                   : std_logic := '0';
signal intt_start                   : std_logic := '0';
signal intt_valid                   : std_logic := '0';
signal intt_write                   : std_logic := '0';
signal intt_index                   : index_t := (others => '0');
signal intt_output                  : coefficient_t := (others => '0');

signal phi_rom_output               : coefficient_t := (others => '0');
signal phi_rom_index                : index_t := (others => '0');

signal iphi_rom_output              : coefficient_t := (others => '0');
signal iphi_rom_index               : index_t := (others => '0');

signal rom_mux_output               : coefficient_t := (others => '0');
signal rom_mux_sel                  : std_logic := '0';

signal rom_multiplied_output        : coefficient_t := (others => '0');

signal final_mux_output             : coefficient_t := (others => '0');
signal final_mux_sel                : std_logic_vector(1 downto 0) := (others => '0');

signal output_buffer_write_index    : index_t := (others => '0');
signal output_buffer_write          : std_logic := '0';

begin

    output_phi: ROM_phi
    port map (
        clk     => clk,
        index   => write_index,
        output  => phi_rom_output
    );    

    ntt_1: ntt
    port map (
      clk       => clk,
      reset     => reset,
      input     => input_buffer_output,
      start     => ntt_start,
      write     => ntt_write,
      index     => ntt_index,
      output    => ntt_output,
      valid     => ntt_valid
    );
    
    intt_1: intt
    port map (
      clk       => clk,
      reset     => reset,
      input     => input_buffer_output,
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
        output  => iphi_rom_output
    );
    
    tom_multiply: pointwise_multiplier
    port map (
        in1     => rom_mux_output,
        in2     => input_buffer_output,
        clk     => clk,
        output  => rom_multiplied_output
    );
    
    output_buffer_component : buff
    port map
    (
        clk         => clk,
        write       => output_buffer_write,
        write_index => output_buffer_write_index,
        read_index  => read_index,
        input       => final_mux_output,
        output      => output
    );
    
    rom_mux : process(rom_mux_sel, phi_rom_output, iphi_rom_output)
    begin
        if rom_mux_sel = '0' then
            rom_mux_output <= phi_rom_output;
        else 
            rom_mux_output <= iphi_rom_output;
        end if;
    end process;
    
    final_mux : process(final_mux_sel, ntt_output, intt_output, rom_multiplied_output)
    begin
        if final_mux_sel = "00" then
            final_mux_output <= ntt_output;
        elsif final_mux_sel = "01" then
            final_mux_output <= intt_output;
        elsif final_mux_sel = "10" then
            final_mux_output <= rom_multiplied_output;
        elsif final_mux_sel = "11" then
            final_mux_output <= ntt_output;
        else 
            final_mux_output <= ntt_output;
        end if;
    end process;

end Behavioral;
