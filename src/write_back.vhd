library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY write_back IS
PORT (
		--control signal
		MUX_SEL  	: in std_logic;
		WR_RF_IN 	: in std_logic;
	
		--inputs
		DATA_WRB 			: in data;
		DATA_BYPASS_WRB 	: in data;
		RD_WRB_IN 			: in register_address;

		--output
		DATA_OUT 		: out data;
		RD_WRB_OUT 		: out register_address;
		WR_RF_OUT 		: out std_logic
);
END ENTITY;

ARCHITECTURE struct OF write_back IS
BEGIN

RD_WRB_OUT <= RD_WRB_IN;
WR_RF_OUT  <= WR_RF_IN;

DATA_OUT <= DATA_WRB WHEN MUX_SEL = '0' ELSE
			DATA_BYPASS_WRB;

END ARCHITECTURE;
