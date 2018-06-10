/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Represents a single temperature mesaurement
     */
    public class Temperature : Measurement
    {
        /**
         * The channel making the temperature measurement
         */
        public Channel channel
        {
            get;
            construct;
        }


        /**
         * The units of the temperature measurement
         */
        public TemperatureUnits units
        {
            get;
            construct;
        }


        /**
         * Initialize a new temperature measurement
         *
         * @param channel The channel making the temperature measurement
         * @param temperature The measurement in string format
         * @param units The units of the temperature measurement
         */
        public Temperature(Channel channel, string temperature, TemperatureUnits units)
        {
            Object(
                channel : channel,
                channel_index : channel.index,
                channel_name : channel.name,
                readout_value : @"$(temperature) $(units)",
                units : units
                );
        }
    }
}
