library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity fetch is
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
end entity;



architecture struct of fetch is

component reg is
generic (nbit_reg : integer := nbit;
			rst_val : std_logic_vector(nbit-1 downto 0));
port (	
		clk, rst, enable : in std_logic;
		data_in : in std_logic_vector(nbit -1 downto 0);
		data_out : out std_logic_vector(nbit-1 downto 0)
		);
end component;

signal next_pc : address;
signal instr_from_IMEM : address;

signal nstall_ctrl : std_logic;

signal pc_if : address;

begin

address_to_mem <= pc_if;
nstall_ctrl <= not stall_ctrl;

next_pc <= std_logic_vector(unsigned(pc_if )+4) when rst = '1' or stall_ctrl = '1' else 		--mux for selecting the next PC
			branch_address when branch_ctrl = '1' or flush_ctrl = '1' else
			std_logic_vector(unsigned(pc_if )+4) ;

instr_from_IMEM <= NOP_instr when flush_ctrl = '1' else
					instruction_in;

pc_reg : 		reg generic map(nbit, first_instruction) port map(clk, rst, nstall_ctrl, next_pc, pc_if);	--PC register

out_reg_pc : 	reg generic map(nbit, reset_pc) port map(clk, rst, nstall_ctrl, pc_if, program_counter_out); --PC to ID register enabled by the (complemented) stall_ctrl signal 

out_inst_pc : 	reg generic map(nbit, NOP_instr) port map(clk, rst, nstall_ctrl, instr_from_IMEM, instruction_out);		-- instruction out registe

end architecture;
