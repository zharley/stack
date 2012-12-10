### About

This is a tool kit consisting of my command-line scripts.

### Install

Add to **~/.profile**:

    # add bin to path
    PATH="$HOME/src/stack/bin:$PATH"

### Reference

Scripts available in **bin**:

* **countdown**: Counts down a certain number of minutes.
* **git-auto**: Adds, commits and pushes changes in a git repository in a single command.
* **mysql-new-app**: Creates a matching database and username, auto-generating a password if desired.
* **pomodoro**: Counts down a 25-minute task period followed by a 5-minute break, in perpetuity, an adaptation of the [Pomodoro Technique](http://en.wikipedia.org/wiki/Pomodoro_Technique). It optionally logs tasks to a file.
* **screen-measure**: Uses *scrot* and *imagemagick* to measure on-screen dimensions.
* **screen-crop**: Snaps a cropped screenshot, outputting to a timestamp-derived filename, then opens the image for editing.
* **unsmart**: Acts as a wrapper for uncompressing tar/zip/rar and extracting them to a clean directory name.
