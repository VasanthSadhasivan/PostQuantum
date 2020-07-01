library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rlwe_main_keygen_sim is
end rlwe_main_keygen_sim;

architecture Behavioral of rlwe_main_keygen_sim is

component rlwe_main is
    Port (clk                   : in std_logic;
          mode                  : in std_logic_vector(1 downto 0);
          start                 : in std_logic;
          reset                 : in std_logic;
          encrypted_data_in1    : in port_t;
          encrypted_data_in2    : in port_t;
          decrypted_data_in   : in port_t;
          public_key_in1        : in port_t;
          public_key_in2        : in port_t;
          private_key_in        : in port_t;
          public_key_out1       : out port_t;
          public_key_out2       : out port_t;
          private_key_out       : out port_t;
          valid                 : out std_logic;
          encrypted_data_out1   : out port_t;
          encrypted_data_out2   : out port_t;
          decrypted_data_out  : out port_t);
end component;
  
	signal CLK      : std_logic := '0';
    signal mode     : std_logic_vector(1 downto 0) := "00";
    signal start    : std_logic := '0';
    signal valid    : std_logic;
    signal reset    : std_logic := '0';
    signal encrypted_data_in1   : port_t;
    signal encrypted_data_in2   : port_t;
    signal decrypted_data_in  : port_t;
    signal public_key_in1   : port_t;
    signal public_key_in2   : port_t;
    signal private_key_in   : port_t;
    signal public_key_out1  : port_t;
    signal public_key_out2  : port_t;
    signal private_key_out  : port_t;
    signal encrypted_data_out1  : port_t;
    signal encrypted_data_out2  : port_t;
    signal decrypted_data_out : port_t;
    
	constant CLK_period : time := 10 ns;

  begin
  
        rlwe_arch: rlwe_main PORT MAP (
            clk                     => CLK                 ,
            mode                    => mode                ,
            start                   => start               ,
            reset                   => reset               ,
            encrypted_data_in1      => encrypted_data_in1  ,
            encrypted_data_in2      => encrypted_data_in2  ,
            decrypted_data_in     => decrypted_data_in ,
            public_key_in1          => public_key_in1      ,
            public_key_in2          => public_key_in2      ,
            private_key_in          => private_key_in      ,
            public_key_out1         => public_key_out1     ,
            public_key_out2         => public_key_out2     ,
            private_key_out         => private_key_out     ,
            valid                   => valid               ,
            encrypted_data_out1     => encrypted_data_out1 ,
            encrypted_data_out2     => encrypted_data_out2 ,
            decrypted_data_out    => decrypted_data_out
        );

		CLK_process : process
		begin
			CLK <= '0';
			wait for CLK_period/2;
			CLK <= '1'; 
			wait for CLK_period/2;
		end process;
		
		
        main: process
        begin
                reset <= '1';
                start <= '0';
                wait for CLK_period;
                reset <= '0';
                start <= '1';
                mode  <= "00";
                wait for CLK_period;
                wait on valid until valid = '1';
                wait for CLK_period;
            wait;
        end process;
end Behavioral;
