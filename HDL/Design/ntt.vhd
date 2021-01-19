library IEEE;
library work;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.my_types.all;

entity ntt is
  Port (clk     : in std_logic;
        reset   : in std_logic;
        input   : in coefficient_t;
        write   : in std_logic;
        index   : in index_t;
        start   : in std_logic;
        output  : out coefficient_t;
        valid   : out std_logic);
end ntt;

architecture Behavioral of ntt is

type ntt_state_type IS (idle, stages_loop, inner_loop, condition, math_operation, done);

----------------------------DATA TO MANIPULATE-----------------------------
signal input_reversed       :   port_t;
signal x                    :   port_t;
---------------------------------------------------------------------------


--------------------------------FSM SIGNALS--------------------------------
signal ntt_state            :   ntt_state_type        := idle;
signal stage_index          :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal inner_loop_index     :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal prev_inner_loop_index:   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal expression           :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal stage_shifted        :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
---------------------------------------------------------------------------

--------------------------POTENTIAL MATH SIGNALS---------------------------
signal potential_k          :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
---------------------------------------------------------------------------

-------------------------------MATH SIGNALS--------------------------------
signal w                    :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal i_corr               :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal prev_i_corr          :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal y_i                  :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal y_i_corr             :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal k                    :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal butterfly_output_i   :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal butterfly_output_i_corr :    unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
---------------------------------------------------------------------------

-------------------------------TEMP SIGNALS--------------------------------
signal temp_k               :   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal temp_butterfly_input1:   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
signal temp_butterfly_input2:   unsigned(BIT_WIDTH-1 downto 0) := to_unsigned(0, BIT_WIDTH);
---------------------------------------------------------------------------

component ROM_twiddle_factors is
    Port ( k : in unsigned (BIT_WIDTH-1 downto 0);
           w : out unsigned (BIT_WIDTH-1 downto 0));
end component;

component shifter is
    Port ( n        : in unsigned (BIT_WIDTH-1 downto 0);
           shift_by : in unsigned (BIT_WIDTH-1 downto 0);
           output   : out unsigned (BIT_WIDTH-1 downto 0));
end component;

component butterfly_math is
    Port ( x_i      :   in  unsigned (BIT_WIDTH-1 downto 0);
           x_i_corr :   in  unsigned (BIT_WIDTH-1 downto 0);
           w        :   in  unsigned (BIT_WIDTH-1 downto 0);
           y_i      :   out unsigned (BIT_WIDTH-1 downto 0);
           y_i_corr :   out unsigned (BIT_WIDTH-1 downto 0)
          );
end component;

component input_index_reversal is
  Port (
        input   : in port_t;
        output  : out port_t
       );
end component;

signal input_buffer     : port_t := (others => (others => '0'));
signal output_buffer    : port_t := (others => (others => '0'));

begin
    input_buffer_process : process(clk)
    begin
        if rising_edge(clk) then
            if write = '1' then
                input_buffer(to_integer(index)) <= input;
            end if;
        end if;
    end process;
    
    output_buffer_process : process(clk)
    begin
        if rising_edge(clk) then
            output <= output_buffer(to_integer(index));
        end if;
    end process;

    input_index_flipping:input_index_reversal
    port map (
        input => input_buffer,
        output => input_reversed
    );

    W_ROM : ROM_twiddle_factors
    port map(
        k => k,
        w => w
    );
        
    --------------- COMBINATIONAL RELATIONSHIP BETWEEN I AND I_CORR ---------------
    i_corr <= inner_loop_index xor stage_shifted;
    -------------------------------------------------------------------------------
    
    -------------------- TEMPORARY SIGNAL FOR BUTTERFLY INPUT ---------------------
    temp_butterfly_input1 <= x(to_integer(inner_loop_index(NUM_STAGES-1 downto 0)));
    temp_butterfly_input2 <= x(to_integer(i_corr(NUM_STAGES-1 downto 0)));
    -------------------------------------------------------------------------------
    
    butterfly : butterfly_math
    port map (
        x_i         => temp_butterfly_input1,
        x_i_corr    => temp_butterfly_input2,
        w           => w,
        y_i         => butterfly_output_i,
        y_i_corr    => butterfly_output_i_corr
    );

    -- have to subtract stage index due to it being 1 more than the actual value 
    temp_k <= k + shift_right(to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH), to_integer(stage_index) + 1 - 1);
    potential_k((NUM_STAGES-2) downto 0) <= temp_k((NUM_STAGES - 2) downto 0);

    shifter_for_condition : shifter
        port map (  n => to_unsigned(1, BIT_WIDTH),
                    shift_by => stage_index,
                    output => stage_shifted);

    fsm : process(reset, clk)
    begin
        if (reset = '1') then
            ntt_state <= idle;
            
        elsif (rising_edge(clk)) then
            if (ntt_state = idle) then
                if (start = '1') then
                    ntt_state <= stages_loop;
                else
                    ntt_state <= idle;
                end if;

            elsif (ntt_state = stages_loop) then
                if (stage_index >= NUM_STAGES) then
                    ntt_state <= done;

                else 
                    ntt_state <= inner_loop;
                end if;
            
            elsif (ntt_state = inner_loop) then
                if (inner_loop_index >= to_unsigned(POLYNOMIAL_LENGTH, BIT_WIDTH)) then
                    ntt_state <= stages_loop;
                
                else
                    ntt_state <= condition;
                end if;
            
            elsif (ntt_state = condition) then
                if (expression = 0) then
                    ntt_state <= math_operation;
                
                else
                    ntt_state <= inner_loop;
                end if;
            
            elsif (ntt_state = math_operation) then
                ntt_state <= inner_loop;
                
            else
                ntt_state <= idle;
            
            end if;
            
        end if;
        
        if (rising_edge(clk)) then
            case ntt_state is
                when idle =>
                    valid               <= '0';
                    x                   <= input_reversed;
                    stage_index         <= (others => '0');
                    inner_loop_index    <= (others => '0');
                    k                   <= (others => '0');                    

                when stages_loop =>
                    valid               <= '0';
                    stage_index         <= to_unsigned(to_integer(stage_index) + 1, BIT_WIDTH);
                    inner_loop_index    <= (others => '0');
                    k                   <= (others => '0');

                when inner_loop =>
                    expression          <= stage_shifted and inner_loop_index;

                when condition =>
                    valid               <= '0';
                    inner_loop_index    <= to_unsigned(to_integer(inner_loop_index) + 1, BIT_WIDTH);
                    y_i                 <= butterfly_output_i;
                    y_i_corr            <= butterfly_output_i_corr;
                    prev_inner_loop_index <= inner_loop_index;
                    prev_i_corr <= i_corr;
                when math_operation =>
                    valid               <= '0';
                    x(to_integer(prev_inner_loop_index))    <= y_i;
                    x(to_integer(prev_i_corr))              <= y_i_corr;
                    k                                       <= potential_k;
                when done =>
                    output_buffer <= x;
                    valid <= '1';
                    
                when others =>
                    valid               <= '0';
                    inner_loop_index    <= inner_loop_index;
                    stage_index         <= stage_index;
            end case;
        end if;
        
    end process;
    
end Behavioral;
