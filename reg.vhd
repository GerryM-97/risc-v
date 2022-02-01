library ieee;
use ieee.std_logic_1164.all;
use WORK.generics.all;

entity reg is
generic (nbit_reg : integer := nbit;
			rst_val : std_logic_vector(nbit-1 downto 0));
port (	
		clk, rst, enable : in std_logic;
		data_in : in std_logic_vector(nbit_reg -1 downto 0);
		data_out : out std_logic_vector(nbit_reg-1 downto 0)
		);
end entity;

architecture behav of reg is
begin

out_proc : process (clk, rst)
begin
		if rst = '1' then --asynch reset
			data_out <= rst_val(nbit_reg-1 downto 0);
		elsif rising_edge(clk) then
			if enable = '1' then
				data_out <= data_in;
			end if;
end if;
end process;

end architecture;
