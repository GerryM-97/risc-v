library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity immediate_gen is
port(
		--instruction type
		instruction_t : in instruction_format;

		--input
		instruction : in instruction;

		--output
		immediate_out : out data
);
end entity;

architecture struct of immediate_gen is
begin

immediate_out <= ((31 downto 12 => instruction(nbit-1)) & instruction(nbit-1 downto 20)) when instruction_t = I_type else
				((31 downto 12 => instruction(nbit-1)) & instruction(nbit-1 downto 25) & instruction(11 downto 7) ) when instruction_t = S_type else
				((31 downto 12 => instruction(nbit-1)) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0' ) when instruction_t = B_type else
				(instruction(31 downto 12) & ( 11 downto 0 => '0') ) when instruction_t = U_type else
				((31 downto 20 => instruction(31)) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0' ) when instruction_t = J_type else
				(others => '0');

end architecture;
