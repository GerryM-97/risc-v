library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity reg_file is
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
end entity;

architecture behav of reg_file is

signal register_file : register_file_array;

begin

data_rd : process (rst, address_rd1, address_rd2, address_wr, wr_en) --process for asynchronous reading
			begin
				if rst = '1' then
					data_p1 <= (others => '0');
					data_p2 <= (others => '0');	
				else
					if address_rd1 = address_wr and wr_en = '1' then
						data_p1 <= wr_data;
						data_p2 <= register_file(to_integer(unsigned(address_rd2)));
					elsif address_rd2 = address_wr and wr_en = '1' then
						data_p2 <= wr_data;
						data_p1 <= register_file(to_integer(unsigned(address_rd1)));
					else 
						data_p1 <= register_file(to_integer(unsigned(address_rd1))); -- no if-then because at rst the reg file is written with all 0s
						data_p2 <= register_file(to_integer(unsigned(address_rd2)));
					end if;
				end if;

end process;

data_wr : process (clk, rst)  --process for synchronous writing
			begin
				if rst = '1' then
					register_file <= ( others => (others => '0'));
				elsif rising_edge(clk) then
					if wr_en = '1' and address_wr /= (4 downto 0 => '0') then		--register R0 cannot be modified
						register_file(to_integer(unsigned(address_wr))) <= wr_data;
					end if;
				end if;
end process;


end architecture;
