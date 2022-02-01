library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity forwarding_unit is
port ( 	
		rst : in std_logic;

		cword_exe : in std_logic; --1 bit for cu for immediate selection

		ex_mem_wr, mem_wb_wr  : in std_logic;

		id_ex_rs1, id_ex_rs2 : in register_address;		

		ex_mem_rd : in register_address;

		mem_wb_rd : in register_address;

		exe_mux1_sel, exe_mux2_sel : out std_logic_vector(1 downto 0)

);
end entity;

architecture behav of forwarding_unit is



begin


exe_mux1_sel <= "10" when ex_mem_wr = '1' and ex_mem_rd = id_ex_rs1 and ex_mem_rd /= (reg_len-1 downto 0 => '0') else
				"11" when mem_wb_wr = '1' and mem_wb_rd = id_ex_rs1 and mem_wb_rd /= (reg_len-1 downto 0 => '0') else
				"00";

exe_mux2_sel <= "10" when ex_mem_wr = '1' and ex_mem_rd = id_ex_rs2 and ex_mem_rd /= (reg_len-1 downto 0 => '0') else
				"11" when mem_wb_wr = '1' and mem_wb_rd = id_ex_rs2 and mem_wb_rd /= (reg_len-1 downto 0 => '0') else
				('0' & cword_exe);


end architecture;
