library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY risc_v IS
PORT(		
		--inputs
		CLK, RST : in std_logic;
		IMEM_DATA : in data;
		DRAM_DATA : in data;

		--outputs
		IMEM_ADD : out address;
		DRAM_ADD : out address;
		DRAM_WR_DATA : out data;
		DRAM_EN : out std_logic;
		DRAM_RD_NWR : out std_logic			
		);
END ENTITY;

ARCHITECTURE struct OF risc_v IS

COMPONENT fetch IS 
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
END COMPONENT;

COMPONENT op_decoder IS
PORT ( 
		--input
		INSTRUCTION_IN 	: in instruction;
		
		--output
		INSTRUCTION_F 	: out instruction_format;
		OP_DECODED 		: out operation
);
END COMPONENT;

COMPONENT control_unit IS
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
END COMPONENT;

COMPONENT decode IS
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
END COMPONENT;

COMPONENT execute IS
PORT (
		--control signals
		CLK, RST 			: in std_logic;
		OPERATION_EX 		: in operation;
		MUX_SEL_OP1 		: in std_logic_vector(1 DOWNTO 0);
		MUX_SEL_OP2 		: in std_logic_vector(1 DOWNTO 0);

		--input
		DATA1_EX, DATA2_EX 	: in data;
		IMMEDIATE_EX		: in data;
		DATA_FORW_MEM		: in data;
		DATA_FORW_WRB		: in data;
		RD_EX				: in register_address;

		--output
		ADDRESS_MEM			: out address;
		DATA_MEM			: out data;
		RD_MEM				: out register_address
);
END COMPONENT;

COMPONENT memory IS
PORT(
		--control signals
		CLK, RST 		: in std_logic;
		DRAM_EN_IN 		: in std_logic;	
		DRAM_RD_NWR_IN 	: in std_logic;
		
		DRAM_EN_OUT 	: out std_logic;
		DRAM_RD_NWR_OUT : out std_logic;

		--inputs 
		ADDRESS_MEM 	: in address;
		DATA_MEM 		: in data;
		DRAM_DATA 		: in data;
		RD_MEM 			: in register_address;

		--outputs
		DRAM_ADD 		: out address;
		DRAM_WR_DATA 	: out data;
		DATA_WRB	 	: out data;
		DATA_BYPASS_WRB : out data;
		RD_WRB 			: out register_address
);
END COMPONENT;

COMPONENT write_back IS
PORT (
		--control signal
		MUX_SEL  	: in std_logic;
		WR_RF_IN 	: in std_logic;
	
		--inputs
		DATA_WRB 			: in data;
		DATA_BYPASS_WRB 	: in data;
		RD_WRB_IN 			: in register_address;

		--output
		DATA_OUT 		: out data;
		RD_WRB_OUT 		: out register_address;
		WR_RF_OUT 		: out std_logic
);
END COMPONENT;

COMPONENT hazard_unit IS
PORT (
		--inputs
		CLK, RST : in std_logic;
		RS1_ID, RS2_ID, RD_EX : in register_address;
		WR_EX : in std_logic;

		--outputs
		STALL_CTRL : out std_logic
);
END COMPONENT;

COMPONENT forwarding_unit IS
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
END COMPONENT;
	
COMPONENT BTB IS
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
		PREDICTION : out std_logic;
		BRANCH_TARGET : out address
);
END COMPONENT;

COMPONENT BTB_control IS
PORT(
		--control signal
		CLK, RST : in std_logic;
		STALL_CTRL : in std_logic;
		BRANCH_TAKEN : in std_logic;
		OPERATION_ID : in operation;

		--inputs
		PC_IF, PC_ID : in address;
		BRANCH_OUTCOME : in address;
		--outputs
		FLUSH_CTRL : out std_logic;
		BRANCH_CTRL : out std_logic;
		BRANCH_TARGET : out address
);
END COMPONENT;

SIGNAL BRANCH_CTRL, STALL_CTRL, FLUSH_CTRL : std_logic;
SIGNAL PC_OUT_CTRL, BRANCH_ID, WR_RF_EN : std_logic;

SIGNAL MUX_SEL_OP1, MUX_SEL_OP2, BRANCH_FORW_CTRL : std_logic_vector(1 DOWNTO 0);

SIGNAL CWORD_EXE : std_logic_vector(cword_exe_len-1 DOWNTO 0);
SIGNAL CWORD_MEM : std_logic_vector(cword_mem_len-1 DOWNTO 0);
SIGNAL CWORD_WRB : std_logic_vector(cword_wrb_len-1 DOWNTO 0);

SIGNAL BRANCH_ADDRESS : address; --BRANCH ADDRESS TO IF
SIGNAL WR_RF_ADD : register_address;
SIGNAL WR_RF_DATA : data;

SIGNAL PC_IF, PC_ID : address;

SIGNAL INSTRUCTION_ID : instruction;

SIGNAL INSTRUCTION_F_ID : instruction_format;

SIGNAL OPERATION_ID, OPERATION_EX : operation;

SIGNAL DATA_MEM, DATA_WRB, DATA_BYPASS_WRB : data;

SIGNAL DATA1_EX, DATA2_EX, IMMEDIATE_EX : data;

SIGNAL RS1_EX, RS2_EX, RD_EX, RD_MEM, RD_WRB : register_address;

SIGNAL BRANCH_OUTCOME_ID : address;

SIGNAL ADDRESS_MEM : address;

BEGIN

IMEM_ADD <= PC_IF;
--WR_RF_EN <= CWORD_WRB(0);

fetch_inst : fetch PORT MAP(	CLK => CLK, RST => RST, FLUSH_CTRL => FLUSH_CTRL,
								BRANCH_CTRL => BRANCH_CTRL,
								STALL_CTRL => STALL_CTRL,
								BRANCH_ADDRESS => BRANCH_ADDRESS,
								INSTRUCTION_IF => IMEM_DATA,
								INSTRUCTION_ID => INSTRUCTION_ID,
								PC_IF => PC_IF,	
								PC_ID => PC_ID
								);

op_decoder_inst : op_decoder PORT MAP( INSTRUCTION_IN => INSTRUCTION_ID, INSTRUCTION_F => INSTRUCTION_F_ID,
										OP_DECODED => OPERATION_ID
										);

cu_inst : control_unit PORT MAP( CLK => CLK, RST => RST, 
								INSTRUCTION_ID => INSTRUCTION_ID, INSTRUCTION_F_ID => INSTRUCTION_F_ID,
								OPERATION_ID => OPERATION_ID,
								STALL_CTRL => STALL_CTRL,
								OPERATION_EX => OPERATION_EX,
								PC_OUT_CTRL => PC_OUT_CTRL,
								CWORD_EXE => CWORD_EXE,
								CWORD_MEM => CWORD_MEM,
								CWORD_WRB => CWORD_WRB
								);

decode_inst : decode PORT MAP ( CLK => CLK, RST => RST, STALL_CTRL => STALL_CTRL,
								WR_EN => WR_RF_EN, PC_OUT_CTRL => PC_OUT_CTRL,
								BRANCH_FORW_CTRL => BRANCH_FORW_CTRL,
								INSTRUCTION_F_ID => INSTRUCTION_F_ID,
								OPERATION_ID => OPERATION_ID,
								INSTRUCTION_ID => INSTRUCTION_ID,
								PC_ID => PC_ID,
								WR_ADD => WR_RF_ADD,
								WR_DATA => WR_RF_DATA,
								BRANCH_FORW_MEM => ADDRESS_MEM,
								DATA1_EX => DATA1_EX, DATA2_EX => DATA2_EX,
								IMMEDIATE_EX => IMMEDIATE_EX,
								RS1_EX => RS1_EX, RS2_EX => RS2_EX, RD_EX => RD_EX,
								BRANCH_ADD_ID => BRANCH_OUTCOME_ID,
								BRANCH_ID => BRANCH_ID
								);


execute_inst : execute PORT MAP( CLK => CLK, RST => RST, OPERATION_EX => OPERATION_EX,
								 MUX_SEL_OP1 => MUX_SEL_OP1,
								 MUX_SEL_OP2 => MUX_SEL_OP2,
								 DATA1_EX => DATA1_EX,
								 DATA2_EX => DATA2_EX,
								 IMMEDIATE_EX => IMMEDIATE_EX,
								 DATA_FORW_MEM => DATA_MEM,
								 DATA_FORW_WRB => WR_RF_DATA,
								 RD_EX => RD_EX,
								 ADDRESS_MEM => ADDRESS_MEM,
								 DATA_MEM => DATA_MEM,
								 RD_MEM => RD_MEM
								);

memory_inst : memory PORT MAP( CLK => CLK, RST => RST, 
								DRAM_EN_IN => CWORD_MEM(cword_mem_len-1), DRAM_RD_NWR_IN => CWORD_MEM(cword_mem_len-2),
								DRAM_EN_OUT => DRAM_EN, DRAM_RD_NWR_OUT => DRAM_RD_NWR,
								ADDRESS_MEM => ADDRESS_MEM,
								DATA_MEM => DATA_MEM,
								DRAM_DATA => DRAM_DATA,
								RD_MEM => RD_MEM,
								DRAM_ADD => DRAM_ADD,
								DRAM_WR_DATA => DRAM_WR_DATA,
								DATA_WRB => DATA_WRB,
								DATA_BYPASS_WRB => DATA_BYPASS_WRB,
								RD_WRB => RD_WRB
							);

write_back_inst : write_back PORT MAP( MUX_SEL => CWORD_WRB(1),
										WR_RF_IN => CWORD_WRB(0),
										DATA_WRB => DATA_WRB,
										DATA_BYPASS_WRB => DATA_BYPASS_WRB,
										RD_WRB_IN => RD_WRB,
										DATA_OUT => WR_RF_DATA,
										RD_WRB_OUT => WR_RF_ADD,
										WR_RF_OUT => WR_RF_EN
										);

hu_inst : hazard_unit PORT MAP( CLK => CLK, RST => RST,
								RS1_ID => INSTRUCTION_ID(19 DOWNTO 15), RS2_ID => INSTRUCTION_ID(24 DOWNTO 20), RD_EX => RD_EX,
								WR_EX => CWORD_EXE(0),
								STALL_CTRL => STALL_CTRL
								);

fu_inst : forwarding_unit PORT MAP( RST => RST,
									STALL_CTRL => STALL_CTRL,
									OPERATION_ID => OPERATION_ID,
									CWORD_EXE => CWORD_EXE(cword_exe_len-2),
									WR_RF_MEM => CWORD_MEM(0), WR_RF_WRB => WR_RF_EN,
									RS1_ID => INSTRUCTION_ID(19 DOWNTO 15), RS2_ID => INSTRUCTION_ID(24 DOWNTO 20),
									RS1_EX => RS1_EX, RS2_EX => RS2_EX,
									RD_MEM => RD_MEM, RD_WRB => WR_RF_ADD,
									BRANCH_FORW => BRANCH_FORW_CTRL,
									EX_MUL1_SEL => MUX_SEL_OP1, EX_MUL2_SEL => MUX_SEL_OP2
									);

btb_inst : BTB_control PORT MAP( CLK => CLK, RST => RST,
								STALL_CTRL => STALL_CTRL,
								BRANCH_TAKEN => BRANCH_ID,
								OPERATION_ID => OPERATION_ID,
								PC_IF => PC_IF, PC_ID => PC_ID,
								BRANCH_OUTCOME => BRANCH_OUTCOME_ID,
								FLUSH_CTRL => FLUSH_CTRL,
								BRANCH_CTRL => BRANCH_CTRL,
								BRANCH_TARGET => BRANCH_ADDRESS
								);


END ARCHITECTURE;

