/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     * A UI representation of a thermometer
     */
    [GtkTemplate(ui="/com/github/ehennes775/ginstlog/ThermometerWidget.ui.xml")]
    public class ThermometerWidget : Gtk.Grid, Gtk.Buildable
    {
        /**
         * The instrument assocaited with this widget
         */
        public Instrument? instrument
        {
            get
            {
                return b_instrument;
            }
            construct set
            {
                if (b_instrument != null)
                {
                    instrument.update_readout.disconnect(on_update_readout);
                }

                b_instrument = value;

                if (b_instrument != null)
                {
                    instrument.update_readout.connect(on_update_readout);

                    b_name_label.label = instrument.name;

                    for (var index = 0; index < READOUT_COUNT; index++)
                    {
                        var visible = index < b_instrument.channel_count;

                        b_label[index].set_visible(visible);
                        b_readout[index].set_visible(visible);
                    }
                }
                else
                {
                    /* Clear the readouts, disable buttons, etc... */
                }
            }
        }


        /**
         * Initialize the instance
         */
        construct
        {
        }


        /**
         *
         */
        public void parser_finished (Gtk.Builder builder)
        {
            b_label = new Gtk.Label[READOUT_COUNT];
            b_readout = new Gtk.Label[READOUT_COUNT];

            for (var index = 0; index < READOUT_COUNT; index++)
            {
                var label_name = @"t$(index+1)-label";

                b_label[index] = builder.get_object(label_name) as Gtk.Label;
                return_if_fail(b_label[index] != null);

                var readout_name = @"t$(index+1)-readout";

                b_readout[index] = builder.get_object(readout_name) as Gtk.Label;
                return_if_fail(b_readout[index] != null);
            }
        }


        /**
         * The maximum number of readouts that can be shown
         *
         * The instrument can have more channels than the widget can show.
         */
        private const int READOUT_COUNT = 4;


        /**
         * The backing store for the instrument
         *
         * This value will be null if no instrument is assocaited with
         * this widget.
         */
        private Instrument? b_instrument;


        /**
         *
         */
        [GtkChild(name="name-label")]
        private Gtk.Label b_name_label;


        /**
         *
         */
        private Gtk.Label[] b_readout;

        /**
         *
         */
        private Gtk.Label[] b_label;


        /**
         * Update a readout using a measurement from the instrument
         *
         * @param measurement The recent measurement from the instrument
         */
        private void on_update_readout(Measurement measurement)

            requires(b_instrument != null)
            requires(b_readout != null)
            requires(b_instrument.channel_count >= 0)
            requires(measurement.channel_index >= 0)
            requires(measurement.channel_index < b_instrument.channel_count)

        {
            if (measurement.channel_index < b_readout.length)
            {
                var label = b_label[measurement.channel_index];
                return_if_fail(label != null);

                label.label = measurement.channel_name;

                var readout = b_readout[measurement.channel_index];
                return_if_fail(readout != null);

                readout.label = measurement.readout_value;
            }
        }
    }
}
