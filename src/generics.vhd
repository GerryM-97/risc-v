library ieee;
use ieee.std_logic_1164.all;

package generics is
	constant nbit :  integer := 32;
	constant opcode_len : integer := 7;
	constant alu_func_len : integer := 3;
	constant rf_len : integer := 32;
	constant reg_len : integer := 5;

	constant cword_exe_len : integer := 6; --first bit is for exe stage mux selection
	constant cword_mem_len : integer := 4; -- 2 bits are for mem wr_enable and rd_nwrite ctrl signals
	constant cword_wrb_len : integer := 2; -- first bit is for mux selection, second bit is for wr_en of register file

	constant reset_pc : std_logic_vector(nbit -1 downto 0) := (others => '1'); --pc value at reset
	constant first_instruction : std_logic_vector(nbit -1 downto 0) := (others => '0'); --first instruction of the program
	constant NOP_instr : std_logic_vector(nbit-1 downto 0) := (31 downto 7 => '0') & "0010011";  --NOP instruction encoding
	


	type operation is (ADD, ADDI, AUIPC, LUI, BEQ, LW, SRAI, ANDI, XOR_T, SLT, JAL, SW, NOP);  
	type instruction_format is (R_type, I_type, B_type, S_type, J_type, U_type);
	type register_file_array is array (0 to 31) of std_logic_vector(nbit-1 downto 0);  --dimension of register file
	
	subtype address is std_logic_vector(nbit-1 downto 0);
	subtype register_address is std_logic_vector(4 downto 0);
	subtype instruction is std_logic_vector(nbit-1 downto 0);
	subtype data is std_logic_vector(nbit-1 downto 0);

end package;
