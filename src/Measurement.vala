/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * An abstract base class for mesaurements
     */
    public abstract class Measurement : Object
    {
        /**
         * The index of the channel on the instrument
         */
        public int channel_index
        {
            get;
            construct;
            default = 0;
        }


        /**
         * The index of the channel on the instrument
         */
        public string readout_value
        {
           get;
           construct;
        }
    }
}
