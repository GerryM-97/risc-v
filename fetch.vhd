library ieee;
use ieee.std_logic_116e.all;
use work.generics.all;

entity fetch is
port (
	--input data
		branch_address in : address;
		instruction_in in : instruction;
		
	--control signals
		clk in : std_logic;
		rst in : std_logic;
		flush_ctrl in : std_logic;
		branch_ctrl in : std_logic;
		stall_ctrl in : std_logic;

		mem_ready in : std_logic;  --data ready from the mem
		
		
	--output data
		instruction_out out : instruction;
		program_counter_out out : address;


	);
end entity;


architecture behav of fetch is

signal pc, next_pc : address;

begin

program_counter_out <= pc;

out_proc : process (clk) 
			begin 
				if rst = '1' then
					pc <= reset_pc;
					instruction_out <= NOP;
				else
					if flush_ctrl = '1' then
						instruction_out <= NOP;
					elsif stall_ctrl = '1' then
						instruction_out <= NOP; 
					elsif mem_ready = '0' then
						instruction_out <= NOP;
					else
						pc <= next_pc;
						instruction_out <= instruction_in;
				end if;
end process;

next_pc_proc : process (branch_ctrl, stall_ctrl, flush_ctrl, mem_ready, rst)
				begin
					if branch_ctrl = '1' then
						next_pc <= branch_address;
					elsif stall_ctrl = '1' then
						next_pc <= pc;
					elsif flush = '1' then 
						next_pc <= std_logic_vector(unsigned(pc) + 4);
					elsif rst = '1' then
						next_pc <= reset_pc;	
					elsif mem_ready = '0' then
						next_pc <= pc;
					else
						next_pc <= std_logic_vector(unsigned(pc) + 4);	
					end if;


end architecture;
