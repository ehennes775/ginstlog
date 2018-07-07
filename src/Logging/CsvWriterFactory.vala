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

            return new CsvWriter(file, FileMode.CREATE, columns, separator);
        }


        /**
         *
         */
        private static CsvColumn create_column(Xml.XPath.Context path_context) throws ConfigurationError
        {
            var name = XmlUtility.get_required_string(
                path_context,
                "./Name"
                );

            return new CsvColumn(name);
        }


        /**
         *
         */
        private static CsvColumn[] create_columns(Xml.XPath.Context path_context) throws ConfigurationError
        {
            var path_result = path_context.eval_expression(
                @"./ColumnTable/Column"
                );

            try
            {
                stdout.printf("Here1\n");

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
    }
}
