### About

This repository consists of some scripts in the **bin** subdirectory and miscellaneous dotfiles in **etc**. This is primarly meant for myself, but may be useful to you if your environment ressembles mine, which at the moment is Ubuntu 12.04.

### Install

To use the scripts, add the **bin** directory to your **~/.profile**:

    # include stack bin
    if [ -d "/path/to/stack/bin" ]; then
        PATH="/path/to/stack/bin:$PATH"
    fi

To use the aliases in **etc**, add it to your **.bashrc** file:

    # include stack aliases
    if [ -f "/path/to/stack/etc/aliases" ]; then
        . "/path/to/stack/etc/aliases"
    fi

There is a very rough install script that will do the above for you, as well as setup symlinks to use the stack's vim configuration.

### Reference

The following scripts are available in **bin**:

* **apache-vhost**: Generates a VirtualHost directive with some often-used settings.
* **apache-htlock**: Generates a templated *.htaccess* for basic HTTP authentication.
* **countdown**: Counts down a certain number of minutes.
* **domain-bulk-lookup**: Reads domain names from a file or input stream and indicates whether they appear to be availble.
* **firefox-preview-image**: Generates some temporary HTML code containing the specified image and launches that in Firefox, in order to preview a website mock-up.
* **git-auto**: Adds, commits and pushes changes in a git repository in a single command.
* **image-label-and-resize**: Resizes an image using ImageMagick and applies a label at the bottom.
* **imap-delete-all**: Bulk-deletes (all) messages from an IMAP inbox.
* **monit-install-default**: Installs a very basic monit configuration for monitoring cpu, memory and a single filesystem.
* **mysql-new-app**: Creates a matching database and username, auto-generating a password if desired.
* **new-script**: Generates a new executable file based on a template in *etc/templates*.
* **note**: Appends a simple note to a text file.
* **openssl-generate-default**: Outputs a self-signed SSL certificate to */etc/ssl/private* for local development usage.
* **pdf2png**: Produces a PNG for each page of a PDF, sampled at 300dpi, using ImageMagick.
* **png2pdf**: Assembles a PDF from a series of PNGs (one per page), using ImageMagick.
* **pomodoro**: Counts down a 25-minute task period followed by a 5-minute break, in perpetuity, an adaptation of the [Pomodoro Technique](http://en.wikipedia.org/wiki/Pomodoro_Technique). It optionally logs tasks to a file.
* **screen-measure**: Uses *scrot* and *imagemagick* to measure on-screen dimensions.
* **screen-crop**: Snaps a cropped screenshot, outputting to a timestamp-derived filename, then opens the image for editing.
* **screen-crop-multi**: Takes screenshots repeatedly, outputting to timestamp-derived filenames.
* **ssh-send-key**: Sets up SSH public key authentication between your computer and a server.
* **sshd-config-set**: Toggles yes/no configuration settings (such as PermitRootLogin and PasswordAuthentication) in the sshd\_config file.
* **svn-remove-data**: Recursively removes all .svn subdirectories under the current tree.
* **ubuntu-mastery**: Just for fun, see how many packages your system is running compared to what's available.
* **unsmart**: Acts as a wrapper for uncompressing tar/zip/rar and extracting them to a clean directory name.
* **use**: Installs a package using *apt-get* and makes a note of it.
* **video-duration**: Reformats video duration information from ffmpeg's verbose output as h:mm:ss.
* **zip-quick**: Just zips a directory, producing a timestamp-derived filename for output.
