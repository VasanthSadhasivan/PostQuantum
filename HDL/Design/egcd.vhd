----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/15/2022 10:38:59 PM
-- Design Name: 
-- Module Name: egcd - Behavioral
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

entity egcd is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           a : in coefficient_t;
           b : in coefficient_t;
           x : out coefficient_t;
           y : out coefficient_t;
           a1 : out coefficient_t;
           done : out STD_LOGIC);
end egcd;

architecture Behavioral of egcd is

component coeff_buffer is
    Port (clk           : in std_logic;
          write         : in std_logic;
          input        : in coefficient_t;
          output        : out coefficient_t
         );
end component;

component pointwise_mult is
    Port ( clk : in STD_LOGIC;
           poly_0 : in coefficient_t;
           poly_1 : in coefficient_t;
           output : out coefficient_t);
end component;

component egcd_control_unit is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           done : out STD_LOGIC;
           b1 : in coefficient_t;
           x1_input_sel : out STD_LOGIC;
           y1_input_sel : out STD_LOGIC;
           b1_input_sel : out STD_LOGIC;
           x_input_sel : out STD_LOGIC;
           y_input_sel : out STD_LOGIC;
           a1_input_sel : out STD_LOGIC;
           x1_write : out STD_LOGIC;
           y1_write : out STD_LOGIC;
           b1_write : out STD_LOGIC;
           x_write: out STD_LOGIC;
           y_write: out STD_LOGIC;
           a1_write : out STD_LOGIC);
end component;

signal x1_write : std_logic := '0';
signal y1_write : std_logic := '0';
signal b1_write : std_logic := '0';
signal x_write : std_logic := '0';
signal y_write : std_logic := '0';
signal a1_write : std_logic := '0';

signal x1_input_sel : std_logic := '0';
signal y1_input_sel : std_logic := '0';
signal b1_input_sel : std_logic := '0';
signal x_input_sel : std_logic := '0';
signal y_input_sel : std_logic := '0';
signal a1_input_sel : std_logic := '0';

signal x1_input : coefficient_t := (others => '0');
signal y1_input : coefficient_t := (others => '0');
signal b1_input : coefficient_t := (others => '0');
signal x_input : coefficient_t := (others => '0');
signal y_input : coefficient_t := (others => '0');
signal a1_input : coefficient_t := (others => '0');

signal x1_output : s_coefficient_t := (others => '0');
signal y1_output : s_coefficient_t := (others => '0');
signal b1_output : s_coefficient_t := (others => '1');
signal b1_output_zero : coefficient_t := (others => '0');
signal x_output : coefficient_t := (others => '0');
signal y_output : coefficient_t := (others => '0');
signal a1_output : s_coefficient_t := (others => '0');

signal a1_div_b1 : s_coefficient_t := (others => '0');

signal x1_new_input : double_coefficient_t := (others => '0');
signal y1_new_input : double_coefficient_t := (others => '0');
signal b1_new_input : double_coefficient_t := (others => '0');

signal x1_mult_output : double_coefficient_t := (others => '0');
signal y1_mult_output : double_coefficient_t := (others => '0');
signal b1_mult_output : double_coefficient_t := (others => '0');

begin
    a1_div_b1 <= a1_output / b1_output;
    
    x1_new_input <= x_output - x1_mult_output;
    y1_new_input <= y_output - y1_mult_output;
    b1_new_input <= unsigned(a1_output) - b1_mult_output;
    
    x <= x_output;
    y <= y_output;
    a1 <= unsigned(a1_output);
    
    b1_output_driver: process(b1_output_zero)
    begin
        if b1_output_zero = to_unsigned(0, BIT_WIDTH) then
            b1_output <= to_signed(1, BIT_WIDTH);
        else
            b1_output <= signed(b1_output_zero);
        end if;
    end process;
    
    x1_buff: coeff_buffer
    port map (
        clk     => clk,
        write   => x1_write,
        input   => x1_input,
        signed(output)  => x1_output
    );
    
    y1_buff: coeff_buffer
    port map (
        clk     => clk,
        write   => y1_write,
        input   => y1_input,
        signed(output)  => y1_output
    );

    b1_buff: coeff_buffer
    port map (
        clk     => clk,
        write   => b1_write,
        input   => b1_input,
        output  => b1_output_zero
    );

    x_buff: coeff_buffer
    port map (
        clk     => clk,
        write   => x_write,
        input   => x_input,
        output  => x_output
    );

    y_buff: coeff_buffer
    port map (
        clk     => clk,
        write   => y_write,
        input   => y_input,
        output  => y_output
    );

    a1_buff: coeff_buffer
    port map (
        clk     => clk,
        write   => a1_write,
        input   => a1_input,
        signed(output)  => a1_output
    );

    x1_mult: process(clk)
    begin
        if rising_edge(clk) then
            x1_mult_output <= unsigned(x1_output * a1_div_b1);
        end if;
    end process;
    
   y1_mult: process(clk)
    begin
        if rising_edge(clk) then
            y1_mult_output <= unsigned(y1_output * a1_div_b1);
        end if;
    end process;
    
   b1_mult: process(clk)
    begin
        if rising_edge(clk) then
            b1_mult_output <= unsigned(b1_output * a1_div_b1);
        end if;
    end process;
    
    control_unit: egcd_control_unit
    port map ( 
        clk             => clk,
        start           => start,
        reset           => reset,
        done            => done,
        b1              => b1_output_zero,
        x1_input_sel    => x1_input_sel,
        y1_input_sel    => y1_input_sel,
        b1_input_sel    => b1_input_sel,
        x_input_sel     => x_input_sel,
        y_input_sel     => y_input_sel,
        a1_input_sel    => a1_input_sel,
        x1_write        => x1_write,
        y1_write        => y1_write,
        b1_write        => b1_write,
        x_write         => x_write,
        y_write         => y_write,
        a1_write        => a1_write);

    x1_input_mux: process(x1_input_sel, x1_new_input)
    begin
        if x1_input_sel = '0' then
            x1_input <= x1_new_input(BIT_WIDTH - 1 downto 0);
        else
            x1_input <= (others => '0');
        end if;
    end process;
    
    y1_input_mux: process(y1_input_sel, y1_new_input)
    begin
        if y1_input_sel = '0' then
            y1_input <= y1_new_input(BIT_WIDTH - 1 downto 0);
        else
            y1_input <= to_unsigned(1, BIT_WIDTH);
        end if;
    end process;
    
    b1_input_mux: process(b1_input_sel, b1_new_input, b)
    begin
        if b1_input_sel = '0' then
            b1_input <= b1_new_input(BIT_WIDTH - 1 downto 0);
        else
            b1_input <= b;
        end if;
    end process;
    
    x_input_mux: process(x_input_sel, x1_output)
    begin
        if x_input_sel = '0' then
            x_input <= unsigned(x1_output);
        else
            x_input <= to_unsigned(1, BIT_WIDTH);
        end if;
    end process;
    
    y_input_mux: process(y_input_sel, y1_output)
    begin
        if y_input_sel = '0' then
            y_input <= unsigned(y1_output);
        else
            y_input <= to_unsigned(0, BIT_WIDTH);
        end if;
    end process;
    

    a1_input_mux: process(a1_input_sel, a, b1_output)
    begin
        if a1_input_sel = '0' then
            a1_input <= unsigned(b1_output);
        else
            a1_input <= a;
        end if;
    end process;
end Behavioral;
