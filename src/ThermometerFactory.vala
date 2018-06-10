/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * A class for creating thermometers
     */
    public class ThermometerFactory : InstrumentFactory
    {
        /**
         *
         *
         * @param node
         * @return
         */
        public override Instrument create_instrument(Xml.Node* node) throws Error

            requires(node != null)

        {
            var activeId = 0;

            var path_context = new Xml.XPath.Context(node);

            var path_result = path_context.eval_expression(
                @"./DeviceTable/*/@activeId"
                );

            var path_result = path_context.eval_expression(
                @"./DeviceTable/*[@id='$(activeId)']"
                );

            try
            {
                return new Thermometer();
            }
            finally
            {
                delete path_result;
            }
        }
    }



    private Channel create_channel(Xml.Node* node) throws Error

        requires(node != null)

    {
       var index = 0;
       var default_name = make_default_channel_name(index);
       var name = "T1";

       return new Channel(index, default_name, name);
    }


    private Channel[] create_channels(Xml.XPath.Context path_context) throws Error
    {
        var path_result = path_context.eval_expression(
            @"./ChannelTable/Channel"
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

            var count = path_result->nodesetval->length();

            var channel_table = new Channel[count];

            for (int node_index = 0; node_index < count; node_index++)
            {
                var node = path_result->nodesetval->item(node_index);

                var channel = create_channel(node);

                if ((channel.index < 0) || (channel.index >= count))
                {
                    throw new ConfigurationError.GENERIC(
                        @"Channel index $(channel.index) out of range [0,$(count))"
                        );
                }

                if (channel_table[channel.index] != null)
                {
                    throw new ConfigurationError.GENERIC(
                        @"Duplicate channel index $(channel.index)"
                        );
                }

                channel_table[channel.index] = channel;
            }

            return channel_table;
        }
        finally
        {
            delete path_result;
        }
    }


    /**
     *
     */
    private string make_default_channel_name(int index)

        requires(index >= 0)

    {
        return @"$(channel_prefix)$(index + 1)";
    }
}
