library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity risc_v is
	port(	--inputs
			clk, rst : in std_logic;
			IMEM_data : in data;
			DRAM_data : in data;

			--outputs
			IMEM_add : out address;
			DRAM_add : out address;
			DRAM_wr_data : out data;
			DRAM_wr_en : out std_logic;
			DRAM_rd_nwr : out std_logic
			
		);
end entity;



architecture struct of risc_v is

component fetch is
port (
	--input data
		branch_address : in address;  --address of the branch
		instruction_in : in  instruction; --instruction from memory
		
	--control signals
		clk : in  std_logic;
		rst : in  std_logic;
		flush_ctrl : in  std_logic; 
		branch_ctrl : in  std_logic;
		stall_ctrl : in  std_logic;
		
		
	--output data
		instruction_out : out instruction; --instruction to decode stage
		address_to_mem : out address;     -- address to the memory
		program_counter_out : out address --progam counter to decode stage


	);
end component;

component op_decoder is
port ( 
		instruction_in : in instruction;
		instruction_f : out instruction_format;
		op_decoded : out operation
		);
end component;

component control_unit is
port(
		--input
		clk, rst : 				in std_logic;
		op_dec : 				in instruction;
		instruction_f_dec : 	in instruction_format;
		operation_ID	:		in operation;
		branch_to_take : 		in std_logic; --from decode comparator
		stall_ctrl : 			in std_logic;
		--output

		instruction_f_exe_out : out instruction_format;
		instruction_f_mem_out : out instruction_format;
		instruction_f_wrb_out : out instruction_format;


		operation_exe : out operation;
		
		pc_to_exe_ctrl : out std_logic;
		cword_exe : out std_logic_vector(cword_exe_len -1 downto 0);
		cword_mem : out std_logic_vector(cword_mem_len -1 downto 0);
		cword_wrb : out std_logic_vector(cword_wrb_len -1 downto 0)
	
);
end component;

component decode is
port(	--control signals
		clk, rst : in std_logic;
		wr_en : in std_logic;
		pc_out_ctrl : in std_logic;
		--input
		instruction_f : in instruction_format;
		instruction_in : in instruction;
		pc_in : in address;
		wr_add : in register_address;
		wr_data : in data;

		--output
		data_p1, data_p2, immediate_out : out data;
		rs1, rs2, rd : out register_address;
		branch_address : out address;
		branch : out std_logic
		);
end component;

component execute is
port(	--control signals
		clk, rst : 						in std_logic;
		instruction_f : 				in instruction_format;
		op_in : 						in operation;
		mux_sel_op1, mux_sel_op2 :  	in std_logic_vector(1 downto 0);

		--inputs
		data_p1, data_p2, immediate : 	in data;
		data_forw_mem : 				in data;
		data_forw_wrb : 				in data;
		rd_in 		  : 				in register_address;

		--outputs
		--zero : 							out std_logic;	
		mem_data : 						out data;
		mem_address : 					out address;
		rd : 							out register_address

		);
end component;

component memory is
port ( --control signals
		clk, rst : in std_logic;
		mem_en_in : in std_logic;	
		mem_rd_nwr_in : in std_logic;
		
		mem_en_out : out std_logic;
		mem_rd_nwr_out : out std_logic;

		--inputs 
		mem_add : in address;
		mem_data : in data;
		data_from_mem : in data;
		rd_in : in register_address;

		--outputs
		add_to_mem : out address;
		data_to_mem : out data;
		data_mem_out : out data;
		data_bypass : out data;
		rd_out : out register_address

		);
end component;

component write_back is
port (	--control signal
		mux_sel : in std_logic;
		wr_rf_in : in std_logic;
	
		--inputs
		data_from_mem : in data;
		data_bypass : in data;
		rd_in : in register_address;

		data_out : out data;
		rd_out : out register_address;
		wr_rf : out std_logic
);
end component;

component forwarding_unit is
port ( 	
		rst : in std_logic;
		cword_exe : in std_logic; --1 bit for cu for immediate selection
		ex_mem_wr, mem_wb_wr  : in std_logic;
		id_ex_rs1, id_ex_rs2 : in register_address;		
		ex_mem_rd : in register_address;
		mem_wb_rd : in register_address;
		exe_mux1_sel, exe_mux2_sel : out std_logic_vector(1 downto 0)

);
end component;

component hazard_unit is
port (	--inputs
		clk, rst : in std_logic;
		rs1, rs2, exe_rd : in register_address;
		exe_wr : in std_logic;

		--outputs
		stall_ctrl : out std_logic

);
end component;

component BTB_control is
port(
		clk, rst : in std_logic;
		pc_if : in address;
		pc_id : in address;
		op_id : in operation;

		stall, branch_outcome : in std_logic;

		--pred_t_t, pred_t_nt, pred_nt_t, pred_nt_nt : out std_logic;

		flush_ctrl : out std_logic;
		branch_target : out address;
		branch_ctrl : out std_logic
);
end component;

signal instr_if_id : instruction;
signal pc_if_id : address;
signal instr_f_id, instr_f_exe : instruction_format;
signal op_id, op_exe : operation;

signal instruction_f_mem_out, instruction_f_wrb_out : instruction_format;

signal pc_to_exe_ctrl : std_logic;

signal rd_id_exe, rd_exe_mem, rd_mem_wrb, rd_rf : register_address;

signal data_p1, data_p2, immediate, rf_wr_data : data;

signal stall_ctrl, branch_ctrl, wr_rf, flush_ctrl : std_logic;

signal cword_exe : std_logic_vector(cword_exe_len -1 downto 0);
signal cword_mem : std_logic_vector(cword_mem_len -1 downto 0);
signal cword_wrb : std_logic_vector(cword_wrb_len -1 downto 0);

signal id_ex_rs1, id_ex_rs2 : register_address;

signal mux_sel_op1, mux_sel_op2 : std_logic_vector(1 downto 0);

signal mem_data : data;
signal mem_add : address;

signal data_mem_out, data_bypass : data;

signal pc_if, branch_target, branch_outcome_id : address;

signal branch_ctrl_if : std_logic;

begin

IMEM_add <= pc_if;

fetch_inst 	 : fetch port map(		branch_address => branch_target,   --it comes from the BTB
									instruction_in => IMEM_data,
									clk => clk, rst => rst, flush_ctrl => flush_ctrl, branch_ctrl => branch_ctrl_if, stall_ctrl => stall_ctrl,	--comes from HU, BTB
									instruction_out => instr_if_id, 
									address_to_mem => pc_if,
									program_counter_out => pc_if_id
);

op_dec_inst  : op_decoder port map(instruction_in => instr_if_id, instruction_f => instr_f_id, op_decoded => op_id);

cu_inst 	 : control_unit port map( clk => clk, rst => rst,
										op_dec => instr_if_id,
										instruction_f_dec => instr_f_id,
										operation_ID => op_id,
										branch_to_take => branch_ctrl,
										stall_ctrl => stall_ctrl,
										instruction_f_exe_out => instr_f_exe,
										instruction_f_mem_out => instruction_f_mem_out,
										instruction_f_wrb_out => instruction_f_wrb_out,
										operation_exe => op_exe,
										pc_to_exe_ctrl => pc_to_exe_ctrl,
										cword_exe => cword_exe,
										cword_mem => cword_mem,
										cword_wrb => cword_wrb
);

decode_inst	 : decode port map(clk => clk, rst => rst, wr_en => wr_rf,
								pc_out_ctrl => pc_to_exe_ctrl,
								instruction_f => instr_f_id,
								instruction_in => instr_if_id,
								pc_in => pc_if_id,
								wr_add => rd_rf,
								wr_data => rf_wr_data,
								data_p1 => data_p1,
								data_p2 => data_p2,
								immediate_out => immediate,
								rs1 => id_ex_rs1,
								rs2 => id_ex_rs2,
								rd => rd_id_exe,
								branch_address => branch_outcome_id, ------------------------
								branch => branch_ctrl
);

execute_inst : execute port map( clk => clk, rst => rst,
								instruction_f => instr_f_exe,
								op_in => op_exe,
								mux_sel_op1 => mux_sel_op1, mux_sel_op2 => mux_sel_op2,
								data_p1 => data_p1,
								data_p2 => data_p2,
								immediate => immediate,
								data_forw_mem => mem_data,
								data_forw_wrb => rf_wr_data,
								rd_in => rd_id_exe,
								--zero => , ---------------------------
								mem_data => mem_data,
								mem_address => mem_add,
								rd => rd_exe_mem
);

mem_inst 	 : memory port map( clk => clk, rst => rst,
								mem_en_in => cword_mem(cword_mem_len-1),	
								mem_rd_nwr_in => cword_mem(cword_mem_len-2),
								mem_en_out => DRAM_wr_en,
								mem_rd_nwr_out => DRAM_rd_nwr,
								mem_add => mem_add,
								mem_data => mem_data,
								data_from_mem => DRAM_data,
								rd_in => rd_exe_mem,
								add_to_mem => DRAM_add,
								data_to_mem => DRAM_wr_data,
								data_mem_out => data_mem_out,
								data_bypass => data_bypass,
								rd_out => rd_mem_wrb

);

wrb_inst	 : write_back port map( mux_sel => cword_wrb(cword_wrb_len-1),
									wr_rf_in => cword_wrb(0),
									data_from_mem => data_mem_out,
									data_bypass => data_bypass,
									rd_in => rd_mem_wrb,
									data_out => rf_wr_data,
									rd_out => rd_rf,
									wr_rf => wr_rf
);


forw_unit_inst : forwarding_unit port map(
												rst => rst,
												cword_exe => cword_exe(cword_exe_len-2),
												ex_mem_wr => cword_mem(0),  
												mem_wb_wr => cword_wrb(0),
												id_ex_rs1 => id_ex_rs1,
												id_ex_rs2 => id_ex_rs2,		
												ex_mem_rd => rd_exe_mem,
												mem_wb_rd => rd_mem_wrb,
												exe_mux1_sel => mux_sel_op1, 
												exe_mux2_sel => mux_sel_op2
);

haz_unit_inst : hazard_unit port map(	clk => clk,
										rst => rst,
										rs1 => instr_if_id(19 downto 15),
										rs2 => instr_if_id(24 downto 20),
										exe_rd => rd_id_exe,
										exe_wr => cword_exe(0),
										stall_ctrl => stall_ctrl

);


btb_control_inst : BTB_control port map ( 	clk => clk,
											 rst => rst,
											pc_if => pc_if,
											pc_id => branch_outcome_id,------------------
											op_id => op_id,
											stall => stall_ctrl,
											branch_outcome => branch_ctrl,
											--pred_t_t, pred_t_nt, pred_nt_t, pred_nt_nt : out std_logic;
											flush_ctrl => flush_ctrl,
											branch_target => branch_target, ---------------
											branch_ctrl => branch_ctrl_if-------------------

);
end architecture;
