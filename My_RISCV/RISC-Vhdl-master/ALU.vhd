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
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity ALU is
	port(
	
	--in
	
	--Basic control
	clk_in: in std_logic;
	rst_in: in std_logic;
	--Data
	cu_data_in1, cu_data_in2:in std_logic_vector(31 downto 0);

	--Adress
	cu_adr_in: in std_logic_vector(4 downto 0);
	--Commands
	cu_com_in: in std_logic_vector(6 downto 0);
	--Synchronization
	cu_work_in : in std_logic;
	
	--out
	cu_data_out: out std_logic_vector(31 downto 0);
	debug_data_out:out std_logic_vector(31 downto 0);
	debug_adr_out: out std_logic_vector(5 downto 0)
	
	);
	
end ALU;

architecture Behavioral of ALU is

	component divUnsigned is
	port(
	 sclr: in STD_LOGIC;
	 rfd : out STD_LOGIC;
	 clk : in STD_LOGIC := 'X';
	 dividend : in STD_LOGIC_VECTOR ( 31 downto 0 );
	 quotient : out STD_LOGIC_VECTOR ( 31 downto 0 );
	 divisor : in STD_LOGIC_VECTOR ( 31 downto 0 );
	 fractional : out STD_LOGIC_VECTOR ( 31 downto 0 )
	);
	end component divUnsigned;

	component divSigned is
	port(
	 sclr: in STD_LOGIC;
	 rfd : out STD_LOGIC;
	 clk : in STD_LOGIC := 'X';
	 dividend : in STD_LOGIC_VECTOR ( 31 downto 0 );
	 quotient : out STD_LOGIC_VECTOR ( 31 downto 0 );
	 divisor : in STD_LOGIC_VECTOR ( 31 downto 0 );
	 fractional : out STD_LOGIC_VECTOR ( 31 downto 0 )
	);
	end component divSigned;
	
	--Opcode related signals
	signal s_op1, s_op2: STD_LOGIC_VECTOR(31 downto 0);
	signal s_opc: STD_LOGIC_VECTOR(6 downto 0);
	signal s_op3: STD_LOGIC_VECTOR(4 downto 0);
	signal state: STD_LOGIC_VECTOR(3 downto 0);
	signal acc: STD_LOGIC_VECTOR(31 downto 0);
	signal debug_signal: STD_LOGIC_VECTOR(31 downto 0);
	signal debug_adr_signal: STD_LOGIC_VECTOR(5 downto 0);
	
	--Register related signals
	signal ram_douta: std_logic_vector(31 downto 0);
	signal ram_doutb: std_logic_vector(31 downto 0);
		 
	--Division related signals
	signal alu_dividend: std_logic_vector(31 downto 0);
	signal alu_divisor: std_logic_vector(31 downto 0);
	signal alu_remainderU: std_logic_vector(31 downto 0);
	signal alu_quotientU: std_logic_vector(31 downto 0);
	signal alu_remainder: std_logic_vector(31 downto 0);
	signal alu_quotient: std_logic_vector(31 downto 0);
	signal alu_rfdU: std_logic;
	signal alu_rfd: std_logic;
	signal division_flank_counter: unsigned(3 downto 0);
	signal division_sclr:std_logic;
		 
	signal mult_result: std_logic_vector(63 downto 0);
	signal shift_ar: std_logic;
	signal ones : unsigned(31 downto 0);

	--32x32 Bit array to store our registers
	type regs is array (1 to 31) of std_logic_vector(31 downto 0); -- 31 free Registers, Register 0 is always 0
		signal reg_data1: regs;
		signal reg_data2: regs;
	
	begin
	
	--Component mapping
	dividerUnsigned: divUnsigned port map(
	 rfd => alu_rfdU,
    clk => clk_in,
    dividend => alu_dividend,
    quotient => alu_quotientU, 
    divisor => alu_divisor,
    fractional => alu_remainderU,
	 sclr => '0'
	);
	
	dividerSigned: divSigned port map(
	 rfd => alu_rfd,
    clk => clk_in,
    dividend => alu_dividend,
    quotient => alu_quotient, 
    divisor => alu_divisor,
    fractional => alu_remainder,
	 sclr => '0'
	);
	
	debug_data_out <= debug_signal;
	debug_adr_out <= debug_adr_signal;

	ones <= x"FFFFFFFF";
	
process (clk_in, rst_in) 
begin
	if(rst_in = '1') then
		division_flank_counter <= "0000";
		division_sclr <='1';
		state <= "0000";
		
	elsif rising_edge(clk_in) then
	
	---- Different operations from here on ----
	
		--state 0 : Get command from control unit + get operands from registers
		if(state = "0000" and cu_work_in = '1') then
			cu_data_out <= x"AAAAAAAA"; 
			
			division_sclr <= '0';
			s_op3 <= cu_adr_in;
			s_opc <= cu_com_in;
			shift_ar <= '0';
			
			
			--First operand
			--Immediate
			if cu_com_in(6) = '0' then
				s_op1 <= cu_data_in1;
				--Register
			elsif cu_com_in(6) = '1' then
					--s_op1 <= x"00000000";
					
				if cu_data_in1 /= std_logic_vector(to_unsigned(0,cu_data_in1'length)) then
						ram_douta <= reg_data1(to_integer(unsigned(cu_data_in1)));
				else
						ram_douta <= x"00000000";
				end if;
				
			end if;
				
			--second operand
			if cu_com_in(5) = '0' then
					s_op2 <= cu_data_in2;
			elsif cu_com_in(5) = '1' then
				--s_op1 <= x"00000000";
					if cu_data_in2 /= std_logic_vector(to_unsigned(0,cu_data_in2'length)) then
						ram_doutb <= reg_data2(to_integer(unsigned(cu_data_in2)));
					else	ram_doutb <= x"00000000";
					end if;
			end if;
			
			state <= "0001";
		end if;

	
		--state1:  calculations
		if(state = "0001") then
		
			case s_opc(4 downto 0) is
			
			--ADD
			when "00000" =>
			
				if s_opc(6)='0' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(s_op1) + unsigned(s_op2));
				elsif s_opc(6)='0' and s_opc(5)='1' then
					acc <= std_logic_vector(unsigned(s_op1) + unsigned(ram_doutb));
				elsif s_opc(6)='1' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(ram_douta) + unsigned(s_op2));
				else
					acc <= std_logic_vector(unsigned(ram_douta) + unsigned(ram_doutb));
				end if;
				
			--SUB
			when "00001" =>
			
			
				if s_opc(6)='0' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(s_op1) - unsigned(s_op2));
				elsif s_opc(6)='0' and s_opc(5)='1' then
					acc <= std_logic_vector(unsigned(s_op1) - unsigned(ram_doutb));
				elsif s_opc(6)='1' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(ram_douta) - unsigned(s_op2));
				else
					acc <= std_logic_vector(unsigned(ram_douta) - unsigned(ram_doutb));
				end if;
			
			--AND
			when "00010" =>
			
				if s_opc(6)='0' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(s_op1) and unsigned(s_op2));
				elsif s_opc(6)='0' and s_opc(5)='1' then
					acc <= std_logic_vector(unsigned(s_op1) and unsigned(ram_doutb));
				elsif s_opc(6)='1' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(ram_douta) and unsigned(s_op2));
				else
					acc <= std_logic_vector(unsigned(ram_douta) and unsigned(ram_doutb));
				end if;
			
			
			--OR
			when "00011" =>
			
				if s_opc(6)='0' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(s_op1) or unsigned(s_op2));
				elsif s_opc(6)='0' and s_opc(5)='1' then
					acc <= std_logic_vector(unsigned(s_op1) or unsigned(ram_doutb));
				elsif s_opc(6)='1' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(ram_douta) or unsigned(s_op2));
				else
					acc <= std_logic_vector(unsigned(ram_douta) or unsigned(ram_doutb));
				end if;
			
				
		
			
			--XOR
			when "00100" =>
			
				if s_opc(6)='0' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(s_op1) xor unsigned(s_op2));
				elsif s_opc(6)='0' and s_opc(5)='1' then
					acc <= std_logic_vector(unsigned(s_op1) xor unsigned(ram_doutb));
				elsif s_opc(6)='1' and s_opc(5)='0' then
					acc <= std_logic_vector(unsigned(ram_douta) xor unsigned(s_op2));
				else
					acc <= std_logic_vector(unsigned(ram_douta) xor unsigned(ram_doutb));
				end if;
			
			
			--Shift Logical Left			
			when "00101" =>
				
					if s_opc(6)='0' and s_opc(5)='0' then
						if s_op2(4 downto 0)="00000" then
							acc <= s_op1;
						else
							acc <= std_logic_vector(shift_left(unsigned(s_op1), to_integer(unsigned(s_op2(4 downto 0)))));
						end if;
					elsif s_opc(6)='0' and s_opc(5)='1' then
						if ram_doutb(4 downto 0)="00000" then
							acc <= s_op1;
						else
							acc <= std_logic_vector(shift_left(unsigned(s_op1), to_integer(unsigned(ram_doutb(4 downto 0)))));
						end if;
					elsif s_opc(6)='1' and s_opc(5)='0' then
						if s_op2(4 downto 0)="00000" then
							acc <= ram_douta;
						else
							acc <= std_logic_vector(shift_left(unsigned(ram_douta), to_integer(unsigned(s_op2(4 downto 0)))));
						end if;
					else
						if ram_doutb(4 downto 0)="00000" then
							acc <= ram_douta;
						else
							acc <= std_logic_vector(shift_left(unsigned(ram_douta), to_integer(unsigned(ram_doutb(4 downto 0)))));
						end if;
					end if;
				
			--Shift Logical Right
			when "00110" =>
			
				if s_opc(6)='0' and s_opc(5)='0' then
						if s_op2(4 downto 0)="00000" then
							acc <= s_op1;
						else
							acc <= std_logic_vector(shift_right(unsigned(s_op1), to_integer(unsigned(s_op2(4 downto 0)))));
						end if;
					elsif s_opc(6)='0' and s_opc(5)='1' then
						if ram_doutb(4 downto 0)="00000" then
							acc <= s_op1;
						else
							acc <= std_logic_vector(shift_right(unsigned(s_op1), to_integer(unsigned(ram_doutb(4 downto 0)))));
						end if;
					elsif s_opc(6)='1' and s_opc(5)='0' then
						if s_op2(4 downto 0)="00000" then
							acc <= ram_douta;
						else
							acc <= std_logic_vector(shift_right(unsigned(ram_douta), to_integer(unsigned(s_op2(4 downto 0)))));
						end if;
					else
						if ram_doutb(4 downto 0)="00000" then
							acc <= ram_douta;
						else
							acc <= std_logic_vector(shift_right(unsigned(ram_douta), to_integer(unsigned(ram_doutb(4 downto 0)))));
						end if;
					end if;
				
			--Shift arithmetic right
			when "00111" =>
			
				if s_opc(6)='0' and s_opc(5)='0' then
						if s_op2(4 downto 0)="00000" then
							acc <= s_op1;
						else
							acc <= std_logic_vector(shift_right(unsigned(s_op1), to_integer(unsigned(s_op2(4 downto 0)))));
							shift_ar <= s_op1(31);
						end if;
					elsif s_opc(6)='0' and s_opc(5)='1' then
						if ram_doutb(4 downto 0)="00000" then
							acc <= s_op1;
						else
							acc <= std_logic_vector(shift_right(unsigned(s_op1), to_integer(unsigned(ram_doutb(4 downto 0)))));
							shift_ar <= s_op1(31);
						end if;
					elsif s_opc(6)='1' and s_opc(5)='0' then
						if s_op2(4 downto 0)="00000" then
							acc <= ram_douta;
						else
							acc <= std_logic_vector(shift_right(unsigned(ram_douta), to_integer(unsigned(s_op2(4 downto 0)))));
							shift_ar <= ram_douta(31);
						end if;
					else
						if ram_doutb(4 downto 0)="00000" then
							acc <= ram_douta;
						else
							acc <= std_logic_vector(shift_right(unsigned(ram_douta), to_integer(unsigned(ram_doutb(4 downto 0)))));
							shift_ar <= ram_douta(31);
						end if;
					end if;
					
			
				
				
			--Set less than immediate
			when "01000" =>
				if s_opc(6)='0' and s_opc(5)='0' then
					if signed(s_op1) < signed(s_op2) then
						acc <= x"00000001";
					else
						acc <= x"00000000";
					end if;
				elsif s_opc(6)='0' and s_opc(5)='1' then
					if signed(s_op1) < signed(ram_doutb) then
						acc <= x"00000001";
					else
						acc <= x"00000000";
					end if;
				elsif s_opc(6)='1' and s_opc(5)='0' then
					if signed(ram_douta) < signed(s_op2) then
						acc <= x"00000001";
					else
						acc <= x"00000000";
					end if;
				else
					if signed(ram_douta) < signed(ram_doutb) then
						acc <= x"00000001";
					else
						acc <= x"00000000";
					end if;
				end if;
			when "01001" =>
			--set less than immediate (unsigned)
			
				if s_opc(6)='0' and s_opc(5)='0' then
					if unsigned(s_op1) < unsigned(s_op2) then
						acc <= x"00000001";
					else
						acc <= x"00000000";
					end if;
				elsif s_opc(6)='0' and s_opc(5)='1' then
					if unsigned(s_op1) < unsigned(ram_doutb) then
						acc <= x"00000001";
					else
						acc <= x"00000000";
					end if;
				elsif s_opc(6)='1' and s_opc(5)='0' then
					if unsigned(ram_douta) < unsigned(s_op2) then
						acc <= x"00000001";
					else
						acc <= x"00000000";
					end if;
				else
					if unsigned(ram_douta) < unsigned(ram_doutb) then
						acc <= x"00000001";
					else
						acc <= x"00000000";
					end if;
				end if;
				
				
			when "01010" | "01101"=>
			--Multiply lower / Multiply upper unsigned unsigned
				if s_opc(6)='0' and s_opc(5)='0' then
						mult_result <= std_logic_vector(unsigned(s_op1) * unsigned(s_op2));
					elsif s_opc(6)='0' and s_opc(5)='1' then
						mult_result <= std_logic_vector(unsigned(s_op1) * unsigned(ram_doutb));
					elsif s_opc(6)='1' and s_opc(5)='0' then
						mult_result <= std_logic_vector(unsigned(ram_douta) * unsigned(ram_doutb));
					else
						mult_result <= std_logic_vector(unsigned(ram_douta) * unsigned(ram_doutb));
				end if;
			
			when "01011"=>
				--Multiply upper signed signed
				if s_opc(6)='0' and s_opc(5)='0' then
					mult_result <= std_logic_vector(signed(s_op1) * signed(s_op2));
				elsif s_opc(6)='0' and s_opc(5)='1' then
					mult_result <= std_logic_vector(signed(s_op1) * signed(ram_doutb));
			   elsif s_opc(6)='1' and s_opc(5)='0' then
					mult_result <= std_logic_vector(signed(ram_douta) * signed(s_op2));
				else
					mult_result <= std_logic_vector(signed(ram_douta) * signed(ram_doutb));
				end if;
			
			when "01100"=>
				--Multiply upper signed unsigned
				if s_opc(6)='0' and s_opc(5)='0' then
					mult_result <= std_logic_vector(signed(s_op1) * abs(signed(s_op2)));
				elsif s_opc(6)='0' and s_opc(5)='1' then
					mult_result <= std_logic_vector(signed(s_op1) * abs(signed(ram_doutb)));
				elsif s_opc(6)='1' and s_opc(5)='0' then
					mult_result <= std_logic_vector(signed(ram_douta) * abs(signed(s_op2)));
				else
					mult_result <= std_logic_vector(signed(ram_douta) * abs(signed(ram_doutb)));
				end if;
				
				
			--Division signed
			when "01110" =>
				state <= "0100";
				cu_data_out <= x"00000100";
				
				
			when "10000" =>
				state <= "0100";
				cu_data_out <= x"00000200";
			
			--Division unsigned
			when "01111"=>
				state <= "0011";
				cu_data_out <= x"00000300";	

			when "10001" =>
				state <= "0011";
				cu_data_out <= x"00000400";	
				
			when others =>
				
			end case;
			
			
			--Move to writeback state, unless a division has to be performed
			if s_opc(4 downto 0) /= "01110"
				and s_opc(4 downto 0) /= "10000"
				and s_opc(4 downto 0) /= "01111"
				and s_opc(4 downto 0) /= "10001" then
				
				state <= "0010";
			end if;
				
		end if;
		
		--state3: write back
		if(state = "0010") then
		
			if s_op3 /= std_logic_vector(to_unsigned(0,s_op3'length)) then
			
				--Special Writebacks
				
				--Arithmetic shift
				if s_opc(4 downto 0) ="00111" and shift_ar='1' then
					if s_opc(4) = '0' then
						reg_data1(to_integer(unsigned(s_op3))) <= acc or std_logic_vector(shift_left(ones, 32-to_integer(unsigned(s_op2(4 downto 0)))));
						debug_signal <= std_logic_vector(resize(signed(acc(31-to_integer(unsigned(s_op2(4 downto 0))) downto 0)), acc'length));
						reg_data2(to_integer(unsigned(s_op3))) <= acc or std_logic_vector(shift_left(ones, 32-to_integer(unsigned(s_op2(4 downto 0)))));
					else
						reg_data1(to_integer(unsigned(s_op3))) <= acc or std_logic_vector(shift_left(ones, 32-to_integer(unsigned(ram_doutb(4 downto 0)))));
						debug_signal <= std_logic_vector(resize(signed(acc(31-to_integer(unsigned(s_op2(4 downto 0))) downto 0)), acc'length));
						reg_data2(to_integer(unsigned(s_op3))) <= acc or std_logic_vector(shift_left(ones, 32-to_integer(unsigned(ram_doutb(4 downto 0)))));
					end if;
				--Multiply lower
				elsif s_opc(4 downto 0)="01010" then
					reg_data1(to_integer(unsigned(s_op3)))<= mult_result(31 downto 0);
					reg_data2(to_integer(unsigned(s_op3)))<= mult_result(31 downto 0);
					
					debug_signal <= mult_result(31 downto 0);
				--Multiply other
				elsif s_opc(4 downto 0)="01011" or s_opc="01100" or s_opc="01101" then
					reg_data1(to_integer(unsigned(s_op3)))<= mult_result(63 downto 32);
					reg_data2(to_integer(unsigned(s_op3)))<= mult_result(63 downto 32);
					
					debug_signal <= mult_result(63 downto 32);
				else
				--Other operations
					reg_data1(to_integer(unsigned(s_op3)))<= acc;
					reg_data2(to_integer(unsigned(s_op3)))<= acc;
					
					debug_signal <= acc;
				end if;
				
				debug_adr_signal <= "0" & s_op3;
				
			end if;
			
			--Output of result to CU
			
			--Multiply lower
			if s_opc="01010" then						
				cu_data_out <= mult_result(31 downto 0);
			--Multiply other
			elsif s_opc="01011" or s_opc="01100" or s_opc="01101" then
				cu_data_out <= mult_result(63 downto 32);
			elsif s_opc(4 downto 0) ="00111" and shift_ar='1' then
				cu_data_out <= std_logic_vector(resize(signed(acc(31-to_integer(unsigned(s_op2(4 downto 0))) downto 0)), acc'length));
			elsif s_opc(4 downto 0) = "01111"
				or s_opc(4 downto 0) = "10001"
				or s_opc(4 downto 0) = "01110"
				or s_opc(4 downto 0) = "10000"
				then
					cu_data_out <= (others => '0');
			else
			--Other operations
				cu_data_out <= acc;
			end if;
			
			state <= "0000";
		end if;

		--state 4 Division Unsigned
		if state = "0011" then
			alu_dividend <= ram_douta;
			alu_divisor <= ram_doutb;			

			if division_flank_counter < "1100" then
				if (alu_rfdU xor division_flank_counter(0)) = '1' then
					division_flank_counter <= division_flank_counter +1;
				end if;
			else
				if s_opc(4 downto 0) = "01111" then
					acc <= alu_quotientU;
				else
					acc <= alu_remainderU;
				end if;	
				division_flank_counter <= "0000";
				state <= "0010";
			end if;
		end if;
		
		
		--state 5 Division signed
		if state = "0100" then
			alu_dividend <= ram_douta;
			alu_divisor <= ram_doutb;

			if division_flank_counter < "1100" then
				if (alu_rfd xor division_flank_counter(0)) = '1' then
					division_flank_counter <= division_flank_counter +1;
				end if;
			else
				if s_opc(4 downto 0) = "01110" then
					acc <= alu_quotient;
				else
					acc <= alu_remainder;
				end if;	
				division_flank_counter <= "0000";
				state <= "0010";
			end if;
		end if;
		
	
	end if;
end process;

end Behavioral;


