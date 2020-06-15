library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

package my_types is 
    function log2 (x : positive) return natural;
    constant BIT_WIDTH : integer := 64;
    constant POLYNOMIAL_LENGTH : integer := 256;
    type port_t is array(POLYNOMIAL_LENGTH-1 downto 0) of unsigned(BIT_WIDTH-1 downto 0);
    type double_port_t is array(POLYNOMIAL_LENGTH-1 downto 0) of unsigned(2*BIT_WIDTH-1 downto 0);
    constant NUM_STAGES : natural := log2(POLYNOMIAL_LENGTH);
    constant NUM_STAGES_INV : natural := 1044991;
    constant MODULO : natural := 1049089;
    constant BARRET_REDUCTION_CONSTANT : unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(4192253, BIT_WIDTH);
    constant BARRET_REDUCTION_K : unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(21, BIT_WIDTH);
    impure function read_mem_file(FileName : STRING) return port_t;
    impure function initialize_q_2_ROM return port_t;
end package;

package body my_types is
    function log2 (x : positive) return natural is
    variable i : natural;
    begin
        i := 0;  
        while (2**i < x) and i < 31 loop
         i := i + 1;
        end loop;
        return i;
    end function;
    
    
    -- Read a *.hex file
    impure function read_mem_file(FileName : STRING) return port_t is
        file file_handle       : TEXT open READ_MODE is FileName;
        variable current_line  : LINE;
        variable result      : port_t    := (others => (others => '0'));
    
    begin
        for i in 0 to POLYNOMIAL_LENGTH - 1 loop
            exit when endfile(file_handle);
            readline(file_handle, current_line);
            hread(current_line, result(i));
        end loop;
       
        return result;
    end function;
    
    impure function initialize_q_2_ROM return port_t is
        variable result      : port_t    := (others => (others => '0'));
    begin
        for i in 0 to POLYNOMIAL_LENGTH - 1 loop
            if i = 0 then
                result(i) := to_unsigned(MODULO/2, BIT_WIDTH);
            else
                result(i) := to_unsigned(0, BIT_WIDTH);
            end if;
        end loop;
       
        return result;
    end function;
end my_types;
