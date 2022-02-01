library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.generics.all;


entity BTB_control is
port(
		clk, rst : in std_logic;
		pc_if : in address;
		pc_id : in address;
		op_id : in operation;

		stall, branch_outcome : in std_logic;

		--pred_t_t, pred_t_nt, pred_nt_t, pred_nt_nt : out std_logic;

		flush_ctrl : out std_logic;
		branch_target : out address;
		branch_ctrl : out std_logic
);
end entity;

architecture behav of BTB_control is

component reg is
generic (nbit_reg : integer := nbit;
			rst_val : std_logic_vector(nbit-1 downto 0));
port (	
		clk, rst, enable : in std_logic;
		data_in : in std_logic_vector(nbit_reg -1 downto 0);
		data_out : out std_logic_vector(nbit_reg-1 downto 0)
		);
end component;

component BTB is
port (
		clk, rst : in std_logic;
		update_en : in std_logic;

		pc_if : in address;
		pc_id : in address;

		predict_t_nt, predict_t_t, predict_nt_t, predict_nt_nt : in std_logic;

		--flush : out std_logic;
		branch_target : out address;
		match : out std_logic;
		prediction : out std_logic_vector(1 downto 0)
);
end component;

signal branch_to_take, match, predicted_t, flush : std_logic;

signal branch_from_BTB : address;

signal prediction : std_logic_vector(1 downto 0);

signal branch_if : std_logic;

signal pred_t_t, pred_t_nt, pred_nt_t, pred_nt_nt : std_logic;

signal update_en : std_logic;

begin

branch_if <= '1' when op_id = BEQ else
				'0';
flush_ctrl <= flush;

BTB_inst : BTB port map (clk => clk, rst => rst, update_en => update_en,
							pc_if => pc_if, pc_id => pc_id,
						predict_t_nt => pred_t_nt, predict_t_t => pred_t_t,
						predict_nt_t => pred_nt_t, predict_nt_nt => pred_nt_nt,
						branch_target => 	branch_from_BTB,
						match => match,
						prediction => prediction						
							);

branch_to_take <=  '0' when rst = '1' else
					'1' when match = '1' and prediction(1) = '1' else					
					'0';

--reg_inst : reg generic map(1, (others => '0')) port map(clk, rst, '1', branch_to_take, prediction);

reg_proc : process(rst, clk)
		begin			
			if rst = '1' then
				predicted_t <= '0';
			elsif rising_edge(clk) then
				predicted_t <= branch_to_take;
			end if;
end process;

p1 : process(branch_to_take, stall, flush) --branch_ctrl and branch_target process
begin
	if stall = '0' then
		if flush = '0' then
			if branch_to_take = '1' then
				branch_ctrl <= '1';
				branch_target <= branch_from_BTB;
			else
				branch_ctrl <= '0';
				branch_target <= (others => '0');
			end if;
		else
			branch_target <= pc_id;
			branch_ctrl <= '1';
		end if;
	else
		branch_target <= (others => '0');
		branch_ctrl <= '0';
		
	end if;
end process;



p2 : process(branch_outcome, op_id, predicted_t, stall, rst) --prediction correct / missprediction process
begin
		if rst = '1' then
			pred_t_t <= '0';
			pred_t_nt <= '0';
			pred_nt_nt <= '0';
			pred_nt_t <= '0';
			update_en <= '0';
			flush <= '0';

		elsif stall = '0' and op_id = BEQ then
			if branch_outcome = '1' and predicted_t = '1' then
					pred_t_t <= '1';
					pred_t_nt <= '0';
					pred_nt_nt <= '0';
					pred_nt_t <= '0';
					update_en <= '0';
					flush <= '0';
			elsif branch_outcome = '1' and predicted_t = '0' then
					pred_t_t <= '0';
					pred_t_nt <= '0';
					pred_nt_nt <= '0';
					pred_nt_t <= '1';
					update_en <= '1';
					flush <= '1';
			elsif branch_outcome = '0' and predicted_t = '1' then
					pred_t_t <= '0';
					pred_t_nt <= '0';
					pred_nt_nt <= '0';
					pred_nt_t <= '1';
					update_en <= '1';
					flush <= '1';
			elsif branch_outcome = '0' and predicted_t = '0' then
					pred_t_t <= '0';
					pred_t_nt <= '0';
					pred_nt_nt <= '1';
					pred_nt_t <= '0';
					update_en <= '0';
					flush <= '0';	
			end if;
		elsif op_id = JAL then
			pred_t_t <= '0';
			pred_t_nt <= '0';
			pred_nt_nt <= '0';
			pred_nt_t <= '0';
			update_en <= '0';
			flush <= '1';
		else
			pred_t_t <= '0';
			pred_t_nt <= '0';
			pred_nt_nt <= '0';
			pred_nt_t <= '0';
			update_en <= '0';
			flush <= '0';
		end if;
end process;




end architecture;
