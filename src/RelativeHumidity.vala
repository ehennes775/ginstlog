/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Represents a single relative humidity measurement
     */
    public class RelativeHumidity : Measurement
    {
        /**
         * The channel making the relative humidity measurement
         */
        public Channel channel
        {
            get;
            construct;
        }


        /**
         * Initialize a new relative humidity measurement
         *
         * @param channel The channel making the relative humidity measurement
         * @param relative_humidity The measurement in string format
         */
        public RelativeHumidity(Channel channel, string relative_humidity)
        {
            Object(
                channel : channel,
                channel_index : channel.index,
                channel_name : channel.name,
                readout_value : @"$(relative_humidity) %RH"
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
