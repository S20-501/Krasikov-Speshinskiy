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


  signal full_reset : STD_LOGIC;
  
  signal c0 : STD_LOGIC;
  signal c1 : STD_LOGIC;
  signal locked : STD_LOGIC;


component TOP_PLL
    port (
    areset : in STD_LOGIC;
    inclk0 : in STD_LOGIC;
    c0 : out STD_LOGIC;
    c1 : out STD_LOGIC;
    locked : out STD_LOGIC
  );
end component;


component Assembled_generator_top
    port (
    reset : in std_logic;
    c0 : in std_logic;
    c1 : in std_logic;
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
    reset : in std_logic;
    c0 : in std_logic;
    c1 : in std_logic;
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

full_reset <= reset or locked;

TOP_PLL_inst : TOP_PLL
  port map (
    areset => reset,
    inclk0 => inclk0,
    c0 => c0,
    c1 => c1,
    locked => locked
  );

  
  
Assembled_generator_top_inst : Assembled_generator_top
  port map (
    reset => full_reset,
    c0 => c0,
    c1 => c1,
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
    reset => full_reset,
    c0 => c0,
    c1 => c1,
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