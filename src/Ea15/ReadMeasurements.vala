/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Ea15
{
    /**
    * A command to read measurements
     */
    public abstract class ReadMeasurements : Object
    {
        /**
         * Initialize a new instance
         */
        public ReadMeasurements()
        {
        }


        /**
         * Read measurements from an instrument
         *
         *
         *
         * @param device The serial device to read the measurements from
         * @return The measurements from the device
         */
        public abstract Measurement[] execute(SerialDevice device) throws Error;
    }
}
