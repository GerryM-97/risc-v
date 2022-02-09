library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

ENTITY hazard_unit IS
PORT (
		--inputs
		CLK, RST : in std_logic;
		RS1_ID, RS2_ID, RD_EX : in register_address;
		WR_EX : in std_logic;

		--outputs
		STALL_CTRL : out std_logic
);
END ENTITY;

ARCHITECTURE behav OF hazard_unit IS
BEGIN

stall_proc : PROCESS(RST, WR_EX, RD_EX, RS1_ID, RS2_ID)
BEGIN
		IF RST = '1' THEN
			STALL_CTRL <= '0';
		ELSIF WR_EX = '1' THEN
			IF RD_EX /= (reg_len-1 DOWNTO 0 => '0') THEN
				IF RD_EX = RS1_ID OR RD_EX = RS2_ID THEN
					STALL_CTRL <= '1';
				ELSE
					STALL_CTRL <= '0';
				END IF;
			ELSE
				STALL_CTRL <= '0';
			END IF;
		ELSE
			STALL_CTRL <= '0';
		END IF;
END PROCESS;

END ARCHITECTURE;
