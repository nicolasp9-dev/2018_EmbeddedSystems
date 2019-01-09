-- Author: Nicolas Peslerbe | Embedded system course | Image Processing Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avalon_master_camera is
    port(

        clk         : in  std_logic;
        reset       : in  std_logic;

        sync_reset                  : in std_logic;
        end_writing_image           : out std_logic;
        base_address                : in std_logic_vector(31 downto 0);

        must_read_from_buffer       : out std_logic;
        pixel_in_buffer             : in std_logic;
        incoming_pixel_value        : in std_logic_vector(15 downto 0);
        number_of_pixels_in_buffer  : in std_logic_vector(7 downto 0);

        -- Avalon Master bus transmission
        avm_address : out std_logic_vector(31 downto 0);
        avm_byteenable_n : out std_logic_vector(3 downto 0);
        avm_burstcount : out std_logic_vector(2 downto 0);
        avm_write : out std_logic;
        avm_writedata : out std_logic_vector(31 downto 0);
        avm_waitrequest : in std_logic

    );
end avalon_master_camera;


architecture synth of avalon_master_camera is

    type  MWriteState is (Idle, GetData, WaitData, WriteData);

    signal must_send : std_logic;
    signal state_machine : MWriteState;
    signal line_id : integer;
    signal column_id : integer;
    signal mask_first : std_logic;
    signal actual_address : std_logic_vector(31 downto 0);
    signal data_written : std_logic;
    constant line_length : integer := 320;

begin

    master_control : process(clk, reset)
    begin
        if reset = '1' then
            state_machine <= Idle;
            avm_write <= '0';
            avm_byteenable_n <= "1111";
            data_written <= '0';

        elsif rising_edge(clk) then
            data_written <= '0';
            must_read_from_buffer <= '0';
            if sync_reset = '1' then
                state_machine <= Idle;
                avm_write <= '0';
                avm_byteenable_n <= "1111";
            else
                case state_machine is
                    when Idle =>
                        if must_send = '1' then
                            state_machine <=  WaitData;
                        end if;
                    when WaitData =>
                        if pixel_in_buffer = '1' then
                           must_read_from_buffer <= '1';
                           state_machine <=  GetData;
                        end if;
                    when GetData =>
                        state_machine <= WriteData;
                        avm_address <= actual_address;
                        avm_write <= '1';
                        avm_writedata(31 downto 16) <= incoming_pixel_value;
                        avm_writedata(15 downto 0) <= incoming_pixel_value;
                        data_written <= '1';
                        if mask_first = '1' then
                            avm_byteenable_n <= "1100";
                        else
                            avm_byteenable_n <= "0011";
                        end if;
                    when WriteData =>
                        if avm_waitrequest = '0' then
                            avm_write <= '0';
                            avm_byteenable_n <= "1111";
                            if must_send = '1' then
                                state_machine <=  WaitData;
                            else
                                state_machine <=  Idle;
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process;


    compute_pixel_location : process(clk, reset)
    begin

        if reset = '1' then
            end_writing_image <= '0';
            line_id <= 0;
            column_id <= 0;
            mask_first <= '0';
            actual_address <= (others => '0');
            must_send <= '0';
        elsif rising_edge(clk) then
            end_writing_image <= '0';
            actual_address <=  std_logic_vector(unsigned(base_address) + to_unsigned(line_id * line_length + column_id, actual_address'length)*4);

            if sync_reset = '1' then
                must_send <= '1';
                line_id <= 0;
                column_id <= 0;
                mask_first <= '0';
                actual_address <= (others => '0');

            elsif data_written = '1' then
                if line_id = 319 then
                    line_id <= 0;
                    if mask_first = '1' then
                        if column_id = 239 then
                            column_id <= 0;
                            end_writing_image <= '1';
                            must_send <= '0';
                        else
                            column_id <= column_id + 1;
                        end if;
                    end if;
                    mask_first <= not mask_first;
                else
                    line_id <= line_id + 1;
                end if;
            end if;
        end if;

    end process;



end synth;
