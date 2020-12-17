----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 06:01:10 PM
-- Design Name: 
-- Module Name: rlwe_core_control_unit - Behavioral
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

entity rlwe_core_control_unit is
    Port (clk               : in std_logic;
          mode              : in std_logic_vector(2 downto 0);
          start             : in std_logic;
          reset             : in std_logic;
          poly_mult_valid   : in std_logic;
          valid             : out std_logic;
          poly_mult_reset   : out std_logic;
          poly_mult_start   : out std_logic;
          rw_in             : out std_logic;
          output_sel        : out std_logic_vector(2 downto 0));
end rlwe_core_control_unit;

architecture Behavioral of rlwe_core_control_unit is
    TYPE STATE_TYPE IS (idle, 
                        start_core, 
                        mult_process, 
                        add_process, 
                        negate_process, 
                        scalar_mult, 
                        decode_process, 
                        output, 
                        stall);
    SIGNAL state   : STATE_TYPE;
begin

    fsm : process(clk, reset)
    begin
        if reset = '1'  then
            state <= idle;
        elsif rising_edge(clk) then
            case state is
                when idle => 
                    if start = '1' then
                        state <= start_core;
                    else
                        state <= idle;
                    end if;
                when start_core =>
                    case mode is
                        when "000" =>
                            state <= add_process;
                        when "001" =>
                            state <= mult_process;
                        when "010" =>
                            state <= negate_process;
                        when "011" =>
                            state <= scalar_mult;
                        when "100" =>
                            state <= decode_process;
                        when others =>
                            state <= add_process;
                    end case;
                when mult_process =>
                    if poly_mult_valid = '0' then
                        state <= mult_process;
                    else
                        state <= output;
                    end if;
                when add_process =>
                    state <= output;
                when negate_process =>
                    state <= output;
                when scalar_mult =>
                    state <= output;
                when decode_process =>
                    state <= output;
                when output =>
                    state <= stall;
                when stall =>
                    state <= idle;
                when others =>
                    state <= idle;
            end case;
        end if;
    end process;
    
    combinational : process(state, mode)
    begin
        case state is
            when idle =>
                valid               <= '0';
                poly_mult_start     <= '0';
                output_sel          <= mode;
                poly_mult_reset     <= '0';
                rw_in               <= '1';
            when start_core =>
                valid               <= '0';
                poly_mult_start     <= '0';
                output_sel          <= mode;
                poly_mult_reset     <= '1';
                rw_in               <= '0';
            when mult_process =>
                valid               <= '0';
                poly_mult_start     <= '1';
                output_sel          <= mode;
                poly_mult_reset     <= '0';
                rw_in               <= '0';
            when add_process =>
                valid               <= '0';
                poly_mult_start     <= '0';
                output_sel          <= mode;
                poly_mult_reset     <= '0';
                rw_in               <= '0';
            when negate_process =>
                valid               <= '0';
                poly_mult_start     <= '0';
                output_sel          <= mode;
                poly_mult_reset     <= '0';
                rw_in               <= '0';
            when scalar_mult =>
                valid               <= '0';
                poly_mult_start     <= '0';
                output_sel          <= mode;
                poly_mult_reset     <= '0';
                rw_in               <= '0';
            when decode_process =>
                valid               <= '0';
                poly_mult_start     <= '0';
                output_sel          <= mode;
                poly_mult_reset     <= '0';
                rw_in               <= '0';
            when output =>
                valid               <= '1';
                poly_mult_start     <= '0';
                output_sel          <= mode;
                poly_mult_reset     <= '0';
                rw_in               <= '0';
            when stall =>
                valid               <= '1';
                poly_mult_start     <= '0';
                output_sel          <= mode;
                poly_mult_reset     <= '0';
                rw_in               <= '0';
        end case;
    end process;

end Behavioral;
