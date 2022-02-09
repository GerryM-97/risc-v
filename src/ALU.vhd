library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY ALU IS 
PORT (	
		--control signals
		ALU_OPERATION 			: in operation;

		--inputs
		OPERAND_1, OPERAND_2 	: in data;
		
		--outputs
		DATA_OUT 				: out data
		
		);
END ENTITY;

ARCHITECTURE behav OF ALU IS

SIGNAL SHIFTED : data;
SIGNAL ZERO : std_logic;
SIGNAL SHIFT_VAL : integer;

BEGIN

SHIFT_VAL <= to_integer(unsigned(OPERAND_2(4 DOWNTO 0)));
ZERO <= '1' WHEN (OPERAND_1) < (OPERAND_2) ELSE '0';


DATA_OUT <= std_logic_vector(signed(OPERAND_1) + signed(OPERAND_2)) WHEN ALU_OPERATION = ADD   ELSE
			std_logic_vector(signed(OPERAND_1) + signed(OPERAND_2)) WHEN ALU_OPERATION = ADDI  ELSE
			std_logic_vector(signed(OPERAND_1) + signed(OPERAND_2)) WHEN ALU_OPERATION = AUIPC ELSE 
			OPERAND_2 												WHEN ALU_OPERATION = LUI   ELSE
			std_logic_vector(signed(OPERAND_1) + signed(OPERAND_2)) WHEN ALU_OPERATION = BEQ   ELSE
			std_logic_vector(signed(OPERAND_1) + signed(OPERAND_2)) WHEN ALU_OPERATION = LW    ELSE
			SHIFTED 												WHEN ALU_OPERATION = SRAI  ELSE
			OPERAND_1 AND OPERAND_2 								WHEN ALU_OPERATION = ANDI  ELSE	
			OPERAND_1 XOR OPERAND_2 								WHEN ALU_OPERATION = XOR_T ELSE	
			(nbit-1 DOWNTO 1 => '0') & ZERO 						WHEN ALU_OPERATION = SLT   ELSE
			std_logic_vector(signed(OPERAND_1) + 4) 				WHEN ALU_OPERATION = JAL   ELSE
			std_logic_vector(signed(OPERAND_1) + signed(OPERAND_2)) WHEN ALU_OPERATION = SW    ELSE
			(OTHERS => '0');

shift_proc : PROCESS ( ALU_OPERATION, OPERAND_1, OPERAND_2) --process for shifting arith right
				VARIABLE  SHIFT_OUT : data;
				--VARIABLE  SHIFT_VAL : integer ;
				BEGIN
					--SHIFT_VAL := to_integer(unsigned(OPERAND_2(4 DOWNTO 0)));
					IF (ALU_OPERATION = SRAI) THEN
						SHIFT_OUT := OPERAND_1;
						FOR i IN 0 TO nbit-1 LOOP
							EXIT WHEN i = SHIFT_VAL;
							SHIFT_OUT := SHIFT_OUT(nbit-1) & SHIFT_OUT(nbit-1 DOWNTO 1);
						END LOOP;
					END IF;
SHIFTED <= SHIFT_OUT;
END PROCESS;

END ARCHITECTURE;
