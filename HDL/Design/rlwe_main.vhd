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

/*
    instruction format: _ _ _ _ | _ _ _ _ | _ _ _ _ | _ _ | _ _ _ _
                         op_1       rx_1       ry    op_2    rx_2
*/

entity rlwe_main is
    Port (clk                       : in std_logic;
          start                     : in std_logic;
          reset                     : in std_logic;
          instruction               : in instruction_op_t;
          input_buffer_write        : in std_logic;
          input_buffer_write_index  : in index_t;
          input                     : in coefficient_t;
          output                    : out coefficient_t;
          output_buffer_read_index  : in index_t;
          valid                     : out std_logic);
end rlwe_main;

architecture Behavioral of rlwe_main is

component main_control_unit is
    Port (
        clk                         : in std_logic;
        start                       : in std_logic;
        reset                       : in std_logic;
        instruction_buffer          : in instruction_t;
        instruction_buffer_rw       : out std_logic;
        input_buffer_read_index     : out index_t   := (others => '0');
        valid                       : out std_logic;
        reg_file_sel_0              : out std_logic_vector(3 downto 0);
        reg_file_sel_1_in_0         : out std_logic_vector(3 downto 0);
        reg_file_sel_1_in_1         : out std_logic_vector(3 downto 0);
        reg_file_sel_1_sel          : out std_logic;
        reg_file_write_0            : out std_logic;
        reg_file_write_1            : out std_logic;
        reg_file_arith_index        : out index_t   := (others => '0');
        reg_file_random_index       : out index_t   := (others => '0');
        in_arith_reg                : out std_logic;
        in_random_reg                : out std_logic;
        reg_file_in_0_sel           : out std_logic;
        reg_file_in_1_sel           : out std_logic;
        uniform_gen                 : out std_logic;
        uniform_reset               : out std_logic;
        uniform_read_index          : out index_t   := (others => '0');
        uniform_valid               : in std_logic;
        gaussian_gen                : out std_logic;
        gaussian_reset              : out std_logic;
        gaussian_read_index         : out index_t   := (others => '0');
        gaussian_valid              : in std_logic;
        rlwe_core_poly_1_sel        : out std_logic;
        rlwe_core_mode              : out std_logic_vector(2 downto 0);
        rlwe_core_start             : out std_logic;
        rlwe_core_write             : out std_logic;
        rlwe_core_write_index       : out index_t   := (others => '0');
        rlwe_core_read_index        : out index_t   := (others => '0');
        rlwe_core_reset             : out std_logic;
        rlwe_core_valid             : in std_logic;
        output_buffer_write         : out std_logic;
        output_buffer_write_index   : out index_t   := (others => '0')
    );
end component;

component uniform_core is
    Port (clk           : in std_logic;
          gen           : in std_logic;
          read_index    : in index_t;
          reset         : in std_logic;
          valid         : out std_logic;
          output        : out coefficient_t );
end component;

component gaussian_core is
    Port (clk           : in std_logic;
          gen           : in std_logic;
          reset         : in std_logic;
          read_index    : in index_t;
          valid         : out std_logic;
          output        : out coefficient_t );
end component;

component rlwe_core is
    Port (clk           : in std_logic;
          start         : in std_logic;
          reset         : in std_logic;
          mode          : in std_logic_vector(2 downto 0);
          write_index   : in index_t;
          write         : in std_logic;
          read_index    : in index_t;
          poly_0        : in coefficient_t;
          poly_1        : in coefficient_t;
          output        : out coefficient_t;
          valid         : out std_logic
           );
end component;

component reg_file is
    Port ( clk              : in STD_LOGIC;
           in_value_0       : in coefficient_t;
           in_value_1       : in coefficient_t;
           reg_file_sel_0   : in STD_LOGIC_VECTOR(3 downto 0);
           reg_file_sel_1   : in STD_LOGIC_VECTOR(3 downto 0);
           write_0          : in STD_LOGIC;
           write_1          : in STD_LOGIC;
           index            : in index_t;
           out_0            : out coefficient_t;
           out_1            : out coefficient_t);
end component;

component mux2to1 is
    Port (input_0    : in coefficient_t;
          input_1    : in coefficient_t;
          sel       : in std_logic;
          output    : out coefficient_t );
end component;

component buff is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC;
           write_index  : in index_t;
           read_index   : in index_t;
           input        : in coefficient_t; 
           output       : out coefficient_t);
end component;

component reg_file_index_decoder is
    Port ( reg_file_arith_index     : in index_t;
           reg_file_random_index    : in index_t;
           in_arith_reg             : in STD_LOGIC;
           in_random_reg            : in STD_LOGIC;
           index                    : out index_t);
end component;

signal reg_file_in_0 : coefficient_t                        := (others => '0');
signal reg_file_in_1 : coefficient_t                        := (others => '0');
signal reg_file_out_0 : coefficient_t                       := (others => '0');
signal reg_file_out_1 : coefficient_t                       := (others => '0');
signal reg_file_sel_0 : std_logic_vector(3 downto 0)        := (others => '0');
signal reg_file_sel_1 : std_logic_vector(3 downto 0)        := (others => '0');
signal reg_file_sel_1_sel : std_logic                       := '0';
signal reg_file_sel_1_in_0 : std_logic_vector(3 downto 0)   := (others => '0');
signal reg_file_sel_1_in_1 : std_logic_vector(3 downto 0)   := (others => '0');
signal reg_file_write_0 : std_logic                         := '0';
signal reg_file_write_1 : std_logic                         := '0';
signal reg_file_index : index_t                             := (others => '0');
signal reg_file_arith_index : index_t                       := (others => '0');
signal reg_file_random_index : index_t                      := (others => '0');
signal in_arith_reg : std_logic                             := '0';
signal in_random_reg : std_logic                            := '0';
signal reg_file_in_0_sel : std_logic                        := '0';
signal reg_file_in_1_sel : std_logic                        := '0';

signal uniform_gen : std_logic                              := '0';
signal uniform_reset : std_logic                            := '0';
signal uniform_valid : std_logic                            := '0';
signal uniform_read_index : index_t                         := (others => '0');
signal uniform_out : coefficient_t                          := (others => '0');

signal gaussian_gen : std_logic                             := '0';
signal gaussian_reset : std_logic                           := '0';
signal gaussian_valid : std_logic                           := '0';
signal gaussian_read_index : index_t                        := (others => '0');
signal gaussian_out : coefficient_t                         := (others => '0');

signal rlwe_core_poly_0 : coefficient_t                     := (others => '0');
signal rlwe_core_poly_1 : coefficient_t                     := (others => '0');
signal rlwe_core_valid : std_logic                          := '0';
signal rlwe_core_out : coefficient_t                        := (others => '0');
signal rlwe_core_mode : std_logic_vector(2 downto 0)        := (others => '0');
signal rlwe_core_start : std_logic                          := '0';
signal rlwe_core_reset : std_logic                          := '0';
signal rlwe_core_write_index : index_t                      := (others => '0');
signal rlwe_core_read_index  : index_t                      := (others => '0');
signal rlwe_core_write : std_logic                          := '0';
signal rlwe_core_poly_1_sel : std_logic                     := '0';

signal input_buffer_read_index : index_t                    := (others => '0');
signal input_buffer_output : coefficient_t                  := (others => '0');

signal output_buffer_write_index : index_t                  := (others => '0');
signal output_buffer_write :  std_logic                     := '0';

signal instruction_buffer       : instruction_t             := (others => '0');
signal instruction_buffer_rw    : std_logic                 := '0';

begin

    control_unit: main_control_unit
    port map (
        clk                         => clk,
        start                       => start,
        reset                       => reset,
        valid                       => valid,
        instruction_buffer          => instruction_buffer,
        instruction_buffer_rw       => instruction_buffer_rw,
        input_buffer_read_index     => input_buffer_read_index,
        reg_file_sel_0              => reg_file_sel_0,
        reg_file_sel_1_sel          => reg_file_sel_1_sel,
        reg_file_sel_1_in_0         => reg_file_sel_1_in_0,
        reg_file_sel_1_in_1         => reg_file_sel_1_in_1,
        reg_file_write_0            => reg_file_write_0,
        reg_file_write_1            => reg_file_write_1,
        reg_file_arith_index        => reg_file_arith_index,
        reg_file_random_index       => reg_file_random_index,
        in_arith_reg                => in_arith_reg,
        in_random_reg               => in_random_reg,
        reg_file_in_0_sel           => reg_file_in_0_sel,
        reg_file_in_1_sel           => reg_file_in_1_sel,
        uniform_gen                 => uniform_gen,
        uniform_reset               => uniform_reset,
        uniform_valid               => uniform_valid,
        uniform_read_index          => uniform_read_index,
        gaussian_gen                => gaussian_gen,
        gaussian_reset              => gaussian_reset,
        gaussian_valid              => gaussian_valid,
        gaussian_read_index         => gaussian_read_index,
        rlwe_core_poly_1_sel        => rlwe_core_poly_1_sel,
        rlwe_core_mode              => rlwe_core_mode,
        rlwe_core_start             => rlwe_core_start,
        rlwe_core_reset             => rlwe_core_reset,
        rlwe_core_valid             => rlwe_core_valid,
        rlwe_core_write             => rlwe_core_write,
        rlwe_core_write_index       => rlwe_core_write_index,
        rlwe_core_read_index        => rlwe_core_read_index,
        output_buffer_write         => output_buffer_write,
        output_buffer_write_index   => output_buffer_write_index
    );

    uniform_rng: uniform_core
    port map (
        clk         => clk,
        gen         => uniform_gen,
        reset       => uniform_reset,
        read_index  => uniform_read_index,
        valid       => uniform_valid,
        output      => uniform_out
    );
    
    input_buffer: buff
    port map (
        clk         => clk,
        write       => input_buffer_write,
        write_index => input_buffer_write_index,
        read_index  => input_buffer_read_index,
        input       => input,
        output      => input_buffer_output
    );

    output_buffer: buff
    port map (
        clk         => clk,
        write       => output_buffer_write,
        write_index => output_buffer_write_index,
        read_index  => output_buffer_read_index,
        input       => rlwe_core_out,
        output      => output
    );

    gaussian_rng: gaussian_core
    port map (
        clk         => clk,
        gen         => gaussian_gen,
        reset       => gaussian_reset,
        read_index  => gaussian_read_index,
        valid       => gaussian_valid,
        output      => gaussian_out
    );
    
    rlwe_logical_unit: rlwe_core
    port map (
        clk         => clk,
        start       => rlwe_core_start,
        reset       => rlwe_core_reset,
        mode        => rlwe_core_mode,
        write_index => rlwe_core_write_index,
        write       => rlwe_core_write,
        read_index  => rlwe_core_read_index,
        poly_0      => rlwe_core_poly_0,
        poly_1      => rlwe_core_poly_1,
        output      => rlwe_core_out,
        valid       => rlwe_core_valid
    );
    
    registers: reg_file
    port map (
        clk             => clk,
        in_value_0      => reg_file_in_0,
        in_value_1      => reg_file_in_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        write_0         => reg_file_write_0,
        write_1         => reg_file_write_1,
        index           => reg_file_index,
        out_0           => reg_file_out_0,
        out_1           => reg_file_out_1
    );
    
    reg_file_in_0_mux: mux2to1
    port map (
        input_0 => input_buffer_output,
        input_1 => rlwe_core_out,
        sel     => reg_file_in_0_sel,
        output  => reg_file_in_0
    );
    
    reg_file_in_1_mux: mux2to1
    port map (
        input_0 => uniform_out,
        input_1 => gaussian_out,
        sel     => reg_file_in_1_sel,
        output  => reg_file_in_1
    );
    
    reg_file_sel_1_mux: process(reg_file_sel_1_sel, reg_file_sel_1_in_0, reg_file_sel_1_in_1)
    begin
        if reg_file_sel_1_sel = '1' then
            reg_file_sel_1 <= reg_file_sel_1_in_1;
        else
            reg_file_sel_1 <= reg_file_sel_1_in_0;
        end if;
    end process;

    rlwe_core_poly_1_mux: mux2to1
    port map (
        input_0 => input_buffer_output,
        input_1 => reg_file_out_0,
        sel     => rlwe_core_poly_1_sel,
        output  => rlwe_core_poly_1
    );

    reg_file_index_decode: reg_file_index_decoder
    port map (
        reg_file_arith_index    => reg_file_arith_index,
        reg_file_random_index   => reg_file_random_index,
        in_arith_reg            => in_arith_reg,
        in_random_reg           => in_random_reg,
        index                   => reg_file_index
    );
        
    instruction_buffer_process : process(clk) begin
        if rising_edge(clk) then
            if instruction_buffer_rw = '1' then
                instruction_buffer <= instruction;
            end if;
        else
        
        end if;
    end process;
    
    rlwe_core_poly_0    <= reg_file_out_1;
    
end Behavioral;