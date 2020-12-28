----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/10/2020 02:46:02 PM
-- Design Name: 
-- Module Name: reg_file - Behavioral
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

entity reg_file is
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
end reg_file;

architecture Behavioral of reg_file is

signal input0 : coefficient_t := (others => '0');
signal input1 : coefficient_t := (others => '0');
signal input2 : coefficient_t := (others => '0');
signal input3 : coefficient_t := (others => '0');
signal input4 : coefficient_t := (others => '0');
signal input5 : coefficient_t := (others => '0');
signal input6 : coefficient_t := (others => '0');
signal input7 : coefficient_t := (others => '0');
signal input8 : coefficient_t := (others => '0');
signal input9 : coefficient_t := (others => '0');
signal input10 : coefficient_t := (others => '0');
signal input11 : coefficient_t := (others => '0');
signal input12 : coefficient_t := (others => '0');
signal input13 : coefficient_t := (others => '0');
signal input14 : coefficient_t := (others => '0');
signal input15 : coefficient_t := (others => '0');

signal output0 : coefficient_t := (others => '0');
signal output1 : coefficient_t := (others => '0');
signal output2 : coefficient_t := (others => '0');
signal output3 : coefficient_t := (others => '0');
signal output4 : coefficient_t := (others => '0');
signal output5 : coefficient_t := (others => '0');
signal output6 : coefficient_t := (others => '0');
signal output7 : coefficient_t := (others => '0');
signal output8 : coefficient_t := (others => '0');
signal output9 : coefficient_t := (others => '0');
signal output10 : coefficient_t := (others => '0');
signal output11 : coefficient_t := (others => '0');
signal output12 : coefficient_t := (others => '0');
signal output13 : coefficient_t := (others => '0');
signal output14 : coefficient_t := (others => '0');
signal output15 : coefficient_t := (others => '0');

signal write0 : std_logic := '0';
signal write1 : std_logic := '0';
signal write2 : std_logic := '0';
signal write3 : std_logic := '0';
signal write4 : std_logic := '0';
signal write5 : std_logic := '0';
signal write6 : std_logic := '0';
signal write7 : std_logic := '0';
signal write8 : std_logic := '0';
signal write9 : std_logic := '0';
signal write10 : std_logic := '0';
signal write11 : std_logic := '0';
signal write12 : std_logic := '0';
signal write13 : std_logic := '0';
signal write14 : std_logic := '0';
signal write15 : std_logic := '0';

component reg_file_ram is
    Port (  clk     : in STD_LOGIC;
            input   : in coefficient_t;
            addr    : in index_t;
            write   : in STD_LOGIC;
            output  : out coefficient_t);
end component;

component reg_file_input_decoder is
    Port ( write_0          : in STD_LOGIC;
           in_value_0       : in coefficient_t;
           write_1          : in STD_LOGIC;
           in_value_1       : in coefficient_t;
           reg_file_sel_0   : in STD_LOGIC_VECTOR(3 downto 0);
           reg_file_sel_1   : in STD_LOGIC_VECTOR(3 downto 0);
           index            : in STD_LOGIC_VECTOR(3 downto 0);
           write            : out STD_LOGIC;
           output           : out coefficient_t);
end component;

component reg_file_output_mux is
    Port ( clk      : in std_logic;
           input_0  : in coefficient_t;
           input_1  : in coefficient_t;
           input_2  : in coefficient_t;
           input_3  : in coefficient_t;
           input_4  : in coefficient_t;
           input_5  : in coefficient_t;
           input_6  : in coefficient_t;
           input_7  : in coefficient_t;
           input_8  : in coefficient_t;
           input_9  : in coefficient_t;
           input_10 : in coefficient_t;
           input_11 : in coefficient_t;
           input_12 : in coefficient_t;
           input_13 : in coefficient_t;
           input_14 : in coefficient_t;
           input_15 : in coefficient_t;
           sel      : in STD_LOGIC_VECTOR(3 downto 0);
           output   : out coefficient_t);
end component;

begin
    
    decoder0 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "0000",
        write           => write0,
        output          => input0
    );
    decoder1 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "0001",
        write           => write1,
        output          => input1
    );
    decoder2 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "0010",
        write           => write2,
        output          => input2
    );
    decoder3 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "0011",
        write           => write3,
        output          => input3
    );
    decoder4 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "0100",
        write           => write4,
        output          => input4
    );
    decoder5 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "0101",
        write           => write5,
        output          => input5
    );
    decoder6 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "0110",
        write           => write6,
        output          => input6
    );
    decoder7 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "0111",
        write           => write7,
        output          => input7
    );
    decoder8 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "1000",
        write           => write8,
        output          => input8
    );
    decoder9 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "1001",
        write           => write9,
        output          => input9
    );
    decoder10 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "1010",
        write           => write10,
        output          => input10
    );
    decoder11 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "1011",
        write           => write11,
        output          => input11
    );
    decoder12 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "1100",
        write           => write12,
        output          => input12
    );
    decoder13 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "1101",
        write           => write13,
        output          => input13
    );
    decoder14 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "1110",
        write           => write14,
        output          => input14
    );
    decoder15 : reg_file_input_decoder
    port map (
        write_0         => write_0,
        in_value_0      => in_value_0,
        write_1         => write_1,
        in_value_1      => in_value_1,
        reg_file_sel_0  => reg_file_sel_0,
        reg_file_sel_1  => reg_file_sel_1,
        index           => "1111",
        write           => write15,
        output          => input15
    );
    
    reg_0_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input0,
        write   => write0,
        addr    => index,
        output  => output0
    );
    
   
   	reg_1_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input1,
        write   => write1,
        addr    => index,
        output  => output1
    );
    
	reg_2_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input2,
        write   => write2,
        addr    => index,
        output  => output2
    );
    
	reg_3_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input3,
        write   => write3,
        addr    => index,
        output  => output3
    );
    
	reg_4_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input4,
        write   => write4,
        addr    => index,
        output  => output4
    );
    
	reg_5_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input5,
        write   => write5,
        addr    => index,
        output  => output5
    );
    
	reg_6_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input6,
        write   => write6,
        addr    => index,
        output  => output6
    );
    
	reg_7_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input7,
        write   => write7,
        addr    => index,
        output  => output7
    );
    
	reg_8_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input8,
        write   => write8,
        addr    => index,
        output  => output8
    );
    
	reg_9_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input9,
        write   => write9,
        addr    => index,
        output  => output9
    );
    
	reg_10_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input10,
        write   => write10,
        addr    => index,
        output  => output10
    );
    
	reg_11_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input11,
        write   => write11,
        addr    => index,
        output  => output11
    );
    
	reg_12_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input12,
        write   => write12,
        addr    => index,
        output  => output12
    );
    
	reg_13_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input13,
        write   => write13,
        addr    => index,
        output  => output13
    );
    
	reg_14_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input14,
        write   => write14,
        addr    => index,
        output  => output14
    );
    
	reg_15_ram : reg_file_ram 
    port map (
        clk     => clk,
        input   => input15,
        write   => write15,
        addr    => index,
        output  => output15
    );
    
   output_mux_0 : reg_file_output_mux 
    port map (
        clk         => clk,
        input_0     => output0,
        input_1     => output1,
        input_2     => output2,
        input_3     => output3,
        input_4     => output4,
        input_5     => output5,
        input_6     => output6,
        input_7     => output7,
        input_8     => output8,
        input_9     => output9,
        input_10    => output10,
        input_11    => output11,
        input_12    => output12,
        input_13    => output13,
        input_14    => output14,
        input_15    => output15,
        sel         => reg_file_sel_0,
        output      => out_0
    );
    
   output_mux_1 : reg_file_output_mux 
    port map (
        clk         => clk,
        input_0     => output0,
        input_1     => output1,
        input_2     => output2,
        input_3     => output3,
        input_4     => output4,
        input_5     => output5,
        input_6     => output6,
        input_7     => output7,
        input_8     => output8,
        input_9     => output9,
        input_10    => output10,
        input_11    => output11,
        input_12    => output12,
        input_13    => output13,
        input_14    => output14,
        input_15    => output15,
        sel         => reg_file_sel_1,
        output      => out_1
    );
    
    
end Behavioral;