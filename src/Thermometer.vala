/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Supports thermometers by an unknown OEM
     *
     * Models Supported
     * * B&K Precision Model 715
     */
    public class Thermometer : Instrument
    {
        /**
         * The default name for this class of thermometer
         */
        public const string DEFAULT_NAME = "Dual Thermometer";


        /**
         * The interval to wait between polls, in microseconds
         */
        public ulong interval
        {
            get;
            construct;
            default = 500000;
        }


        /**
         * Construct the thermometer
         */
        public Thermometer(
            Channel[] channels,
            string name,
            SerialDevice serial_device
            ) throws Error
        {
            Object(
                channel_count : 2,
                interval : 500000,
                name : name
                );

            m_inner = new Inner(
                channels,
                interval,
                name,
                serial_device
                );

            m_inner.update_readout.connect(on_update_readout);

            m_inner.start();
        }


        /**
         *
         */
        ~Thermometer()
        {
            if (m_inner != null)
            {
                m_inner.update_readout.disconnect(on_update_readout);
                m_inner.stop();
                m_inner = null;
            }
        }


        /**
         *
         */
        public void toggle_hold() throws Error
        {
            //m_serial_device.send_command(TOGGLE_HOLD_COMMAND);
        }


        /**
         *
         */
        public void toggle_time() throws Error
        {
            //m_serial_device.send_command(TOGGLE_TIME_COMMAND);
        }


        /**
         *
         */
        public void change_units() throws Error
        {
            //m_serial_device.send_command(CHANGE_UNITS_COMMAND);
        }


        /**
         * An inner class to separate reference counting
         *
         * The threads and idle process add reference counts to the inner
         * class. The lifespan of an instance of the inner class lasts
         * until the idle process and thread are finished.
         *
         * The rest of the system adds reference counts to the outer class.
         * The lifespan of an instance of the outer class lasts until clients
         * no longer needs the outer class.
         *
         * If reference counting occured on an instance of the same class, then
         * an alternate mechanism would be requred to force garbage collection.
         */
        private class Inner
        {
            /**
             * Update UI readouts with a new measurement
             *
             * @param measurement The recent measurement
             */
            public signal void update_readout(Measurement measurement);


            /**
             *
             */
            public Inner(
                Channel[] channels,
                ulong interval,
                string name,
                SerialDevice serial_device
                )
            {
                m_channel = channels;
                m_interval = interval;
                m_queue = new AsyncQueue<Measurement>();
                m_name = name;
                m_serial_device = serial_device;
                AtomicInt.set(ref m_stop, 0);
            }


            /**
             * Start the background task an thread
             */
            public void start()
            {
                Idle.add(poll_measurement);

                m_thread = new Thread<int>(
                    @"Thread.$(m_name)",
                    read_measurements
                    );

                m_serial_device.connect();
            }


            /**
             * Stop the background task and thread
             *
             * This function must be called to ensure garbage collection. The
             * object will be freed when the idle background task and thread
             * no longer reference it.
             */
            public void stop()
            {
                AtomicInt.set(ref m_stop, 1);
                Idle.remove_by_data(this);
            }


            /**
             *
             */
            private static uint8 BLANK_NIBBLE = 0x0B;


            /**
             *
             */
            private static const uint8[] CHANGE_UNITS_COMMAND = { 'C' };


            /**
             *
             */
            private static const uint8[] EXIT_MINMAX_COMMAND = { 'N' };


            /**
             *
             */
            private static const uint8[] READ_COMMAND = { 'A' };


            /**
             *
             */
            private static const uint8[] READ_ALL_MEMORY_COMMAND = { 'U' };


            /**
             *
             */
            private static const uint8[] READ_MODEL_COMMAND = { 'K' };


            /**
             *
             */
            private static const uint8[] READ_RECORDINGS_COMMAND = { 'P' };


            /**
             *
             */
            private static const uint8[] SELECT_MINMAX_COMMAND = { 'M' };


            /**
             *
             */
            private static const uint8[] TOGGLE_HOLD_COMMAND = { 'H' };


            /**
             *
             */
            private static const uint8[] TOGGLE_TIME_COMMAND = { 'T' };


            /**
             *
             */
            private Channel[] m_channel;


            /**
             * The interval to wait between polls, in microseconds
             */
            private ulong m_interval;


            /**
             * The name of the instrument
             */
            private string m_name;


            /**
             * The serial device to communicate with the instrument
             */
            private SerialDevice m_serial_device;


            /**
             *
             */
            private AsyncQueue<Measurement> m_queue;


            private int m_stop;


            /**
             *
             */
            private Thread<int> m_thread;


            /**
             * Read measurements from the instrument
             *
             * @return A dummy value
             */
            private int read_measurements()
            {
                while (AtomicInt.get(ref m_stop) == 0)
                {
                    Thread.usleep(m_interval);

                    update();
                }

                return 0;
            }


            /**
             * Poll for recent measurements
             *
             * Called by the GUI thread to check if another measurement is
             * available.
             *
             * @return
             */
            private bool poll_measurement()
            {
                var measurement = m_queue.try_pop();

                if (measurement != null)
                {
                    update_readout(measurement);
                }

                return Source.CONTINUE;
            }

            /**
             * Decode both BCD digits in a byte
             *
             * The value 0x0B decodes to a "blank."
             *
             * @param byte The BCD byte to decode
             * @param allow Allow leading 'blank' values.
             * @return The value of byte [0,99].
             */
            private static int decode_bcd_byte(uint8 byte, ref bool allow) throws Error

                ensures (result >= 0)
                ensures (result <= 99)

            {
                var binary = 10 * decode_bcd_nibble(byte >> 4, allow);

                if (binary > 0)
                {
                    allow = false;
                }

                binary += decode_bcd_nibble(byte, allow);

                return binary;
            }


            /**
             * Decode the BCD digit in the least significant nibble
             *
             * The value 0x0B decodes to a "blank." The blank provides a
             * mechanism to remove leading zeros on the display. If blanks
             * are allowed, then the value is treated as a 0. If blanks
             * are not allowed, an error occurs when a blank is encountered.
             *
             * @param byte The BCD nibble to decode
             * @param allow Allow a 'blank' value.
             * @return The value of the least significant nibble [0,9].
             * @throw InstrumentError.INVALID_DATA
             */
            private static int decode_bcd_nibble(uint8 byte, bool allow) throws Error

                ensures (result >= 0)
                ensures (result <= 9)

            {
                var nibble = byte & 0x0F;

                if (allow && (nibble == BLANK_NIBBLE))
                {
                    nibble = 0x00;
                }

                if (nibble > 0x09)
                {
                    throw new InstrumentError.INVALID_DATA("");
                }

                return nibble;
            }


            /**
             * Decode a sequence of BCD bytes
             *
             * Most significant bytes are first in the array.
             *
             * @param bytes The string of BCD bytes to decode
             * @return The binary equivalent of the BCD bytes
             */
            private static int decode_bcd_string(uint8[] bytes) throws Error

                ensures (result >= 0)

            {
                bool allow = true;
                int binary = 0;
                uint8 last_byte = 0x00;

                foreach (var byte in bytes)
                {
                    last_byte = byte;

                    binary *= 100;

                    binary += decode_bcd_byte(byte, ref allow);
                }

                if ((last_byte & 0x0F) == BLANK_NIBBLE)
                {
                    // throw an error
                }

                return binary;
            }


            private string tempf(bool negative, uint8[] bytes, int places) throws Error
            {
                var builder = new StringBuilder();

                if (negative)
                {
                    builder.append_c('-');
                }

                var allow = true;
                var remaining_digits = 2 * bytes.length;

                foreach (var @byte in bytes)
                {
                    var upper_nibble = (@byte >> 4) & 0x0F;
                    var upper_decoded = decode_bcd_nibble(upper_nibble, allow);

                    if (upper_nibble != BLANK_NIBBLE)
                    {
                        builder.append_c((char)('0' + upper_decoded));

                        allow = false;
                    }

                    remaining_digits--;

                    if (remaining_digits == places)
                    {
                        builder.append_c('.');
                    }

                    var lower_nibble = @byte & 0x0F;
                    var lower_decoded = decode_bcd_nibble(lower_nibble, allow);

                    if (lower_nibble != BLANK_NIBBLE)
                    {
                        builder.append_c((char)('0' + lower_decoded));

                        allow = false;
                    }

                    remaining_digits--;
                }

                return builder.str;
            }


            /**
             *
             *
             *
             */
            private void update()
            {
                try
                {
                    m_serial_device.send_command(READ_COMMAND);

                    var response = m_serial_device.receive_response(10);

                    if ((response[0] != 0x02) || (response[9] != 0x03))
                    {
                        throw new InstrumentError.FRAMING_ERROR("Framing error\n");
                    }

                    var time_mode = ((response[1] & 0x08) == 0x08);

                    if (!time_mode)
                    {
                        var units = ((response[1] & 0x80) == 0x80) ?
                            TemperatureUnits.CELSIUS : TemperatureUnits.FAHRENHEIT;

                        if ((response[2] & 0x01) == 0x01)
                        {
                            stdout.printf("Open loop T1 error\n");
                        }
                        else
                        {
                            var negative = ((response[2] & 0x02) == 0x02);
                            var tenths = ((response[2] & 0x04) == 0x00);

                            var t1_readout = tempf(
                                negative,
                                response[3:5],
                                tenths ? 1 : 0
                                );

                            var t1 = new Temperature(
                                m_channel[0],
                                t1_readout,
                                units
                                );

                            m_queue.push(t1);
                        }

                        if ((response[2] & 0x08) == 0x08)
                        {
                            stdout.printf("Open loop T2 error\n");
                        }
                        else
                        {
                            var negative = ((response[2] & 0x10) == 0x10);
                            var tenths = ((response[2] & 0x20) == 0x00);

                            var t2_readout = tempf(
                                negative,
                                response[7:9],
                                tenths ? 1 : 0
                                );

                            var t2 = new Temperature(
                                m_channel[1],
                                t2_readout,
                                units
                                );

                            m_queue.push(t2);
                        }
                    }
                }
                catch (Error error)
                {
                    stderr.printf("%s\n", error.message);
                }
            }
        }


        /**
         *
         */
        private Inner? m_inner;


        /**
         *
         */
        private void on_update_readout(Measurement measurement)
        {
            update_readout(measurement);
        }
    }
}
