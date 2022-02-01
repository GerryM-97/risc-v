library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity write_back is
port (	--control signal
		mux_sel : in std_logic;
		wr_rf_in : in std_logic;
	
		--inputs
		data_from_mem : in data;
		data_bypass : in data;
		rd_in : in register_address;

		data_out : out data;
		rd_out : out register_address;
		wr_rf : out std_logic
);
end entity;

architecture struct of write_back is

begin

rd_out <= rd_in;
wr_rf <= wr_rf_in;

data_out <= data_from_mem when mux_sel = '0' else
			data_bypass;

end architecture;
