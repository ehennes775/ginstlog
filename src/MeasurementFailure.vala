/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Represents an error while taking a measurment
     */
    public class MeasurementFailure : Measurement
    {
        /**
         * Initialize a new measurement failure
         *
         * @param channel The channel making the temperature measurement
         * @param readout A short message to fit on the display of the instrument
         */
        public MeasurementFailure(Channel channel, string readout)
        {
            Object(
                channel_index : channel.index,
                channel_name : channel.name,
                readout_value : readout
                );
        }


        /**
         * {@inheritDoc}
         */
        public override string get_value(string name)
        {
            return "0.0";
        }
    }
}
