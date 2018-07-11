/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * Contains the metadata for a time column in a CSV file
     */
    public class CsvTimeColumn : CsvColumn
    {
        /**
         * Initialize the instance
         *
         * @param name The name of the column in the CSV file
         */
        public CsvTimeColumn(int index, string name)
        {
            Object(
                index : index,
                name : name
                );
        }


        /**
         * {@inheritDoc}
         */
        public override string get_value(SuccessEntry entry)
        {
            if (name == "mtime")
            {
                return entry.mtime.to_string();
            }
            else if (name == "rtime")
            {
                return entry.rtime.to_string();
            }
            else
            {
                return "ERR";
            }
        }
    }
}
