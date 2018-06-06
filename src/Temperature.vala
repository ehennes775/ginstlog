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
        public Temperature(int channel_index, double temperature)
        {
            var readout = "%3.1f \u00B0F".printf(temperature);

            Object(
                channel_index : channel_index,
                readout_value : readout
                );
        }
    }
}
