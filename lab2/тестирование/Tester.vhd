library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Tester is
  port (
    -- входные данные с FT
    FT2232H_FSDI : in std_logic;
    -- Входной тактовый сигнал для микросхемы FT2232H
    FT2232H_FSCLK : in std_logic;
    -- общие сигналы
    tester_clk : out std_logic := '0';
    tester_reset : out std_logic := '1';
    -- готовность FT к приму данных (0)
    FT2232H_FSCTS : out std_logic := '1';
    -- канал передачи данных к FT
    FT2232H_FSDO : out std_logic := '1'
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
  --увеличивающийся при записи FT2232H_FSDI счетчик
  signal FSDI_count : std_logic_vector(3 downto 0) := "0000";
  --активен(1), если в данный момент идет запись в CTS
  signal CTS_open_r : std_logic := '0';
  --нужен для просмотра отправляемой информации
  signal test_FullHeader : std_logic_vector(47 downto 0);
  --проверка конкатенации с выводом результата


  function Test_Concatination(
    constant BCount : in std_logic_vector(9 downto 0);
    constant FB : in std_logic;
    constant Cmd : in std_logic_vector(2 downto 0);
    constant TID_count : in std_logic_vector(7 downto 0);
    constant Addr : in std_logic_vector(15 downto 0)
  ) return std_logic_vector is
    variable FullHeader : std_logic_vector(47 downto 0);
  begin

    FullHeader := BCount & "00" & FB & Cmd & "00000000" & TID_count & Addr;
    --FullHeader := Addr & "00000000" & TID_count & BCount & "00" & FB & Cmd;
    return FullHeader;

  end function Test_Concatination;


  procedure skiptime(time_count : in integer) is
  begin

    count_time : for k in 0 to time_count - 1 loop
      wait until rising_edge(TbClock);
    end loop count_time;

  end;


  --увеличение счетчика запросов
  function RecalculationTID(TID_count : in std_logic_vector(7 downto 0)) return std_logic_vector is
    variable result : std_logic_vector(7 downto 0);
  begin

    if TID_count = "11111111" then
      result := "00000000";
    else
      result := std_logic_vector(to_unsigned(to_integer(unsigned(TID_count)) + 1, 8));
    end if;
    return result;

  end function RecalculationTID;


  --процедура записи
  procedure WriteCommand(
    -- количество байт данных
    constant BCount : in std_logic_vector(9 downto 0);
    -- FeedBack наличие 1 - необходимость отправки на  хост для подтверждения приема и корректного анализа
    constant FB : in std_logic;
    -- команда
    constant Cmd : in std_logic_vector(2 downto 0);
    -- идентификатор транзакции
    constant TID_count : in std_logic_vector(7 downto 0);
    -- Адрес назначения (источника) данных
    constant Addr : in std_logic_vector(15 downto 0);
    --данные для записи
    constant data : in std_logic_vector;
    --выходы для записи
    signal FT2232H_FSDO : out std_logic
  )is
    variable FullHeader : std_logic_vector(0 to 47);
  begin

    FullHeader := Addr & "00000000" & TID_count & BCount & "00" & FB & Cmd;

    --циклическая запись заголовка
    full_write : for k in 0 to 5 loop
      -- запись Start bit (==0), если 1 то ошибка
      if (k /= 0) then
        wait until rising_edge(TbClock);
      end if;
      FT2232H_FSDO <= '0';
      --запись 8 значащих бит
      write8bit : for i in 0 to 7 loop
        wait until rising_edge(TbClock);
        --FT2232H_FSDO <= FullHeader(i + k*8);
        FT2232H_FSDO <= FullHeader(47 - (k * 8 + i));--записываемый бит
      end loop write8bit;
      -- запись Source bit
      wait until rising_edge(TbClock);
      FT2232H_FSDO <= '1';
    end loop full_write;

    if (BCount(0) /= '1') then
      --циклическая запись данных
      data_write1 : for g in 0 to ((to_integer(unsigned(BCount)))/2 - 1) loop
        -- запись Start bit (==0), если 1 то ошибка
        wait until rising_edge(TbClock);
        FT2232H_FSDO <= '0';
        --запись 16 значащих бит
        write16bit_data1 : for n in 15 downto 0 loop
          if (n = 7) then
            wait until rising_edge(TbClock);
            FT2232H_FSDO <= '1';
            wait until rising_edge(TbClock);
            FT2232H_FSDO <= '0';
          end if;

          wait until rising_edge(TbClock);
          FT2232H_FSDO <= data(n + g * 16);
        end loop write16bit_data1;
        -- запись Source bit
        wait until rising_edge(TbClock);
        FT2232H_FSDO <= '1';
      end loop data_write1;

    else

	 
	 --циклическая запись данных
      data_write2 : for g in 0 to ((to_integer(unsigned(BCount)))/2 - 1) loop
        -- запись Start bit (==0), если 1 то ошибка
        wait until rising_edge(TbClock);
        FT2232H_FSDO <= '0';
        --запись 16 значащих бит
        write16bit_data2 : for n in 15 downto 0 loop
          if (n = 7) then
            wait until rising_edge(TbClock);
            FT2232H_FSDO <= '1';
            wait until rising_edge(TbClock);
            FT2232H_FSDO <= '0';
          end if;

          wait until rising_edge(TbClock);
          FT2232H_FSDO <= data(n + g * 16);
        end loop write16bit_data2;
        -- запись Source bit
        wait until rising_edge(TbClock);
        FT2232H_FSDO <= '1';
      end loop data_write2;
	 
	 
      --значащая наоборот, а потом нули
      wait until rising_edge(TbClock);
      FT2232H_FSDO <= '0';
      write8bit_data1 : for q in ((to_integer(unsigned(BCount)))*8-1) downto ((to_integer(unsigned(BCount)))*8-8) loop
        wait until rising_edge(TbClock);
        FT2232H_FSDO <= data(q);
      end loop write8bit_data1;
		
      wait until rising_edge(TbClock);
      FT2232H_FSDO <= '1';
      wait until rising_edge(TbClock);
      FT2232H_FSDO <= '0';
		
      write8bit_data2 : for q in 7 downto 0 loop
        wait until rising_edge(TbClock);
        FT2232H_FSDO <= '0';
      end loop write8bit_data2;
      wait until rising_edge(TbClock);
      FT2232H_FSDO <= '1';

    end if;

  end procedure WriteCommand;
  --процедура чтения
  procedure ReadCommand(
    -- количество байт данных
    constant BCount : in std_logic_vector(9 downto 0);
    -- FeedBack наличие 1 - необходимость отправки на  хост для подтверждения приема и корректного анализа
    constant FB : in std_logic;
    -- команда
    constant Cmd : in std_logic_vector(2 downto 0);
    -- идентификатор транзакции
    constant TID_couunt : in std_logic_vector(7 downto 0);
    -- Адрес назначения (источника) данных
    constant Addr : in std_logic_vector(15 downto 0);
    signal FT2232H_FSDO : out std_logic
  )is
    variable FullHeader : std_logic_vector(0 to 47);
  begin

    FullHeader := Addr & "00000000" & TID_count & BCount & "00" & FB & Cmd; 

    --циклическая запись заголовка
    full_write : for k in 0 to 5 loop
      -- запись Start bit (==0), если 1 то ошибка
      if (k /= 0) then
        wait until rising_edge(TbClock);
      end if;
      FT2232H_FSDO <= '0';
      --запись 8 значащих бит
      write8bit : for i in 0 to 7 loop
        wait until rising_edge(TbClock);
        --FT2232H_FSDO <= FullHeader(i + k*8);
        FT2232H_FSDO <= FullHeader(47 - (k * 8 + i));--записываемый бит
      end loop write8bit;
      -- запись Source bit
      wait until rising_edge(TbClock);
      FT2232H_FSDO <= '1';
    end loop full_write;

  end procedure ReadCommand;

begin
  TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
  tester_clk <= TbClock;
  
  
  --установка FT2232H_FSCTS по запросу FT2232H_FSDI на 10 тактов
  set_FT2232H_FSCTS : process(TbClock)
  begin
    if(rising_edge(TbClock)) then
	   if (CTS_open_r = '0' and FT2232H_FSDI = '0') then
		      FSDI_count <= "0000";
	         CTS_open_r <= '1';
				FT2232H_FSCTS <= '0';
		else
				FSDI_count <= std_logic_vector(to_unsigned(to_integer(unsigned(FSDI_count)) + 1, 4));
	   end if;
	 
	   if (CTS_open_r = '1' and FSDI_count = "1000") then 
	       FT2232H_FSCTS <= '1';
	  	    CTS_open_r <= '0';
	   end if;
	 end if;
  end process;

  
  stimuli : process
  begin
    tester_reset <= '0';
    wait for TbPeriod;
    tester_reset <= '1';
    wait for TbPeriod;

	 
	 --010
    test_FullHeader <= Test_Concatination("0000000001", '0', "010", TID_count, "0000000100000000");
    WriteCommand("0000000001", '0', "010", TID_count, "0000000100000000", "11111111", FT2232H_FSDO);
	  TID_count <= RecalculationTID(TID_count);
    wait for TbPeriod;
	 
	 
	 --001
	 test_FullHeader <= Test_Concatination("0000000001", '1', "001", TID_count, "0000000100000001");
    ReadCommand("0000000001", '1', "001", TID_count, "0000000100000000", FT2232H_FSDO);
    TID_count <= RecalculationTID(TID_count);
    wait for TbPeriod;
	 
    --010
    test_FullHeader <= Test_Concatination("0000000001", '0', "010", TID_count, "0000000100000000");
    WriteCommand("0000000001", '0', "010", TID_count, "0000000100000000", "00000000", FT2232H_FSDO);
	  TID_count <= RecalculationTID(TID_count);
    wait for TbPeriod;
	 
	 --110
    test_FullHeader <= Test_Concatination("0000000001", '0', "010", TID_count, "0000000100000000");
    WriteCommand("0000000100", '1', "110", TID_count, "0000000100000011", "00100000000000000000000000000000", FT2232H_FSDO);
	 TID_count <= RecalculationTID(TID_count);
    wait for TbPeriod;
	 
	 
	 --101
	 test_FullHeader <= Test_Concatination("0000000001", '1', "001", TID_count, "0000000100000001");
    ReadCommand("0000000100", '1', "101", TID_count, "0000000100000011", FT2232H_FSDO);
    TID_count <= RecalculationTID(TID_count);
    wait for TbPeriod;
	 
	 --макар
	 
	 --110
  --   test_FullHeader <= Test_Concatination("0000000001", '0', "010", TID_count, "0000000100000000");
  --   WriteCommand("0000000011", '1', "110", TID_count, "0000000000000000", "010000001111111100000110", FT2232H_FSDO);
	--  TID_count <= RecalculationTID(TID_count);
  --   wait for TbPeriod;
	 
	 
	 --101
	--  test_FullHeader <= Test_Concatination("0000000001", '1', "001", TID_count, "0000000100000001");
  --   ReadCommand("0000000011", '1', "101", TID_count, "0000000000000000", FT2232H_FSDO);
  --   TID_count <= RecalculationTID(TID_count);
  --   wait for TbPeriod;


    skiptime(3000);
    TbSimEnded <= '1';
  end process;
  

end tester_top;
configuration ts_top of Tester is
  for tester_top
  end for;
end ts_top;