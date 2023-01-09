library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Assembled_top is
  port (
    inclk0 : in STD_LOGIC;
	 reset : in STD_LOGIC;
	 
	 --связь с FT
	 FT2232H_FSCTS : in std_logic;
    FT2232H_FSDO : in std_logic;
    FT2232H_FSDI : out std_logic;
    FT2232H_FSCLK : out std_logic;
	 
	 --выходы генератора
	 DAC_Clk : out std_logic;
    DAC_Rst : out std_logic;
    DAC_Write : out std_logic;
    DAC_Select : out std_logic;
    DAC_Data : out std_logic_vector(9 downto 0);
	 
	 --выходы анализатора
	 DataStrobe_out : out std_logic;
    dataout : out std_logic_vector(7 downto 0);
    ADC_SigIn : in std_logic_vector(9 downto 0);
    Gain_s : out std_logic;
    OutputBusSelect_s : out std_logic;
    Standby_s : out std_logic;
    PowerDown_s : out std_logic;
    OffsetCorrect_s : out std_logic;
    OutputFormat_s : out std_logic
	 
  );
end entity Assembled_top;


architecture assembled_top of Assembled_top is


component Assembled_generator_top
    port (
    inclk0 : in STD_LOGIC;
    reset : in STD_LOGIC;
    FT2232H_FSCTS : in std_logic;
    FT2232H_FSDO : in std_logic;
    FT2232H_FSDI : out std_logic;
    FT2232H_FSCLK : out std_logic;
    DAC_Clk : out std_logic;
    DAC_Rst : out std_logic;
    DAC_Write : out std_logic;
    DAC_Select : out std_logic;
    DAC_Data : out std_logic_vector(9 downto 0)
  );
end component;




component Assembled_analyzer_top
    port (
    inclk0 : in STD_LOGIC;
    reset : in STD_LOGIC;
    FT2232H_FSCTS : in std_logic;
    FT2232H_FSDO : in std_logic;
    FT2232H_FSDI : out std_logic;
    FT2232H_FSCLK : out std_logic;
    DataStrobe_out : out std_logic;
    dataout : out std_logic_vector(7 downto 0);
    ADC_SigIn : in std_logic_vector(9 downto 0);
    Gain_s : out std_logic;
    OutputBusSelect_s : out std_logic;
    Standby_s : out std_logic;
    PowerDown_s : out std_logic;
    OffsetCorrect_s : out std_logic;
    OutputFormat_s : out std_logic
  );
end component;




begin

  Assembled_generator_top_inst : Assembled_generator_top
  port map (
    inclk0 => inclk0,
    reset => reset,
    FT2232H_FSCTS => FT2232H_FSCTS,
    FT2232H_FSDO => FT2232H_FSDO,
    FT2232H_FSDI => FT2232H_FSDI,
    FT2232H_FSCLK => FT2232H_FSCLK,
    DAC_Clk => DAC_Clk,
    DAC_Rst => DAC_Rst,
    DAC_Write => DAC_Write,
    DAC_Select => DAC_Select,
    DAC_Data => DAC_Data
  );


  Assembled_analyzer_top_inst : Assembled_analyzer_top
  port map (
    inclk0 => inclk0,
    reset => reset,
    FT2232H_FSCTS => FT2232H_FSCTS,
    FT2232H_FSDO => FT2232H_FSDO,
    --FT2232H_FSDI => FT2232H_FSDI,
    --FT2232H_FSCLK => FT2232H_FSCLK,
    DataStrobe_out => DataStrobe_out,
    dataout => dataout,
    ADC_SigIn => ADC_SigIn,
    Gain_s => Gain_s,
    OutputBusSelect_s => OutputBusSelect_s,
    Standby_s => Standby_s,
    PowerDown_s => PowerDown_s,
    OffsetCorrect_s => OffsetCorrect_s,
    OutputFormat_s => OutputFormat_s
  );




end architecture;