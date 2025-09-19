-- -----------------------------------------------------------------------------
--
--  Title      :  FSMD implementation of GCD
--             :
--  Developers :  Jens Sparsø, Rasmus Bo Sørensen and Mathias Møller Bruhn
--           :
--  Purpose    :  This is a FSMD (finite state machine with datapath) 
--             :  implementation the GCD circuit
--             :
--  Revision   :  02203 fall 2019 v.5.0
--
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
  port (clk : in std_logic;             -- The clock signal.
    reset : in  std_logic;              -- Reset the module.
    req   : in  std_logic;              -- Input operand / start computation.
    AB    : in  unsigned(15 downto 0);  -- The two operands.
    ack   : out std_logic;              -- Computation is complete.
    C     : out unsigned(15 downto 0)); -- The result.
end gcd;

architecture fsmd of gcd is

  type state_type is (idle, state2, state3, state4, state5, state6, state7, state8 ); -- Input your own state names

  signal reg_a, next_reg_a, next_reg_b, reg_b : unsigned(15 downto 0);

  signal state, next_state : state_type;


begin

  -- Combinatoriel logic

  cl : process (req,ab,state,reg_a,reg_b,reset)
  begin
    ack <= '0';
    C <= (others=>'Z');
    next_reg_a <= reg_a;
    next_reg_b <= reg_b;
    
    
    case (state) is
        when idle =>
            ack <= '0';
            
            if req='1' then
                next_state <= state2;
            else
                next_state <= idle;
            end if;
        when state2 =>
            ack <= '1';
            next_reg_a <= AB;
            
            if req='0' then
                next_state <= state3;
            else
                next_state <= state2;
            end if;
        when state3 =>
            
            ack <= '0';
            if req='1' then
                next_state <= state4;
            else
                next_state <= state3;
            end if;
        when state4 =>
            next_reg_b <= AB;
            
            next_state <= state5;
        when state5 =>
            
            if reg_a = reg_b then
                next_state <= state8;
            elsif reg_a > reg_b then
                next_state <= state7;
            else 
                next_state <= state6;
            end if;
        when state6 =>
            next_reg_b <= reg_b-reg_a;
            next_state <= state5;
        when state7 =>
            
            next_reg_a <= reg_a-reg_b;
            next_state <= state5;
        
        when state8 =>
            C <= reg_a;
            ack <= '1';
            if req = '0' then
                next_state <= idle;
            else
                next_state <= state8;
            end if;
        when others  =>
            next_state <= idle;
    end case;
  end process cl;

  -- Registers

  seq : process (clk)
  begin
    
    if (rising_edge(clk)) then
        if (reset='1') then
            state <= idle;
            reg_a <= (others=>'0');
            reg_b <= (others=>'0');
        else
            state <= next_state;
            reg_a <= next_reg_a;
            reg_b <= next_reg_b;
        end if;
    end if;

  end process seq;


end fsmd;
