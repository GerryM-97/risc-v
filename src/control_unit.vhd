library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY control_unit IS
PORT (
		--input
		CLK, RST  			 :  in std_logic;
		INSTRUCTION_ID 		 :	in instruction;
		INSTRUCTION_F_ID	 : 	in instruction_format;
		OPERATION_ID		 :  in operation;
		STALL_CTRL			 : 	in std_logic;
		
		--output
		OPERATION_EX	 : out operation;
		PC_OUT_CTRL 	 : out std_logic;

		CWORD_EXE : out std_logic_vector(cword_exe_len -1 DOWNTO 0);
		CWORD_MEM : out std_logic_vector(cword_mem_len -1 DOWNTO 0);
		CWORD_WRB : out std_logic_vector(cword_wrb_len -1 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE behav OF control_unit IS


SIGNAL CWORD_TO_EXE : std_logic_vector(cword_exe_len -1 DOWNTO 0);
SIGNAL CWORD_TO_MEM : std_logic_vector(cword_mem_len -1 DOWNTO 0);
SIGNAL CWORD_TO_WRB : std_logic_vector(cword_wrb_len -1 DOWNTO 0);

BEGIN

CWORD_EXE <= CWORD_TO_EXE;
CWORD_MEM <= CWORD_TO_MEM;
CWORD_WRB <= CWORD_TO_WRB;

PC_OUT_CTRL	 <= '0' WHEN RST = '1' ELSE
				'1' WHEN OPERATION_ID = AUIPC OR operation_ID = JAL ELSE
				'0';

cw_proc : PROCESS(RST, CLK)
BEGIN
		IF RST = '1' THEN
			OPERATION_EX <= ADDI;
			CWORD_TO_EXE <= (OTHERS => '0');
			CWORD_TO_MEM <= (OTHERS => '0');
			CWORD_TO_WRB <= (OTHERS => '0');
		ELSIF RISING_EDGE(CLK) THEN
			CWORD_TO_MEM <= CWORD_TO_EXE(cword_mem_len-1 DOWNTO 0);
			CWORD_TO_WRB <= CWORD_TO_MEM(cword_wrb_len-1 DOWNTO 0);
			IF STALL_CTRL = '1' THEN
				OPERATION_EX <= ADDI;
				CWORD_TO_EXE <= (OTHERS => '0');
			ELSE
				OPERATION_EX <= OPERATION_ID;
				IF OPERATION_ID = AUIPC THEN
                  CWORD_TO_EXE <= "110011";
                ELSIF OPERATION_ID = ADD OR OPERATION_ID = SLT OR OPERATION_ID = XOR_T   THEN
                  CWORD_TO_EXE <= "000011";
                ELSIF OPERATION_ID = ADDI OR OPERATION_ID = ANDI OR OPERATION_ID = SRAI OR OPERATION_ID = LUI  THEN
                  CWORD_TO_EXE <= "010011";   
                ELSIF OPERATION_ID = BEQ  THEN
                  CWORD_TO_EXE <= "000000";
                ELSIF OPERATION_ID = JAL   THEN
                  CWORD_TO_EXE <= "100011";
                ELSIF OPERATION_ID = LW  THEN
                  CWORD_TO_EXE <= "011101";
                ELSIF OPERATION_ID = SW  THEN
                  CWORD_TO_EXE <= "011000";
				END IF;
			END IF;
		END IF;
END PROCESS;


END ARCHITECTURE;
