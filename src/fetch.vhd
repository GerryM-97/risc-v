library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;


ENTITY fetch IS 
PORT (			
			--control signals
			CLK 			: in  std_logic;
			RST 			: in  std_logic;
			FLUSH_CTRL 		: in  std_logic; 
			BRANCH_CTRL 	: in  std_logic;
			STALL_CTRL 		: in  std_logic;
		
			--input data
			BRANCH_ADDRESS	: in  address;  --address of the branch
			INSTRUCTION_IF 	: in  instruction; --instruction from memory

		
			--output data
			INSTRUCTION_ID 		: out instruction; --instruction to decode stage
			PC_IF		 		: out address;     -- address to the memory
			PC_ID 				: out address --progam counter to decode stage
	);
END ENTITY;

ARCHITECTURE struct OF fetch IS

SIGNAL PC, NEXT_PC : address;


BEGIN

PC_IF <= PC;

pc_proc : PROCESS(RST, CLK)
BEGIN
		IF RST = '1' THEN
			PC <= (OTHERS => '0');
			PC_ID <= (OTHERS => '0');
		ELSIF RISING_EDGE(CLK) THEN
			IF STALL_CTRL = '0' THEN
				PC 		<= NEXT_PC;
				PC_ID 	<= PC;
			END IF;
		END IF;
END PROCESS;

next_pc_proc : PROCESS (RST, FLUSH_CTRL, BRANCH_CTRL, STALL_CTRL, PC)
BEGIN
		IF FLUSH_CTRL = '1' OR BRANCH_CTRL = '1' THEN
			NEXT_PC <= BRANCH_ADDRESS;
		ELSE
			NEXT_PC <= STD_LOGIC_VECTOR(UNSIGNED(PC) + 4);
		END IF;
END PROCESS;


OUT_PROC : PROCESS(RST, CLK)
BEGIN
		IF RST = '1' THEN
			INSTRUCTION_ID <= NOP_INSTR;
		ELSIF RISING_EDGE(CLK) THEN
			IF FLUSH_CTRL = '1' THEN
				INSTRUCTION_ID <= NOP_INSTR;
			ELSIF STALL_CTRL = '0' THEN
				INSTRUCTION_ID <= INSTRUCTION_IF;
			END IF;

		END IF;

END PROCESS;
END ARCHITECTURE;
