library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Datapath_3bus_tb is
end entity;


architecture yolo of Datapath_3bus_tb is

--clock and reset signals
signal clk : std_logic := '0';
signal rst : std_LOGIC := '1';
signal testbench_done : std_logic := '0';

--current state output (from process)
signal cur_state : std_logic_vector(31 downto 0);
signal cur_instr : std_LOGIC_VECTOR(31 downto 0);

--output signals for testing
signal a, b, c, pc, ir, ma_out, md_in, md_out, r0, r1, r2, r3, r4, r5, r6, r7, rHI, rLO, c_sx : std_LOGIC_VECTOR(31 downto 0);

--bus/alu select signals
signal a_bus, b_bus, fcn_sel : std_LOGIC_VECTOR(4 downto 0) := "00000";

signal a_bus_out, b_bus_out : std_logic_vector(4 downto 0);

--register write enable signals - manually set by the testbench
signal c_r0, c_r1, c_r2, c_r3, c_r4, c_r5, c_r6, c_r7, c_r8, c_r9, c_r10, c_r11, c_r12, c_r13, c_r14, c_r15, c_hilo, c_ir, c_pc : STD_LOGIC := '0';

--combination of the write enables that matter (0-15)
signal c_r0_out, c_r1_out, c_r2_out, c_r3_out, c_r4_out, c_r5_out, c_r6_out, c_r7_out, c_r8_out, c_r9_out, c_r10_out, c_r11_out, c_r12_out, c_r13_out, c_r14_out, c_r15_out : std_LOGIC;

--when R0 is selected at the same time as this, we get a zero value on whatever bus
signal ba_out : std_LOGIC := '0';

--memory address&data write enable / source select signals, and a RAM write enable signal
signal MAR_en, MAR_sel, MDR_en, MDR_sel, RAM_we, RAM_re : std_LOGIC := '0';


--r_in signals from selectdecode
signal sd_rin : std_logic := '0';
signal sd_r0, sd_r1, sd_r2, sd_r3, sd_r4, sd_r5, sd_r6, sd_r7, sd_r8, sd_r9, sd_r10, sd_r11, sd_r12, sd_r13, sd_r14, sd_r15 : std_logic;

--bus select signals from selectdecode
signal sd_gAra, sd_gArb, sd_gArc, sd_gBra, sd_gBrb, sd_gBrc : std_logic := '0';
signal sd_a_sel, sd_b_sel : std_logic_vector(3 downto 0);

--i/o ports
signal in_port_en, out_port_en : std_logic := '0';
signal in_port : std_logic_vector(31 downto 0) := x"796f6c6f";
signal out_port : std_logic_vector(31 downto 0);

--branch result
signal branch_result : std_LOGIC;


COMPONENT Datapath_3Bus
	PORT
	(
		a_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		b_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		c_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		pc_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ir_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		c_sx		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		dp_md_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		dp_ma_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		dp_md_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		MAR_en		:	 IN STD_LOGIC;
		MAR_sel		:	 IN STD_LOGIC;
		MDR_en		:	 IN STD_LOGIC;
		MDR_sel		:	 IN STD_LOGIC;
		r0_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r1_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r2_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r3_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r4_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r5_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r6_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r7_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		rHI_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		rLO_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		a_bus_sel		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		b_bus_sel		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		c_r0		:	 IN STD_LOGIC;
		c_r1		:	 IN STD_LOGIC;
		c_r2		:	 IN STD_LOGIC;
		c_r3		:	 IN STD_LOGIC;
		c_r4		:	 IN STD_LOGIC;
		c_r5		:	 IN STD_LOGIC;
		c_r6		:	 IN STD_LOGIC;
		c_r7		:	 IN STD_LOGIC;
		c_r8		:	 IN STD_LOGIC;
		c_r9		:	 IN STD_LOGIC;
		c_r10		:	 IN STD_LOGIC;
		c_r11		:	 IN STD_LOGIC;
		c_r12		:	 IN STD_LOGIC;
		c_r13		:	 IN STD_LOGIC;
		c_r14		:	 IN STD_LOGIC;
		c_r15		:	 IN STD_LOGIC;
		c_hilo		:	 IN STD_LOGIC;
		c_IR		:	 IN STD_LOGIC;
		c_PC		:	 IN STD_LOGIC;
		ba_out		:	 IN STD_LOGIC;
		clk		:	 IN STD_LOGIC;
		rst		:	 IN STD_LOGIC;
		fsel		:	 IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		out_port : out std_logic_vector(31 downto 0);
		out_port_en : in std_logic;
		in_port : in std_logic_vector(31 downto 0);
		in_port_en : in std_logic
	);
END COMPONENT;

component RamMemory
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		rden		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

COMPONENT SelectDecode_3bus
	PORT
	(
		ir_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		c_sx		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		rIN		:	 IN STD_LOGIC;
		gAra		:	 IN STD_LOGIC;
		gArb		:	 IN STD_LOGIC;
		gArc		:	 IN STD_LOGIC;
		gBra		:	 IN STD_LOGIC;
		gBrb		:	 IN STD_LOGIC;
		gBrc		:	 IN STD_LOGIC;
		a_sel_out		:	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		b_sel_out		:	 OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		c_r0		:	 OUT STD_LOGIC;
		c_r1		:	 OUT STD_LOGIC;
		c_r2		:	 OUT STD_LOGIC;
		c_r3		:	 OUT STD_LOGIC;
		c_r4		:	 OUT STD_LOGIC;
		c_r5		:	 OUT STD_LOGIC;
		c_r6		:	 OUT STD_LOGIC;
		c_r7		:	 OUT STD_LOGIC;
		c_r8		:	 OUT STD_LOGIC;
		c_r9		:	 OUT STD_LOGIC;
		c_r10		:	 OUT STD_LOGIC;
		c_r11		:	 OUT STD_LOGIC;
		c_r12		:	 OUT STD_LOGIC;
		c_r13		:	 OUT STD_LOGIC;
		c_r14		:	 OUT STD_LOGIC;
		c_r15		:	 OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT ConFF_3Bus
	PORT
	(
		ir_in		:	 IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		r_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		result		:	 OUT STD_LOGIC
	);
END COMPONENT;

begin

--clocking and reset signals
clk <= not clk after 10ns;
rst <= '0' after 25ns;

--ORing of the proper select/decode signals
c_r0_out <= c_r0 OR sd_r0;
c_r1_out <= c_r1 OR sd_r1;
c_r2_out <= c_r2 OR sd_r2;
c_r3_out <= c_r3 OR sd_r3;
c_r4_out <= c_r4 OR sd_r4;
c_r5_out <= c_r5 OR sd_r5;
c_r6_out <= c_r6 OR sd_r6;
c_r7_out <= c_r7 OR sd_r7;
c_r8_out <= c_r8 OR sd_r8;
c_r9_out <= c_r9 OR sd_r9;
c_r10_out <= c_r10 OR sd_r10;
c_r11_out <= c_r11 OR sd_r11;
c_r12_out <= c_r12 OR sd_r12;
c_r13_out <= c_r13 OR sd_r13;
c_r14_out <= c_r14 OR sd_r14;
c_r15_out <= c_r15 OR sd_r15;

--ORing of the A/B bus select signals
a_bus_out <= a_bus or '0' & sd_a_sel;
b_bus_out <= b_bus or '0' & sd_b_sel;

swag : process(clk,rst)
variable state : integer := 0;
variable istr : integer := 0;

begin

cur_state <= conv_std_logic_vector(state,32);
cur_instr <= conv_std_logic_vector(istr,32);

--ld instruction at location 0
if reset = '1' then
	state := 0;
	istr  := 0;
elsif rising_edge(clk) then
		
	if state = 0 then
			--pc_out
			--ma_in
			--
		
	end if;


end if;



end process;




TheConFF : conFF_3Bus port map
(
	ir_in => ir(1 downto 0),
	r_in => a,
	result => branch_result
);



TheDatapath : Datapath_3Bus port map
(
		a_out => a,
		b_out => b,
		c_out => c,
		pc_out => pc,
		ir_out => ir,
		c_sx => c_sx,
		
		dp_ma_out => ma_out,
		dp_md_in => md_in,
		dp_md_out => md_out,
		MAR_en => mar_en,
		MAR_sel => mar_sel,
		MDR_en => mdr_en,
		MDR_sel => mdr_sel,
		
		r0_out => r0,
		r1_out => r1,
		r2_out => r2,
		r3_out => r3,
		r4_out => r4,
		r5_out => r5,
		r6_out => r6,
		r7_out => r7,
		rHI_out => rHI,
		rLO_out => rLO,
		
		a_bus_sel => a_bus_out,
		b_bus_sel => b_bus_out,
		
		c_r0 => c_r0_out,
		c_r1 => c_r1_out,
		c_r2 => c_r2_out,
		c_r3 => c_r3_out,
		c_r4 => c_r4_out,
		c_r5 => c_r5_out,
		c_r6 => c_r6_out,
		c_r7 => c_r7_out,
		c_r8 => c_r8_out,
		c_r9 => c_r9_out,
		c_r10 => c_r10_out,
		c_r11 => c_r11_out,
		c_r12 => c_r12_out,
		c_r13 => c_r13_out,
		c_r14 => c_r14_out,
		c_r15 => c_r15_out,
		
		c_hilo => c_hilo,
		c_IR => c_ir,
		c_PC => c_pc,
		
		ba_out => ba_out,
		
		clk => clk,
		rst => rst,
		fsel => fcn_sel,
		
		out_port => out_port,
		out_port_en => out_port_en,
		
		in_port => in_port,
		in_port_en => in_port_en
);


TheMemory : RamMemory port map
(
		address => ma_out(8 downto 0),
		clock => clk,
		data => md_out,
		wren => RAM_we,
		rden => RAM_re,
		q => md_in
);

TheSelector : SelectDecode_3bus port map
(
			ir_in => ir,
			c_sx => c_sx,
			rIN => sd_rin,
			gAra => sd_gAra,
			gArb => sd_gArb,
			gArc => sd_garc,
			gBra => sd_gbra,
			gBrb => sd_gbrb,
			gBrc => sd_gbrc,
			a_sel_out => sd_a_sel,
			b_sel_out => sd_b_sel,
			c_r0 => sd_r0,
			c_r1 => sd_r1,
			c_r2 => sd_r2,
			c_r3 => sd_r3,
			c_r4 => sd_r4,
			c_r5 => sd_r5,
			c_r6 => sd_r6,
			c_r7 => sd_r7,
			c_r8 => sd_r8,
			c_r9 => sd_r9,
			c_r10 => sd_r10,
			c_r11 => sd_r11,
			c_r12 => sd_r12,
			c_r13 => sd_r13,
			c_r14	=> sd_r14,
			c_r15 => sd_r15
);







end architecture;