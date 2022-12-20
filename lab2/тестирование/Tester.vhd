library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Tester is
  port (
    -- входные данные с FT
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
end Tester;


-- симуляция побитовой оптравки данных
architecture tester_top of Tester is
  --общее...
  constant TbPeriod : time := 2 ps;
  signal TbClock : std_logic := '1';
  signal TbSimEnded : std_logic := '0';
  --увеличивающийся при каждом запросе TID
  signal TID_count : std_logic_vector(7 downto 0) := "00000000";  
  --нужен для просмотра отправляемой информации
  signal test_FullHeader: std_logic_vector(47 downto 0);
  
  
  --проверка конкатенации с выводом результата
   function Test_Concatination(
  constant BCount: in std_logic_vector(9 downto 0);
	constant FB: in std_logic;
	constant Cmd: in std_logic_vector(2 downto 0);
	constant count_TID: in std_logic_vector(7 downto 0);
	constant Addr: in std_logic_vector(15 downto 0)
  ) return std_logic_vector is
    variable FullHeader: std_logic_vector(47 downto 0);
  begin
    FullHeader := Addr & "00000000" & count_TID & BCount & "00" & FB & Cmd;
    return FullHeader;
  end function Test_Concatination;
	
	
  --увеличение счетчика запросов
  function RecalculationTID(TID_count : in std_logic_vector(7 downto 0)) return std_logic_vector is
    variable result : std_logic_vector(7 downto 0);
  begin
    if TID_count = "11111111" then
      result := "00000000";
    else
      result := std_logic_vector(to_unsigned(to_integer(unsigned( TID_count )) + 1, 8));
    end if;
    return result;
  end function RecalculationTID;

  
	--процедура записи
	procedure WriteCommand(
		-- количество байт данных
		constant BCount: in std_logic_vector(9 downto 0);
		-- FeedBack наличие 1 - необходимость отправки на  хост для подтверждения приема и корректного анализа
		constant FB: in std_logic;
		-- команда
		constant Cmd: in std_logic_vector(2 downto 0);
		-- идентификатор транзакции
		constant TID_count: in std_logic_vector(7 downto 0);
		-- Адрес назначения (источника) данных
		constant Addr: in std_logic_vector(15 downto 0);
		--данные для записи
		constant data: in std_logic_vector;
		--выходы для записи
		signal FT2232H_FSCTS : out std_logic;
		signal FT2232H_FSDO : out std_logic
	)is
		variable FullHeader: std_logic_vector(0 to 47);			
	begin
		FullHeader := Addr & "00000000" & TID_count & BCount & "00" & FB & Cmd;
		 
		-- разрешение на запись в FT
		wait until rising_edge(TbClock);
		FT2232H_FSCTS <= '0';
		
		
		
		--циклическая запись заголовка
		full_write: for k in 0 to 5 loop
			-- запись Start bit (==0), если 1 то ошибка
			wait until rising_edge(TbClock);
			FT2232H_FSDO <= '0';
			--запись 8 значащих бит
			write8bit: for i in 0 to 7 loop
				wait until rising_edge(TbClock);
				FT2232H_FSDO <= FullHeader(47 - (k*8 + i));--записываемый бит
			end loop write8bit;
			-- запись Source bit
			wait until rising_edge(TbClock);
			FT2232H_FSDO <= '1';
		end loop full_write;

		
		--циклическая запись данных
		data_write: for g in 0 to (to_integer(unsigned(BCount))-1) loop
			-- запись Start bit (==0), если 1 то ошибка
			wait until rising_edge(TbClock);
			FT2232H_FSDO <= '0';
			--запись 8 значащих бит
			write8bit_data: for n in 7 downto 0 loop
				wait until rising_edge(TbClock);
				FT2232H_FSDO <= data((to_integer(unsigned(BCount))*8-1) - (g*8+n));--записываемый бит
			end loop write8bit_data;
			-- запись Source bit
			wait until rising_edge(TbClock);
			FT2232H_FSDO <= '1';	
		end loop data_write;
		
		--запрет на запись в FT
		wait until rising_edge(TbClock);
		FT2232H_FSCTS <= '1';
		
	end procedure WriteCommand;
  
  
--процедура чтения
procedure ReadCommand(
-- количество байт данных
	constant BCount: in std_logic_vector(9 downto 0);
-- FeedBack наличие 1 - необходимость отправки на  хост для подтверждения приема и корректного анализа
	constant FB: in std_logic;
-- команда
	constant Cmd: in std_logic_vector(2 downto 0);
-- идентификатор транзакции
	constant TID_couunt: in std_logic_vector(7 downto 0);
-- Адрес назначения (источника) данных
	constant Addr: in std_logic_vector(15 downto 0);
	signal FT2232H_FSCTS : out std_logic;
	signal FT2232H_FSDO : out std_logic
)is
	variable FullHeader: std_logic_vector(0 to 47);			
begin

		FullHeader := Addr & "00000000" & TID_count & BCount & "00" & FB & Cmd;
		 
		-- разрешение на запись в FT
		wait until rising_edge(TbClock);
		FT2232H_FSCTS <= '0';
		
		--циклическая запись заголовка
		full_write: for k in 0 to 5 loop
			-- запись Start bit (==0), если 1 то ошибка
			wait until rising_edge(TbClock);
			FT2232H_FSDO <= '0';
			--запись 8 значащих бит
			write8bit: for i in 0 to 7 loop
				wait until rising_edge(TbClock);
				FT2232H_FSDO <= FullHeader(47 - (k*8 + i));--записываемый бит
			end loop write8bit;
			-- запись Source bit
			wait until rising_edge(TbClock);
			FT2232H_FSDO <= '1';
		end loop full_write;
		
		--запрет на запись в FT
		wait until rising_edge(TbClock);
		FT2232H_FSCTS <= '1';
		
end procedure ReadCommand;



begin


  TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
  tester_clk <= TbClock;


  stimuli : process --сменить название?
  begin
    wait for TbPeriod;
    tester_reset <= '1';
    wait for TbPeriod;
    tester_reset <= '0';
    wait for TbPeriod;
    --001
	 test_FullHeader <= Test_Concatination("0000000001", '0', "001", TID_count, "1100000000000001");
	 ReadCommand("0000000001", '0', "001", TID_count, "1100000000000001", FT2232H_FSCTS, FT2232H_FSDO);
	 wait for TbPeriod;
    TID_count <= RecalculationTID(TID_count);
    wait for TbPeriod;
    --010
    test_FullHeader <= Test_Concatination("0000000010", '0', "010", TID_count, "0000000000000000");
	 WriteCommand("0000000010", '0', "010", TID_count, "0000000000000000", "1000001111000001", FT2232H_FSCTS, FT2232H_FSDO);
	 wait for TbPeriod;
    TID_count <= RecalculationTID(TID_count);
    wait for TbPeriod;
    --011
	 --
    --wait for TbPeriod;
    --100
    --
    --wait for TbPeriod;
    --101
    --
    --wait for TbPeriod;
    --110
    --
    --wait for TbPeriod;
    TbSimEnded <= '1';
  end process;
end tester_top;


configuration ts_top of Tester is
  for tester_top
  end for;
end ts_top;