library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Datapath_3bus_tb is

port	(

			clk,rst_n, stop_n : in std_logic;
			run : out std_logic;
			
			bankSwitch : in std_logic;
			digit0 : out std_logic_vector(6 downto 0);
			digit1 : out std_logic_vector(6 downto 0);
			digit2 : out std_logic_vector(6 downto 0);
			digit3 : out std_logic_vector(6 downto 0);
			
			inputData : in std_logic_vector(7 downto 0)
		);
end entity;


architecture yolo of Datapath_3bus_tb is

signal clk_div_out : std_logic;

--bus signals and c_sign_extended
signal a,b,c,c_sx : std_logic_vector(31 downto 0);

signal pc,ir : std_logic_vector(31 downto 0);

signal ma_out,md_out,md_in : std_logic_vector(31 downto 0);

--bus select signals
signal a_bus_sel, b_bus_sel, fcn_sel : std_logic_vector(4 downto 0);

--data register value
signal r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, rHI, rLO : std_logic_vector(31 downto 0);

signal in_port : std_logic_vector(31 downto 0) := x"00000000";
signal out_port : std_logic_vector(31 downto 0);




--pc/ir and enables
signal pc_en, ir_en, ba_out : std_logic;

--memory enables
signal mar_en, mar_sel, mdr_en, mdr_sel, RAM_we : std_logic;

--register enables
signal r0_en, r1_en, r2_en, r3_en, r4_en, r5_en, r6_en, r7_en, r8_en, r9_en, r10_en, r11_en, r12_en, r13_en, r14_en, r15_en, rHILO_en : std_logic;

--in/out port en
signal in_port_en, out_port_en : std_logic;

signal rst, stop : std_logic;

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
		r8_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r9_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r10_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r11_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r12_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r13_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r14_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		r15_out		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
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
		address	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock		: IN STD_LOGIC;
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

COMPONENT ControlUnit_3Bus
	PORT
	(
		clk		:	 IN STD_LOGIC;
		rst		:	 IN STD_LOGIC;
		stop		:	 IN STD_LOGIC;
		run_out	:	 OUT STD_LOGIC;
		c_r0_out		:	 OUT STD_LOGIC;
		c_r1_out		:	 OUT STD_LOGIC;
		c_r2_out		:	 OUT STD_LOGIC;
		c_r3_out		:	 OUT STD_LOGIC;
		c_r4_out		:	 OUT STD_LOGIC;
		c_r5_out		:	 OUT STD_LOGIC;
		c_r6_out		:	 OUT STD_LOGIC;
		c_r7_out		:	 OUT STD_LOGIC;
		c_r8_out		:	 OUT STD_LOGIC;
		c_r9_out		:	 OUT STD_LOGIC;
		c_r10_out		:	 OUT STD_LOGIC;
		c_r11_out		:	 OUT STD_LOGIC;
		c_r12_out		:	 OUT STD_LOGIC;
		c_r13_out		:	 OUT STD_LOGIC;
		c_r14_out		:	 OUT STD_LOGIC;
		c_r15_out		:	 OUT STD_LOGIC;
		c_hilo_out		:	 OUT STD_LOGIC;
		c_ir_out		:	 OUT STD_LOGIC;
		c_pc_out		:	 OUT STD_LOGIC;
		ba_out		:	 OUT STD_LOGIC;
		out_port_en		:	 OUT STD_LOGIC;
		in_port_en		:	 OUT STD_LOGIC;
		MAR_en		:	 OUT STD_LOGIC;
		MAR_sel		:	 OUT STD_LOGIC;
		MDR_en		:	 OUT STD_LOGIC;
		MDR_sel		:	 OUT STD_LOGIC;
		RAM_we		:	 OUT STD_LOGIC;
		a_bus_out		:	 OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		b_bus_out		:	 OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		fcn_sel		:	 OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		c_sign_extended		:	 OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		ir_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		a_in		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT SevenSegment
	PORT
	(
		inputPort		:	 IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		progCount :  IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		bankSwitch		:	 IN STD_LOGIC;
		digit0		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		digit1		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		digit2		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		digit3		:	 OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END COMPONENT;

component ClockGenerator is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic      -- clk
			
		);
end component ClockGenerator;


begin

--clocking and reset signals
--clk <= not clk after 10ns;

rst <= not rst_n;

stop <= not stop_n;

in_port <= x"000000" & inputData;	


TheClockDivider : ClockGenerator port map
(
			refclk => clk,
			rst => rst,
			outclk_0 => clk_div_out
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
		r8_out => r8,
		r9_out => r9,
		r10_out => r10,
		r11_out => r11,
		r12_out => r12,
		r13_out => r13,
		r14_out => r14,
		r15_out => r15,
		rHI_out => rHI,
		rLO_out => rLO,
		
		a_bus_sel => a_bus_sel,
		b_bus_sel => b_bus_sel,
		
		c_r0 => r0_en,
		c_r1 => r1_en,
		c_r2 => r2_en,
		c_r3 => r3_en,
		c_r4 => r4_en,
		c_r5 => r5_en,
		c_r6 => r6_en,
		c_r7 => r7_en,
		c_r8 => r8_en,
		c_r9 => r9_en,
		c_r10 => r10_en,
		c_r11 => r11_en,
		c_r12 => r12_en,
		c_r13 => r13_en,
		c_r14 => r14_en,
		c_r15 => r15_en,
		
		c_hilo => rHILO_en,
		c_IR => ir_en,
		c_PC => pc_en,
		
		ba_out => ba_out,
		
		clk => clk_div_out,
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
		clock => clk_div_out,
		data => md_out,
		wren => RAM_we,
		q => md_in
);


TheControlUnit : ControlUnit_3Bus port map
(
		clk => clk_div_out,
		rst => rst,
		stop => stop,
		run_out => run,
		c_r0_out => r0_en,
		c_r1_out => r1_en,
		c_r2_out => r2_en,
		c_r3_out => r3_en,
		c_r4_out => r4_en,
		c_r5_out => r5_en,
		c_r6_out	=> r6_en,
		c_r7_out => r7_en,
		c_r8_out => r8_en,
		c_r9_out => r9_en,
		c_r10_out => r10_en,
		c_r11_out => r11_en,
		c_r12_out => r12_en,
		c_r13_out => r13_en,
		c_r14_out => r14_en,
		c_r15_out => r15_en,
		c_hilo_out => rHILO_en,
		c_ir_out => ir_en,
		c_pc_out => pc_en,
		ba_out => ba_out,
		out_port_en => out_port_en,
		in_port_en => in_port_en,
		MAR_en => mar_en,
		MAR_sel => mar_sel,
		MDR_en => mdr_en,
		MDR_sel => mdr_sel,
		RAM_we => ram_we,
		a_bus_out => a_bus_sel,
		b_bus_out => b_bus_sel, 
		fcn_sel => fcn_sel,
		c_sign_extended => c_sx,
		ir_in => ir,
		a_in => a
);

TheSevenSegment : SevenSegment port map
(
		inputPort => out_port,
		progCount => pc,
		bankSwitch => bankSwitch,
		digit0 => digit0,
		digit1 => digit1,
		digit2 => digit2,
		digit3 => digit3
);

end architecture;