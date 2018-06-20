/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
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
         *
         */
        public abstract Measurement[] execute(SerialDevice device) throws Error;
    }
}
