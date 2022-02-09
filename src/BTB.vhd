library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY BTB IS
PORT (
		--control signals
		CLK, RST : in std_logic;
		STALL_CTRL : in std_logic;
		UPDATE_EN  : in std_logic;

		--inputs
		PC_IF : in address;
		PC_ID : in address;
		BRANCH_OUTCOME : in address;
		PRED_T_T, PRED_T_NT, PRED_NT_T, PRED_NT_NT : in std_logic;
		
		--outputs
		MATCH : out std_logic;
		BRANCH_TARGET : out address;
		PREDICTION : out std_logic_vector(1 DOWNTO 0)
);
END ENTITY;

ARCHITECTURE struct OF BTB IS

TYPE BHT_ARR IS ARRAY (0 TO 31) OF address;
TYPE TARGET_ADD_ARR IS ARRAY (0 TO 31) of address;
TYPE PREDICTOR_ARR is array (0 TO 31) of std_logic_vector(1 DOWNTO 0);

SIGNAL BHT : BHT_arr;
SIGNAL TARGET_ADD : target_add_arr;
SIGNAL PREDICTOR : predictor_arr;

SIGNAL ENTRY_IF, ENTRY_ID : integer := 0;

BEGIN

ENTRY_IF <= TO_INTEGER(UNSIGNED(PC_IF(6 DOWNTO 2))) WHEN RST = '0' ELSE 0;
ENTRY_ID <= TO_INTEGER(UNSIGNED(PC_ID(6 DOWNTO 2))) WHEN RST = '0' ELSE 0;

rd_proc : PROCESS(RST, PC_IF, ENTRY_IF, PREDICTOR, TARGET_ADD, BHT)
BEGIN
		IF RST = '1' THEN
			MATCH <= '0';
			BRANCH_TARGET <= (OTHERS => '0');
			PREDICTION <= (OTHERS => '0');
		ELSIF PC_IF = BHT(ENTRY_IF) THEN
			MATCH <= '1';
			BRANCH_TARGET <= TARGET_ADD(ENTRY_IF);
			PREDICTION <= PREDICTOR(ENTRY_IF);
		ELSE
			MATCH <= '0';
			BRANCH_TARGET <= TARGET_ADD(ENTRY_IF);
			PREDICTION <= PREDICTOR(ENTRY_IF);
		END IF;
END PROCESS;

update_proc : PROCESS(RST, CLK)
BEGIN
		IF RST = '1' THEN
			BHT <= (OTHERS => (OTHERS => '0'));
			TARGET_ADD <= (OTHERS => (OTHERS => '0'));
			--PREDICTOR <= (OTHERS => (OTHERS => '0'));
		ELSIF RISING_EDGE(CLK) THEN
			IF STALL_CTRL = '0' THEN
				IF UPDATE_EN = '1' THEN
					BHT(ENTRY_ID) <= PC_ID;
					TARGET_ADD(ENTRY_ID) <= BRANCH_OUTCOME;
				END IF;
			END IF;
		END IF;
END PROCESS;

pred_proc : PROCESS(RST, CLK)
BEGIN
		IF RST = '1' THEN
			PREDICTOR <= (OTHERS => (OTHERS => '0'));
		ELSIF RISING_EDGE(CLK) THEN
			IF PRED_T_T = '1' THEN
				IF PREDICTOR(ENTRY_ID) = "10" THEN
					PREDICTOR(ENTRY_ID) <= "11";
				END IF;
			ELSIF PRED_T_NT = '1' THEN
				IF PREDICTOR(ENTRY_ID) = "11" THEN
					PREDICTOR(ENTRY_ID) <= "10";
				ELSE
					PREDICTOR(ENTRY_ID) <= "00";
				END IF;
			ELSIF PRED_NT_T = '1' THEN
				IF PREDICTOR(ENTRY_ID) = "00" THEN
					PREDICTOR(ENTRY_ID) <= "01";
				ELSE
					PREDICTOR(ENTRY_ID) <= "11";
				END IF;
			ELSIF PRED_NT_NT = '1' THEN
				IF PREDICTOR(ENTRY_ID) = "01" THEN
					PREDICTOR(ENTRY_ID) <= "00";
				END IF;
			END IF;
		END IF;
END PROCESS;
 
END ARCHITECTURE;
