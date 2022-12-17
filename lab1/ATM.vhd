library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ATM is
port ( userinput : in std_logic_vector(2 downto 0); -- Ввод пользователя
			enter : in std_logic;     -- первая кнопка(аналог enter)
			reset : in std_logic;     -- вторая кнопка(аналог reset)
			clk :  in std_logic;    -- clock
			seven_seg_6 : out std_logic_vector(7 downto 0);  -- вывод баланса, ошибок, сообщений,
			seven_seg_5 : out std_logic_vector(7 downto 0);  -- посредством помещения в эти сигналы
			seven_seg_4 : out std_logic_vector(7 downto 0);  -- значений, соответствующих константам
			seven_seg_3 : out std_logic_vector(7 downto 0);
			seven_seg_2 : out std_logic_vector(7 downto 0);
			seven_seg_1 : out std_logic_vector(7 downto 0)
);
end ATM;


architecture sequential of ATM is
-- набор констант для отображения в ATM_Display
constant D0 : std_logic_vector(7 downto 0):="11000000";
constant D1 : std_logic_vector(7 downto 0):="11111001";
constant D2 : std_logic_vector(7 downto 0):="10100100";
constant D3 : std_logic_vector(7 downto 0):="10110000";
constant D4 : std_logic_vector(7 downto 0):="10011001";
constant D5 : std_logic_vector(7 downto 0):="10010010";  --второе значение - S
constant D6 : std_logic_vector(7 downto 0):="10000010";	 --второе значение - G
constant D7 : std_logic_vector(7 downto 0):="11111000";
constant D8 : std_logic_vector(7 downto 0):="10000000";
constant D9 : std_logic_vector(7 downto 0):="10010000";
constant DA : std_logic_vector(7 downto 0):="10001000";
constant DB : std_logic_vector(7 downto 0):="10000011";
constant DC : std_logic_vector(7 downto 0):="11000110";
constant DD : std_logic_vector(7 downto 0):="10100001";
constant DE : std_logic_vector(7 downto 0):="10000110";
constant DF : std_logic_vector(7 downto 0):="10001110";
constant DH : std_logic_vector(7 downto 0):="10001001";
constant DL : std_logic_vector(7 downto 0):="11000111";
constant DN : std_logic_vector(7 downto 0):="11001000";
constant DP : std_logic_vector(7 downto 0):="10001100";
constant DR : std_logic_vector(7 downto 0):="10001000";
constant DV : std_logic_vector(7 downto 0):= "11000001";
constant Dfhalf_W : std_logic_vector(7 downto 0):="11000011";
constant Dshalf_W : std_logic_vector(7 downto 0):="11100001";
constant Dpoint : std_logic_vector(7 downto 0):="01111111";
constant Doff : std_logic_vector(7 downto 0) := "11111111";


signal ss6 : std_logic_vector(7 downto 0);
signal ss5 : std_logic_vector(7 downto 0);
signal ss4 : std_logic_vector(7 downto 0);
signal ss3 : std_logic_vector(7 downto 0);
signal ss2 : std_logic_vector(7 downto 0);
signal ss1 : std_logic_vector(7 downto 0);


type state_type is (state_start, state_select, state_input, state_output, state_done, state_digit, state_balance, state_error);
signal state : state_type ;
signal previous_state : state_type ; --Для внесения и снятия денег

signal balance : std_logic_vector(7 downto 0);

signal upper_digit, lower_digit : std_logic_vector(3 downto 0);

signal tens_digit : std_logic_vector(7 downto 0);
signal ones_digit : std_logic_vector(7 downto 0);

signal past_enter : std_logic;
signal event_enter : std_logic;

signal timer_4sec : integer  := 0;
signal timer_3sec : integer := 0;
signal timer_2sec : integer := 0;

begin
-----------------------------------------------------
clock_divider: process (clk)
variable clk_count: integer:=0;
begin
if(clk'event and clk = '1') then
  if clk_count = 4 then
	 
	if ((state = state_start or state = state_done) and timer_4sec <= 8) then
		timer_4sec <= timer_4sec + 1;
	else
		timer_4sec <= 0;
	end if;
	
	if (state = state_balance and timer_3sec <= 6) then
		timer_3sec <= timer_3sec + 1;
	else
		timer_3sec <= 0;
	end if;
	
	if (state = state_error and timer_2sec <= 4) then
		timer_2sec <= timer_2sec + 1;
	else
		timer_2sec <= 0;
	end if;
	 
    clk_count := 0;
  else
    clk_count := clk_count + 1;
  end if;
end if;
end process;
-----------------------------------------------------

ATM_Response: process(clk,reset)
variable tens, ones, int_result : integer := 0 ;
begin
	if (reset = '0') then --reset
		state <= state_start;
	elsif (rising_edge(clk)) then
		past_enter <= enter;
		case state is
		
			when state_start=> --hello
				if (timer_4sec >= 8) then
					state <= state_select;
				else
					state <= state_start; 
				end if;
	
			when state_select =>  -- выбор действия Withdrawl или Deposit (W-0 D-1)
				if (event_enter = '1' and userinput(0) = '1') then
					state <= state_input;
				elsif (event_enter = '1' and userinput(0) = '0') then
					state <= state_output;
				end if;

-------------------------------------------------------------------------------			
			when state_input =>  --внесение денег
				if (event_enter = '1' and userinput /= "000") then
					int_result := to_integer(unsigned(balance)) + to_integer(unsigned(userinput));
					if (int_result > 99) then
						previous_state <= state_input;
						state <= state_error;
					else
						tens := 0;
						digits1: while tens < 10 loop
							int_result := int_result - 10;
							tens := tens + 1 ;
							exit digits1 when int_result < 10;
						end loop digits1;
						ones := int_result;
						upper_digit <= std_logic_vector(to_unsigned(tens,4));
						lower_digit <= std_logic_vector(to_unsigned(ones,4));
						state <= state_done;
					end if;
				end if;
						
			
			when state_output => -- снятие денег
				if (event_enter = '1' and userinput /= "000") then
					if (balance < userinput) then
						previous_state <= state_output;
						upper_digit <= std_logic_vector(to_unsigned(tens,4));
						lower_digit <= std_logic_vector(to_unsigned(ones,4));
						state <= state_error;
					else
						int_result := to_integer(unsigned(balance)) - to_integer(unsigned(userinput));
						tens := 0;
						digits2: while tens < 10 loop
							int_result := int_result - 10;
							tens := tens + 1 ;
							exit digits2 when int_result < 10;
						end loop digits2;
						ones := int_result;
						upper_digit <= std_logic_vector(to_unsigned(tens,4));
						lower_digit <= std_logic_vector(to_unsigned(ones,4));
						state <= state_done;
					end if;
				end if;
				
			
			when state_done =>--сообщение об успешном выполнении
				if (timer_4sec >= 8) then
					state <= state_digit;
				else
					state <= state_done;
				end if;
				
			when state_digit => --вывод разрядов баланса
					
				case upper_digit is --первый разряд
					when "1001" => tens_digit <= D9;
					when "1000" => tens_digit <= D8;
					when "0111" => tens_digit <= D7;
					when "0110" => tens_digit <= D6;
					when "0101" => tens_digit <= D5;
					when "0100" => tens_digit <= D4;
					when "0011" => tens_digit <= D3;
					when "0010" => tens_digit <= D2;
					when "0001" => tens_digit <= D1;
					when "0000" => tens_digit <= D0;
					when others => tens_digit <= Doff;
				end case;
				
				case lower_digit is --второй разряд
					when "1001" => ones_digit <= D9;
					when "1000" => ones_digit <= D8;
					when "0111" => ones_digit <= D7;
					when "0110" => ones_digit <= D6;
					when "0101" => ones_digit <= D5;
					when "0100" => ones_digit <= D4;
					when "0011" => ones_digit <= D3;
					when "0010" => ones_digit <= D2;
					when "0001" => ones_digit <= D1;
					when "0000" => ones_digit <= D0;
					when others => ones_digit <= Doff;
				end case;
				
				state <= state_balance;
				
			when state_balance =>  --баланс
				if (timer_3sec >= 6) then
					state <= state_start;
				else
					state <= state_balance;
				end if;
				
				
			when state_error => --ошибка
				if (timer_2sec >= 4) then
				--если ошибка пришла из выдачи или внесения, то показываем баланс
					if (previous_state = state_input) then
						previous_state <= state_start;  -- обнуляем предыдущее состояние
						state <= state_balance;
					elsif (previous_state = state_output) then
						previous_state <= state_start;  -- обнуляем предыдущее состояние
						state <= state_digit;
					else
						state <= state_start;
					end if;
				else
					state <= state_error;
				end if;
-------------------------------------------------------------------------------				
				
			when others =>
				state <= state_start;

		end case;
	end if;
	event_enter <= enter and not past_enter;
end process;


ATM_Display: process(clk)
-- В любой момент времени будет отображаться какая-либо информация
begin
	if (rising_edge(clk)) then
		case state is
		
			when state_start =>
			-- приветствие
				ss6 <= DH;
				ss5 <= DE;
				ss4 <= DL;
				ss3 <= DL;
				ss2 <= D0;
				ss1 <= Doff;

			when state_select =>
			-- W-0 D-1 отображение
				ss6 <= Dfhalf_W;
				ss5 <= Dshalf_W;
				ss4 <= D0;
				ss3 <= Doff;
				ss2 <= DD;
				ss1 <= D1;
			
			when state_input =>
			-- VALUE
				ss6 <= DV;
				ss5 <= DA;
				ss4 <= DL;
				ss3 <= DV;
				ss2 <= DE;
				ss1 <= D1;
				
			when state_output =>
			-- VALUE
				ss6 <= DV;
				ss5 <= DA;
				ss4 <= DL;
				ss3 <= DV;
				ss2 <= DE;
				ss1 <= D0;
			
			when state_done =>
			-- DONE
				ss6 <= DD;
				ss5 <= D0;
				ss4 <= DN;
				ss3 <= DE;
				ss2 <= Doff;
				ss1 <= Doff;
			
			when state_balance =>
			-- отображение остатка на счету
				ss6 <= Doff;
				ss5 <= Doff;
				ss4 <= tens_digit;
				ss3 <= ones_digit;
				ss2 <= Doff;
				ss1 <= Doff;
			
			when state_error =>
			-- ERROR
				ss6 <= DE;
				ss5 <= DR;
				ss4 <= DR;
				ss3 <= D0;
				ss2 <= DR;
				ss1 <= Doff;
			
			when others =>
				-- Display all lights off --
				ss6 <= Doff;
				ss5 <= Doff;
				ss4 <= Doff;
				ss3 <= Doff;
				ss2 <= Doff;
				ss1 <= Doff;
				
		end case;
	end if;
end process;

seven_seg_6 <= ss6;
seven_seg_5 <= ss5;
seven_seg_4 <= ss4;
seven_seg_3 <= ss3;
seven_seg_2 <= ss2;
seven_seg_1 <= ss1;

end architecture sequential;