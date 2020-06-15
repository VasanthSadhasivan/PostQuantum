library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity poly_mult is
    Port (clk     : in std_logic;
          reset   : in std_logic; 
          poly1   : in port_t;
          poly2   : in port_t;
          start   : in std_logic;
          output  : out port_t;
          valid   : out std_logic);
end poly_mult;

architecture Behavioral of poly_mult is

component poly_mult_control_unit is
    Port ( clk : in STD_LOGIC;
           ntt1_rst : out STD_LOGIC;
           ntt2_rst : out STD_LOGIC;
           ntt1_start : out STD_LOGIC;
           ntt2_start : out STD_LOGIC;
           ntt1_valid : in STD_LOGIC;
           ntt2_valid : in STD_LOGIC;
           intt_rst : out STD_LOGIC;
           intt_start : out STD_LOGIC;
           intt_valid : in STD_LOGIC;
           valid    : out STD_LOGIC;
           start    : in STD_LOGIC;
           reset    : in STD_LOGIC);
end component;

component ntt is
  Port (clk     : in std_logic;
        reset   : in std_logic;
        input   : in port_t;
        start   : in std_logic;
        output  : out port_t;
        valid   : out std_logic);
end component;

component intt is
  Port (clk     : in std_logic;
        reset   : in std_logic;
        input   : in port_t;
        start   : in std_logic;
        output  : out port_t;
        valid   : out std_logic);
end component;

component pointwise_multiplier is
  Port (
            in1     : in port_t;
            in2     : in port_t; 
            clk     : in std_logic;
            output  : out port_t);
end component;

component ROM_phi is
  Port (
         phi : out port_t);
end component;

component ROM_phi_inv is
  Port (
         phi_inv : out port_t);
end component;

signal phi      :   port_t;
signal phi_inv  :   port_t;
signal in1_phi  :   port_t;
signal in2_phi  :   port_t;
signal output_inv   :   port_t;
signal in1_ntt  :   port_t;
signal in2_ntt  :   port_t;
signal ntt1_valid   :   std_logic;
signal ntt2_valid   :   std_logic;
signal ntt1_start   :   std_logic;
signal ntt2_start   :   std_logic;
signal intt_start   :   std_logic;
signal intt_valid   :   std_logic;
signal intt_rst     :   std_logic;
signal ntt1_rst     :   std_logic;
signal ntt2_rst     :   std_logic;
signal output_ntt   :   port_t;

begin

    controller: poly_mult_control_unit
    port map (
        clk         => clk       ,
        ntt1_rst    => ntt1_rst  ,
        ntt2_rst    => ntt2_rst  ,
        ntt1_start  => ntt1_start,
        ntt2_start  => ntt2_start,
        ntt1_valid  => ntt1_valid,
        ntt2_valid  => ntt2_valid,
        intt_rst    => intt_rst  ,
        intt_start  => intt_start,
        intt_valid  => intt_valid,
        valid       => valid     ,
        start       => start     ,
        reset       => reset     
    );    
    
    output_phi: ROM_phi
    port map (
        phi => phi
    );    
    
    output_phi_inv: ROM_phi_inv
    port map (
        phi_inv => phi_inv
    );    
    
    input_multiply_1: pointwise_multiplier
    port map (
        in1 => in1,
        in2 => phi,
        clk => clk,
        output => in1_phi
    );    
    
    input_multiply_2: pointwise_multiplier
    port map (
        in1 => in2,
        in2 => phi,
        clk => clk,
        output => in2_phi
    );
    
    output_multiply: pointwise_multiplier
    port map (
        in1 => output_inv,
        in2 => phi_inv,
        clk => clk,
        output => output
    );

    transform_input_1: ntt
    port map (
      clk => clk,
      reset => reset,
      input => in1_phi,
      start => ntt1_start,
      output => in1_ntt,
      valid => ntt1_valid
    );
    
    transform_input_2: ntt
    port map (
      clk => clk,
      reset => reset,
      input => in2_phi,
      start => ntt2_start,
      output => in2_ntt,
      valid => ntt2_valid
    );

    transform_multiply: pointwise_multiplier
    port map (
        in1 => in1_ntt,
        in2 => in2_ntt,
        clk => clk,
        output => output_ntt
    );

    transform_output: intt
    port map (
      clk => clk,
      reset => reset,
      input => output_ntt,
      start => intt_start,
      output => output_inv,
      valid => intt_valid
    );

end Behavioral;
