library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY memory IS
PORT(
		--control signals
		CLK, RST 		: in std_logic;
		DRAM_EN_IN 		: in std_logic;	
		DRAM_RD_NWR_IN 	: in std_logic;
		
		DRAM_EN_OUT 	: out std_logic;
		DRAM_RD_NWR_OUT : out std_logic;

		--inputs 
		ADDRESS_MEM 	: in address;
		DATA_MEM 		: in data;
		DRAM_DATA 		: in data;
		RD_MEM 			: in register_address;

		--outputs
		DRAM_ADD 		: out address;
		DRAM_WR_DATA 	: out data;
		DATA_WRB	 	: out data;
		DATA_BYPASS_WRB : out data;
		RD_WRB 			: out register_address
);
END ENTITY;

ARCHITECTURE struct OF memory IS

BEGIN

DRAM_ADD 		<= ADDRESS_MEM;
DRAM_WR_DATA 	<= DATA_MEM;

DRAM_RD_NWR_OUT <= DRAM_RD_NWR_IN;
DRAM_EN_OUT 	<= DRAM_EN_IN;

out_proc : PROCESS(RST, CLK)
BEGIN
		IF RST = '1' THEN
			DATA_WRB 			<= (OTHERS => '0');
			DATA_BYPASS_WRB 	<= (OTHERS => '0');
			RD_WRB 				<= (OTHERS => '0');
		ELSIF  RISING_EDGE(CLK) THEN
			IF DRAM_EN_IN = '1' THEN
				DATA_WRB 			<= DRAM_DATA;
			END IF;
			DATA_BYPASS_WRB 	<= ADDRESS_MEM;
			RD_WRB 				<= RD_MEM;
		END IF;
END PROCESS;

END ARCHITECTURE;
