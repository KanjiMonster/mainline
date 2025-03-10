
/*
 * TeeJee.FileSystem.vala
 *
 * Copyright 2016 Tony George <teejeetech@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *
 *
 */

namespace TeeJee.FileSystem {

	/* Convenience functions for handling files and directories */

	using TeeJee.Logging;
	using TeeJee.ProcessHelper;
	using TeeJee.Misc;

	public const int64 KB = 1000;
	public const int64 MB = 1000 * KB;
	public const int64 GB = 1000 * MB;
	public const int64 TB = 1000 * GB;
	public const int64 KiB = 1024;
	public const int64 MiB = 1024 * KiB;
	public const int64 GiB = 1024 * MiB;
	public const int64 TiB = 1024 * GiB;

	// path helpers ----------------------------

	public string file_parent(string f) {
		//log_debug("file_parent("+f+")");
		return File.new_for_path(f).get_parent().get_path();
	}

	public string file_basename(string f) {
		//log_debug("file_basename("+f+")");
		return File.new_for_path(f).get_basename();
	}

	// file helpers -----------------------------

	public bool file_exists(string file_path) {
		//log_debug("file_exists("+file_path+")");
		return (FileUtils.test(file_path, GLib.FileTest.EXISTS)
			&& !FileUtils.test(file_path, GLib.FileTest.IS_DIR));
	}

	public bool file_delete(string file_path) {
		//log_debug("file_delete("+file_path+")");

		if(!file_exists(file_path)) return true;

		try {
			var file = File.new_for_path (file_path);
			if (file.query_exists()) file.delete();
			return true;
		} catch (Error e) {
			log_error (e.message);
			return false;
		}
	}

	public string? file_read (string file_path) {
		//log_debug("file_read("+file_path+")");

		string txt;
		size_t size;

		try {
			GLib.FileUtils.get_contents (file_path, out txt, out size);
			return txt;
		}
		catch (Error e) { log_error (e.message); }

		return null;
	}

	public bool file_write (string f, string contents) {
		//log_debug("file_write("+f+")");

		try {

			string d = file_parent(f);
			dir_create(d);

			var file = File.new_for_path (f);
			if (file.query_exists ()) file.delete ();

			var file_stream = file.create (FileCreateFlags.REPLACE_DESTINATION);
			var data_stream = new DataOutputStream (file_stream);
			data_stream.put_string (contents);
			data_stream.close();

			return true;
		}
		catch (Error e) {
			log_error (e.message);
			return false;
		}
	}

	public bool file_copy (string src_file, string dest_file) {
		//log_debug("file_copy('"+src_file+"','"+dest_file+"')");

		try {
			var file_src = File.new_for_path (src_file);
			if (file_src.query_exists()) {
				var file_dest = File.new_for_path (dest_file);
				file_src.copy(file_dest,FileCopyFlags.OVERWRITE,null,null);
				return true;
			}
		}
		catch (Error e) { log_error (e.message); }

		return false;
	}

	public void file_move (string src_file, string dest_file) {
		//log_debug("file_move('"+src_file+"','"+dest_file+"')");
		try {
			if (!file_exists(src_file)) {
				log_error(_("File not found") + ": '%s'".printf(src_file));
				return;
			}

			dir_create(file_parent(dest_file));

			if (file_exists(dest_file)) file_delete(dest_file);

			var file_src = File.new_for_path (src_file);
			var file_dest = File.new_for_path (dest_file);
			file_src.move(file_dest,FileCopyFlags.OVERWRITE,null,null);

		}
		catch(Error e) { log_error (e.message); }
	}

	// file info -----------------

	public int64 file_get_size(string file_path) {
		try {
			File file = File.parse_name (file_path);
			if (FileUtils.test(file_path, GLib.FileTest.EXISTS)) {
				if (FileUtils.test(file_path, GLib.FileTest.IS_REGULAR)
					&& !FileUtils.test(file_path, GLib.FileTest.IS_SYMLINK)) {
					return file.query_info("standard::size",0).get_size();
				}
			}
		}
		catch(Error e) {
			log_error (e.message);
		}

		return -1;
	}

	// directory helpers ----------------------

	public bool dir_exists (string dir_path) {
		return ( FileUtils.test(dir_path, GLib.FileTest.EXISTS) && FileUtils.test(dir_path, GLib.FileTest.IS_DIR));
	}

	public bool dir_create (string d) {
		log_debug("dir_create("+d+")");

		try{
			var dir = File.parse_name(d);
			if (!dir.query_exists()) dir.make_directory_with_parents();
			return true;
		}
		catch (Error e) {
			log_error (e.message);
			return false;
		}
	}

	public bool dir_delete (string dir_path) {
		log_debug("dir_delete("+dir_path+")");
		if (!dir_exists(dir_path)) return true;
		File d = File.new_for_path(dir_path);
		try { _dir_delete(d); }
		catch (Error e) { print ("Error: %s\n", e.message); }
		return !dir_exists(dir_path);
	}

	private void _dir_delete (File p) throws Error {
		//log_debug("_dir_delete("+p.get_path()+")");
		FileEnumerator en = p.enumerate_children ("standard::*",FileQueryInfoFlags.NOFOLLOW_SYMLINKS,null);
		FileInfo i = null;
		while (((i = en.next_file (null)) != null)) {
			//log_debug(i.get_name());
			File n = p.resolve_relative_path (i.get_name());
			if (i.get_file_type() == FileType.DIRECTORY) _dir_delete(n);
			else n.delete();
		}
		p.delete();
	}

	// misc --------------------

	public string format_file_size (
		uint64 size, bool binary_units = false,
		string unit = "", bool show_units = true, int decimals = 1) {

		int64 unit_k = binary_units ? 1024 : 1000;
		int64 unit_m = binary_units ? 1024 * unit_k : 1000 * unit_k;
		int64 unit_g = binary_units ? 1024 * unit_m : 1000 * unit_m;
		int64 unit_t = binary_units ? 1024 * unit_g : 1000 * unit_g;

		string txt = "";

		if ((size > unit_t) && ((unit.length == 0) || (unit == "t"))) {
			txt += ("%%'0.%df".printf(decimals)).printf(size / (1.0 * unit_t));
			if (show_units) txt += " %sB".printf(binary_units ? "Ti" : "T");
		} else if ((size > unit_g) && ((unit.length == 0) || (unit == "g"))) {
			txt += ("%%'0.%df".printf(decimals)).printf(size / (1.0 * unit_g));
			if (show_units) txt += " %sB".printf(binary_units ? "Gi" : "G");
		} else if ((size > unit_m) && ((unit.length == 0) || (unit == "m"))) {
			txt += ("%%'0.%df".printf(decimals)).printf(size / (1.0 * unit_m));
			if (show_units) txt += " %sB".printf(binary_units ? "Mi" : "M");
		} else if ((size > unit_k) && ((unit.length == 0) || (unit == "k"))) {
			txt += ("%%'0.%df".printf(decimals)).printf(size / (1.0 * unit_k));
			if (show_units) txt += " %sB".printf(binary_units ? "Ki" : "K");
		} else {
			txt += "%'0lu".printf(size);
			if (show_units) txt += " B";
		}

		return txt;
	}

	public string escape_single_quote(string file_path) {
		return file_path.replace("'","'\\''");
	}

}
