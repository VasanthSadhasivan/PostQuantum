----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/23/2022 09:33:06 AM
-- Design Name: 
-- Module Name: fast_mod - Behavioral
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

entity fast_mod is
    Port ( clk : in STD_LOGIC;
           m : in coefficient_t;
           a : in coefficient_t;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           done : out STD_LOGIC;
           output : out coefficient_t);
end fast_mod;

architecture Behavioral of fast_mod is

component coeff_buffer is
    Port ( clk : in STD_LOGIC;
           write : in STD_LOGIC;
           input : in coefficient_t;
           output : out coefficient_t);
end component;

component fast_mod_control_unit is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           a : in coefficient_t;
           m : in coefficient_t;
           m_mult_multiplier : in coefficient_t;
           multiplier_write : out STD_LOGIC;
           m_write : out STD_LOGIC;
           a_write : out STD_LOGIC;
           multiplier_sel : out STD_LOGIC;
           a_sel : out STD_LOGIC;
           multiplier_output_sel : out STD_LOGIC;
           done : out STD_LOGIC);
end component;

signal multiplier_input : coefficient_t := (others => '0');
signal multiplier_output : coefficient_t := (others => '0');
signal multiplier_write : std_logic := '0';
signal multiplier_sel : std_logic := '0';
signal multiplier_output_sel : std_logic := '0';

signal m_write : std_logic := '0';
signal m_output : coefficient_t := (others => '0');

signal a_write : std_logic := '0';
signal a_sel : std_logic := '0';
signal a_input : coefficient_t := (others => '0');
signal a_output : coefficient_t := (others => '0');

signal m_mult_multiplier : coefficient_t := (others => '0');

signal almost_multiplier_input : coefficient_t := (others => '0');

signal almost_a_input : coefficient_t := (others => '0');

begin
    almost_a_input <= a_output - m_mult_multiplier;
    output <= almost_a_input;

    multiplier: coeff_buffer
    port map (
        clk     => clk,
        write   => multiplier_write,
        input   => multiplier_input,
        output  => multiplier_output
    );
    
    m_buff: coeff_buffer
    port map (
        clk     => clk,
        write   => m_write,
        input   => m,
        output  => m_output
    );
    
    a_buff: coeff_buffer
    port map (
        clk     => clk,
        write   => a_write,
        input   => a_input,
        output  => a_output
    );
    
    cu: fast_mod_control_unit
    port map (
        clk     => clk,
        start   => start,
        reset   => reset,
        done  => done,
        multiplier_write => multiplier_write,
        m_write => m_write,
        a_write => a_write,
        a_sel => a_sel,
        multiplier_sel => multiplier_sel,
        multiplier_output_sel => multiplier_output_sel,
        a => a_output,
        m => m_output,
        m_mult_multiplier => m_mult_multiplier
    );
    
    multiplier_sel_block : process(multiplier_sel, almost_multiplier_input) begin
        if multiplier_sel = '1' then
            multiplier_input <= to_unsigned(1, BIT_WIDTH);
        else
            multiplier_input <= almost_multiplier_input;
        end if;
    end process;
    
    a_sel_block : process(a_sel, almost_a_input) begin
        if a_sel = '1' then
            a_input <= a;
        else
            a_input <= almost_a_input;
        end if;
    end process;

    multiplier_output_sel_block : process(multiplier_output, multiplier_output_sel) begin
        if multiplier_output_sel = '1' then
            almost_multiplier_input <= shift_left(multiplier_output, 1);
        else
            almost_multiplier_input <= shift_right(multiplier_output, 1);
        end if;
    end process;
    
    m_mult_multiplier_block : process(clk) begin
        if rising_edge(clk) then
            m_mult_multiplier <= m_output * multiplier_output;
        end if;
    end process;

end Behavioral;
