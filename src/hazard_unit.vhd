library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity hazard_unit is
port (	--inputs
		clk, rst : in std_logic;
		rs1, rs2, exe_rd : in register_address;
		exe_wr : in std_logic;

		--outputs
		stall_ctrl : out std_logic

);
end entity;

architecture struct of hazard_unit is

begin

stall_ctrl <= '0' when rst = '1' else
			  '1' when exe_wr = '1' and (exe_rd = rs1 or exe_rd = rs2) and exe_rd /= (reg_len-1 downto 0 => '0') else
			  '0';

--stall_proc : process(clk, rst)
--begin
--		if rst = '1' then
--			stall_ctrl <= '0';
--		elsif rising_edge(clk) then
--			if exe_wr = '1' and (exe_rd = rs1 or exe_rd = rs2) and exe_rd /= (reg_len-1 downto 0 => '0') then
--				stall_ctrl <= '1';
--			else
--				stall_ctrl <= '0';
--			end if;
		
--		end if;
--end process;

end architecture;
