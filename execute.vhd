library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity execute is
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
end entity;

architecture struct of execute is

component ALU is
port (	
		--control signals
		alu_func : in operation;

		--inputs
		operand_1, operand_2 : in data;
		
		--outputs
		data_out : out data
		--zero : out std_logic
		
		);
end component;

component reg is
generic (nbit_reg : integer := nbit;
			rst_val : std_logic_vector(nbit-1 downto 0));
port (	
		clk, rst, enable : in std_logic;
		data_in : in std_logic_vector(nbit_reg -1 downto 0);
		data_out : out std_logic_vector(nbit_reg-1 downto 0)
		);
end component;

signal alu_op1, alu_op2,alu_out : data;

begin

alu_op1 <=	data_forw_mem when mux_sel_op1 = "10" else		
			data_forw_wrb  when mux_sel_op1 = "11" else
			data_p1;

alu_op2 <=  data_forw_mem when mux_sel_op2 = "10" else
			data_forw_wrb when mux_sel_op2 = "11" else
			data_p2 	  when mux_sel_op2 = "00" else
			immediate	  when mux_sel_op2 = "01" else
			(others => '0');

alu_inst : ALU port map(op_in, alu_op1, alu_op2, alu_out);

mem_data_out : reg generic map(nbit, (others => '0')) port map(clk, rst, '1', alu_out, mem_address);
mem_add_out  : reg generic map(nbit, (others => '0')) port map(clk, rst, '1', alu_op2, mem_data);
rd_out		 : reg generic map(5,  	 (others => '0')) port map(clk, rst, '1', rd_in, rd);

end architecture;
