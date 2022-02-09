library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY immediate_gen IS
PORT(
		--instruction type
		INSTRUCTION_F_IN : in instruction_format;

		--input
		INSTRUCTION_IN 	 : in instruction;

		--output
		IMMEDIATE_OUT 	 : out data
);
END ENTITY;

ARCHITECTURE struct OF immediate_gen IS
BEGIN

IMMEDIATE_OUT <= 
		((31 downto 12 => INSTRUCTION_IN(nbit-1)) & INSTRUCTION_IN(nbit-1 downto 20)) 														when INSTRUCTION_F_IN = I_type else
		((31 downto 12 => INSTRUCTION_IN(nbit-1)) & INSTRUCTION_IN(nbit-1 downto 25) & INSTRUCTION_IN(11 downto 7) ) 					    when INSTRUCTION_F_IN = S_type else
		((31 downto 12 => INSTRUCTION_IN(nbit-1)) & INSTRUCTION_IN(7) & INSTRUCTION_IN(30 downto 25) & INSTRUCTION_IN(11 downto 8) & '0' )  when INSTRUCTION_F_IN = B_type else
		(INSTRUCTION_IN(31 downto 12) & ( 11 downto 0 => '0') ) 																			when INSTRUCTION_F_IN = U_type else
		((31 downto 20 => INSTRUCTION_IN(31)) & INSTRUCTION_IN(19 downto 12) & INSTRUCTION_IN(20) & INSTRUCTION_IN(30 downto 21) & '0' )	when INSTRUCTION_F_IN = J_type else
		(others => '0');

END ARCHITECTURE;
