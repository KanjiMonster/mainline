### Ubuntu Mainline Kernel Installer
A tool for installing the latest Linux kernels from the [ubuntu mainline ppa](https://kernel.ubuntu.com/~kernel-ppa/mainline/) onto debian-based distributions.

![Main window screenshot](main_window.png)

### About
mainline is a fork of [ukuu](https://github.com/teejee2008/ukuu)  

### Changes
* Changed name from "ukuu" to "mainline"
* Removed all GRUB / bootloader options
* Removed all donate buttons, links, dialogs
* Removed un-related/un-used code
* Better temp and cache management
* Better desktop notification behavior
* Slow but ongoing re-writes of most parts

### Features
* Download the list of available kernels from the [Ubuntu Mainline PPA](http://kernel.ubuntu.com/~kernel-ppa/mainline/)
* Display, install, uninstall, available and installed kernels conveniently, gui and cli
* For each kernel, the related headers & modules packages are automatically grouped and installed or uninstalled at the same time
* Optionally monitor and send desktop notifications when new kernels become available

### Not Features
* Care if the kernels run or boot or are compatible with your system beyond the basic plaform arch and whatever dependencies the .deb packages declare and dpkg enforces. The mainline-ppa kernel deb packages are produced with no warranty. When they work, great, when they don't, don't use them. This app intentionally does not even touch a single grub or bootloader file itself. All it does is download .deb packages that the ubuntu kernel team authors, and runs dpkg to install them the same way you would manually.

### Install
The [PPA](https://code.launchpad.net/~cappelikan/+archive/ubuntu/ppa) is kindly maintained by [cappelikan](https://github.com/cappelikan)  
```
sudo add-apt-repository ppa:cappelikan/ppa
sudo apt update
sudo apt install mainline
```
There is also usually a single reference .deb package in [releases](../../releases/latest), generated by ```make release_deb```  
but it is usually not current.

### Build
```
sudo apt install libgee-0.8-dev libjson-glib-dev libvte-2.91-dev valac aria2 lsb-release make gettext dpkg-dev
git clone https://github.com/bkw777/mainline.git
cd mainline
make
sudo make install
```

### Usage
Look for System -> Ubuntu Mainline Kernel Installer in your desktop's Applications/Start menu.

Otherwise:  
CLI
```
$ mainline --help
$ mainline
```
GUI
```
$ mainline-gtk
```
Note that neither of those commands invoked sudo or pkexec or other su-alike.  
The app runs as the user and uses pkexec internally just for the dpkg command.

**Install** downloads and installs the selected kernel

**Uninstall** uninstalls the selected kernel(1)

**Changes** displays the CHANGES file for the selected kernel

**PPA** launches your default https:// handler to the web page for the selected kernel  
If no kernels are selected (when first launching the app before clicking on any) launches the main page listing all the kernels.

**Uninstall Old** uninstalls all installed kernels below the latest installed version(1)

**Reload** deletes, re-downloads, and re-reads the local cached copies of all the index.html's from the mainline-ppa web site, and regenerates the displayed list.  
Management of these files has been a problem with this app in the past due to various spaghetti code and permissions issues.  
This is much better now, but there can still be occasional glitches from bad downloads or sometimes the upstream contents change after your copy was downloaded. For instance a kernel might be invalid when you happened to first cache it, and then later become valid (failed build that later succeeded), but your local cached info about that kernel doesn't know it, etc.  
Normally the app tries not to re-download things as much as possible for speed and annoyance reasons. The main index is always re-downloaded at least once every start-up, but the individual pages for each kernel are cached and never re-downloaded by default, only new/missing ones are downloaded.  
That can lead to some files being stale or wrong over time, so, to compensate for that, this button just makes it as convenient as possible to force a full re-load any time you want.  

**Settings** access the [settings](settings.md) dialog to configure various options

**About** basic info and credits

**Exit** order pizza

(1) In all cases the currently running kernel is protected and the app will not uninstall the currently running kernel.  
For the single manual uninstall button, the button simply isn't activated. For the cli app if you manually give that version, it will simply ignore it. For uninstall-old, either gui or cli, the currently running kernel is simply skipped over when scanning and building the list of uninstall candidates.

### Help / FAQ

* Secure Boot  
  Possibly useful, I have not tried:  
  https://github.com/M-P-P-C/Signing-a-Linux-Kernel-for-Secure-Boot

* Kernel versions 5.15.7+ and libssl3  
  [Install libssl3](../../wiki/Install-libssl3)

* Missing kernels  
  Failed or incomplete builds for your platform/arch are not included in the list.  
  If you think the list is missing something, press the "PPA" button to jump to the mainline-ppa web site where the .deb packages come from, and look at the build results for the missing kernel, and you will usually find that it is a failed or incomplete build for your arch, and can not be installed.

### TODO & WIP
* Make the background process for notifications detect when the user logs out of the desktop session and exit itself
* Move the notification/dbus code from the current shell script into the app and make an "applet mode"
* Combine the gtk and cli apps into one, or, make the gtk app into a pure front-end for the cli app, either way is better than the current mix of overlapping concerns and duplicate logic
