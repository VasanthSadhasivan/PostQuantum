----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/30/2022 04:46:32 PM
-- Design Name: 
-- Module Name: polyreduce - Behavioral
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

entity polyreduce is
    Port ( clk : in STD_LOGIC;
           poly_1 : in coefficient_t;
           poly_2 : in coefficient_t;
           write_index : in index_t;
           write : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           read_index : in index_t;
           output : out coefficient_t;
           done : out STD_LOGIC);
end polyreduce;

architecture Behavioral of polyreduce is

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

component buff is
    Port ( clk          : in STD_LOGIC;
           write        : in STD_LOGIC;
           write_index  : in index_t;
           read_index   : in index_t;
           input        : in coefficient_t; 
           output       : out coefficient_t);
end component;

component pointwise_mult is
    Port ( clk : in STD_LOGIC;
           poly_0 : in coefficient_t;
           poly_1 : in coefficient_t;
           output : out coefficient_t);
end component;

component polyreduce_control_unit is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           reset : in STD_LOGIC;
           poly_1 : in coefficient_t;
           poly_2 : in coefficient_t;
           poly_1_order : in index_t;
           poly_2_order : in index_t;
           deg_delt : in index_t;
           poly_1_0th_output : in coefficient_t;
           poly_1_input_sel : out std_logic;
           poly_1_write_index : out index_t;
           poly_1_write_index_sel : out std_logic;
           poly_1_write_sel : out std_logic;
           poly_1_write : out std_logic;
           poly_1_read_index_sel : out std_logic;
           poly_1_read_index : out index_t;
           poly_2_read_index : out index_t;
           ttr_input_sel : out std_logic_vector(1 downto 0);
           ttr_write_index : out index_t;
           ttr_write : out std_logic;
           ttr_read_index : out index_t;
           poly_1_order_write : out std_logic;
           poly_2_order_write : out std_logic;
           modinv_start : out std_logic;
           modinv_reset : out std_logic;
           modinv_done : in std_logic;
           modinv_buff_write : out std_logic;
           done : out STD_LOGIC
    );
end component;

signal poly_1_input_sel : std_logic;
signal poly_1_write_index : index_t;
signal poly_1_write_index_final : index_t;
signal poly_1_write_index_sel : std_logic;
signal poly_1_write_sel : std_logic;
signal poly_1_write : std_logic;
signal poly_1_write_final : std_logic;
signal poly_1_read_index_sel : std_logic;
signal poly_1_read_index : index_t;
signal poly_1_read_index_final : index_t;
signal poly_2_read_index : index_t;
signal ttr_input_sel : std_logic_vector(1 downto 0);
signal ttr_write_index : index_t;
signal ttr_write : std_logic;
signal ttr_read_index : index_t;
signal ttr_input : coefficient_t;
signal poly_1_order_write : std_logic;
signal poly_2_order_write : std_logic;
signal modinv_start : std_logic;
signal modinv_reset : std_logic;
signal modinv_done : std_logic;
signal modinv_buff_write : std_logic;

signal poly_1_input : coefficient_t;
signal poly_2_sub_ttr : coefficient_t;
signal poly_1_output : coefficient_t;
signal poly_1_0th_output : coefficient_t;
signal poly_2_output : coefficient_t;
signal ttr_output : coefficient_t;
signal poly_1_order_output : index_t;
signal poly_2_order_output : index_t;
signal deg_delt : index_t;
signal poly_1_sub_ttr : coefficient_t;
signal poly_1_sub_ttr_mod : coefficient_t;
signal ttr_mult_poly_1 : coefficient_t;
signal ttr_mult_modinv : coefficient_t;
signal modinv_buff_output : coefficient_t;
signal modinv_output : coefficient_t;

signal max          : double_coefficient_t := (others => '1');

begin
    max <= (others => '1');
    
    deg_delt <= poly_1_order_output - poly_2_order_output;
    poly_1_sub_ttr <= poly_1_output - ttr_output;
    output <= poly_1_output; 
    
    poly_1_sub_ttr_mod_driver: process(poly_1_sub_ttr, max)
    begin
        if signed(poly_1_sub_ttr) < 0 then
            poly_1_sub_ttr_mod <= to_unsigned(MODULO - to_integer((max + 1 - poly_1_sub_ttr)), BIT_WIDTH);
        else
            poly_1_sub_ttr_mod <= poly_1_sub_ttr;
        end if;
    end process;

    poly_1_buff_component: buff
    port map (
        clk         => clk,
        write       => poly_1_write_final,
        write_index => poly_1_write_index_final,
        read_index  => poly_1_read_index_final,
        input       => poly_1_input,
        output      => poly_1_output
    );

    poly_2_buff_component: buff
    port map (
        clk         => clk,
        write       => write,
        write_index => write_index,
        read_index  => poly_2_read_index,
        input       => poly_2,
        output      => poly_2_output
    );

    ttr_buff_component: buff
    port map (
        clk         => clk,
        write       => ttr_write,
        write_index => ttr_write_index,
        read_index  => ttr_read_index,
        input       => ttr_input,
        output      => ttr_output
    );
    
    modinv_component: modinv 
    port map(
        clk     => clk          ,
        a       => poly_2_output,
        start   => modinv_start ,
        reset   => modinv_reset ,
        output  => modinv_output,
        done    => modinv_done  ,
        error   => open
    );
    
    poly_1_order : process(clk)
    begin
        if rising_edge(clk) then
            if poly_1_order_write = '1' then
                poly_1_order_output <= poly_1_read_index_final + 1;
            end if;
        end if;
    end process;
    
    poly_2_order : process(clk)
    begin
        if rising_edge(clk) then
            if poly_2_order_write = '1' then
                poly_2_order_output <= poly_2_read_index + 1;
            end if;
        end if;
    end process;
    
    ttr_mult_poly_1_block : pointwise_mult
    port map (
        clk     => clk,
        poly_0  => ttr_output,
        poly_1  => poly_1_output,
        output  => ttr_mult_poly_1
    );
   
    ttr_mult_modinv_block : pointwise_mult
    port map (
        clk     => clk,
        poly_0  => ttr_output,
        poly_1  => modinv_buff_output,
        output  => ttr_mult_modinv
    );
    
    cu: polyreduce_control_unit
    port map (
        clk                     =>  clk                   ,
        start                   =>  start                 ,
        reset                   =>  reset                 ,
        poly_1                  =>  poly_1_output         ,
        poly_2                  =>  poly_2_output         ,
        poly_1_order            =>  poly_1_order_output   ,
        poly_2_order            =>  poly_2_order_output   ,
        poly_1_0th_output       =>  poly_1_0th_output     ,
        deg_delt                =>  deg_delt              ,
        poly_1_input_sel        =>  poly_1_input_sel      ,
        poly_1_write_index      =>  poly_1_write_index    ,
        poly_1_write_index_sel  =>  poly_1_write_index_sel,
        poly_1_write_sel        =>  poly_1_write_sel      ,
        poly_1_write            =>  poly_1_write          ,
        poly_1_read_index_sel   =>  poly_1_read_index_sel ,
        poly_1_read_index       =>  poly_1_read_index     ,
        poly_2_read_index       =>  poly_2_read_index     ,
        ttr_input_sel           =>  ttr_input_sel         ,
        ttr_write_index         =>  ttr_write_index       ,
        ttr_write               =>  ttr_write             ,
        ttr_read_index          =>  ttr_read_index        ,
        poly_1_order_write      =>  poly_1_order_write    ,
        poly_2_order_write      =>  poly_2_order_write    ,
        modinv_start            =>  modinv_start          ,
        modinv_reset            =>  modinv_reset          ,
        modinv_done             =>  modinv_done           ,
        modinv_buff_write       =>  modinv_buff_write     ,
        done                    =>  done                  
    );
    
    poly_1_input_mux : process(poly_1_input_sel, poly_1, poly_1_sub_ttr_mod)
    begin
        if poly_1_input_sel = '0' then
            poly_1_input <= poly_1_sub_ttr_mod;
        else 
            poly_1_input <= poly_1;
        end if;
    end process;
    
    poly_1_write_index_mux : process(write_index, poly_1_write_index, poly_1_write_index_sel)
    begin
        if poly_1_write_index_sel = '1' then
            poly_1_write_index_final <= write_index;
        else 
            poly_1_write_index_final <= poly_1_write_index;
        end if;
    end process;

    poly_1_write_mux : process(write, poly_1_write, poly_1_write_sel)
    begin
        if poly_1_write_sel = '1' then
            poly_1_write_final <= write;
        else 
            poly_1_write_final <= poly_1_write;
        end if;
    end process;
    
    poly_1_read_index_mux : process(poly_1_read_index, read_index, poly_1_read_index_sel)
    begin
        if poly_1_read_index_sel = '0' then
            poly_1_read_index_final <= poly_1_read_index;
        else 
            poly_1_read_index_final <= read_index;
        end if;
    end process;
    
    ttr_buff_input_mux : process(ttr_input_sel, poly_2_output, ttr_mult_modinv, ttr_mult_poly_1)
    begin
        if ttr_input_sel = "00" then
            ttr_input <= poly_2_output;
        elsif ttr_input_sel = "01" then
            ttr_input <= ttr_mult_modinv;
        elsif ttr_input_sel = "10" then
            ttr_input <= ttr_mult_poly_1;
        else
            ttr_input <= to_unsigned(0, BIT_WIDTH);
        end if;
    end process;
    
    poly_1_0th_output_driver : process(clk)
    begin
        if rising_edge(clk) then
            if poly_1_write_index_final = to_unsigned(0, INDEX_BIT_WIDTH) then
                poly_1_0th_output <= poly_1_input;
            end if;
        end if;
    end process;

    modinv_buff : process(clk)
    begin
        if rising_edge(clk) then
            if modinv_buff_write = '1' then
                modinv_buff_output <= modinv_output;
            end if;
        end if;
    end process;

end Behavioral;
