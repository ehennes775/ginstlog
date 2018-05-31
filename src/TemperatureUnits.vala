/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * Represents units for temperature measurements
     */
    public enum TemperatureUnits
    {
        /**
         * Indicates measurements made in Celsius
         */
        CELSIUS,


        /**
         * Indicates measurements made in Fahrenheit
         */
        FAHRENHEIT,


        /**
         * Indicates measurements made in Kelvin
         */
        KELVIN,


        /**
         * The number of temperature units
         */
        COUNT;


        /**
         * Return a string representation of the units
         *
         * The string returned by this function is suitable for both debugging
         * and display.
         *
         * @return The string representation of the units
         */
        public string to_string()

            requires(this < COUNT)

        {
            switch (this)
            {
                case CELSIUS:
                    return "\u00B0C";

                case FAHRENHEIT:
                    return "\u00B0F";

                case KELVIN:
                    return "\u00B0K";

                default:
                    return_val_if_reached("\u00B0");
            }
        }
    }
}
