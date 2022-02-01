library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity ALU is 
port (	
		--control signals
		alu_func : in operation;

		--inputs
		operand_1, operand_2 : in data;
		
		--outputs
		data_out : out data
		--zero : out std_logic
		
		);
end entity;

architecture behav of ALU is

signal shifted : data;
signal zero : std_logic;

begin

--zero for comparison
--zero <= '1' when signed(operand_1) < signed(operand_2) else '0';
zero <= '1' when (operand_1) < (operand_2) else '0';


data_out <= std_logic_vector(signed(operand_1) + signed(operand_2)) when alu_func = ADD else
			std_logic_vector(signed(operand_1) + signed(operand_2)) when alu_func = ADDI else
			std_logic_vector(signed(operand_1) + signed(operand_2)) when alu_func = AUIPC else 
			operand_2 												when alu_func = LUI else
			std_logic_vector(signed(operand_1) + signed(operand_2)) when alu_func = BEQ else
			std_logic_vector(signed(operand_1) + signed(operand_2)) when alu_func = LW else
			shifted 												when alu_func = SRAI else
			operand_1 and operand_2 								when alu_func = ANDI else	
			operand_1 xor operand_2 								when alu_func = XOR_T else	
			(nbit-1 downto 1 => '0') & zero 						when alu_func = SLT else
			std_logic_vector(signed(operand_1) + 4) 				when alu_func = JAL else
			std_logic_vector(signed(operand_1) + signed(operand_2)) when alu_func = SW else
			(others => '0');


shift_proc : process ( alu_func, operand_1, operand_2) --process for shifting arith right
				variable  shift_out : data; 
				begin
					if (alu_func = SRAI) then
						shift_out := operand_1;
						for i in 0 to to_integer(unsigned(operand_2(4 downto 0))) loop
							shift_out := shift_out(nbit-1) & shift_out(nbit-1 downto 1);
						end loop;
					end if;
shifted <= shift_out;
			
end process;

end architecture;
