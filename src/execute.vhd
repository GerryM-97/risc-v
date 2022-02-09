library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY execute IS
PORT (
		--control signals
		CLK, RST 			: in std_logic;
		OPERATION_EX 		: in operation;
		MUX_SEL_OP1 		: in std_logic_vector(1 DOWNTO 0);
		MUX_SEL_OP2 		: in std_logic_vector(1 DOWNTO 0);

		--input
		DATA1_EX, DATA2_EX 	: in data;
		IMMEDIATE_EX		: in data;
		DATA_FORW_MEM		: in data;
		DATA_FORW_WRB		: in data;
		RD_EX				: in register_address;

		--output
		ADDRESS_MEM			: out address;
		DATA_MEM			: out data;
		RD_MEM				: out register_address
);
END ENTITY;

ARCHITECTURE behav OF execute IS

COMPONENT ALU IS
PORT (	
		--control signals
		ALU_OPERATION 			: in operation;

		--inputs
		OPERAND_1, OPERAND_2 	: in data;
		
		--outputs
		DATA_OUT 				: out data
		
		);
END COMPONENT;

SIGNAL ALU_OP1, ALU_OP2, ALU_OUT : data;

BEGIN

alu_op1_mux : ALU_OP1 <= DATA_FORW_MEM WHEN MUX_SEL_OP1 = "10" ELSE		
						 DATA_FORW_WRB WHEN MUX_SEL_OP1 = "11" ELSE
						 DATA1_EX;

alu_op2_mux : ALU_OP2 <= DATA2_EX 	   WHEN MUX_SEL_OP2 = "00" ELSE
						 IMMEDIATE_EX  WHEN MUX_SEL_OP2 = "01" ELSE	 
						 DATA_FORW_MEM WHEN MUX_SEL_OP2 = "10" ELSE		
						 DATA_FORW_WRB WHEN MUX_SEL_OP2 = "11";

alu_inst  : ALU PORT MAP(OPERATION_EX, ALU_OP1, ALU_OP2, ALU_OUT);

out_proc : PROCESS (CLK, RST)
BEGIN
		IF RST = '1' THEN
			ADDRESS_MEM <= (OTHERS => '0');
			DATA_MEM 	<= (OTHERS => '0');
			RD_MEM 		<= (OTHERS => '0');
		ELSIF RISING_EDGE(CLK) THEN
			ADDRESS_MEM <= ALU_OUT;
			DATA_MEM 	<= ALU_OP2;
			RD_MEM 		<= RD_EX;
		END IF;
END PROCESS;

END ARCHITECTURE;
