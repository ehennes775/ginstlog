/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Series407
{
    /**
     *
     */
    public abstract class ReadMeasurements : Object
    {
        /**
         * The last byte in a response, used to detect framing errors
         */
        public const uint8 END_BYTE = 0x0D;


        /**
         * The first byte in a response, used to detect framing errors
         */
        public const uint8 START_BYTE = 0x02;


        /**
         * Initialize a new instance
         */
        public ReadMeasurements()
        {
        }


        /**
         *
         */
        public abstract Measurement[] execute(SerialDevice device) throws Error;
    }
}
