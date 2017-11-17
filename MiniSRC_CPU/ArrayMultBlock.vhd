-- Copyright (C) 1991-2014 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.1.4 Build 182 03/12/2014 SJ Web Edition"
-- CREATED		"Sun Feb 07 01:37:08 2016"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY ArrayMultBlock IS 
	PORT
	(
		carry_in :  IN  STD_LOGIC;
		m_in :  IN  STD_LOGIC;
		PP_in :  IN  STD_LOGIC;
		q_in :  IN  STD_LOGIC;
		PP_Out :  OUT  STD_LOGIC;
		m_out :  OUT  STD_LOGIC;
		q_out :  OUT  STD_LOGIC;
		carry_out :  OUT  STD_LOGIC
	);
END ArrayMultBlock;

ARCHITECTURE bdf_type OF ArrayMultBlock IS 

COMPONENT lpm_add_sub1
	PORT(cin : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(0 TO 0);
		 datab : IN STD_LOGIC_VECTOR(0 TO 0);
		 cout : OUT STD_LOGIC;
		 result : OUT STD_LOGIC_VECTOR(0 TO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;


BEGIN 
m_out <= m_in;
q_out <= q_in;



b2v_inst : lpm_add_sub1
PORT MAP(cin => carry_in,
		 dataa(0) => PP_in,
		 datab(0) => SYNTHESIZED_WIRE_0,
		 cout => carry_out,
		 result(0) => PP_Out);


SYNTHESIZED_WIRE_0 <= m_in AND q_in;


END bdf_type;