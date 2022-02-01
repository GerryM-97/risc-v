library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity memory is
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
end entity;

architecture struct of memory is

component reg is
generic (nbit_reg : integer := nbit;
			rst_val : std_logic_vector(nbit-1 downto 0));
port (	
		clk, rst, enable : in std_logic;
		data_in : in std_logic_vector(nbit_reg -1 downto 0);
		data_out : out std_logic_vector(nbit_reg-1 downto 0)
		);
end component;

begin

add_to_mem <= mem_add;
data_to_mem <= mem_data;

mem_rd_nwr_out <= mem_rd_nwr_in;
mem_en_out <= mem_en_in;

mem_data_reg : 		reg generic map(nbit, (others => '0')) port map(clk, rst, '1', data_from_mem, data_mem_out);

mem_bypass_reg :	reg generic map(nbit, (others => '0')) port map(clk, rst, '1', mem_add, data_bypass);

rd_reg : 			reg generic map(5, (others => '0')) port map(clk, rst, '1', rd_in, rd_out);


end architecture;
