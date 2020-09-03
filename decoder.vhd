library ieee;
use ieee.std_logic_1164.all;

entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
		  cs_buttons : out std_logic
    );
end decoder;

architecture synth of decoder is
signal s1: std_logic_vector(15 downto 0);
signal s2: std_logic_vector(15 downto 0);
begin
s1 <= x"0000";
s2 <= x"0FFC";
activate: process(address) is
begin
if(address >= s1 and address <= s2) then
 cs_ROM <= '1';
 cs_RAM <= '0';
 cs_LEDS <= '0';
 cs_buttons <= '0';

elsif(address >= x"1000" and address <= x"1FFC") then
 cs_RAM <= '1';
 cs_LEDS <= '0';
 cs_ROM <= '0';
 cs_buttons <= '0';

elsif(address >= x"2000" and address<= x"200C") then
 cs_LEDS <= '1'; 
 cs_RAM <= '0';
 cs_ROM <= '0';
 cs_buttons <= '0';
elsif(address >= x"2030" and address<= x"2034") then
 cs_buttons <= '1';
 cs_LEDS <= '0'; 
 cs_RAM <= '0';
 cs_ROM <= '0';
else 
 cs_LEDS <= '0'; 
 cs_RAM <= '0';
 cs_ROM <= '0';
 cs_buttons <= '0';
end if;

end process activate;

end synth;
