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

entity rlwe_main is
    Port (clk   : in std_logic;
          mode  : in std_logic_vector(1 downto 0);
          start : in std_logic;
          reset : in std_logic;
          encrypted_data_in1    : in port_t;
          encrypted_data_in2    : in port_t;
          decrypted_data_in   : in port_t;
          public_key_in1           : in port_t;
          public_key_in2           : in port_t;
          private_key_in           : in port_t;
          public_key_out1          : out port_t;
          public_key_out2          : out port_t;
          private_key_out          : out port_t;
          valid : out std_logic;
          encrypted_data_out1   : out port_t;
          encrypted_data_out2   : out port_t;
          decrypted_data_out  : out port_t);
end rlwe_main;

architecture Behavioral of rlwe_main is

component main_control_unit is
    Port (clk                       : in std_logic;
          mode                      : in std_logic_vector(1 downto 0);
          start                     : in std_logic;
          reset                     : in std_logic;
          valid                     : out std_logic;
          temp_reg_rw               : out std_logic;
          y_reg_rw                  : out std_logic;
          e2_reg_rw                 : out std_logic;
          e1_reg_rw                 : out std_logic;
          s_reg_rw                  : out std_logic;
          r_reg_rw                  : out std_logic;
          a_reg_rw                  : out std_logic;
          uniform_gen               : out std_logic;
          uniform_valid             : in std_logic;
          uniform_reset             : out std_logic;
          gaussian_gen              : out std_logic;
          gaussian_valid            : in std_logic;
          gaussian_reset            : out std_logic;
          rlwe_core_poly1_sel       : out std_logic_vector(2 downto 0);
          rlwe_core_poly2_sel       : out std_logic_vector(2 downto 0);
          rlwe_core_mode            : out std_logic_vector(2 downto 0);
          rlwe_core_start           : out std_logic;
          rlwe_core_reset           : out std_logic;
          rlwe_core_valid           : in std_logic;
          encrypted_msg1_reg_rw     : out std_logic;
          encrypted_msg2_reg_rw     : out std_logic;
          encrypted_msg_input_sel   : out std_logic;
          decrypted_msg_reg_rw     : out std_logic;
          a_reg_input_sel       : out std_logic_vector(1 downto 0);
          s_reg_input_sel       : out std_logic;
          y_reg_input_sel       : out std_logic
          );
end component;

component uniform_core is
    Port (clk       : in std_logic;
          gen       : in std_logic;
          valid     : out std_logic;
          output    : out port_t );
end component;

component gaussian_core is
    Port (clk           : in std_logic;
          gen           : in std_logic;
          valid         : out std_logic;
          output        : out port_t );
end component;

component rlwe_core is
    Port (clk       : in std_logic;
          start     : in std_logic;
          reset     : in std_logic;
          mode      : in std_logic_vector(2 downto 0);
          poly1     : in port_t;
          poly2     : in port_t;
          output    : out port_t;
          valid     : out std_logic
           );
end component;

component reg is
    Port ( clk : in STD_LOGIC;
           rw : in STD_LOGIC;
           input : in port_t;
           output : out port_t);
end component;

component mux2to1 is
    Port (input1    : in port_t;
          input2    : in port_t;
          sel       : in std_logic;
          output    : out port_t );
end component;

component mux3to1 is
    Port (input1    : in port_t;
          input2    : in port_t;
          input3    : in port_t;
          sel       : in std_logic_vector(1 downto 0);
          output    : out port_t );
end component;

component mux5to1 is
    Port (input1    : in port_t;
          input2    : in port_t;
          input3    : in port_t;
          input4    : in port_t;
          input5    : in port_t;
          sel       : in std_logic_vector(2 downto 0);
          output    : out port_t );
end component;


component mux7to1 is
    Port (input1    : in port_t;
          input2    : in port_t;
          input3    : in port_t;
          input4    : in port_t;
          input5    : in port_t;
          input6    : in port_t;
          input7    : in port_t;
          sel       : in std_logic_vector(2 downto 0);
          output    : out port_t );
end component;


signal temp_reg_rw : std_logic;
signal y_reg_rw : std_logic;
signal e2_reg_rw : std_logic;
signal e1_reg_rw : std_logic;
signal s_reg_rw : std_logic;
signal r_reg_rw : std_logic;
signal a_reg_rw : std_logic;
signal uniform_gen : std_logic;
signal uniform_valid : std_logic;
signal uniform_reset : std_logic;
signal gaussian_gen : std_logic;
signal gaussian_valid : std_logic;
signal gaussian_reset : std_logic;
signal rlwe_core_poly1_sel : std_logic_vector(2 downto 0);
signal rlwe_core_poly2_sel : std_logic_vector(2 downto 0);
signal rlwe_core_mode : std_logic_vector(2 downto 0);
signal rlwe_core_start : std_logic;
signal rlwe_core_reset : std_logic;
signal rlwe_core_valid : std_logic;
signal encrypted_msg1_reg_rw : std_logic;
signal encrypted_msg2_reg_rw : std_logic;
signal encrypted_msg_input_sel : std_logic;
signal decrypted_msg_reg_rw : std_logic;
signal a_reg_input_sel : std_logic_vector(1 downto 0);
signal s_reg_input_sel : std_logic;
signal y_reg_input_sel : std_logic;

signal uniform_output : port_t;
signal gaussian_output : port_t;

signal rlwe_core_poly1 : port_t;
signal rlwe_core_poly2 : port_t;

signal rlwe_core_output             : port_t;
signal q_2_ROM_out                  : port_t;
signal a_reg_out                    : port_t;
signal temp_reg_out                 : port_t;
signal y_reg_out                    : port_t;
signal encrypted_msg1_reg_out       : port_t;
signal s_reg_out                    : port_t;
signal e1_reg_out                   : port_t;
signal r_reg_out                    : port_t;
signal e2_reg_out                   : port_t;
signal decrypted_msg_reg_out      : port_t;
signal decrypted_msg_reg_input    : port_t;
signal encrypted_msg2_reg_out       : port_t;
signal encrypted_msg1_reg_input     : port_t;
signal encrypted_msg2_reg_input     : port_t;
signal a_reg_input                  : port_t;
signal s_reg_input                  : port_t;
signal y_reg_input                  : port_t;


begin
    q_2_ROM_out <= initialize_q_2_ROM;
    
    public_key_out1 <= a_reg_out;
    public_key_out2 <= y_reg_out;

    private_key_out <= s_reg_out;

    encrypted_data_out1 <= encrypted_msg1_reg_out;
    encrypted_data_out2 <= encrypted_msg2_reg_out;

    decrypted_data_out <= decrypted_msg_reg_out;
    
    decrypted_msg_reg_input <= rlwe_core_output;

    control_unit: main_control_unit
    port map (
        clk                     => clk,
        mode                    => mode,
        start                   => start,
        reset                   => reset,
        valid                   => valid,
        temp_reg_rw             => temp_reg_rw,
        y_reg_rw                => y_reg_rw,
        e2_reg_rw               => e2_reg_rw,
        e1_reg_rw               => e1_reg_rw,
        s_reg_rw                => s_reg_rw,
        r_reg_rw                => r_reg_rw,
        a_reg_rw                => a_reg_rw,
        uniform_gen             => uniform_gen,
        uniform_valid           => uniform_valid,
        uniform_reset           => uniform_reset,
        gaussian_gen            => gaussian_gen,
        gaussian_valid          => gaussian_valid,
        gaussian_reset          => gaussian_reset,
        rlwe_core_poly1_sel     => rlwe_core_poly1_sel,
        rlwe_core_poly2_sel     => rlwe_core_poly2_sel,
        rlwe_core_mode          => rlwe_core_mode,
        rlwe_core_start         => rlwe_core_start,
        rlwe_core_reset         => rlwe_core_reset,
        rlwe_core_valid         => rlwe_core_valid,
        encrypted_msg1_reg_rw   => encrypted_msg1_reg_rw,
        encrypted_msg2_reg_rw   => encrypted_msg2_reg_rw,
        encrypted_msg_input_sel => encrypted_msg_input_sel,
        decrypted_msg_reg_rw  => decrypted_msg_reg_rw,
        a_reg_input_sel         => a_reg_input_sel,
        s_reg_input_sel         => s_reg_input_sel,
        y_reg_input_sel         => y_reg_input_sel
    );

    uniform_rng: uniform_core
    port map (
        clk     => clk,
        gen     => uniform_gen,
        valid   => uniform_valid,
        output  => uniform_output
    );

    gaussian_rng: gaussian_core
    port map (
        clk         => clk,
        gen         => gaussian_gen,
        valid       => gaussian_valid,
        output      => gaussian_output
    );
    
    rlwe_logical_unit: rlwe_core
    port map (
        clk     => clk,
        start   => rlwe_core_start,
        reset   => rlwe_core_reset,
        mode    => rlwe_core_mode,
        poly1   => rlwe_core_poly1,
        poly2   => rlwe_core_poly2,
        output  => rlwe_core_output,
        valid   => rlwe_core_valid
    );
    
    rlwe_core_poly1_mux: mux5to1
    port map(input1 => a_reg_out,
             input2 => temp_reg_out,
             input3 => y_reg_out,
             input4 => encrypted_msg1_reg_out,
             input5 => decrypted_data_in,
             sel    => rlwe_core_poly1_sel,
             output => rlwe_core_poly1
    );    
    
    
    rlwe_core_poly2_mux: mux7to1
    port map(input1 => s_reg_out,
             input2 => e1_reg_out,
             input3 => r_reg_out,
             input4 => e2_reg_out,
             input5 => decrypted_msg_reg_out,
             input6 => encrypted_msg2_reg_out,
             input7 => q_2_ROM_out,
             sel    => rlwe_core_poly2_sel,
             output => rlwe_core_poly2
    );    
    
    encrypted_msg_reg_input1_mux: mux2to1
    port map(input1 => encrypted_data_in1,
             input2 => rlwe_core_output,
             sel    => encrypted_msg_input_sel,
             output => encrypted_msg1_reg_input
        
    );
    
    encrypted_msg_reg_input2_mux: mux2to1
    port map(input1 => encrypted_data_in2,
             input2 => rlwe_core_output,
             sel    => encrypted_msg_input_sel,
             output => encrypted_msg2_reg_input
        
    );
    
    a_reg_input_mux: mux3to1
    port map(input1 => uniform_output,
             input2 => public_key_in1,
             input3 => rlwe_core_output,
             sel    => a_reg_input_sel,
             output => a_reg_input
        
    );
    
    s_reg_input_mux: mux2to1
    port map(input1 => gaussian_output,
             input2 => private_key_in,
             sel    => s_reg_input_sel,
             output => s_reg_input
        
    );
    
    y_reg_input_mux: mux2to1
    port map(input1 => rlwe_core_output,
             input2 => public_key_in2,
             sel    => y_reg_input_sel,
             output => y_reg_input
        
    );
    
    temp_reg : reg
    port map (
        clk     => clk,
        rw      => temp_reg_rw,
        input   => rlwe_core_output,
        output  => temp_reg_out
    );
    
    y_reg : reg
    port map (
        clk     => clk,
        rw      => y_reg_rw,
        input   => y_reg_input,
        output  => y_reg_out
    );
    
    e2_reg : reg
    port map (
        clk     => clk,
        rw      => e2_reg_rw,
        input   => gaussian_output,
        output  => e2_reg_out
    );
    
    e1_reg : reg
    port map (
        clk     => clk,
        rw      => e1_reg_rw,
        input   => gaussian_output,
        output  => e1_reg_out
    );
    
    s_reg : reg
    port map (
        clk     => clk,
        rw      => s_reg_rw,
        input   => s_reg_input,
        output  => s_reg_out
    );
    
    r_reg : reg
    port map (
        clk     => clk,
        rw      => r_reg_rw,
        input   => gaussian_output,
        output  => r_reg_out
    );
    
    a_reg : reg
    port map (
        clk     => clk,
        rw      => a_reg_rw,
        input   => a_reg_input,
        output  => a_reg_out
    );
    
    encrypted_msg1_reg : reg
    port map (
        clk     => clk,
        rw      => encrypted_msg1_reg_rw,
        input   => encrypted_msg1_reg_input,
        output  => encrypted_msg1_reg_out
    );

    encrypted_msg2_reg : reg
    port map (
        clk     => clk,
        rw      => encrypted_msg2_reg_rw,
        input   => encrypted_msg2_reg_input,
        output  => encrypted_msg2_reg_out
    );

    decrypted_msg_reg : reg
    port map (
        clk     => clk,
        rw      => decrypted_msg_reg_rw,
        input   => decrypted_msg_reg_input,
        output  => decrypted_msg_reg_out
    );
end Behavioral;
