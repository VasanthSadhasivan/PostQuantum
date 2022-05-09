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
          mode_buffer_write         : out std_logic;
          valid                     : out std_logic;
          ntt_reset                 : out std_logic;
          ntt_write                 : out std_logic;
          ntt_start                 : out std_logic;
          ntt_index                 : out index_t := (others => '0');
          ntt_valid                 : in std_logic;
          intt_reset                : out std_logic;
          intt_write                : out std_logic;
          intt_start                : out std_logic;
          intt_index                : out index_t := (others => '0');
          intt_valid                : in std_logic;
          polyreduce_start          : out std_logic;
          polyreduce_write          : out std_logic;
          polyreduce_reset          : out std_logic;         
          polyreduce_index          : out index_t := (others => '0');       
          polyreduce_done           : in std_logic;
          rom_output_mux_sel        : out std_logic_vector(1 downto 0) := (others => '0');
          phi_rom_index             : out index_t := (others => '0');
          iphi_rom_index            : out index_t := (others => '0');
          poly_0_buffer_read_index  : out index_t := (others => '0');
          poly_1_buffer_read_index  : out index_t := (others => '0');
          output_buffer_write_index : out index_t := (others => '0');
          output_buffer_write       : out std_logic
          );
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

component pointwise_mult is
    Port ( clk : in STD_LOGIC;
           poly_0 : in coefficient_t;
           poly_1 : in coefficient_t;
           output : out coefficient_t);
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

component ROM_iphi is
  Port (
        clk     : in std_logic;
        index   : in index_t;
        output  : out coefficient_t
        );
end component;

component ROM_phi is
  Port (
        clk     : in std_logic;
        index   : in index_t;
        output  : out coefficient_t
        );
end component;


component polyreduce is
    Port ( clk : in STD_LOGIC;
           poly_1 : in coefficient_t;
           poly_2 : in coefficient_t;
           write_index : in index_t;
           write : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           read_index : in index_t;
           output : out coefficient_t;
           done : out STD_LOGIC);
end component;

signal poly_add_output              : coefficient_t                 := (others => '0');
signal poly_negate_output           : coefficient_t                 := (others => '0');
signal poly_pointwise_mult_output   : coefficient_t                 := (others => '0');
signal poly_ntt_output              : coefficient_t                 := (others => '0');
signal poly_intt_output             : coefficient_t                 := (others => '0');

signal poly_0_buffer                : coefficient_t                 := (others => '0');
signal poly_1_buffer                : coefficient_t                 := (others => '0');
signal mode_buffer                  : std_logic_vector(2 downto 0)  := (others => '0');
signal output_buffer_input          : coefficient_t                 := (others => '0');

signal poly_0_buffer_read_index     : index_t                       := (others => '0');
signal poly_1_buffer_read_index     : index_t                       := (others => '0');

signal phi_rom_index                : index_t                       := (others => '0');
signal phi_rom_output               : coefficient_t                 := (others => '0');

signal iphi_rom_index               : index_t                       := (others => '0');
signal iphi_rom_output              : coefficient_t                 := (others => '0');

signal rom_output_mux_sel           : std_logic_vector(1 downto 0)  := (others => '0');
signal rom_output                   : coefficient_t                 := (others => '0');

signal poly_ntt_reset               : std_logic                     := '0';
signal poly_ntt_write               : std_logic                     := '0';
signal poly_ntt_index               : index_t                       := (others => '0');
signal poly_ntt_start               : std_logic                     := '0';
signal poly_ntt_valid               : std_logic                     := '0';

signal poly_intt_reset              : std_logic                     := '0';
signal poly_intt_write              : std_logic                     := '0';
signal poly_intt_index              : index_t                       := (others => '0');
signal poly_intt_start              : std_logic                     := '0';
signal poly_intt_valid              : std_logic                     := '0';

signal output_mux_sel               : std_logic_vector(2 downto 0)  := "000";

signal output_buffer_write          : std_logic                     := '0';
signal output_buffer_write_index    : index_t                       := (others => '0');

signal mode_buffer_write            : std_logic                     := '0';


signal polyreduce_index     : index_t := (others => '0');
signal polyreduce_write     : std_logic := '0';
signal polyreduce_start     : std_logic := '0';
signal polyreduce_reset     : std_logic := '0';
signal polyreduce_output    : coefficient_t := (others => '0');
signal polyreduce_done      : std_logic := '0';


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
    
    control_unit: rlwe_core_control_unit 
        port map (
        clk                       => clk,
        mode_buffer               => mode_buffer, 
        start                     => start, 
        reset                     => reset,
        mode_buffer_write         => mode_buffer_write, 
        valid                     => valid, 
        ntt_reset                 => poly_ntt_reset,
        ntt_write                 => poly_ntt_write  ,
        ntt_start                 => poly_ntt_start  ,
        ntt_index                 => poly_ntt_index  ,
        ntt_valid                 => poly_ntt_valid  ,
        intt_reset                => poly_intt_reset ,
        intt_write                => poly_intt_write ,
        intt_start                => poly_intt_start ,
        intt_index                => poly_intt_index ,
        intt_valid                => poly_intt_valid ,
        polyreduce_start          => polyreduce_start ,
        polyreduce_write          => polyreduce_write ,
        polyreduce_reset          => polyreduce_reset ,
        polyreduce_index          => polyreduce_index ,
        polyreduce_done           => polyreduce_done ,
        rom_output_mux_sel        => rom_output_mux_sel       ,
        phi_rom_index             => phi_rom_index            ,
        iphi_rom_index            => iphi_rom_index           ,
        poly_0_buffer_read_index  => poly_0_buffer_read_index ,
        poly_1_buffer_read_index  => poly_1_buffer_read_index ,
        output_buffer_write_index => output_buffer_write_index,
        output_buffer_write       => output_buffer_write
    );
    
    PHI: ROM_phi
    port map (
        clk     => clk,
        index   => phi_rom_index,
        output  => phi_rom_output
    );

    
    iPHI: ROM_iphi
    port map (
        clk     => clk,
        index   => iphi_rom_index,
        output  => iphi_rom_output
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
    
    pointwise: pointwise_mult
    port map (
        clk     => clk,
        poly_0  => rom_output,
        poly_1  => poly_1_buffer,
        output  => poly_pointwise_mult_output
    );
    
    ntt_1: ntt
    port map (
        clk     => clk,
        reset   => poly_ntt_reset,
        input   => poly_1_buffer,
        write   => poly_ntt_write,
        index   => poly_ntt_index,
        start   => poly_ntt_start,
        output  => poly_ntt_output,
        valid   => poly_ntt_valid
    );
    
    intt_1: intt
    port map (
        clk     => clk,
        reset   => poly_intt_reset,
        input   => poly_1_buffer,
        write   => poly_intt_write,
        index   => poly_intt_index,
        start   => poly_intt_start,
        output  => poly_intt_output,
        valid   => poly_intt_valid
    );
    
    reduction: polyreduce
    port map (
        clk         => clk,
        poly_1      => poly_0_buffer,
        poly_2      => poly_1_buffer,
        write_index => polyreduce_index,
        write       => polyreduce_write,
        start       => polyreduce_start,
        reset       => polyreduce_reset,
        read_index  => polyreduce_index,
        output      => polyreduce_output,
        done        => polyreduce_done
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
    
    rom_output_mux : process(rom_output_mux_sel, phi_rom_output, iphi_rom_output, poly_0_buffer)
    begin
        if rom_output_mux_sel = "00" then
            rom_output <= poly_0_buffer;
        elsif rom_output_mux_sel = "01" then
            rom_output <= phi_rom_output;
        elsif rom_output_mux_sel = "10" then
            rom_output <= iphi_rom_output;
        else 
            rom_output <= poly_0_buffer;
        end if;
    end process;
        
    output_mux : process(output_mux_sel, poly_add_output, poly_negate_output, poly_pointwise_mult_output, poly_ntt_output, poly_intt_output)
    begin
        if output_mux_sel = "000" then
            output_buffer_input <= poly_add_output;
        elsif output_mux_sel = "001" then
            output_buffer_input <= poly_negate_output;
        elsif output_mux_sel = "010" then
            output_buffer_input <= poly_pointwise_mult_output;
        elsif output_mux_sel = "011" then
            output_buffer_input <= poly_ntt_output;
        elsif output_mux_sel = "100" then
            output_buffer_input <= poly_intt_output;
        elsif output_mux_sel = "101" then
            output_buffer_input <= polyreduce_output;
        else 
            output_buffer_input <= poly_add_output;
        end if;
    end process;
    
    output_sel_decoder : process(mode_buffer)
    begin
        case (mode_buffer) is
            when "000" => output_mux_sel <= "000";
            when "001" => output_mux_sel <= "001";
            when "010" => output_mux_sel <= "010";
            when "011" => output_mux_sel <= "010";
            when "100" => output_mux_sel <= "010";
            when "101" => output_mux_sel <= "011";
            when "110" => output_mux_sel <= "100";
            when "111" => output_mux_sel <= "101";
            when others=> output_mux_sel <= "000";
        end case;
    end process;

end Behavioral;
