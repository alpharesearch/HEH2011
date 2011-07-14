using Gtk;

public void on_button1_clicked (Button source) {
    source.label = "Thank you!";
}

public void on_button2_clicked (Button source) {
    source.label = "Thanks!";
}

int main (string[] args) {     
    Gtk.init (ref args);

    try {
        var builder = new Builder ();
        builder.add_from_file ("src/sample.ui");
        builder.connect_signals (null);
        var window = builder.get_object ("window") as Window;
        var statusbar1 = builder.get_object ("statusbar1") as Statusbar;
        window.show_all ();
        statusbar1.push(0,"test");
        Gtk.main ();
        
    } catch (Error e) {
        stderr.printf ("Could not load UI: %s\n", e.message);
        return 1;
    } 

    return 0;
}
