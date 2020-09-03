library ieee;
use ieee.std_logic_1164.all;

entity comparator is
    port(
        a_31    : in  std_logic;
        b_31    : in  std_logic;
        diff_31 : in  std_logic;
        carry   : in  std_logic;
        zero    : in  std_logic;
        op      : in  std_logic_vector(2 downto 0);
        r       : out std_logic
    );
end comparator;

architecture synth of comparator is
begin
--input op(2..0) type of comparison
--output R result 0 = false and 1 = true
--rest are used to perform the comparison
comp : process (a_31, b_31, diff_31, carry, zero, op) is
begin

if(op = "011") then
   r <= not zero;

elsif(op  = "101") then
   r <= (not carry) or zero;

elsif(op = "110") then
   r <= carry and (not zero);
elsif(op = "010") then 
   r <= ((not a_31) and b_31) or ((a_31 xnor b_31) and ((not diff_31) and (not zero)));
elsif(op = "001") then
   r <= (a_31 and (not b_31)) or ((a_31 xnor b_31) and (diff_31 or zero));
else r <= zero;
end if;
end process comp;
end synth;
