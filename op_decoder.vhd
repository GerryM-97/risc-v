library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity op_decoder is
port ( 
		instruction_in : in instruction;
		instruction_f : out instruction_format;
		op_decoded : out operation
		);
end entity;

architecture struct of op_decoder is

signal op_dec : operation;

begin

op_decoded <= op_dec;

op_dec <=   ADD 	when 		instruction_in(opcode_len-1 downto 0) = "0110011" and instruction_in(14 downto 12) = "000" 	else 	
				ADDI	when 		instruction_in(opcode_len-1 downto 0) = "0010011" and instruction_in(14 downto 12) = "000"	else
				AUIPC	when 		instruction_in(opcode_len-1 downto 0) = "0010111" 											else
				LUI		when 		instruction_in(opcode_len-1 downto 0) = "0110111" 											else
				BEQ		when 		instruction_in(opcode_len-1 downto 0) = "1100011" and instruction_in(14 downto 12) = "000"	else
				LW		when 		instruction_in(opcode_len-1 downto 0) = "0000011" and instruction_in(14 downto 12) = "010"	else
				SRAI	when 		instruction_in(opcode_len-1 downto 0) = "0010011" and instruction_in(14 downto 12) = "101"	else
				ANDI	when 		instruction_in(opcode_len-1 downto 0) = "0010011" and instruction_in(14 downto 12) = "111"	else
				XOR_T	when 		instruction_in(opcode_len-1 downto 0) = "0110011" and instruction_in(14 downto 12) = "100"	else
				SLT		when 		instruction_in(opcode_len-1 downto 0) = "0110011" and instruction_in(14 downto 12) = "010"	else
				JAL		when 		instruction_in(opcode_len-1 downto 0) = "1101111" 											else
				SW		when 		instruction_in(opcode_len-1 downto 0) = "0100011" and instruction_in(14 downto 12) = "010"	else
				ADDI; --NOP

instruction_f <= R_type 	when op_dec = ADD or op_dec = XOR_T else
				 I_type 	when op_dec = ADDI or op_dec = LW or op_dec = SRAI or op_dec = ANDI or op_dec = NOP else
				 B_type 	when op_dec = BEQ 	else
				 S_type 	when op_dec = SW else
				 J_type 	when op_dec = JAL else
				 U_type 	when op_dec = AUIPC or op_dec = LUI else
				 I_type; --nop operation

end architecture;
