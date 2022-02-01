library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity control_unit is
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
end entity;

architecture behav of control_unit is

component reg is
generic (nbit_reg : integer := nbit;
		rst_val : std_logic_vector(nbit-1 downto 0));
port (	
		clk, rst, enable : in std_logic;
		data_in : in std_logic_vector(nbit_reg -1 downto 0);
		data_out : out std_logic_vector(nbit_reg-1 downto 0)
		);
end component;

signal op_to_alu : operation;

signal instruction_f_to_exe, instruction_f_to_mem, instruction_f_to_wrb : instruction_format;


signal cword_dec    : std_logic_vector(cword_exe_len -1 downto 0);
signal cword_to_exe : std_logic_vector(cword_exe_len -1 downto 0);
signal cword_to_mem : std_logic_vector(cword_mem_len -1 downto 0);
signal cword_to_wrb : std_logic_vector(cword_wrb_len -1 downto 0);



begin

instruction_f_exe_out <= instruction_f_to_exe;
instruction_f_mem_out <= instruction_f_to_mem;
instruction_f_wrb_out <= instruction_f_to_wrb;

cword_exe <= cword_to_exe;
cword_mem <= cword_to_mem;
cword_wrb <= cword_to_wrb;

pc_to_exe_ctrl <= '0' when rst = '1' else
					'1' when operation_ID = AUIPC or operation_ID = JAL else
				'0';

p1 : process (clk,rst)
begin
		if rst = '1' then
			operation_exe <= ADDI;
			instruction_f_to_exe <= I_type;
			instruction_f_to_mem <= I_type;
			instruction_f_to_wrb <= I_type;
		elsif rising_edge(clk) then
			if stall_ctrl = '1' then
				operation_exe <= ADDI;
				instruction_f_to_exe <= I_type;
				instruction_f_to_mem <= instruction_f_to_exe;
				instruction_f_to_wrb <= instruction_f_to_mem;
			else
				operation_exe <= operation_ID;
				instruction_f_to_exe <= I_type;
				instruction_f_to_mem <= instruction_f_to_exe;
				instruction_f_to_wrb <= instruction_f_to_mem;
			end if;
		end if;
end process;

p2 : process(clk, rst)
begin
		if rst = '1' then
			--pc_to_exe_ctrl <= '0';
			cword_to_exe <= (others => '0');
			cword_to_mem <= (others => '0');
			cword_to_wrb <= (others => '0');
		elsif rising_edge(clk) then
			if stall_ctrl = '1' then
				cword_to_exe <= (others => '0');
				--cword_to_mem <= cword_to_exe(cword_mem_len-1 downto 0);
				--cword_to_wrb <= cword_to_mem(cword_wrb_len-1 downto 0);
			else
				if operation_ID = AUIPC then
                  cword_to_exe <= "110011";
                elsif operation_ID = ADD or operation_ID = SLT or operation_ID = XOR_T   then
                  cword_to_exe <= "000011";
                elsif operation_ID = ADDI or operation_ID = ANDI or operation_ID = SRAI or operation_ID = LUI  then
                  cword_to_exe <= "010011";   
                elsif operation_ID = BEQ  then
                  cword_to_exe <= "000000";
                elsif operation_ID = JAL   then
                  cword_to_exe<= "100011";
                elsif operation_ID = LW  then
                  cword_to_exe <= "011101";
                elsif operation_ID = SW  then
                  cword_to_exe <= "011000";

				end if;
			end if;
			cword_to_mem <= cword_to_exe(cword_mem_len-1 downto 0);
			cword_to_wrb <= cword_to_mem(cword_wrb_len-1 downto 0);
		end if;
end process;


end architecture;
