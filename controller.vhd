library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
          --instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
          --activates branch condition
        branch_op  : out std_logic;
          --immediate value sign extention
        imm_signed : out std_logic;
          --instruction register enable
        ir_en      : out std_logic;
          --PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
          --register file enable
        rf_wren    : out std_logic;
          --multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
          --write memory output
        read       : out std_logic;
        write      : out std_logic;
          --alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is
Type state_type is (Fetch1, Fetch2, Decode, R_OP, I_OP, LOAD1, LOAD2, STORE, BREAK, BRANCH, CALL, CALLR, JMP, JMPI, UNSIGNED_I, IMM_R);
signal state, next_state : state_type;

BEGIN
state_proc : process (clk, reset_n) is
begin
if(reset_n = '0') then 
  state <= Fetch1;
elsif(rising_edge(clk)) then
  state <= next_state;
end if;
end process state_proc;

comb_proc: process(state, opx, op) is
begin
next_state <= state;
  case state is
   when Fetch1 => 
	 --initialize used
	     write <= '0';
        imm_signed <= '0';
        ir_en    <= '0';
        pc_en   <='0';
        rf_wren   <='0';
        sel_addr  <='0';
        sel_b   <='0';
        sel_mem <='0';
        sel_rC <= '0';
  	 --initialize unused
  	     branch_op <= '0';
  		  pc_add_imm <= '0';
  		  pc_sel_a <= '0';
  		  pc_sel_imm <= '0';
  		  sel_pc <= '0';
  		  sel_ra <= '0';
  		
  	 --end initialize
	   read <= '1';
      next_state <= Fetch2;
   
   when Fetch2 =>
	   read <= '0';
	   ir_en <= '1';
	   pc_en <= '1';
      next_state <= Decode;
	
	when Decode =>
	   pc_en <= '0';
		read <= '0';
		ir_en <= '0';

	
	   if ("00" & opx = x"34") and ("00" & op = x"3A")  then
      next_state <= Break;
		elsif (("00" & opx = x"05") or ("00" & opx = x"0D")) and ("00" & op = x"3A") then
		next_state <= JMP;
		elsif (("00" & opx = x"12") or ("00" & opx = x"1A") or ("00" & opx = x"3A") or ("00" & opx = x"02"))
		      and ("00" & op = x"3A") then
		next_state <= IMM_R;
		elsif "00" & op = x"15" then
		next_state <= Store;
		elsif ("00" & opx = x"1D") and ("00" & op = x"3A") then
		next_state <= CALLR;
		elsif "00" & op = x"3A" then
		next_state <= R_OP;
		elsif "00" & op = x"17" then
		next_state <= Load1;
		elsif "00" & op = x"06" or ("00" & op = x"0E")
                              or ("00" & op = x"16")
                              or ("00" & op = x"1E")
                              or ("00" & op = x"26")
                              or ("00" & op = x"2E")
                              or ("00" & op = x"36") then
		next_state <= BRANCH;
	   elsif "00" & op = x"00" then
	   next_state <= CALL;
		elsif "00" & op = x"01" then 
		next_state <= JMPI;
		elsif ("00" & op = x"0C") or ("00" & op = x"14") or ("00" & op = x"1C")
		       or ("00" & op = x"28")
				 or ("00" & op = x"30") then
		next_state <= UNSIGNED_I;
		
		else 
		next_state <= I_OP;
		end if;
	
	when R_OP =>
	   imm_signed <= '0';
	   read <= '0';
	   pc_en <= '0';
		ir_en <= '0';
	   rf_wren <= '1';
		sel_b <= '1';
		sel_rC <= '1';
      next_state <= Fetch1;
	when IMM_R =>
	   imm_signed <= '0';
	   read <= '0';
	   pc_en <= '0';
		ir_en <= '0';
	   rf_wren <= '1';
		sel_b <= '0';
		sel_rC <= '1';
      next_state <= Fetch1;
	
	when Store =>
	   sel_b <= '0';
		rf_wren<='0';
		sel_mem <='0';
		sel_rC<='0';
		read<='0';
		ir_en<='0';
		imm_signed<='1';
		sel_addr <= '1';
	   write <= '1';
      next_state <= Fetch1;
		
	when Break =>
      next_state <= Break;
		
	when Load1 =>
	   rf_wren<='0';
		sel_b<='0';
		pc_en<='0';
		sel_rC<='0';
		ir_en<='0';
		imm_signed<='1';
	   read <= '1';
	   sel_addr <= '1';
		next_state <= Load2;
		
	when Load2 =>
	   
		sel_addr<='0';
		sel_b<='0';
		pc_en<='0';
		sel_rC<='0';
		read<='0';
		imm_signed<='0';
		ir_en<='0';
	   rf_wren <= '1';
		sel_mem <= '1';
      next_state <= Fetch1;
		
	when I_OP =>
	   read <= '0';
		pc_en <= '0';
		ir_en <= '0';
	   imm_signed <= '1';
		rf_wren <= '1';
      next_state <= Fetch1;
	when UNSIGNED_I =>
      read <= '0';
      pc_en <= '0';
      ir_en <= '0';
      imm_signed <= '0';
      rf_wren <= '1';
      next_state <= Fetch1;
	
	when BRANCH => 
	   ir_en <= '0';
		imm_signed <= '0';
		write <= '0';
		read <= '0';
		sel_rC <= '0';
		pc_add_imm <= '1';
		pc_en <= '0';
		sel_mem <= '0';
		sel_b <= '1';
		sel_addr <= '0';
		rf_wren <= '0';
		branch_op <= '1';
	   next_state <= Fetch1;
		
	when CALL =>
	   ir_en <= '0';
		imm_signed <= '0';
		write <= '0';
		read <= '0';
		sel_rC <= '0';
		sel_ra <= '1';
		sel_pc <= '1';
		pc_add_imm <= '0';
		pc_sel_imm <= '1';
		pc_en <= '1';
		sel_mem <= '0';
		sel_b <= '0';
		sel_addr <= '0';
		rf_wren <= '1';
		branch_op <= '0';
		next_state <= Fetch1;
	when CALLR =>
	   ir_en <= '0';
		imm_signed <= '0';
		write <= '0';
		read <= '0';
		sel_rC <= '0';
		sel_ra <= '1';
		sel_pc <= '1';
		pc_add_imm <= '0';
		pc_sel_imm <= '0';
		pc_sel_a <= '1';
		pc_en <= '1';
		sel_mem <= '0';
		sel_b <= '0';
		sel_addr <= '0';
		rf_wren <= '1';
		branch_op <= '0';
		next_state <= Fetch1;
	when JMP =>
	   ir_en <= '0';
		imm_signed <= '0';
		write <= '0';
		read <= '0';
		sel_rC <= '0';
		sel_ra <= '0';
		sel_pc <= '0';
		pc_add_imm <= '0';
		pc_sel_imm <= '0';
		pc_sel_a <= '1';
		pc_en <= '1';
		sel_mem <= '0';
		sel_b <= '0';
		sel_addr <= '0';
		rf_wren <= '0';
		branch_op <= '0';
		next_state <= Fetch1;
	when JMPI =>
	   ir_en <= '0';
		imm_signed <= '0';
		write <= '0';
		read <= '0';
		sel_rC <= '0';
		sel_ra <= '0';
		sel_pc <= '0';
		pc_add_imm <= '0';
		pc_sel_imm <= '1';
		pc_sel_a <= '0';
		pc_en <= '1';
		sel_mem <= '0';
		sel_b <= '0';
		sel_addr <= '0';
		rf_wren <= '0';
		branch_op <= '0';
		next_state <= Fetch1;
	
		
  end case;
end process comb_proc;

opProc : process (op , opx) is
begin
--R-Types
if ("00" & op = x"3A") and ("00" & opx = x"0E") then 
 op_alu <= "100001";  --2 in the middle don't care
elsif ("00" & op = x"3A") and ("00" & opx = x"1B") then
 op_alu <= "110011";  
elsif ("00" & op = x"3A") and ("00" & opx = x"31") then
 op_alu <= "000000";
elsif ("00" & op = x"3A") and ("00" & opx = x"39") then
 op_alu <= "001000"; 
elsif ("00" & op = x"3A") and ("00" & opx = x"08") then
 op_alu <= "011001";  
elsif ("00" & op = x"3A") and ("00" & opx = x"10") then
 op_alu <= "011010"; 
elsif ("00" & op = x"3A") and ("00" & opx = x"06") then
 op_alu <= "100000";
elsif ("00" & op = x"3A") and ("00" & opx = x"16") then
 op_alu <= "100010";
elsif ("00" & op = x"3A") and ("00" & opx = x"1E") then
 op_alu <= "100011";
elsif ("00" & op = x"3A") and ("00" & opx = x"13") then
 op_alu <= "110010";
elsif ("00" & op = x"3A") and ("00" & opx = x"3B") then
 op_alu <= "111111";
elsif ("00" & op = x"3A") and ("00" & opx = x"12") then
 op_alu <= "110010";
elsif ("00" & op = x"3A") and ("00" & opx = x"1A") then
 op_alu <= "110011";
elsif ("00" & op = x"3A") and ("00" & opx = x"3A") then
 op_alu <= "111111";
elsif ("00" & op = x"3A") and ("00" & opx = x"18") then
 op_alu <= "011011";
elsif ("00" & op = x"3A") and ("00" & opx = x"20") then
 op_alu <= "011100";
elsif ("00" & op = x"3A") and ("00" & opx = x"28") then
 op_alu <= "011101";
elsif ("00" & op = x"3A") and ("00" & opx = x"30") then
 op_alu <= "011110";
elsif ("00" & op = x"3A") and ("00" & opx = x"03") then
 op_alu <= "111000";
elsif ("00" & op = x"3A") and ("00" & opx = x"0B") then
 op_alu <= "110001";
elsif ("00" & op = x"3A") and ("00" & opx = x"02") then
 op_alu <= "111000";



 
 
 
--Not R-Types
elsif "00" & op = x"04" then
 op_alu <= "000000";  --3 don't cares
elsif "00" & op = x"17" then
 op_alu <= "000000";  --3 don't cares
elsif "00" & op = x"15" then
 op_alu <= "000000";  --3 don't cares
elsif "00" & op = x"0E" then
 op_alu <= "011001";   --0 don't care
elsif "00" & op = x"16" then 
 op_alu <= "011010";    -- 0 don't care
elsif "00" & op = x"1E" then
 op_alu <= "011011"; --0 don't care
elsif "00" & op = x"26" then
 op_alu <= "011100"; --0 don't care
elsif "00" & op = x"2E" then 
 op_alu <= "011101"; -- 0 don't care
elsif "00" & op = x"36" then
 op_alu <= "011110"; -- 0 don't care
elsif "00" & op = x"06" then     ---UNCONDITIONAL BRANCH
 op_alu <= "011100"; -- 0 don't care
elsif "00" & op = x"0C" then
 op_alu <= "100001"; -- 0 don't care
elsif "00" & op = x"14" then
 op_alu <= "100010"; -- 0 don't care
elsif "00" & op = x"1C" then
 op_alu <= "100011"; -- 0 don't care
elsif "00" & op = x"08" then
 op_alu <= "011001"; -- 0 don't care
elsif "00" & op = x"10" then
 op_alu <= "011010"; -- 0 don't care
elsif "00" & op = x"18" then
 op_alu <= "011011"; -- 0 don't care
elsif "00" & op = x"20" then
 op_alu <= "011100" ; -- 0 don't care
elsif "00" & op = x"28" then
 op_alu <= "011101" ; -- 0 don't care
elsif "00" & op = x"30" then
 op_alu <= "011110" ; -- 0 don't care

end if;
 
end process opProc;


end synth;