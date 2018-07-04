/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    [GtkTemplate(ui="/com/github/ehennes775/ginstlog/LoggerWidget.ui.xml")]
    public class LoggerWidget : Gtk.Grid, Gtk.Buildable
    {
        /**
         * The logger assocaited with this widget
         */
        public Logging.Logger? logger
        {
            get
            {
                return b_logger;
            }
            construct set
            {
                if (b_logger != null)
                {
                    b_logger.notify["enable"].disconnect(on_notify_enable);
                }

                b_logger = value;

                if (b_logger != null)
                {
                    m_enable_switch.sensitive = true;
                    b_logger.notify["enable"].connect(on_notify_enable);
                    b_logger.notify_property("enable");
                }
                else
                {
                    m_enable_switch.sensitive = false;
                    m_enable_switch.active = false;
                }
            }
            default = null;
        }


        /**
         * Initialize the instance
         */
        construct
        {
            m_enable_switch.notify["active"].connect(on_notify_active);
            m_enable_switch.state_set.connect(on_state_set);
        }


        /**
         *
         */
        public void parser_finished(Gtk.Builder builder)
        {
        }


        /**
         * The switch to enable and disable logging
         */
        [GtkChild(name="data-logger-enable-switch")]
        private Gtk.Switch m_enable_switch;


        /**
         * The backing store for the logger
         *
         * This value will be null if no logger is assocaited with
         * this widget.
         */
        private Logging.Logger? b_logger = null;


        /**
         * A callback handling when the user activates the switch
         */
        private void on_notify_active(ParamSpec param)
        {
            if (b_logger != null)
            {
                b_logger.enable = m_enable_switch.active;
            }
        }


        /**
         *
         */
        private void on_notify_enable(ParamSpec param)
        {
            // TODO set this to a boolean that indicates the logger is running
            m_enable_switch.set_state(b_logger.enable);
        }


        /**
         * Callback to disable the default signal handler
         */
        private bool on_state_set(bool state)
        {
            return true;
        }
    }
}
