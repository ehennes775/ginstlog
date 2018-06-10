/*
 *  Copyright (C) 2018 Edward Hennessy
 */
namespace ginstlog
{
    /**
     *
     */
    public class ErrorDialog
    {
        /**
         *
         */
        public static void run(Error error, Gtk.Window? parent = null)
        {
            var dialog = new Gtk.MessageDialog(
                parent,
                Gtk.DialogFlags.MODAL,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.OK,
                "%s\n\nDomain: %s\nCode: %d",
                error.message,
                error.domain.to_string(),
                error.code
                );

            var result = dialog.run();

            dialog.destroy();
        }
    }
}
