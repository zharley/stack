### About

This is a tool kit consisting of some scripts and dotfiles.

### Install

Add bin directory to **~/.profile**:

    # add bin to path
    PATH="$HOME/src/stack/bin:$PATH"

Use aliases:

    # include aliases
    if [ -f "$HOME/src/stack/etc/aliases" ]; then
        . "$HOME/src/stack/etc/aliases"
    fi

### Reference

Scripts available in **bin**:

* **apache-vhost**: Generates a VirtualHost directive with some often-used settings.
* **apache-htlock**: Generates a templated *.htaccess* for basic HTTP authentication.
* **countdown**: Counts down a certain number of minutes.
* **domain-bulk-lookup**: Reads domain names from a file or input stream and indicates whether they appear to be availble.
* **firefox-preview-image**: Generates a temporary HTML frame containing the specified image and launches that in Firefox, in order to preview a website mock-up.
* **git-auto**: Adds, commits and pushes changes in a git repository in a single command.
* **image-label-and-resize**: Resizes an image using ImageMagick and applies a label at the bottom.
* **mysql-new-app**: Creates a matching database and username, auto-generating a password if desired.
* **new-script**: Generates a new executable file based on a template in *etc/templates*.
* **openssl-generate-default**: Outputs a self-signed SSL certificate to */etc/ssl/private* for local development usage.
* **pdf2png**: Produces a PNG for each page of a PDF, sampled at 300dpi, using ImageMagick.
* **png2pdf**: Assembles a PDF from a series of PNGs (one per page), using ImageMagick.
* **pomodoro**: Counts down a 25-minute task period followed by a 5-minute break, in perpetuity, an adaptation of the [Pomodoro Technique](http://en.wikipedia.org/wiki/Pomodoro_Technique). It optionally logs tasks to a file.
* **screen-measure**: Uses *scrot* and *imagemagick* to measure on-screen dimensions.
* **screen-crop**: Snaps a cropped screenshot, outputting to a timestamp-derived filename, then opens the image for editing.
* **screen-crop-multi**: Takes screenshots repeatedly, outputting to timestamp-derived filenames.
* **ssh-send-key**: Sets up SSH public key authentication between your computer and a server.
* **sshd-config-set**: Toggles yes/no configuration settings (such as PermitRootLogin and PasswordAuthentication) in the sshd\_config file.
* **unsmart**: Acts as a wrapper for uncompressing tar/zip/rar and extracting them to a clean directory name.
* **video-duration**: Reformats video duration information from ffmpeg's verbose output as h:mm:ss.
