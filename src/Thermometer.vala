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
            SerialDevice serial_device
            ) throws Error
        {
            Object(
                channel_count : 2,
                interval : 500000,
                name : "B&K Precision 715"
                );

            m_channel = channels;
            m_serial_device = serial_device;

            m_serial_device.connect();

            Idle.add(poll_measurement);

            m_thread = new Thread<int>(
                @"Thread.$(name)",
                read_measurements
                );
        }


        /**
         *
         *
         *
         */
        ~Thermometer()
        {
            Idle.remove_by_data(this);
        }


		//public void change_units() throws Error
		//{
        //    send_command(CHANGE_UNITS_COMMAND);
		//}


		public void toggle_hold() throws Error
		{
            m_serial_device.send_command(TOGGLE_HOLD_COMMAND);
		}


		public void toggle_time() throws Error
		{
            m_serial_device.send_command(TOGGLE_TIME_COMMAND);
		}


		public void change_units() throws Error
		{
            m_serial_device.send_command(CHANGE_UNITS_COMMAND);
		}


        /**
         *
         *
         *
         */
        public void update() throws Error
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
                    var units = 0;

                    if ((response[2] & 0x01) == 0x01)
                    {
                        stdout.printf("Open loop T1 error\n");
                    }
                    else
                    {
                        var temp_t1 = (double) decode_bcd_string(response[3:5]);

                        if ((response[2] & 0x02) == 0x02)
                        {
                            temp_t1 = -temp_t1;
                        }

                        if ((response[2] & 0x04) == 0x00)
                        {
                            temp_t1 *= 0.1;
                        }

                        var to1 = new Temperature(m_channel[0], temp_t1);
                        m_queue.push(to1);
                    }

                    if ((response[2] & 0x08) == 0x08)
                    {
                        stdout.printf("Open loop T2 error\n");
                    }
                    else
                    {
                        var temp_t2 = (double) decode_bcd_string(response[7:9]);

                        if ((response[2] & 0x10) == 0x10)
                        {
                            temp_t2 = -temp_t2;
                        }

                        if ((response[2] & 0x20) == 0x00)
                        {
                            temp_t2 *= 0.1;
                        }

                        var to2 = new Temperature(m_channel[1], temp_t2);
                        m_queue.push(to2);
                    }
                }
            }
            catch (Error error)
            {
                stderr.printf("%s\n", error.message);
            }
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
         *
         */
        private AsyncQueue<Measurement> m_queue = new AsyncQueue<Measurement>();


        /**
         * The serial device to communicate with the instrument
         */
        private SerialDevice m_serial_device;


        /**
         *
         */
        private Thread<int> m_thread;


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



        /**
         *
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
         *
         */
        private int read_measurements()
        {
            while (true)
            {
                Thread.usleep(interval);

                update();
            }

            return 0;
        }
    }
}
