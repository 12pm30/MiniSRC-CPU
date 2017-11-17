library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity PotatoALU is
port( a_in, b_in : in std_logic_vector(31 downto 0);
		c_low_out, c_hi_out : out std_logic_vector(31 downto 0);
		clk , carry_in, reset : in std_logic;
		fcn_sel : in std_logic_vector(4 downto 0);
		overflow_out, underflow_out, carry_out : out std_logic);

end entity;


architecture potato of PotatoALU is

component AddSub
	PORT
	(
		add_sub		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		cout		: OUT STD_LOGIC ;
		overflow		: OUT STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component ArithShift
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		direction		: IN STD_LOGIC ;
		distance		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		overflow		: OUT STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		underflow		: OUT STD_LOGIC 
	);
end component;

component Div
	PORT
	(
		denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component IncDec
	PORT
	(
		
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN std_logic_vector (31 downto 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component Rotator
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		direction		: IN STD_LOGIC ;
		distance		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

component Shifter
	PORT
	(
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		direction		: IN STD_LOGIC ;
		distance		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		overflow		: OUT STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		underflow		: OUT STD_LOGIC 
	);
end component;

component SigDiv
	PORT
	(
		denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;


COMPONENT BoothMultiplier
	PORT
	(
		m_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		q_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		result_out		:	 OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
		n_out, t_z_out, t_o_out : out STD_LOGIC_VECTOR(15 downto 0);
		done		:	 OUT STD_LOGIC
	);
END COMPONENT;

signal AddSub_out, ArithShift_out, Div_out, SigDiv_out, Div_Rem_out, SigDiv_Rem_out, IncDec_out, Rotator_out, Shifter_out, IncPC_out: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal AddSub_overflow, ArithShift_overflow, Shifter_overflow, ArithShift_underflow, Shifter_underflow, AddSub_cout : std_logic := '0';
signal BoothMult_out : std_logic_vector(63 downto 0);
signal ArrMult_out : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
signal not_a_in : std_LOGIC_VECTOR(31 downto 0) := "00000000000000000000000000000000";
signal rot_shift : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
begin

-- stick port_map here

not_a_in <= NOT a_in;

Negator : incDec port map (
		--add_sub => '1',
		dataa => not_a_in,
		datab => conv_std_logic_vector(1,32),
		result => IncDec_out
		);
		
IncPC : incDec port map (
		--add_sub => '1',
		dataa => B_in,
		datab => conv_std_logic_vector(1,32),
		result => IncPC_out
		);
		
AdderSubtractor : AddSub port map (
		add_sub => fcn_sel(0),
	
		dataa => a_in,
		datab => b_in,
		cout => AddSub_cout, 
		overflow => AddSub_overflow,
		result => AddSub_out
		);

Mult : BoothMultiplier port map (
		m_in => a_in,
		q_in => b_in,
		result_out => BoothMult_out
		);

DIVS : SigDiv port map
	(
		denom => b_in,
		numer => a_in,
		quotient => SigDiv_out,
		remain => SigDiv_rem_out
	);

DIVU : Div port map
	(
		denom => b_in,
		numer => a_in,
		quotient => Div_out,
		remain => Div_rem_out
	);
	
	
SHLR : Shifter
	PORT map
	(
		data => a_in,
		direction => fcn_sel(0),
		distance => b_in(4 DOWNTO 0),
		overflow => Shifter_overflow,
		result => Shifter_out,
		underflow => Shifter_underflow 
	);
	
SHLRA : ArithShift
	PORT map
	(
		data => a_in,
		direction => fcn_sel(0),
		distance => b_in(4 DOWNTO 0),
		overflow => ArithShift_overflow,
		result => ArithShift_out,
		underflow => ArithShift_underflow 
	);

ROTATE : Rotator
	PORT map
	(
		data => a_in,
		direction => fcn_sel(0),
		distance => b_in(4 DOWNTO 0),

		result => Rotator_out
		
	);	

rot_shift(4 downto 0) <= b_in(4 downto 0);

c_low_out <= x"00000000"		when fcn_sel = "00000" else
				 a_in AND b_in 	when fcn_sel = "00001" else
				 a_in OR b_in 		when fcn_sel = "00010" else
				 NOT a_in			when fcn_sel = "00011" else
				 a_in NAND b_in 	when fcn_sel = "00100" else
				 a_in NOR b_in 	when fcn_sel = "00101" else
				 a_in XOR b_in 	when fcn_sel = "00110" else
				 a_in XNOR b_in 	when fcn_sel = "00111" else
				 AddSub_out			when fcn_sel = "01000" else
				 AddSub_out			when fcn_sel = "01001" else
				 IncDec_out			when fcn_sel = "01010" else
				 BoothMult_out(31 downto 0) when fcn_sel = "01011" else
				 b_in			 		when fcn_sel = "01100" else
				 SigDiv_out			when fcn_sel = "01101" else
				 Div_out				when fcn_sel = "01110" else
				 IncPC_out			when fcn_sel = "01111" else
				 Shifter_out		when fcn_sel = "10000" else
				 Shifter_out		when fcn_sel = "10001" else
				 ArithShift_out 	when fcn_sel = "10010" else
				 ArithShift_out	when fcn_sel = "10011" else
				 Rotator_out		when fcn_sel = "10100" else
				 Rotator_out		when fcn_sel = "10101" else
				 "00000000000000000000000000000000";

c_hi_out <=  BoothMult_out(63 downto 32) when fcn_sel = "01011" else
				 SigDiv_rem_out	when fcn_sel = "01101" else
				 Div_rem_out		when fcn_sel = "01110" else
				 rot_shift			when fcn_sel = "10000" else
				 rot_shift			when fcn_sel = "10001" else
				 rot_shift			when fcn_sel = "10010" else
				 rot_shift			when fcn_sel = "10011" else
				 rot_shift			when fcn_sel = "10100" else
				 rot_shift			when fcn_sel = "10101" else
				 "00000000000000000000000000000000";

overflow_out <= Shifter_overflow OR AddSub_overflow OR ArithShift_overflow OR '0';
underflow_out <= ArithShift_underflow OR Shifter_underflow OR '0';
carry_out <= AddSub_cout OR '0';				 
end architecture;