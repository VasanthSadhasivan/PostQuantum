----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 11:48:58 PM
-- Design Name: 
-- Module Name: rlwe_main - Behavioral
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

/*
    instruction format: _ _ _ | _ _ _ _ | _ _ _ _ | _ _ | _ _ _ _
                         op_1    rx_1       ry     op_2    rx_2

*/

entity rlwe_main is
    Port (clk           : in std_logic;
          start         : in std_logic;
          reset         : in std_logic;
          instruction   : in instruction_op_t;
          input         : in port_t;
          output        : out port_t;
          valid         : out std_logic;
          output_test   : out std_logic);
end rlwe_main;

architecture Behavioral of rlwe_main is

component main_control_unit is
    Port (clk                       : in std_logic;
          start                     : in std_logic;
          reset                     : in std_logic;
          valid                     : out std_logic; 
          instruction               : in instruction_op_t; 
          reg_file_sel_0            : out std_logic_vector(3 downto 0);
          reg_file_sel_1            : out std_logic_vector(3 downto 0);
          reg_file_rw_0             : out std_logic;
          reg_file_rw_1             : out std_logic;
          reg_file_in_0_sel         : out std_logic;
          reg_file_in_1_sel         : out std_logic;
          uniform_gen               : out std_logic;
          uniform_reset             : out std_logic;
          uniform_valid             : in std_logic;
          gaussian_gen              : out std_logic;
          gaussian_reset            : out std_logic;
          gaussian_valid            : in std_logic;
          rlwe_core_poly_1_sel      : out std_logic;
          rlwe_core_mode            : out std_logic_vector(2 downto 0);
          rlwe_core_start           : out std_logic;
          rlwe_core_reset           : out std_logic;
          rlwe_core_valid           : in std_logic;
          output_test               : out std_logic
          );
end component;

component uniform_core is
    Port (clk       : in std_logic;
          gen       : in std_logic;
          reset     : in std_logic;
          valid     : out std_logic;
          output    : out port_t );
end component;

component gaussian_core is
    Port (clk           : in std_logic;
          gen           : in std_logic;
          reset         : in std_logic;
          valid         : out std_logic;
          output        : out port_t );
end component;

component rlwe_core is
    Port (clk       : in std_logic;
          start     : in std_logic;
          reset     : in std_logic;
          mode      : in std_logic_vector(2 downto 0);
          poly_0     : in port_t;
          poly_1     : in port_t;
          output    : out port_t;
          valid     : out std_logic
           );
end component;

component reg_file is
    Port ( clk          : in STD_LOGIC;
           in_value_0   : in port_t;
           in_value_1   : in port_t;
           reg_file_sel_0    : in STD_LOGIC_VECTOR(3 downto 0);
           reg_file_sel_1    : in STD_LOGIC_VECTOR(3 downto 0);
           rw_0         : in STD_LOGIC;
           rw_1         : in STD_LOGIC;
           out_0        : out port_t;
           out_1        : out port_t);
end component;

component mux2to1 is
    Port (input_0    : in port_t;
          input_1    : in port_t;
          sel       : in std_logic;
          output    : out port_t );
end component;

signal reg_file_in_0 : port_t;
signal reg_file_in_1 : port_t;
signal reg_file_out_0 : port_t;
signal reg_file_out_1 : port_t;
signal reg_file_sel_0 : std_logic_vector(3 downto 0);
signal reg_file_sel_1 : std_logic_vector(3 downto 0);
signal reg_file_rw_0 : std_logic;
signal reg_file_rw_1 : std_logic;
signal reg_file_in_0_sel : std_logic;
signal reg_file_in_1_sel : std_logic;

signal uniform_gen : std_logic;
signal uniform_reset : std_logic;
signal uniform_valid : std_logic;
signal uniform_out : port_t;

signal gaussian_gen : std_logic;
signal gaussian_reset : std_logic;
signal gaussian_valid : std_logic;
signal gaussian_out : port_t;

signal rlwe_core_poly_0 : port_t;
signal rlwe_core_poly_1 : port_t;
signal rlwe_core_valid : std_logic;
signal rlwe_core_out : port_t;
signal rlwe_core_mode : std_logic_vector(2 downto 0);
signal rlwe_core_start : std_logic;
signal rlwe_core_reset : std_logic;
signal rlwe_core_poly_1_sel : std_logic;

begin

    output <= rlwe_core_out;

    control_unit: main_control_unit
    port map (
        clk                     => clk,
        start                   => start,
        reset                   => reset,
        valid                   => valid,
        instruction             => instruction,
        reg_file_sel_0          => reg_file_sel_0,
        reg_file_sel_1          => reg_file_sel_1,
        reg_file_rw_0           => reg_file_rw_0,
        reg_file_rw_1           => reg_file_rw_1,
        reg_file_in_0_sel       => reg_file_in_0_sel,
        reg_file_in_1_sel       => reg_file_in_1_sel,
        uniform_gen             => uniform_gen,
        uniform_reset           => uniform_reset,
        uniform_valid           => uniform_valid,
        gaussian_gen            => gaussian_gen,
        gaussian_reset          => gaussian_reset,
        gaussian_valid          => gaussian_valid,
        rlwe_core_poly_1_sel    => rlwe_core_poly_1_sel,
        rlwe_core_mode          => rlwe_core_mode,
        rlwe_core_start         => rlwe_core_start,
        rlwe_core_reset         => rlwe_core_reset,
        rlwe_core_valid         => rlwe_core_valid,
        output_test             => output_test
    );

    uniform_rng: uniform_core
    port map (
        clk     => clk,
        gen     => uniform_gen,
        reset   => uniform_reset,
        valid   => uniform_valid,
        output  => uniform_out
    );

    gaussian_rng: gaussian_core
    port map (
        clk         => clk,
        gen         => gaussian_gen,
        reset       => gaussian_reset,
        valid       => gaussian_valid,
        output      => gaussian_out
    );
    
    rlwe_logical_unit: rlwe_core
    port map (
        clk     => clk,
        start   => rlwe_core_start,
        reset   => rlwe_core_reset,
        mode    => rlwe_core_mode,
        poly_0   => rlwe_core_poly_0,
        poly_1   => rlwe_core_poly_1,
        output  => rlwe_core_out,
        valid   => rlwe_core_valid
    );
    
    registers: reg_file
    port map (
        clk         => clk,
        in_value_0  => reg_file_in_0,
        in_value_1  => reg_file_in_1,
        reg_file_sel_0   => reg_file_sel_0,
        reg_file_sel_1   => reg_file_sel_1,
        rw_0        => reg_file_rw_0,
        rw_1        => reg_file_rw_1,
        out_0       => reg_file_out_0,
        out_1       => reg_file_out_1
    );
    
    reg_file_in_0_mux: mux2to1
    port map (
        input_0  => input,
        input_1  => rlwe_core_out,
        sel     => reg_file_in_0_sel,
        output  => reg_file_in_0
    );
    
    reg_file_in_1_mux: mux2to1
    port map (
        input_0  => uniform_out,
        input_1  => gaussian_out,
        sel     => reg_file_in_1_sel,
        output  => reg_file_in_1
    );
    

    rlwe_core_poly_1_mux: mux2to1
    port map (
        input_0  => input,
        input_1  => reg_file_out_0,
        sel     => rlwe_core_poly_1_sel,
        output  => rlwe_core_poly_1
    );
    
    rlwe_core_poly_0 <= reg_file_out_1;
    
end Behavioral;