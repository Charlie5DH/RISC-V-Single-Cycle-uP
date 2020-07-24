library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity rising_edge_detector_tb is

end entity rising_edge_detector_tb;

-------------------------------------------------------------------------------

architecture arch of rising_edge_detector_tb is

  -- component ports
  signal CLK   : STD_LOGIC := '0';
  signal rst   : STD_LOGIC := '1';
  signal step : STD_LOGIC := '0';
  signal CLKOut : STD_LOGIC;

  signal CLK_period : time := 50 ns;

begin  -- architecture arch

  -- component instantiation
  DUT: entity work.rising_edge_detector
    port map (
      CLK   => CLK,
      rst   => rst,
      step => step,
      CLKOut => CLKOut);

  CLK_generation : process
  begin
    CLK <= '0';
    wait for CLK_period/2;
    CLK <= '1';
    wait for CLK_period/2;
  end process ; -- CLK_generation

  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for CLK_period;
    rst <= '0';
    step <= not step;
  
  end process WaveGen_Proc;
end architecture arch;

-------------------------------------------------------------------------------

configuration rising_edge_detector_tb_arch_cfg of rising_edge_detector_tb is
  for arch
  end for;
end rising_edge_detector_tb_arch_cfg;

-------------------------------------------------------------------------------
