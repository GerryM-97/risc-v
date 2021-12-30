library ieee;
use ieee.std_logic_1164.all;

package generics is
	constant nbit :  integer := 32;
	constant opcode_len : integer := 7
	constant reset_pc : std_logic_vector(nbit -1 downto 0) := (others => '0');
	constant NOP : std_logic_vector(nbit-1 downto 0) := (31 downto 5 => '0') & "0010011"; 
	
	type address : std_logic_vector(nbit-1 downto 0);
	type instruction : std_logic_vector(nbit-1 downto 0);

end package;
