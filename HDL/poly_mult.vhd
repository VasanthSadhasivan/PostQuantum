library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity poly_mult is
    Port (clk     : in std_logic;
          reset   : in std_logic; 
          in1   : in port_t;
          in2   : in port_t;
          start   : in std_logic;
          output  : out port_t;
          valid   : out std_logic);
end poly_mult;

architecture Behavioral of poly_mult is

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
signal output_inv  :   port_t;
signal in1_ntt  :   port_t;
signal in2_ntt  :   port_t;
signal valid1   :   std_logic;
signal valid2   :   std_logic;
signal output_ntt  :   port_t;

begin
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
        output => in1_phi
    );    
    
    input_multiply_2: pointwise_multiplier
    port map (
        in1 => in2,
        in2 => phi,
        output => in2_phi
    );
    
    output_multiply: pointwise_multiplier
    port map (
        in1 => output_inv,
        in2 => phi_inv,
        output => output
    );

    transform_input_1: ntt
    port map (
      clk => clk,
      reset => reset,
      input => in1_phi,
      start => start,
      output => in1_ntt,
      valid => valid1
    );
    
    transform_input_2: ntt
    port map (
      clk => clk,
      reset => reset,
      input => in2_phi,
      start => start,
      output => in2_ntt,
      valid => valid2
    );

    transform_multiply: pointwise_multiplier
    port map (
        in1 => in1_ntt,
        in2 => in2_ntt,
        output => output_ntt
    );

    transform_output: intt
    port map (
      clk => clk,
      reset => reset,
      input => output_ntt,
      start => valid1 and valid2,
      output => output_inv,
      valid => valid
    );

end Behavioral;
