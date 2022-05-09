library IEEE;
library work;

use STD.textio.all;
use ieee.std_logic_textio.all;
use work.my_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity egcd_test is
end egcd_test;

architecture Behavioral of egcd_test is

    component egcd is
        Port ( clk : in STD_LOGIC;
               start : in STD_LOGIC;
               reset : in STD_LOGIC;
               a : in coefficient_t;
               b : in coefficient_t;
               x : out coefficient_t;
               y : out coefficient_t;
               a1 : out coefficient_t;
               done : out STD_LOGIC);
    end component;
      
	signal CLK                      : std_logic                         := '0';
    signal start                    : std_logic                         := '0';
    signal reset                    : std_logic                         := '0';
    signal a                        : coefficient_t                     := (others => '0');
    signal b                        : coefficient_t                     := (others => '0');
    signal x                        : coefficient_t                     := (others => '0');
    signal y                        : coefficient_t                     := (others => '0');
    signal a1                       : coefficient_t                     := (others => '0');
    signal done                    : std_logic                          := '0';
        
	constant CLK_period             : time                              := 20 ns;

  begin
  
        egcd_component: egcd PORT MAP (
            clk     => clk,
            start   => start,   
            reset   => reset,
            a       => a,
            b       => b,
            x       => x,
            y       => y,
            a1      => a1,
            done    => done
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
            b       <= to_unsigned(1049089, BIT_WIDTH);
            start   <= '0';
            reset   <= '1';
            wait for CLK_period;
            reset <= '0';
            start <= '1';
            wait for CLK_period;
            wait on done until done = '1';            
            wait for CLK_period;
            
            report "-----TEST BENCH RESULTS-----";
            
            if signed(x) = to_signed(-87424, BIT_WIDTH) then
                report "Output Matches";
            else
                report "Output Incorrect";
            end if;
            
            if y = to_unsigned(1, BIT_WIDTH) then
                report "Output Matches";
            else
                report "Output Incorrect";
            end if;
            
            if a1 = to_unsigned(1, BIT_WIDTH) then
                report "Output Matches";
            else
                report "Output Incorrect";
            end if;
            
            wait on done until done = '0'; 
        end process;
end Behavioral;
