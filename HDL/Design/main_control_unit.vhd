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

entity main_control_unit is
    Port (clk                   : in std_logic;
          mode                  : in std_logic_vector(1 downto 0);
          start                 : in std_logic;
          reset                 : in std_logic;
          valid                 : out std_logic;
          temp_reg_rw           : out std_logic;
          y_reg_rw              : out std_logic;
          e2_reg_rw             : out std_logic;
          e1_reg_rw             : out std_logic;
          s_reg_rw              : out std_logic;
          r_reg_rw              : out std_logic;
          a_reg_rw              : out std_logic;
          uniform_gen           : out std_logic;
          uniform_valid         : in std_logic;
          uniform_reset         : out std_logic;
          gaussian_gen          : out std_logic;
          gaussian_valid        : in std_logic;
          gaussian_reset        : out std_logic;
          rlwe_core_poly1_sel   : out std_logic_vector(2 downto 0);
          rlwe_core_poly2_sel   : out std_logic_vector(2 downto 0);
          rlwe_core_mode        : out std_logic_vector(1 downto 0);
          rlwe_core_start       : out std_logic;
          rlwe_core_reset       : out std_logic;
          rlwe_core_valid       : in std_logic;
          encrypt_msg1_reg_rw   : out std_logic;
          encrypt_msg2_reg_rw   : out std_logic;
          encrypt_msg_input_sel : out std_logic;
          unencrypted_msg_reg_rw : out std_logic
          );
end main_control_unit;

architecture Behavioral of main_control_unit is

begin


end Behavioral;
