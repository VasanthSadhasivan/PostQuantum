----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2020 12:06:00 AM
-- Design Name: 
-- Module Name: poly_mult_control_unit - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity poly_mult_control_unit is
    Port ( clk : in STD_LOGIC;
           ntt1_rst : out STD_LOGIC;
           ntt2_rst : out STD_LOGIC;
           ntt1_start : out STD_LOGIC;
           ntt2_start : out STD_LOGIC;
           ntt1_valid : in STD_LOGIC;
           ntt2_valid : in STD_LOGIC;
           intt_rst : out STD_LOGIC;
           intt_start : out STD_LOGIC;
           intt_valid : in STD_LOGIC;
           valid    : out STD_LOGIC;
           start    : in STD_LOGIC;
           reset    : in STD_LOGIC);
end poly_mult_control_unit;

architecture Behavioral of poly_mult_control_unit is
    TYPE STATE_TYPE IS (idle, start_ntt, ntt_process, pointwise_mult, intt_process, iphi_mult, output);
    SIGNAL state   : STATE_TYPE;
begin

    fsm : process(clk, reset)
    begin
        if(reset = '1') then
            state <= idle;
        elsif(rising_edge(clk)) then
            case state is
                when idle =>
                    if (start = '1') then
                        state <= start_ntt;
                    else 
                        state <= idle;
                    end if;
                when start_ntt =>
                    state <= ntt_process;
                when ntt_process =>
                    if (not(ntt1_valid and ntt2_valid)) = '1' then
                        state <= ntt_process;
                    else
                        state <= pointwise_mult;
                    end if;
                when pointwise_mult =>
                    state <= intt_process;
                when intt_process =>
                    if (intt_valid = '0') then
                        state <= intt_process;
                    else
                        state <= iphi_mult;
                    end if;
                when iphi_mult =>
                    state <= output;
                when output =>
                    state <= idle;
            end case;   
        end if;
    end process;
    
    combinational: process(state)
    begin
        case state is 
            when idle =>
                ntt1_rst    <= '0';
                ntt2_rst    <= '0';
                ntt1_start  <= '0';
                ntt2_start  <= '0';
                intt_rst    <= '0';
                intt_start  <= '0';
                valid       <= '0';
            when start_ntt =>
                ntt1_rst    <= '1';
                ntt2_rst    <= '1';
                ntt1_start  <= '0';
                ntt2_start  <= '0';
                intt_rst    <= '0';
                intt_start  <= '0';
                valid       <= '0';
            when ntt_process =>
                ntt1_rst    <= '0';
                ntt2_rst    <= '0';
                ntt1_start  <= '1';
                ntt2_start  <= '1';
                intt_rst    <= '0';
                intt_start  <= '0';
                valid       <= '0';
            when pointwise_mult =>
                ntt1_rst    <= '0';
                ntt2_rst    <= '0';
                ntt1_start  <= '0';
                ntt2_start  <= '0';
                intt_rst    <= '1';
                intt_start  <= '0';
                valid       <= '0';
            when intt_process =>
                ntt1_rst    <= '0';
                ntt2_rst    <= '0';
                ntt1_start  <= '0';
                ntt2_start  <= '0';
                intt_rst    <= '0';
                intt_start  <= '1';
                valid       <= '0';
            when iphi_mult =>
                ntt1_rst    <= '0';
                ntt2_rst    <= '0';
                ntt1_start  <= '0';
                ntt2_start  <= '0';
                intt_rst    <= '0';
                intt_start  <= '0';
                valid       <= '0';
            when output =>
                ntt1_rst    <= '0';
                ntt2_rst    <= '0';
                ntt1_start  <= '0';
                ntt2_start  <= '0';
                intt_rst    <= '0';
                intt_start  <= '0';
                valid       <= '1';
        end case;
    end process;


end Behavioral;
