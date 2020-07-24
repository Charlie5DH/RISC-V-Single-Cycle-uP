-- VHDL implementation of RISC-V-ISA
-- Copyright (C) 2016 Chair of Computer Architecture
-- at Technical University of Munich
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.


library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity toplevel is
port (
    -- Clocks --
    clk_50mhz   : in   std_logic;

    -- User Interface --
    sw   : in std_logic_vector(3 downto 0);
    btn  : in std_logic_vector(4 downto 0);
    leds : out std_logic_vector(7 downto 0) ;

    -- DDR2 SDRAM-Port-Pins --
    cntrl0_ddr2_a       : out std_logic_vector(12 downto 0) := (others => '0');
    cntrl0_ddr2_ba      : out std_logic_vector(1 downto 0) := (others => '0');
    cntrl0_ddr2_ck      : out std_logic_vector(0 downto 0) := (others => '0');
    cntrl0_ddr2_ck_n    : out std_logic_vector(0 downto 0) := (others => '0');
    cntrl0_ddr2_cke     : out std_logic := '0';
    cntrl0_ddr2_cs_n    : out std_logic := '0';
    cntrl0_ddr2_ras_n   : out std_logic := '0'; 
    cntrl0_ddr2_cas_n   : out std_logic := '0';
    cntrl0_ddr2_we_n    : out std_logic := '0';
    cntrl0_ddr2_odt     : out std_logic := '0';
    cntrl0_ddr2_dm      : out std_logic_vector(1 downto 0) := (others => '0');
    cntrl0_ddr2_dqs_n   : inout std_logic_vector(1 downto 0) := (others => '0');
    cntrl0_ddr2_dqs     : inout std_logic_vector(1 downto 0) := (others => '0');
    cntrl0_ddr2_dq      : inout std_logic_vector(15 downto 0) := (others => '0');
    cntrl0_rst_dqs_div_in   : in std_logic;
    cntrl0_rst_dqs_div_out  : out std_logic;	

    -- VGA --
    r           : out   std_logic_vector(3 downto 0);
    g           : out   std_logic_vector(3 downto 0);
    b           : out   std_logic_vector(3 downto 0);
    hsync       : out   std_logic;
    vsync       : out   std_logic;

    -- UART --
    rx : in std_logic
);
end toplevel;


architecture behaviour of toplevel is

----------------------------------------------------
-- Components                                     --
----------------------------------------------------

-- Clocking --
COMPONENT Clock_VHDL is
PORT (
    clk_in_133MHz : in std_logic;
    clk_out_1Hz : out std_logic
);
END COMPONENT Clock_VHDL;

component clk133m_dcm is
port ( CLKIN_IN        : in    std_logic; 
    CLKFX_OUT       : out   std_logic; 
    CLKIN_IBUFG_OUT : out   std_logic; 
    CLK0_OUT        : out   std_logic; 
    CLK2X_OUT       : out   std_logic; 
    LOCKED_OUT      : out   std_logic);
end component clk133m_dcm;

component UART
port (
	 clk  : in  std_logic;
	 rst  : in  std_logic;
	 rx   : in  std_logic;
	 
	 err   : out std_logic;
	 valid : out std_logic;
	 data  : out std_logic_vector(7 downto 0));
end component UART;


component ASCIIUNIT
port ( 
    clk: in std_logic;
    char_in : in  STD_LOGIC_VECTOR(7 downto 0);
    x_in : in  std_logic_vector(9 downto 0);
    y_in : in  std_logic_vector(9 downto 0);
    pixel_out : out  STD_LOGIC;
    addr_out : out  STD_LOGIC_VECTOR(10 downto 0)
);
end component;


-- VGA --
COMPONENT vga
PORT(
    clk : IN std_logic;
    rst : IN std_logic;

    rgb : IN std_logic_vector(11 downto 0);          
    x : OUT std_logic_vector(9 downto 0);
    y : OUT std_logic_vector(9 downto 0);
    offs : OUT std_logic;
    r : OUT std_logic_vector(3 downto 0);
    g : OUT std_logic_vector(3 downto 0);
    b : OUT std_logic_vector(3 downto 0);
    h : OUT std_logic;
    v : OUT std_logic;
    reg_data_in : in std_logic_vector(31 downto 0);
    reg_adr_in  : in std_logic_vector(5 downto 0);
    pc_in : in std_logic_vector(31 downto 0);
    ir_in : in std_logic_vector(31 downto 0);
	 
    debug_on    : in std_logic; --debug : regs else ascii				
    x_out        : out std_logic_vector(9 downto 0);
    y_out       : out std_logic_vector(9 downto 0);
    pixel       : in std_logic
);
END COMPONENT;

COMPONENT vga_clk
PORT(
    CLKIN_IN   : in    std_logic; 
    RST_IN     : in    std_logic; 
    CLKDV_OUT  : out   std_logic; 
    CLK0_OUT   : out   std_logic; 
    LOCKED_OUT : out   std_logic);
END COMPONENT;	

-- DDR2 Control --
COMPONENT MMU is
PORT (
		--Clocking and reset ports
		reset_in : in std_logic;
		clk_in : in std_logic;
		clk90_in : in std_logic;

		--Ports connected to CPU
		data_out: out std_logic_vector(31 downto 0);
		data_in: in std_logic_vector(31 downto 0);
		addr_in: in std_logic_vector(31 downto 0);
		cmd_in: in std_logic_vector(2 downto 0);
		work_in : in std_logic;
		ack_out : out std_logic;
		
		--Ports connected to DRR2_RAM_CORE
		init_done : in std_logic;
		command_register : out std_logic_vector(2 downto 0);
		input_adress : out std_logic_vector(24 downto 0);
		input_data : out std_logic_vector(31 downto 0);
		output_data : in std_logic_vector(31 downto 0);
		cmd_ack : in std_logic;
		data_valid : in std_logic;
		burst_done : out std_logic;
		auto_ref_req : in std_logic;
		
		char_out: out std_logic_vector(7 downto 0);	
		char_addr_in : in std_logic_vector( 10 downto 0);
		
		pins_in : in std_logic_vector(31 downto 0);
		pins_out : out std_logic_vector(15 downto 0);
		
		mmu_state_out : out std_logic_vector(31 downto 0);
		ddr2_cntrl_state_out : out std_logic_vector(31 downto 0)
);
END COMPONENT MMU;

COMPONENT DDR2_Ram_Core is
PORT (
    cntrl0_ddr2_dq : inout std_logic_vector(15 downto 0);
    cntrl0_ddr2_a : out std_logic_vector(12 downto 0);
    cntrl0_ddr2_ba : out std_logic_vector(1 downto 0);
    cntrl0_ddr2_cke : out std_logic;
    cntrl0_ddr2_cs_n : out std_logic;
    cntrl0_ddr2_ras_n : out std_logic;
    cntrl0_ddr2_cas_n : out std_logic;
    cntrl0_ddr2_we_n : out std_logic;
    cntrl0_ddr2_odt : out std_logic;
    cntrl0_ddr2_dm : out std_logic_vector(1 downto 0);
    cntrl0_rst_dqs_div_in : in std_logic;
    cntrl0_rst_dqs_div_out : out std_logic;		
    sys_clk_in : in std_logic;
    reset_in_n : in std_logic;
    cntrl0_burst_done : in std_logic;
    cntrl0_init_done : out std_logic;
    cntrl0_ar_done : out std_logic;
    cntrl0_user_data_valid : out std_logic;
    cntrl0_auto_ref_req : out std_logic;
    cntrl0_user_cmd_ack : out std_logic;
    cntrl0_user_command_register : in std_logic_vector(2 downto 0);
    cntrl0_clk_tb : out std_logic;
    cntrl0_clk90_tb : out std_logic;
    cntrl0_sys_rst_tb : out std_logic;
    cntrl0_sys_rst90_tb : out std_logic;
    cntrl0_sys_rst180_tb : out std_logic;
    cntrl0_user_output_data : out std_logic_vector(31 downto 0);
    cntrl0_user_input_data : in std_logic_vector(31 downto 0);
    cntrl0_user_data_mask : in std_logic_vector(3 downto 0);
    cntrl0_user_input_address : in std_logic_vector(24 downto 0);
    cntrl0_ddr2_dqs : inout std_logic_vector(1 downto 0);
    cntrl0_ddr2_dqs_n : inout std_logic_vector(1 downto 0);
    cntrl0_ddr2_ck : out std_logic_vector(0 downto 0);
    cntrl0_ddr2_ck_n : out std_logic_vector(0 downto 0)
);
END COMPONENT DDR2_Ram_Core;

signal reset_n  : std_logic;

-- User interface -----------------------------------------------
signal reset    : std_logic;
signal slow     : std_logic;
signal debug_en : std_logic;
signal pins_in  : std_logic_vector(31 downto 0);
signal pins_out : std_logic_vector(15 downto 0);

-- VGA ----------------------------------------------------------
signal clk25 : std_logic;
signal rgb : std_logic_vector(11 downto 0) := (others => '0');
signal x, y : std_logic_vector(9 downto 0);
signal offs : std_logic;

-- CPU ----------------------------------------------------------
signal debug : std_logic_vector(31 downto 0);
signal debug_adr : std_logic_vector(5 downto 0);
signal pc : std_logic_vector(31 downto 0);
signal ir : std_logic_vector(31 downto 0);
signal err_out : std_logic;

signal clk_cpu : std_logic;

-- DDR2 SDRAM-Leitungen -----------------------------------------
signal we_rise		: std_logic;
signal rd_rise		: std_logic;
signal maddr: std_logic_vector(15 downto 0);
signal SDRAM_DO: std_logic_vector(7 downto 0);
signal cpu_ram_d_to_cv_s,
cpu_ram_d_from_cv_s : std_logic_vector( 7 downto 0);
signal cart_a_s            : std_logic_vector(14 downto 0);

signal clk_tb : std_logic;
signal clk90_tb : std_logic;
signal burst_done : std_logic;
signal user_command_register : std_logic_vector(2 downto 0) := (others => '0');
signal user_data_mask : std_logic_vector(3 downto 0):= (others => '0');
signal user_input_data : std_logic_vector(31 downto 0);
signal user_input_address : std_logic_vector(24 downto 0);
signal v_init_done : std_logic;
signal ar_done : std_logic;
signal auto_ref_req : std_logic;
signal user_cmd_ack : std_logic;
signal user_data_valid : std_logic;
signal user_output_data	: std_logic_vector(31 downto 0);

signal ddr2_led : std_logic;

signal CLK_130M : std_logic;
signal CLKB_130M : std_logic;
signal CLK50M : std_logic;

-- Signals to connect CPU with MMU (declaration follows MMUs interface)
signal   mmu_data_in:  std_logic_vector(31 downto 0);
signal	 mmu_data_out:  std_logic_vector(31 downto 0);
signal	 mmu_addr_in:  std_logic_vector(31 downto 0);
signal	 mmu_cmd_in:  std_logic_vector(2 downto 0);
signal	 mmu_work_in :  std_logic;
signal	 mmu_ack_out :  std_logic;
signal	 mmu_state_out : std_logic_vector(31 downto 0);
signal   mmu_ddr2_state_out : std_logic_vector(31 downto 0);

-- Asci unit signals
signal ascii_char_in : std_logic_vector(7 downto 0);
signal ascii_x_in :  std_logic_vector(9 downto 0);
signal ascii_y_in :  std_logic_vector(9 downto 0);
signal ascii_pixel_out :  STD_LOGIC;
signal ascii_addr_out :  STD_LOGIC_VECTOR(10 downto 0);
	
--Uart connection
signal uart_data : std_logic_vector(7 downto 0);
signal uart_valid : std_logic;
signal uart_err : std_logic;

begin

-----------------------------------------------------------------------------
-- Reset & LEDs
-----------------------------------------------------------------------------

reset <= sw(0);
slow <= sw(1);
debug_en <= sw(2);
pins_in <= "000000" & uart_err & uart_valid & uart_data(7 downto 0) & sw(3 downto 0) & btn(4 downto 0) & "0000000";
reset_n <= not reset;

leds(7 downto 3) <= (others => '0') when sw(3) = '1' else pins_out(7 downto 3);
leds(2) <= err_out when sw(3) = '1' else pins_out(2);
leds(1) <= slow when sw(3) = '1' else pins_out(1);
leds(0) <= ddr2_led when sw(3) = '1' else pins_out(0);

-----------------------------------------------------------------------------
-- Clock Generator
-----------------------------------------------------------------------------
	
INST_Clock_VHDL : Clock_VHDL
PORT MAP (	
    clk_in_133MHz => clk_tb,		
    clk_out_1Hz => ddr2_led
);

clk133 : clk133m_dcm
port map( 
    CLKIN_IN    => CLK_50MHZ, 
    CLKFX_OUT      => CLK_130M,
    CLKIN_IBUFG_OUT => open, 
    CLK0_OUT        => clk50m, 
    CLK2X_OUT       => open,
    LOCKED_OUT      => open
    );
         
clk_obuf : OBUF port map ( I => CLK_130M, O => CLKB_130M ); 
  
  
inst_asciiunit : ASCIIUNIT PORT MAP(
 clk => clk25,
 char_in => ascii_char_in,
 x_in => ascii_x_in,
 y_in => ascii_y_in,
 pixel_out => ascii_pixel_out,
 addr_out => ascii_addr_out
);
  
  
-----------------------------------------------------------------------------
-- VGA
-----------------------------------------------------------------------------

Inst_vga: vga PORT MAP(
    clk => clk25,
    rst => reset,
    rgb => rgb,
    x => x,
    y => y,
    offs => offs,
    r => r,
    g => g,
    b => b,
    h => hsync,
    v => vsync,
    reg_data_in => debug,
    reg_adr_in => debug_adr,
    pc_in => pc,
    ir_in => ir,
	 
    debug_on => debug_en,
    x_out   => ascii_x_in,
    y_out   => ascii_y_in,
    pixel   => ascii_pixel_out
);
	
Inst_vga_clk: vga_clk PORT MAP(
    CLKIN_IN => clk50m,
    RST_IN => reset,
    CLKDV_OUT => clk25,
    CLK0_OUT => clk_cpu,
    LOCKED_OUT => open
);  

-----------------------------------------------------------------------------
-- CPU
-----------------------------------------------------------------------------

CPU: entity work.cpu PORT MAP(
	cpu_rst_in => reset,
	cpu_clk_in => clk_cpu, --clk25,
	cpu_debug_pc_out => pc,
	cpu_debug_ir_out => ir,
	cpu_debug_data_out => debug,
	cpu_debug_adr_out => debug_adr,
	cpu_slow_in => slow,
	cpu_err_out => err_out,		

	cpu_mmu_data_in  => mmu_data_out,
	cpu_mmu_data_out => mmu_data_in,
	cpu_mmu_adr_out  => mmu_addr_in,
	cpu_mmu_com_out  => mmu_cmd_in,
	cpu_mmu_work_out => mmu_work_in,
	cpu_mmu_ack_in   => mmu_ack_out
); 
  
-----------------------------------------------------------------------------
-- UART
-----------------------------------------------------------------------------  

INST_UART : UART
PORT MAP (
	 clk  => clk_cpu,
	 rst  => reset,
	 rx   => rx,
	 
	 err   => uart_err,
	 valid => uart_valid,
	 data => uart_data
);

  
-----------------------------------------------------------------------------
-- DDR2
-----------------------------------------------------------------------------

maddr <= '0' & cart_a_s(14 downto 0);
rd_rise <= '0';
we_rise <= '0';

INST_MMU : MMU
PORT MAP (
	reset_in => Reset,
	clk_in => clk_tb,
	clk90_in => clk90_tb,
	
	--Connecting CPU signals to MMU
	data_out =>mmu_data_out,
	data_in =>mmu_data_in,
	addr_in =>mmu_addr_in,
	cmd_in =>mmu_cmd_in,
	work_in =>mmu_work_in,
	ack_out =>mmu_ack_out,

	-- ddr2	
	init_done => v_init_done, --in
	command_register => user_command_register, --out
	input_adress => user_input_address, --out
	input_data => user_input_data, --out 
	output_data => user_output_data, --in
	cmd_ack => user_cmd_ack, --in
	data_valid => user_data_valid, --in
	burst_done => burst_done, --out
	auto_ref_req => auto_ref_req, --in
	
	char_out =>	ascii_char_in,
	char_addr_in => ascii_addr_out,
	
	pins_in(31 downto 0) => pins_in,
	pins_out(15 downto 0) => pins_out,
	
	mmu_state_out => mmu_state_out,
	ddr2_cntrl_state_out => mmu_ddr2_state_out


);

INST_DDR2_RAM_CORE : DDR2_Ram_Core
PORT MAP (
    sys_clk_in => CLKB_130M,
    reset_in_n => Reset_n,
    cntrl0_burst_done => burst_done,
    cntrl0_user_command_register => user_command_register,
    cntrl0_user_data_mask => user_data_mask,
    cntrl0_user_input_data => user_input_data,
    cntrl0_user_input_address => user_input_address,
    cntrl0_init_done => v_init_done,
    cntrl0_ar_done => ar_done,
    cntrl0_auto_ref_req => auto_ref_req,
    cntrl0_user_cmd_ack => user_cmd_ack,
    cntrl0_clk_tb => clk_tb,
    cntrl0_clk90_tb => clk90_tb,
    cntrl0_sys_rst_tb => open,
    cntrl0_sys_rst90_tb => open,
    cntrl0_sys_rst180_tb => open,
    cntrl0_user_data_valid => user_data_valid,
    cntrl0_user_output_data => user_output_data,			
    cntrl0_ddr2_ras_n => cntrl0_ddr2_ras_n,
    cntrl0_ddr2_cas_n => cntrl0_ddr2_cas_n,
    cntrl0_ddr2_we_n => cntrl0_ddr2_we_n,
    cntrl0_ddr2_cs_n => cntrl0_ddr2_cs_n,
    cntrl0_ddr2_cke => cntrl0_ddr2_cke,
    cntrl0_ddr2_dm => cntrl0_ddr2_dm,
    cntrl0_ddr2_ba => cntrl0_ddr2_ba,
    cntrl0_ddr2_a => cntrl0_ddr2_a,
    cntrl0_ddr2_ck => cntrl0_ddr2_ck,
    cntrl0_ddr2_ck_n => cntrl0_ddr2_ck_n,
    cntrl0_ddr2_dqs => cntrl0_ddr2_dqs,
    cntrl0_ddr2_dqs_n => cntrl0_ddr2_dqs_n,
    cntrl0_ddr2_dq => cntrl0_ddr2_dq,
    cntrl0_ddr2_odt => cntrl0_ddr2_odt,		
    cntrl0_rst_dqs_div_in => cntrl0_rst_dqs_div_in,
    cntrl0_rst_dqs_div_out => cntrl0_rst_dqs_div_out);	 

end behaviour;
