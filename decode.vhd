library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity decode is
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
end entity;

architecture struct of decode is

component reg is
generic (nbit_reg : integer := nbit;
			rst_val : std_logic_vector(nbit-1 downto 0));
port (	
		clk, rst, enable : in std_logic;
		data_in : in std_logic_vector(nbit_reg -1 downto 0);
		data_out : out std_logic_vector(nbit_reg-1 downto 0)
		);
end component;

component immediate_gen is
port(
		--instruction type
		instruction_t : in instruction_format;

		--input
		instruction : in instruction;

		--output
		immediate_out : out data
);
end component;

component reg_file is
port ( 
		--control signals
		clk, rst : in std_logic;
		wr_en : in std_logic;

		--inputs
		address_rd1, address_rd2, address_wr : in register_address;
		wr_data : in data;

		--outputs
		data_p1, data_p2 : out data

);
end component;

signal regf_p1, regf_p2, immediate : data;
signal data_to_exe1 : address;

begin

data_to_exe1 <= pc_in when pc_out_ctrl = '1' else
				regf_p1;

branch <= '1' when regf_p1 = regf_p2 and instruction_f = B_type else
			'0';

branch_address <= std_logic_vector(unsigned(immediate) + unsigned(pc_in)) when instruction_f = B_type or instruction_f = J_type else
				  (others => '0');

imm_gen_inst : immediate_gen port map(instruction_f, instruction_in, immediate);

reg_file_inst : reg_file port map(clk, rst, wr_en, instruction_in(19 downto 15), instruction_in(24 downto 20), wr_add, wr_data, regf_p1, regf_p2);

out_reg1 : reg generic map(nbit, (others => '0') ) port map(clk, rst, '1', data_to_exe1, data_p1);
out_reg2 : reg generic map(nbit, (others => '0') ) port map(clk, rst, '1', regf_p2, data_p2);
out_imm :  reg generic map(nbit, (others => '0') ) port map(clk, rst, '1', immediate, immediate_out);

out_rs1 : reg generic map(5, (others => '0') ) port map(clk, rst, '1', instruction_in(19 downto 15), rs1);
out_rs2 : reg generic map(5, (others => '0') ) port map(clk, rst, '1', instruction_in(24 downto 20), rs2);
out_rd : reg generic map(5, (others => '0') ) port map(clk, rst, '1', instruction_in(11 downto 7), rd);

end architecture;
