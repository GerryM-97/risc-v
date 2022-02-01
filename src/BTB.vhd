library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;

entity BTB is
port (
		clk, rst : in std_logic;
		update_en : in std_logic;

		pc_if : in address;
		pc_id : in address; --branch from decode

		predict_t_nt, predict_t_t, predict_nt_t, predict_nt_nt : in std_logic;

		branch_target : out address;
		match : out std_logic;
		prediction : out std_logic_vector(1 downto 0)
);
end entity;

architecture behav of BTB is

type BHT_arr is array (0 to 31) of address;
type target_add_arr is array (0 to 31) of address;
type predictor_arr is array (0 to 31) of std_logic_vector(1 downto 0);

signal BHT : BHT_arr;
signal target_add : target_add_arr;
signal predictor : predictor_arr;
signal entry, old_entry : integer := 0;

signal old_pc : address;

begin

entry <= to_integer(unsigned(pc_if(6 downto 2))) when rst = '0' else
		 0;


rd_proc : process(pc_if, rst)
begin
		if rst = '1' then
			branch_target <= (others => '0');
			match <= '0'; 
			prediction <= (others => '0');
		else
			branch_target <= target_add(entry);
			prediction <= predictor(entry);
			if pc_if = BHT(entry) then
				match <= '1';
			else
				match <= '0';
			end if;
		end if;
end process;

wr_proc : process (clk, rst) 
begin
		if rst = '1' then
			BHT <= (others => (others => '0'));
			target_add <= (others => (others => '0'));
			old_pc <= (others => '0');
		elsif rising_edge(clk) then
			old_pc <= pc_if; --potrebbe non funzionare 
			old_entry <= entry;
			if update_en = '1' then
				BHT(old_entry) <= old_pc;
				target_add(old_entry) <= pc_id;
			end if;
			
		end if;
end process;

predict_proc_wr : process(clk, rst) 
	begin
		if rst = '1' then
			predictor <= (others => (others => '0'));
		elsif rising_edge(clk) then
			--if update_en = '1' then
				if predict_t_t = '1' then --predicted taken and taken so if was "11" no update, if was "10" update to "11"
					if predictor(entry) = "10" then
						predictor(entry) <= "11";
					end if;
				elsif predict_t_nt = '1' then --predicted taken and not taken, so if was "11" update to "10", if was "10" update to "00"
					if predictor(entry) = "11" then
						predictor(entry) <= "10";
					else
						predictor(entry) <= "00";
					end if;
				elsif predict_nt_t = '1' then		
					if predictor(entry) = "00" then
						predictor(entry) <= "01";
					else
						predictor(entry) <= "11";
					end if;
				elsif predict_nt_nt = '1' then
					if predictor(entry) = "01" then
						predictor(entry) <= "00";
					end if;
				end if;
			--end if;
		end if;
end process;

end architecture;
