library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY forwarding_unit IS
PORT(
		--input
		RST			 		  : in std_logic;
		STALL_CTRL 	 		  : in std_logic;
		OPERATION_ID 		  : in operation;
		CWORD_EXE 			  : in std_logic; --1 bit for cu for immediate selection
		WR_RF_MEM, WR_RF_WRB  : in std_logic;	
		RS1_ID, RS2_ID 		  : in register_address;
		RS1_EX, RS2_EX 		  : in register_address;		
		RD_MEM				  : in register_address;
		RD_WRB 				  : in register_address;
		
		--output
		BRANCH_FORW 			 : out std_logic_vector(1 downto 0);
		EX_MUL1_SEL, EX_MUL2_SEL : out std_logic_vector(1 downto 0)
);
END ENTITY;

ARCHITECTURE behav OF forwarding_unit IS
BEGIN

EX_MUL1_SEL  <= "10" WHEN WR_RF_MEM = '1' AND RD_MEM = RS1_EX AND RD_MEM /= (reg_len-1 DOWNTO 0 => '0') ELSE
				"11" WHEN WR_RF_WRB = '1' AND RD_WRB = RS1_EX AND RD_WRB /= (reg_len-1 DOWNTO 0 => '0') ELSE
				"00";

EX_MUL2_SEL  <= "10" WHEN WR_RF_MEM = '1' AND RD_MEM = RS2_EX AND RD_MEM /= (reg_len-1 DOWNTO 0 => '0') ELSE
				"11" when WR_RF_WRB = '1' AND RD_WRB = RS2_EX and RD_WRB /= (reg_len-1 DOWNTO 0 => '0') ELSE
				('0' & CWORD_EXE);


-- IT MIGHT NOT WORK!!!!!!!!!!!!
branch_for: PROCESS(RST, OPERATION_ID, RS1_ID, RS2_ID, RD_MEM, WR_RF_MEM)
BEGIN
		IF RST = '1' THEN
			BRANCH_FORW <= "00";
		ELSIF OPERATION_ID = BEQ  THEN
			IF WR_RF_MEM = '1' THEN
				IF RS1_ID = RD_MEM AND RD_MEM /= (reg_len-1 DOWNTO 0 => '0') THEN
					BRANCH_FORW <= "10";
				ELSIF RS2_ID = RD_MEM AND RD_MEM /= (reg_len-1 DOWNTO 0 => '0') THEN
					BRANCH_FORW <= "11";
				ELSE
					BRANCH_FORW <= "00";
				END IF;
			END IF;
		ELSE
			BRANCH_FORW <= "00";
		END IF;
END PROCESS;

END ARCHITECTURE;
