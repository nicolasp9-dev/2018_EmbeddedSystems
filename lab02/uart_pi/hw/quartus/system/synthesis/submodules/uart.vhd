-- Author: Nicolas Peslerbe | Embedded system course | UART Programmabe Interface

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

entity uart is
    port(
        clk         : in  std_logic;
        reset       : in std_logic;

        -- Avalon bus transmission
        avs_address : in std_logic_vector(1 downto 0);
        avs_read    : in std_logic;
        avs_readdata: out std_logic_vector(31 downto 0);
        avs_write   : in std_logic;
        avs_writedata:in std_logic_vector(31 downto 0);

        -- External Tx / Rx Transmission
        tx          : out std_logic;
        rx          : in std_logic
    );
end uart;

architecture synth of uart is

    component flags
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;

            read        : in  std_logic;
            rddata      : out std_logic_vector(7 downto 0);
            data_to_read: in  std_logic
        );
    end component;

    component setup
        port(
            clk         : in    std_logic;
            reset       : in    std_logic;
            data        : in    std_logic_vector(7 downto 0);
            must_record : in    std_logic;
            word_lenth  : out   std_logic_vector(2 downto 0);
            parity      : out   std_logic;
            rate        : out   std_logic_vector(3 downto 0)
        );
    end component;

    component write_buffer
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;
            write       : in  std_logic;
            wrdata      : in  std_logic_vector(7 downto 0);
            not_empty   : out std_logic;
            next_item   : in  std_logic;
            rddata      : out std_logic_vector(7 downto 0)
        );
    end component;

    component write
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;
            written     : out std_logic;
            write       : in  std_logic;
            wrdata      : in  std_logic_vector(7 downto 0);
            word_lenth  : in  std_logic_vector(2 downto 0);
            parity      : in  std_logic;
            rate        : in  std_logic_vector(3 downto 0);
            tx          : out std_logic
        );
    end component;

    component read_buffer
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;
            read        : in  std_logic;
            rddata      : out std_logic_vector(7 downto 0);

            not_empty   : out std_logic;
            write       : in  std_logic;
            wrdata      : in  std_logic_vector(7 downto 0)
        );
    end component;


    component read
        port(
            clk         : in  std_logic;
            reset       : in  std_logic;
            read        : out std_logic;
            rddata      : out std_logic_vector(7 downto 0);
            word_lenth  : in  std_logic_vector(2 downto 0);
            parity      : in  std_logic;
            rate        : in  std_logic_vector(3 downto 0);
            rx          : in  std_logic
        );

    end component;

    -- Global states
    signal action_write_to_uart : std_logic;
    signal action_read_from_uart : std_logic;
    signal action_setup_uart : std_logic;
    signal action_get_flags : std_logic;

    --Setup parameters
    signal word_lenth  : std_logic_vector(2 downto 0);
    signal parity      : std_logic;
    signal rate        : std_logic_vector(3 downto 0);

    signal must_write_to_uart : std_logic ;
    signal written_on_uart : std_logic;
    signal data_to_write_on_uart : std_logic_vector(7 downto 0);

    signal read_flags : std_logic_vector(7 downto 0);
    signal read_buffer_sig : std_logic_vector(7 downto 0);

    signal data_read_from_uart : std_logic_vector(7 downto 0);
    signal must_save_from_uart : std_logic;
    signal data_incomming_from_uart : std_logic;
    signal was_read : std_logic;

    signal write_data : std_logic_vector(7 downto 0);

begin
    flags_0 : flags
        port map(
            clk         => clk,
            reset       => reset,
            read        => action_get_flags,
            rddata      => read_flags,
            data_to_read => data_incomming_from_uart);

    setup_0 : setup
        port map(
            clk         => clk,
            reset       => reset,
            data        => write_data,
            must_record => action_setup_uart,
            word_lenth  => word_lenth,
            parity      => parity,
            rate        => rate);

    write_buffer_0 : write_buffer
        port map(
            clk         => clk,
            reset       => reset,
            write       => action_write_to_uart,
            wrdata      => write_data,

            not_empty   => must_write_to_uart,
            next_item   => written_on_uart,
            rddata      => data_to_write_on_uart);

    write_0 : write
        port map(
            clk         => clk,
            reset       => reset,
            tx          => tx,
            written     => written_on_uart,
            write       => must_write_to_uart,
            wrdata      => data_to_write_on_uart,

            word_lenth  => word_lenth,
            parity      => parity,
            rate        => rate);

    read_buffer_0 : read_buffer
        port map(
            clk         => clk,
            reset       => reset,

            read        => action_read_from_uart,
            rddata      => read_buffer_sig,
            not_empty   => data_incomming_from_uart,

            wrdata      => data_read_from_uart,
            write       => must_save_from_uart);

    read_0 : read
        port map(
            clk         => clk,
            reset       => reset,

            rddata      => data_read_from_uart,
            read        => must_save_from_uart,
            word_lenth  => word_lenth,
            parity      => parity,
            rate        => rate,
            rx          => rx);


    map_action: process(clk)
    begin
        if rising_edge(clk) then
            action_read_from_uart <= '0';
            action_write_to_uart <= '0';
            action_setup_uart <= '0';
            action_get_flags <= '0';
            was_read <= '0';

            case avs_address is
                when "00" =>
                    action_setup_uart <= avs_write;
                    write_data <= avs_writedata(7 downto 0);
			        avs_readdata(7 downto 0) <= (others => 'Z');
                when "01" =>
                    if (avs_read = '1') and (was_read = '0') then
                        was_read <= '1';
                        avs_readdata(7 downto 0) <= read_buffer_sig;
                        action_read_from_uart <= '1';
                    end if;
                when "10" =>
                    action_write_to_uart <= avs_write;
                    write_data <= avs_writedata(7 downto 0);
			        avs_readdata(7 downto 0) <= (others => 'Z');
                when "11" =>
                    if avs_read = '1' then
                        avs_readdata(7 downto 0) <= read_flags;
                    end if;

                when others =>
			        avs_readdata(7 downto 0) <= (others => 'Z');
            end case;

        end if;

    end process map_action;

end synth;