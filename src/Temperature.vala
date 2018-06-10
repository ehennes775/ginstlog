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
        public Channel channel
        {
            get;
            construct;
        }


        public Temperature(Channel channel, double temperature)
        {
            var readout = "%3.1f \u00B0F".printf(temperature);

            Object(
                channel : channel,
                channel_index : channel.index,
                channel_name : channel.name,
                readout_value : readout
                );
        }
    }
}
