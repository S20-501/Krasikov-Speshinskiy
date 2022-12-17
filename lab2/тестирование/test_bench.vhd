-- connector
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity test_bench is
end test_bench;

architecture conecter of test_bench is

signal conect_FT2232H_FSDI		: std_logic;
signal conect_FT2322H_FSCLK		: std_logic;
signal conect_tester_clk		: std_logic;
signal conect_tester_reset		: std_logic;
signal conect_FT2232H_FSCTS		: std_logic;
signal conect_FT2232H_FSDO		: std_logic;


component DUT
	port(
		FT2232H_FSDI : out std_logic;
        FT2322H_FSCLK : out std_logic;
        tester_clk : in std_logic;
        tester_reset : in std_logic;
        FT2232H_FSCTS : in std_logic;
        FT2232H_FSDO : in std_logic
	);
end component;	
	
component Tester
	port(
		FT2232H_FSDI : in std_logic;
 		-- Входной тактовый сигнал для микросхемы FT2232H
    	FT2322H_FSCLK : in std_logic;
		-- общие сигналы
	   	tester_clk : out std_logic := '0';
 	  	tester_reset : out std_logic := '0';
  	 	-- готовность FT к приму данных (0)
  	  	FT2232H_FSCTS : out std_logic := '1';
 	  	-- канал передачи данных к FT
   		FT2232H_FSDO : out std_logic
	);
end component;	
	
begin

	connect_1: DUT
		port map(
			FT2232H_FSDI => conect_FT2232H_FSDI,
			FT2322H_FSCLK => conect_FT2322H_FSCLK,
			tester_clk => conect_tester_clk,
			tester_reset => conect_tester_reset,
			FT2232H_FSCTS => conect_FT2232H_FSCTS,
			FT2232H_FSDO => conect_FT2232H_FSDO
		);	
	connect_2: tester
		port map(
			FT2232H_FSDI => conect_FT2232H_FSDI,
			FT2322H_FSCLK => conect_FT2322H_FSCLK,
			tester_clk => conect_tester_clk,
			tester_reset => conect_tester_reset,
			FT2232H_FSCTS => conect_FT2232H_FSCTS,
			FT2232H_FSDO => conect_FT2232H_FSDO
		);
	
end conecter;	
