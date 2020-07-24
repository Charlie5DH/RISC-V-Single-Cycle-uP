
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rising_edge_detector is
    Port ( 
		CLK 		: in  STD_LOGIC;
        rst 		: in  STD_LOGIC;
		step 		: in  STD_LOGIC;
		CLKOut 		: out  STD_LOGIC
	);
end rising_edge_detector;

architecture Behavioral of rising_edge_detector is
type rising_edge_detector_fsm_states is (ZERO, EDGE, ONE);

signal rising_edge_detector_fsm_curr_st : rising_edge_detector_fsm_states;
signal rising_edge_detector_fsm_next_st : rising_edge_detector_fsm_states;

begin

rising_edge_state_transition_logic: process(CLK, rst)
begin
if rising_edge(CLK) then
	if rst = '0' then
		rising_edge_detector_fsm_curr_st <= ZERO; 
	else
		rising_edge_detector_fsm_curr_st <= rising_edge_detector_fsm_next_st; 
	end if;
end if;	
end process;

rising_edge_next_state_logic: process(step, rising_edge_detector_fsm_curr_st)
begin
	rising_edge_detector_fsm_next_st <= rising_edge_detector_fsm_curr_st;
	case rising_edge_detector_fsm_curr_st is
	
		when ZERO =>
			if step = '1' then
				rising_edge_detector_fsm_next_st <= EDGE;
			end if;
			
		when EDGE =>
			if step = '1' then
				rising_edge_detector_fsm_next_st <= ONE;
			else
				rising_edge_detector_fsm_next_st <= ZERO;
			end if;			
		
		when ONE =>
			if step = '0' then
				rising_edge_detector_fsm_next_st <= ZERO;
			end if;
		
	end case;
end process;

rising_edge_output_logic: process(rising_edge_detector_fsm_curr_st)
begin
	CLKOut <= '0';
	if rising_edge_detector_fsm_curr_st = EDGE then
		CLKOut <= '1';
	end if;
end process;

end Behavioral;

