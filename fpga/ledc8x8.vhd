library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ledc8x8 is
port ( -- Sem doplnte popis rozhrani obvodu.
	RESET: in std_logic;
	SMCLK: in std_logic;
	ROW: out std_logic_vector(0 to 7);
	LED: out std_logic_vector(0 to 7)
);
end ledc8x8;

architecture main of ledc8x8 is

    -- Sem doplnte definice vnitrnich signalu.
    signal row_sig: std_logic_vector(7 downto 0);
    signal led_sig: std_logic_vector(7 downto 0);
    signal clk_enable: std_logic;
    signal first: std_logic := '0';
    signal J_in: std_logic_vector(7 downto 0);
    signal K_in: std_logic_vector(7 downto 0);    
    signal J_out: std_logic_vector(7 downto 0);
    signal K_out: std_logic_vector(7 downto 0);
    signal Y: std_logic_vector(7 downto 0);
begin

    -- Sem doplnte popis funkce obvodu (zakladni konstrukce VHDL jako napr.
    -- prirazeni signalu, multiplexory, dekodery, procesy...).
    -- DODRZUJTE ZASADY PSANI SYNTETIZOVATELNEHO VHDL UVEDENE NA WEBU:
    -- http://merlin.fit.vutbr.cz/FITkit/docs/navody/synth_templates.html

    -- Nezapomente take doplnit mapovani signalu rozhrani na piny FPGA
    -- v souboru ledc8x8.ucf.
    -- rotační registr
    registr: process(RESET, SMCLK)
	begin
	   if (RESET='1') then
	   	  --reset na prvni radek
	      row_sig <= ('1', others => '0'); 
	   elsif (SMCLK'event) and (SMCLK='1') then
	      	-- provedu rotaci (konkatenace posledniho bitu a a bitu 7-1)
	        row_sig <= row_sig(0) & row_sig(7 downto 1);
	   end if;
	end process;

	demux: process(row_sig) 	
	begin
	   case first is
	      when '0' => J_in <= row_sig;
	      when '1' => K_in <= row_sig;
	      when others => J_in <= row_sig;
	   end case;
	end process;

	mux: process(J_out, K_out)
	begin
	   case first is
	      when '0' => Y <= J_out;
	      when '1' => Y <= K_out;
	      when others => Y <= J_out;
	   end case;
	end process;

	j_decoder: process(J_in)
	begin
	   case J_in is
	      when "10000000" => J_out <= "11110111";
	      when "01000000" => J_out <= "11110111";
	      when "00100000" => J_out <= "11110111";
	      when "00010000" => J_out <= "10110111";
	      when "00001000" => J_out <= "11001111";
	      when "00000100" => J_out <= "11111111";
	      when "00000010" => J_out <= "11111111";
	      when "00000001" => J_out <= "11111111";
	      when others => J_out <= "11111111";
	   end case;
	end process;

	k_decoder: process(K_in)
	begin
	   case K_in is
	      when "10000000" => K_out <= "01101111";
	      when "01000000" => K_out <= "01011111";
	      when "00100000" => K_out <= "00111111";
	      when "00010000" => K_out <= "01011111";
	      when "00001000" => K_out <= "01101111";
	      when "00000100" => K_out <= "11111111";
	      when "00000010" => K_out <= "11111111";
	      when "00000001" => K_out <= "11111111";
	      when others => K_out <= "11111111";
	   end case;
	end process;
end main;
