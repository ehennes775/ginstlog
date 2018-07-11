/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * Contains the metadata for a measurment column in a CSV file
     */
    public class CsvMeasurementColumn : CsvColumn
    {
        /**
         *
         */
        public int channel_index
        {
            get;
            construct;
        }


        /**
         *
         */
        public string instrument_id
        {
            get;
            construct;
        }


        /**
         * Initialize the instance
         *
         * @param index The column index
         * @param name The name of the column in the CSV file
         * @param instrument_id
         * @param channel_index
         */
        public CsvMeasurementColumn(int index, string name, string instrument_id, int channel_index)
        {
            Object(
                index : index,
                name : name,
                instrument_id : instrument_id,
                channel_index : channel_index
                );
        }


        /**
         * {@inheritDoc}
         */
        public override string get_value(SuccessEntry entry)
        {
            return "0.0";
        }
    }
}
