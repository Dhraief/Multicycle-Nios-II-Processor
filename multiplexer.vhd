library ieee;
use ieee.std_logic_1164.all;

entity multiplexer is
    port(
        i0  : in  std_logic_vector(31 downto 0);
        i1  : in  std_logic_vector(31 downto 0);
        i2  : in  std_logic_vector(31 downto 0);
        i3  : in  std_logic_vector(31 downto 0);
        sel : in  std_logic_vector(1 downto 0);
        o   : out std_logic_vector(31 downto 0)
    );
end multiplexer;

architecture synth of multiplexer is
begin
mux : process(i0, i1, i2, i3, sel) is
begin
if(sel = "00") then o <= i0;
elsif(sel = "01") then o <= i1;
elsif(sel = "10") then o <= i2;
else o <= i3;
end if;
end process mux;
end synth;
