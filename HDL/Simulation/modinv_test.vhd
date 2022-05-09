library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modinv_test is
end modinv_test;

architecture Behavioral of modinv_test is

    component modinv is
        Port (
            clk     : in STD_LOGIC;
            a       : in coefficient_t;
            start   : in STD_LOGIC;
            reset   : in STD_LOGIC;
            output  : out coefficient_t;
            done    : out STD_LOGIC;
            error   : out STD_LOGIC
        );
    end component;
      
	signal CLK                      : std_logic                         := '0';
    signal a                        : coefficient_t                     := (others => '0');
    signal start                    : std_logic                         := '0';
    signal reset                    : std_logic                         := '0';
    signal output                   : coefficient_t                     := (others => '0');
    signal done                    : std_logic                          := '0';
        
	constant CLK_period             : time                              := 20 ns;

  begin
  
        modinv_component: modinv PORT MAP (
            clk         => clk      ,
            a           => a        ,
            start       => start    ,
            reset       => reset    ,
            output      => output   ,
            done        => done     ,
            error       => open
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
            a       <= to_unsigned(12, BIT_WIDTH);
            start   <= '0';
            reset   <= '1';
            wait for CLK_period;
            reset <= '0';
            start <= '1';
            wait for CLK_period;
            wait on done until done = '1';            
            wait for CLK_period;
            
            report "-----TEST BENCH RESULTS-----";
            
            if output = to_unsigned(961665, BIT_WIDTH) then
                report "Output Matches";
            else
                report "Output Incorrect";
            end if;
        end process;
end Behavioral;
