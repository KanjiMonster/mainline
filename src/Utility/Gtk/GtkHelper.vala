
using TeeJee.Logging;
using TeeJee.FileSystem;
using TeeJee.JsonHelper;
using TeeJee.ProcessHelper;
using TeeJee.System;
using TeeJee.Misc;

namespace TeeJee.GtkHelper {

	using Gtk;

	public void errbox (Window parent, string message) {
		Gtk.MessageDialog msg = new Gtk.MessageDialog (
			parent,
			Gtk.DialogFlags.MODAL,
			Gtk.MessageType.ERROR,
			Gtk.ButtonsType.OK,
			message
		);
		msg.response.connect((response_id) => msg.destroy());
		msg.show();
	}

	public Gdk.Pixbuf? get_app_icon(int icon_size){
		var img_icon = get_shared_icon(BRANDING_SHORTNAME ,icon_size);
		if (img_icon != null){
			return img_icon.pixbuf;
		}
		else{
			return null;
		}
	}

	public Gtk.Image? get_shared_icon(string icon_name, int icon_size){

		Gdk.Pixbuf pix_icon = null;
		Gtk.Image img_icon = null;

		try {
			Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
			pix_icon = icon_theme.load_icon_for_scale (
				icon_name, Gtk.IconSize.MENU, icon_size, Gtk.IconLookupFlags.FORCE_SIZE);
		} catch (Error e) {
			//log_error (e.message);
		}

		if (pix_icon == null){
			log_error (_("Missing Icon") + ": '%s'".printf(icon_name));
		}
		else{
			img_icon = new Gtk.Image.from_pixbuf(pix_icon);
		}

		return img_icon;
	}

	public Gdk.Pixbuf? get_shared_icon_pixbuf(string icon_name, int icon_size){

		var img = get_shared_icon(icon_name, icon_size);
		var pixbuf = (img == null) ? null : img.pixbuf;
		return pixbuf;
	}

}
