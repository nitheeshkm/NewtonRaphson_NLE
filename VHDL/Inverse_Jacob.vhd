----------------------------------------------------------------------------------
-- Company: URTPC
-- Engineer: Nitheesh Manjunath
-- 
-- Create Date: 06/18/2020 11:07:57 AM
-- Design Name: 
-- Module Name: Inverse_Jacob - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Inverse_Jacob is
    Generic (
        dw : natural := 32
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        en : in std_logic;
        x : in std_logic_vector(dw-1 downto 0);
        y : in std_logic_vector(dw-1 downto 0);
        z : in std_logic_vector(dw-1 downto 0);
        
        done_o : out std_logic;
        determinant : out std_logic_vector(dw-1 downto 0);
        Aj00 : out std_logic_vector(dw-1 downto 0);
        Aj10 : out std_logic_vector(dw-1 downto 0);
        Aj20 : out std_logic_vector(dw-1 downto 0);
        Aj01 : out std_logic_vector(dw-1 downto 0);
        Aj11 : out std_logic_vector(dw-1 downto 0);
        Aj21 : out std_logic_vector(dw-1 downto 0);
        Aj02 : out std_logic_vector(dw-1 downto 0);
        Aj12 : out std_logic_vector(dw-1 downto 0);
        Aj22 : out std_logic_vector(dw-1 downto 0)
        );
        
end Inverse_Jacob;

architecture Behavioral of Inverse_Jacob is
    type state_type is (state_0, state_1, state_2, state_3, state_4, state_5, state_6); 
    signal currentState : state_type;
    
    signal j00 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal j01 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal j02 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal j10 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal j11 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal j12 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal j20 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal j21 : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal j22 : std_logic_vector(dw-1 downto 0) := (others => '0');
    
    signal iAj00 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal iAj01 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal iAj02 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal iAj10 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal iAj11 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal iAj12 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal iAj20 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal iAj21 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal iAj22 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    
    signal D : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal DD : std_logic_vector(dw-1 downto 0) := (others => '0');
    signal DDD : std_logic_vector(dw-1 downto 0) := (others => '0');
    
    signal j00_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j01_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j02_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j10_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j11_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j12_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j20_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j21_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j22_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal j22_2 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    
    signal D_0 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal D_1 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    signal D_2 : std_logic_vector(2*dw-1 downto 0) := (others => '0');
    
    signal DI : std_logic_vector(dw-1 downto 0) := (others => '0');
    
    signal done : std_logic := '0';
    signal overflow_flag : std_logic := '0';
    
    signal div_start : std_logic := '0';
begin

process(clk) begin
    if  rising_edge(clk) then
        if rst = '1' then
            currentState <= state_0;
            done_o <= '0';
        else 
            case (currentState) is
                when state_0 =>
                    done_o <= '0';
                    if en = '1' then
                        currentState <= state_1;
                    else 
                        currentState <= state_0;
                    end if;
                    
                when state_1 => 
                    currentState <= state_2;
                
                when state_2 =>
                    currentState <= state_3;
                    
                when state_3 =>
                    currentState <= state_4;
                
                when state_4 =>
                    currentState <= state_5;
                    
                when state_5 =>
                    if done = '0' then
                        currentState <= state_5;
                    else 
                        currentState <= state_6;
                    end if;
                
                when state_6 => 
                    done_o <= '1';
                    currentState <= state_0;
                
                when others =>
                    currentState <= state_0;
                    
            end case;
        end if;
    end if;
end process;

process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            j00 <= (others => '0');
            j01 <= (others => '0');
            j02 <= (others => '0');
            
            j10 <= (others => '0');
            j11 <= (others => '0');
            j12 <= (others => '0');
            
            j20 <= (others => '0');
            j21 <= (others => '0');
            j22 <= (others => '0');
            
        else 
            if en = '1' then
                j00 <= std_logic_vector(signed(j00_1(56-1 downto 24)) + "11111110000000000000000000000000");
                j01 <= j01_1(56-1 downto 24);
                j02 <="11111111000000000000000000000000";
                
                j10 <= std_logic_vector(signed(j10_1(56-1 downto 24)) + "11111111000000000000000000000000");
                j11 <= std_logic_vector(signed(j11_1(56-1 downto 24)) + "11111101000000000000000000000000" + signed(z));
                j12 <= y;
                
                j20 <= std_logic_vector(signed(j20_1(56-1 downto 24)) + signed(y));
                j21 <= std_logic_vector(signed(j20_1(56-1 downto 24)) + signed(x));
                j22 <= std_logic_vector(signed(j22_2(56-1 downto 24)) + "11111101000000000000000000000000");
            end if;        
        end if;
    end if;
end process;

j00_1 <= std_logic_vector("00000010000000000000000000000000"*signed(x));   --2*x
j01_1 <= std_logic_vector("00000010000000000000000000000000"*signed(y));     --2*y
j10_1 <= std_logic_vector(signed(y) * signed(y));                                        --y^2
j11_1 <= std_logic_vector(signed(j00_1(56-1 downto 24))*signed(y));                            --2*x*y
j20_1 <= std_logic_vector(signed(z) * signed(z));                                        --z^2
j22_1 <= std_logic_vector("00000010000000000000000000000000"* signed(z));  --2*z
j22_2 <= std_logic_vector(signed(j22_1(56-1 downto 24))*(signed(y) + signed(x)));                      --2*z(x+y)


process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            iAj00 <= (others => '0');
            iAj01 <= (others => '0');
            iAj02 <= (others => '0');
            
            iAj10 <= (others => '0');
            iAj11 <= (others => '0');
            iAj12 <= (others => '0');
            
            iAj20 <= (others => '0');
            iAj21 <= (others => '0');
            iAj22 <= (others => '0');
        else 
            if currentState = state_1 then
                iAj00 <= std_logic_vector(signed(j11)*signed(j22) - signed(j12)*signed(j21));
                iAj01 <= std_logic_vector(-(signed(j10)*signed(j22) - signed(j20)*signed(j12)));
                iAj02 <= std_logic_vector(signed(j10)*signed(j21) - signed(j20)*signed(j11));
                iAj10 <= std_logic_vector(-(signed(j01)*signed(j22) - signed(j21)*signed(j02)));
                iAj11 <= std_logic_vector(signed(j00)*signed(j22) - signed(j20)*signed(j02));
                iAj12 <= std_logic_vector(-(signed(j00)*signed(j21) - signed(j01)*signed(j20)));
                iAj20 <= std_logic_vector(signed(j01)*signed(j12) - signed(j11)*signed(j02));
                iAj21 <= std_logic_vector(-(signed(j00)*signed(j12) - signed(j10)*signed(j02)));
                iAj22 <= std_logic_vector(signed(j00)*signed(j11) - signed(j10)*signed(j01));
            end if;
        end if;
    end if;
end process;

process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            D <= (others => '0');
        else
            if currentState = state_2 then
               D <= std_logic_vector(signed(D_0(56-1 downto 24)) + signed(D_1(56-1 downto 24)) + signed(D_2(56-1 downto 24))); 
            end if;
        end if;
    end if;
end process;

D_0 <= std_logic_vector(signed(j00)*signed(iAj00(56-1 downto 24)));
D_1 <= std_logic_vector(signed(j01)*signed(iAj01(56-1 downto 24)));
D_2 <= std_logic_vector(signed(j02)*signed(iAj02(56-1 downto 24)));


process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            DD <= (others => '0');
        else 
            if D(31) = '1' then
                DD <= std_logic_vector(-(signed(D)));
            else 
                DD <= D;
            end if;
        end if;
    end if;
end process;

process(currentState, div_start) begin
    if currentState = state_4 then
        div_start <= '1';
    else 
        div_start <= '0';
    end if;
end process;

my_divider : entity work.qdiv 
    generic map
    (
    Q => 24,
    N => dw
    )
    port map(
    i_dividend => "00000001000000000000000000000000",
    i_divisor => DD,
    i_start => div_start,
    i_clk => clk,
    o_quotient_out => DI,
    o_complete => done,
    o_overflow =>overflow_flag
    );
    

process(clk) begin
    if rising_edge(clk) then
        if rst = '1' then
            DDD <= (others => '0');
        else 
            if D(31) = '1' then
                DDD <= std_logic_vector(-(signed(DI)));
            else 
                DDD <= DI;
            end if;
        end if;
    end if;
end process;

determinant <= std_logic_vector(DDD);

Aj00 <= iAj00(56-1 downto 24);
Aj10 <= iAj10(56-1 downto 24);
Aj20 <= iAj20(56-1 downto 24);
Aj01 <= iAj01(56-1 downto 24);
Aj11 <= iAj11(56-1 downto 24);
Aj21 <= iAj21(56-1 downto 24);
Aj02 <= iAj02(56-1 downto 24);
Aj12 <= iAj12(56-1 downto 24);
Aj22 <= iAj22(56-1 downto 24);


end Behavioral;
