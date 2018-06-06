/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * An abstract base class for mesaurement devices
     */
    public abstract class Instrument : Object
    {
        /**
         * Update UI readouts with a new measurement
         *
         * @param measurement The measurement
         */
        public signal void update_readout(Measurement measurement);


        /**
         * The number of channels on the instrument
         */
        public int channel_count
        {
            get;
            construct;
            default = 0;
        }
    }
}
