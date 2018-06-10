/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    namespace XmlUtility
    {
        /**
         * @param path_context
         * @param relative_path
         * @return
         */
        private int get_path_int(Xml.XPath.Context path_context, string relative_path) throws ConfigurationError
        {
            var content = get_required_string(path_context, relative_path);
            int64 @value = 0;

            var success = int64.try_parse(content, out @value);

            if (!success)
            {
                //throw new ConfigurationError.
            }

            if ((@value < int.MIN) || (@value > int.MAX))
            {
                //throw new ConfigurationError.
            }

            return (int) @value;
        }


        /**
         * @param path_context
         * @param relative_path
         * @return
         */
        private string? get_optional_string(Xml.XPath.Context path_context, string relative_path, string? default_value = null) throws ConfigurationError
        {
            var path_result = path_context.eval_expression(relative_path);

            try
            {
                return_val_if_fail(
                    path_result != null,
                    default_value
                    );

                return_val_if_fail(
                    path_result->type == Xml.XPath.ObjectType.NODESET,
                    default_value
                    );

                return_val_if_fail(
                    path_result->nodesetval != null,
                    default_value
                    );

                var count = path_result->nodesetval->length();

                if (count == 0)
                {
                    return default_value;
                }

                return_val_if_fail(
                    count == 1,
                    default_value
                    );

                var node = path_result->nodesetval->item(0);

                return_val_if_fail(
                    node != null,
                    default_value
                    );

                return node->get_content();
            }
            finally
            {
                delete path_result;
            }
        }


        /**
         * @param path_context
         * @param relative_path
         * @return
         */
        private Xml.Node* get_required_node(Xml.XPath.Context path_context, string relative_path) throws ConfigurationError
        {
            var path_result = path_context.eval_expression(relative_path);

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

                var count = path_result->nodesetval->length();

                if (count != 1)
                {

                }

                var node = path_result->nodesetval->item(0);

                return_val_if_fail(
                    node != null,
                    null
                    );

                return node;
            }
            finally
            {
                delete path_result;
            }
        }


        /**
         * @param path_context
         * @param relative_path
         * @return
         */
        private string get_required_string(Xml.XPath.Context path_context, string relative_path) throws ConfigurationError
        {
            var path_result = path_context.eval_expression(relative_path);

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

                var count = path_result->nodesetval->length();

                if (count != 1)
                {

                }

                var node = path_result->nodesetval->item(0);

                return_val_if_fail(
                    node != null,
                    null
                    );

                return node->get_content();
            }
            finally
            {
                delete path_result;
            }
        }
    }
}
