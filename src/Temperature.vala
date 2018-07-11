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
         * The thermocouple type making the measurement
         */
        public ThermocoupleType thermocouple_type
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
         * @param type The thermocouple type making the measurement
         */
        public Temperature(
            Channel channel,
            string temperature,
            TemperatureUnits units,
            ThermocoupleType type
            )
        {
            Object(
                channel : channel,
                channel_index : channel.index,
                channel_name : channel.name,
                readout_value : @"$(temperature) $(units)",
                units : units,
                thermocouple_type : type
                );

            m_temperature = temperature;
        }


        /**
         * {@inheritDoc}
         */
        public override string get_value(string name)
        {
            return m_temperature;
        }


        /**
         *
         */
        private string m_temperature;
    }
}
