library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY BTB_control IS
PORT(
		--control signal
		CLK, RST : in std_logic;
		STALL_CTRL : in std_logic;
		BRANCH_TAKEN : in std_logic;
		OPERATION_ID : in operation;
	
		PREDICTION : IN STD_LOGIC;
	
		UPDATE_EN : OUT std_logic;
		PRED_T_T, PRED_T_NT, PRED_NT_T, PRED_NT_NT : OUT std_logic;

		--inputs
		PC_IF, PC_ID : in address;
		BRANCH_OUTCOME : in address;
		--outputs
		FLUSH_CTRL : out std_logic;
		BRANCH_CTRL : out std_logic
);
END ENTITY;

ARCHITECTURE behav OF BTB_control IS

--SIGNAL BRANCH_BTB : address;
--SIGNAL PREDICTION : std_logic_vector(1 DOWNTO 0);
SIGNAL FLUSH, PREDICTED_T : std_logic;

BEGIN

FLUSH_CTRL <= FLUSH;

predicted_proc : PROCESS(RST, CLK)
BEGIN
		IF RST = '1' THEN
			PREDICTED_T <= '0';
		ELSIF RISING_EDGE(CLK) THEN
			IF STALL_CTRL = '0' THEN
				PREDICTED_T <= PREDICTION;
			END IF;
		END IF;
END PROCESS;


branch_proc : PROCESS(RST, OPERATION_ID, MATCH, PREDICTION, BRANCH_BTB, FLUSH)
BEGIN
		IF RST = '1' THEN
			BRANCH_CTRL <= '0';
			--BRANCH_TARGET <= (OTHERS => '0');
		ELSIF PREDICTION = '1' THEN
			BRANCH_CTRL <= '1';
			--BRANCH_TARGET <= BRANCH_BTB;
		ELSIF FLUSH = '1' THEN
			BRANCH_CTRL <= '1';
			--BRANCH_TARGET <= BRANCH_OUTCOME;
		ELSE
			BRANCH_CTRL <= '0';
		END IF;
END PROCESS;

pred_proc : PROCESS(RST,  OPERATION_ID, STALL_CTRL, PREDICTED_T, BRANCH_TAKEN)
BEGIN
		IF RST = '1' THEN
			PRED_T_T <= '0';
			PRED_T_NT <= '0';
			PRED_NT_T <= '0';
			PRED_NT_NT <= '0';
			UPDATE_EN <= '0';
			FLUSH <= '0';
		ELSIF OPERATION_ID = BEQ OR OPERATION_ID = JAL THEN
			IF STALL_CTRL = '0' THEN
				IF PREDICTED_T = '1' AND BRANCH_TAKEN = '1' THEN
					PRED_T_T <= '1';
					PRED_T_NT <= '0';
					PRED_NT_T <= '0';
					PRED_NT_NT <= '0';
					UPDATE_EN <= '0';
					FLUSH <= '0';
				ELSIF PREDICTED_T = '1' AND BRANCH_TAKEN = '0' THEN
					PRED_T_T <= '0';
					PRED_T_NT <= '1';
					PRED_NT_T <= '0';
					PRED_NT_NT <= '0';
					UPDATE_EN <= '0';
					FLUSH <= '1';
				ELSIF PREDICTED_T = '0' AND BRANCH_TAKEN = '1' THEN
					PRED_T_T <= '0';
					PRED_T_NT <= '0';
					PRED_NT_T <= '1';
					PRED_NT_NT <= '0';
					UPDATE_EN <= '1';
					FLUSH <= '1';
				ELSIF PREDICTED_T = '0' AND BRANCH_TAKEN = '0' THEN
					PRED_T_T <= '0';
					PRED_T_NT <= '0';
					PRED_NT_T <= '0';
					PRED_NT_NT <= '1';
					UPDATE_EN <= '0';
					FLUSH <= '0';
				END IF;
			ELSE
				PRED_T_T <= '0';
				PRED_T_NT <= '0';
				PRED_NT_T <= '0';
				PRED_NT_NT <= '0';
				UPDATE_EN <= '0';
				FLUSH <= '0';
			END IF;
		ELSE
			PRED_T_T <= '0';
			PRED_T_NT <= '0';
			PRED_NT_T <= '0';
			PRED_NT_NT <= '0';
			UPDATE_EN <= '0';
			FLUSH <= '0';
		END IF;
END PROCESS;

END ARCHITECTURE;
