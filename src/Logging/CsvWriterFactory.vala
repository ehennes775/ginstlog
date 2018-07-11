/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog.Logging
{
    /**
     *
     */
    namespace CsvWriterFactory
    {
        /**
         *
         */
        public static Writer create(Xml.XPath.Context path_context) throws ConfigurationError
        {
            var columns = create_columns(path_context);

            var file_path = XmlUtility.get_required_string(
                path_context,
                "./FilePath"
                );

            var file = File.new_for_path(file_path);

            var separator = XmlUtility.get_optional_string(
                path_context,
                "./Separator",
                CsvWriter.DEFAULT_SEPARATOR
                );

            return new CsvWriter(file, FileMode.REPLACE, columns, separator);
        }


        /**
         *
         */
        private static CsvColumn create_column(Xml.XPath.Context path_context) throws ConfigurationError
        {
            var element_name = path_context.node->name;

            if (element_name == "MeasurementColumn")
            {
                return create_measurement_column(path_context);
            }
            else if (element_name == "TimeColumn")
            {
                return create_time_column(path_context);
            }
            else
            {
                throw new ConfigurationError.UKNOWN_CSV_COLUMN(
                    @"Uknown column type '$(element_name)'"
                    );
            }
        }


        /**
         *
         */
        private static CsvColumn[] create_columns(Xml.XPath.Context path_context) throws ConfigurationError
        {
            var path_result = path_context.eval_expression(
                @"./ColumnTable/*[@index]"
                );

            try
            {
                return_val_if_fail(
                    path_result != null,
                    null
                    );

                return_val_if_fail(
                    path_result->type == Xml.XPath.ObjectType.NODESET,
                    null
                    );

                return_val_if_fail(
                    path_result->nodesetval != null,
                    null
                    );

                var column_path_context = new Xml.XPath.Context(path_context.doc);
                var count = path_result->nodesetval->length();
                var column_table = new CsvColumn[count];

                for (int node_index = 0; node_index < count; node_index++)
                {
                    column_path_context.node = path_result->nodesetval->item(node_index);

                    var column = create_column(column_path_context);

                    column_table[node_index] = column;
                }

                return column_table;
            }
            finally
            {
                delete path_result;
            }
        }


        /**
         *
         */
        private static CsvColumn create_measurement_column(Xml.XPath.Context path_context) throws ConfigurationError
        {
            var column_index = XmlUtility.get_required_int(
                path_context,
                "./@index"
                );

            var name = XmlUtility.get_required_string(
                path_context,
                "./Name"
                );

            var instrument_id = XmlUtility.get_required_string(
                path_context,
                "./InstrumentId"
                );

            var channel_index = XmlUtility.get_required_int(
                path_context,
                "./ChannelIndex"
                );

            return new CsvMeasurementColumn(column_index, name, instrument_id, channel_index);
        }


        /**
         *
         */
        private static CsvColumn create_time_column(Xml.XPath.Context path_context) throws ConfigurationError
        {
            var column_index = XmlUtility.get_required_int(
                path_context,
                "./@index"
                );

            var name = XmlUtility.get_required_string(
                path_context,
                "./Name"
                );

            return new CsvTimeColumn(column_index, name);
        }
    }
}
