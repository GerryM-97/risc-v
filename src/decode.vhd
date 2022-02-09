library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY decode IS
PORT (	
		--control signals
		CLK, RST 			: in std_logic;
		STALL_CTRL 			: in std_logic;
		WR_EN 				: in std_logic;
		PC_OUT_CTRL 		: in std_logic;
		BRANCH_FORW_CTRL	: in std_logic_vector(1 downto 0);

		--input
		INSTRUCTION_F_ID 		: in instruction_format;
		OPERATION_ID			: in operation;
		INSTRUCTION_ID 			: in instruction;
		PC_ID 					: in address;
		WR_ADD 					: in register_address;
		WR_DATA 				: in data;
		BRANCH_FORW_MEM 		: in data;

		--output
		DATA1_EX, DATA2_EX, IMMEDIATE_EX 	: out data;
		RS1_EX, RS2_EX, RD_EX 				: out register_address;
		BRANCH_ADD_ID 						: out address;
		BRANCH_ID 							: out std_logic
);
END ENTITY;

ARCHITECTURE struct OF decode IS 

COMPONENT immediate_gen IS
PORT(
		--instruction type
		INSTRUCTION_F_IN : in instruction_format;

		--input
		INSTRUCTION_IN 	 : in instruction;

		--output
		IMMEDIATE_OUT 	 : out data
);
END COMPONENT;

COMPONENT reg_file IS
PORT ( 
		--control signals
		CLK, RST 	: in std_logic;
		WR_EN 		: in std_logic;

		--inputs
		ADDRESS_RD1, ADDRESS_RD2, ADDRESS_WR : in register_address;
		WR_DATA								 : in data;

		--outputs
		DATA_P1, DATA_P2 : out data

);
END COMPONENT;

SIGNAL IMMEDIATE_ID 			: data;
SIGNAL RS1_ID, RS2_ID, RD_ID 	: register_address;
SIGNAL REGF_P1, REGF_P2 		: data;

BEGIN

RS1_ID <= INSTRUCTION_ID(19 DOWNTO 15);
RS2_ID <= INSTRUCTION_ID(24 DOWNTO 20);
RD_ID  <= INSTRUCTION_ID(11 DOWNTO 7);

imm_gen_inst 	: immediate_gen PORT MAP (INSTRUCTION_F_ID, INSTRUCTION_ID, IMMEDIATE_ID);

reg_file_inst 	:  reg_file PORT MAP(CLK => CLK,
									 RST => RST,
									 WR_EN => WR_EN,
									 ADDRESS_RD1 => RS1_ID,
									 ADDRESS_RD2 => RS2_ID,
									 ADDRESS_WR => WR_ADD,
									 WR_DATA => WR_DATA,
									 DATA_P1 => REGF_P1,
									 DATA_P2 => REGF_P2);

out_proc : PROCESS(CLK, RST)
BEGIN
		IF RST = '1' THEN
			DATA1_EX 		<= (OTHERS => '0');
			DATA2_EX 		<= (OTHERS => '0');
			IMMEDIATE_EX 	<= (OTHERS => '0');

			RS1_EX 			<= (OTHERS => '0');
			RS2_EX 			<= (OTHERS => '0');
			RD_EX			<= (OTHERS => '0');
		ELSIF RISING_EDGE(CLK) THEN
			IF PC_OUT_CTRL = '1' THEN
				DATA1_EX 		<= PC_ID; 
			ELSE
				DATA1_EX 		<= REGF_P1;
			END IF;
			DATA2_EX 		<= REGF_P2;
			IMMEDIATE_EX 	<= IMMEDIATE_ID;

			RS1_EX 			<= RS1_ID;
			RS2_EX 			<= RS2_ID;
			RD_EX			<= RD_ID;
		END IF;
END PROCESS;

branch_proc : PROCESS(RST, OPERATION_ID, BRANCH_FORW_CTRL, BRANCH_FORW_MEM, REGF_P1, REGF_P2, STALL_CTRL, PC_ID, IMMEDIATE_ID) ---------------------------------
BEGIN
		IF RST = '1' THEN
			BRANCH_ID <= '0';
			BRANCH_ADD_ID <= (OTHERS => '0');
		ELSIF OPERATION_ID = JAL THEN
			BRANCH_ID <= '1';
			BRANCH_ADD_ID <= STD_LOGIC_VECTOR(UNSIGNED(PC_ID) + UNSIGNED(IMMEDIATE_ID));
		ELSIF OPERATION_ID = BEQ and STALL_CTRL = '0' THEN
			IF BRANCH_FORW_CTRL = "11" THEN
				IF REGF_P1 = BRANCH_FORW_MEM THEN
					BRANCH_ID <= '1';
					BRANCH_ADD_ID <= STD_LOGIC_VECTOR(UNSIGNED(PC_ID) + UNSIGNED(IMMEDIATE_ID));
				ELSE
					BRANCH_ID <= '0';
				END IF;
			ELSIF BRANCH_FORW_CTRL = "10" THEN
				IF BRANCH_FORW_MEM = REGF_P2 THEN
					BRANCH_ID <= '1';
					BRANCH_ADD_ID <= STD_LOGIC_VECTOR(UNSIGNED(PC_ID) + UNSIGNED(IMMEDIATE_ID));
				ELSE
					BRANCH_ID <= '0';
				END IF;
			ELSE
				IF REGF_P1 = REGF_P2 THEN	
					BRANCH_ID <= '1';
					BRANCH_ADD_ID <= STD_LOGIC_VECTOR(UNSIGNED(PC_ID) + UNSIGNED(IMMEDIATE_ID));
				ELSE
					BRANCH_ID <= '0';
				END IF;
			END IF;
		ELSE
			BRANCH_ID <= '0';
		END IF;
END PROCESS;


END ARCHITECTURE;
