library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity arraymult is
    Generic (N: integer:=4);
    Port ( X : in  STD_LOGIC_VECTOR (N-1 downto 0); -- factor 1
           Y : in  STD_LOGIC_VECTOR (N-1 downto 0); -- factor 2
           P : out  STD_LOGIC_VECTOR (2*N-1 downto 0)); -- product
end arraymult;

architecture structural of arraymult is
  -- all the 1-bit products are computed here. All of them have to be
  -- computed some time. They may as well be done here. XY(n)(m) represents
  -- the product x(n)y(m)
  type product_terms is array (0 to N-1) of std_logic_vector(0 to N-1);
  signal XY: product_terms;

  -- these are the carry and sum signals that connect one stage to the next
  type interconnect is array (0 to N-2) of std_logic_vector(N-2 downto 0);
  signal C, S: interconnect;
  
  -- other handy temporary variables demanded by VHDL syntax constraints
  signal addend, partial_prod: std_logic_vector(N-2 downto 0);
 
  -- 1-bit half adder
  component HalfAdder is
    Port ( X, Y : in  STD_LOGIC;
           Co, Sum : out  STD_LOGIC);
  end component;
  
  -- 1-bit full adder
  component FullAdder is
    Port ( X, Y, Ci : in  STD_LOGIC;
           Co, Sum : out  STD_LOGIC);
  end component;
  
  -- N-bit fast carry adder
  component FastAdder is
    Generic (BITS : INTEGER);
    Port ( X, Y: in  STD_LOGIC_VECTOR (BITS-1 downto 0);
           Sum : out  STD_LOGIC_VECTOR (BITS downto 0));
  end component;

begin

   -- compute 1-bit products
	process (X, Y)
	begin
	  for i in 0 to N-1 loop
	    for j in 0 to N-1 loop
		   XY(j)(i) <= X(j) and Y(i);
		 end loop;
	  end loop;
	end process;

   -- generate structural model for all adders
   Gen1: for j in 0 to N-2 generate
     -- row 0, all half adders
     HA1: HalfAdder port map(XY(j+1)(0),XY(j)(1),C(0)(j),S(0)(j));
	  Gen2: for i in 1 to N-2 generate -- rows 1-N
	    GenMSB: if j=N-2 generate -- most significant bit has no adder above it
		   FA1: FullAdder port map(XY(j)(i+1),XY(j+1)(i),C(i-1)(j),C(i)(j),S(i)(j));
		 end generate;
	    GenNorm: if j<N-2 generate -- regular adder, a superior adder exists
		   FA2: FullAdder port map(XY(j)(i+1),S(i-1)(j+1),C(i-1)(j),C(i)(j),S(i)(j));
		 end generate;
	  end generate;
	end generate;
	
	-- connect the bottom half of the product to the sums that have escaped the
   -- array and the one-bit XoYo product
	process (S)
	begin
	  for i in 0 to N-2 loop
		 partial_prod(i) <= S(i)(0);
	  end loop;
	end process;

	P(N-1 downto 0)<= partial_prod & XY(0)(0);
	
	-- VHDL demands that no operators are allowed in a port list, not even
	-- concatenation (which is a bit lame), so we form an addend from the
	-- top bits of the final stage of the array to feed to the adder.
	addend <= XY(N-1)(N-1) & S(N-2)(N-2 downto 1);
	FCA1: FastAdder Generic Map(BITS=>N-1) port map(C(N-2),addend,P(2*N-1 downto N));
	
end structural;