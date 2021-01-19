----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 11:27:29 PM
-- Design Name: 
-- Module Name: uniform_core - Behavioral
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

entity gaussian_core is
    Port (clk           : in std_logic;
          gen           : in std_logic;
          read_index    : in index_t;
          reset         : in std_logic;
          valid         : out std_logic;
          output        : out coefficient_t );
end gaussian_core;

architecture Behavioral of gaussian_core is

component buff is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC;
           write_index  : in index_t;
           read_index   : in index_t;
           input        : in coefficient_t; 
           output       : out coefficient_t);
end component;

component gaussian_control_unit is
    Port (
        clk                     : in std_logic;
        reset                   : in std_logic;
        start                   : in std_logic;
        data_reg                : out unsigned(19 downto 0);
        data_buffer_write_index : out index_t;
        data_buffer_write       : out std_logic;
        valid                   : out std_logic
    );
end component;

component icdf is
    Port (
        uniform_number  : in coefficient_t;
        gaussian_number : out coefficient_t
    );
end component;

signal data_reg                 : unsigned(19 downto 0) := to_unsigned(1, 20);
signal data_buffer_write        : std_logic := '0';
signal data_buffer_write_index  : index_t := (others => '0');
signal gaussian_number          : coefficient_t := (others => '0');

begin
    icdf_component : icdf
    port map
    (
        uniform_number  => to_unsigned(0, BIT_WIDTH - 20) & data_reg,
        gaussian_number => gaussian_number
    );

    data_buffer_component : buff
    port map
    (
        clk         => clk,
        write       => data_buffer_write,
        write_index => data_buffer_write_index,
        read_index  => read_index,
        input       => gaussian_number,
        output      => output
    );

    gaussian_control_unit_component : gaussian_control_unit
    port map
    (
        clk                     => clk                    ,
        reset                   => reset                  ,
        start                   => gen                    ,
        data_reg                => data_reg               ,
        data_buffer_write_index => data_buffer_write_index,
        data_buffer_write       => data_buffer_write      ,
        valid                   => valid                  
    );
end Behavioral;
