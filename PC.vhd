library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic; -- for exo 1 use this
        reset_n : in  std_logic; -- for exo 1 use this
        en      : in  std_logic; -- for exo 1 use this
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0) -- for exo 1 use this
    );
end PC;

architecture synth of PC is
signal s_addrFour, s_ResAddImm, s_current , s_next: std_logic_vector(31 downto 0);

begin

proc: process(clk, reset_n) is
begin
if(reset_n ='0') then
  s_current <= (others => '0');
elsif(rising_edge(clk)) then
  s_current <= s_next;
end if;
end process proc;

   s_ResAddImm <= std_logic_vector(signed(s_current) + signed(imm));
	s_addrFour <= std_logic_vector(signed(s_current) + 4);

   s_next <= ("0000000000000000" & (s_ResAddImm(15 downto 2) & "00"))  when (en ='1' and add_imm='1') else

             ("0000000000000000" & (imm(13 downto 0) & "00"))          when (en ='1' and sel_imm= '1') else 
			  
			    ("0000000000000000" & (a(15 downto 2) & "00"))            when (en ='1' and sel_a= '1') else  
			  
		       ("0000000000000000" & s_addrFour(15 downto 0))            when (en ='1') else 
			  
			    s_current                                                 when (en ='0');
			  
--pour a verifier les 2 derniers bits a 0 
--pour std_logic_vector(signed(s_current) + signed(imm)) verifier 16 bits de poids lourd et 2 bits a droite 0
--pour imm verifier 2 bits de poids lourd a 0 

addr <= s_current;

end synth;