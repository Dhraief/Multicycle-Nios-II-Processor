library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is

SIGNAL res33Bits : std_logic_vector(32 downto 0);
SIGNAL BValue : std_logic_vector(31 downto 0);
SIGNAL RES : std_logic_vector(31 downto 0 );
SIGNAL SubSignal : std_logic_vector(32 downto 0);

begin

zero <= '1' when RES = "00000000000000000000000000000000" else '0';
carry <= res33Bits(32);
RES <= res33Bits(31 downto 0);
r <= RES;
BValue <= b xor (31 downto 0 => sub_mode);
SubSignal <= "00000000000000000000000000000000" & sub_mode;
res33Bits <= std_logic_vector(unsigned('0' & a) + unsigned('0' & BValue) + 
             unsigned(SubSignal));

end synth;

