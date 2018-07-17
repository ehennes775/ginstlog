/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     * Contains the metadata for a timestamp column in a CSV file
     */
    public class CsvTimestampColumn : CsvColumn
    {
        /**
         * Initialize the instance
         *
         * @param index The zero based index if the column
         * @param name The name of the column in the CSV file
         */
        public CsvTimestampColumn(int index, string name)
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
            var rtime = entry.rtime;

            var seconds = rtime / 1000000;
            var microseconds = rtime % 1000000;

            var stamp = new DateTime.from_unix_local(seconds);
            stamp = stamp.add(microseconds);

            var builder = new StringBuilder();

            builder.append(stamp.format("%Y%m%dT%H%M%S"));
            builder.append_printf(@".%06$(int64.FORMAT)", microseconds);

            return builder.str;
        }
    }
}
