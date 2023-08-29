# tmux-now-playing

Showing currently playing track in tmux status bar with music controls

![Screenshot](https://raw.githubusercontent.com/spywhere/tmux-now-playing/master/images/screenshot.png)

## Integrations

- (macOS only) `osascript` (AppleScript) - enable the following integrations and more in the future
  - Spotify
  - iTunes / Music
- (Windows through WSL only, experimental) `cscript` (Windows Script Host) - enable the following integrations and more in the future
  - iTunes
- `mpd` ([Music Player Daemon](https://www.musicpd.org)) through `nc` (netcat)

## Configurations

Use `#{now_playing}` in `status-left` or `status-right` to show a currently
playing track in supported music player

### Status Format

- `@now-playing-status-format`  
Description: An interpolated string with components to show for `#{now_playing}`
component  
Default: `{icon} {scrollable} [{position}/{duration}]`  
Values: string with components
- `@now-playing-scrollable-format`  
Description: A scrolling interpolated string with components for `{scrollable}`
component (see scrollable component section below for more details)  
Default: `{artist} - {title}`  
Values: string with components
- `@now-playing-scrollable-threshold`  
Description: A maximum number of characters in a component before it will be
turned into a scrolling one  
Default: `25`  
Values: number of characters
- `@now-playing-playing-icon`  
Description: A string to display for `{icon}` component when the music player
is playing  
Default: `>`  
Values: string
- `@now-playing-paused-icon`  
Description: A string to display for `{icon}` component when the music player
is paused  
Default: ` ` (empty space)  
Values: string
- `@now-playing-keytable`  
Description: A string that is bound in the key table for combinating keys.  
Default: `prefix`  
Values: string
### Key Bindings

- `@now-playing-play-pause-key`  
Description: A list of key to bind as a play/pause command  
Default: `,`  
Values: a space separated string
- `@now-playing-stop-key`  
Description: A list of key to bind as a stop command  
Default: `.`  
Values: a space separated string
- `@now-playing-previous-key`  
Description: A list of key to bind as a previous track command  
Default: `;`  
Values: a space separated string
- `@now-playing-next-key`  
Description: A list of key to bind as a next track command  
Default: `'`  
Values: a space separated string

### Update Interval

- `@now-playing-auto-interval`  
Description: A string indicated whether to have plugin automatically adjusted
the refresh interval based on the music player state  
Default: `no`  
Values: `yes` or `no`
- `@now-playing-playing-interval`  
Description: A number of seconds to refresh when the music player is playing  
Default: `1`  
Values: number
- `@now-playing-paused-interval`
Description: A number of seconds to refresh when the music player is paused  
Default: `5`  
Values: number

### Music Player

- `@now-playing-mpd-host`  
Description: An IP address to MPD server  
Default: `127.0.0.1`  
Values: string
- `@now-playing-mpd-port`  
Description: A port number of MPD server  
Default: `6600`  
Values: number

#### Components

- `{icon}` A string from `@now-playing-playing-icon` or
`@now-playing-paused-icon` depends on the music player state
- `{scrollable}` A scrolling interpolated string from
`@now-playing-scrollable-format` (see scrollable component section below for more details)
- `{title}` (Scrollable) A track title
- `{artist}` (Scrollable) A track artist
- `{position}` A playing position in `mm:ss` format with zero-padded
- `{position_sec}` A playing position in seconds
- `{duration}` A track duration in `mm:ss` format with zero-padded
- `{duration_sec}` A track duration in seconds
- `{percent}` A playing position in percent (without percent sign)
- `{app}` A music player name

#### Scrollable Components

When specific component is too long to display (per
`@now-playing-scrollable-threshold` value), it will turned itself into a
scrolling one. This scrolling will be padded with 3 spaces and based on the
playing position of the current track.

If a component is not exceeding the threshold, it will simply be a static one.

So if the threshold is set to `10` and a song name is `This is too long`, a
`{title}` component will be shown as...

```
[00:00] This is to
[00:01] his is too
[00:02] is is too 
[00:03] s is too l
[00:04]  is too lo
[00:05] is too lon
...
[00:09] oo long   
[00:10] o long   T
[00:11]  long   Th
[00:12] long   Thi
```

Now, if all scrollable component in the `{scrollable}` component is exceeding
the threshold, the whole `{scrollable}` component itself will be expanded and
turned into a scrolling one instead.

## Key Bindings

These are default key bindings, you can configure your own key bindings by refer
to the configuration section above

- `<Prefix>+,` Play/Pause
- `<Prefix>+.` Stop
- `<Prefix>+;` Previous track
- `<Prefix>+'` Next track

## Installation

### Requirements

Please note that this plugin utilize multiple unix tools to deliver its
functionalities (most of these tools should be already installed on most unix systems)

- `sed`
- `grep`
- `cut`
- `awk`
- `uname`
- `wc`

### Scroll Tool

This plugin shipped with optimized scroller included. You can build the scroller
tool for fast performance on scrollable components using the following command.

```sh
$CC -o scroll scroll.c
```

Then the plugin will automatically try to use this binary from its directory.

### Using [TPM](https://github.com/tmux-plugins/tpm)

```
set -g @plugin 'spywhere/tmux-now-playing'
```

### Manual

Clone the repo

```
$ git clone https://github.com/spywhere/tmux-now-playing ~/target/path
```

Then add this line into your `.tmux.conf`

```
run-shell ~/target/path/now-playing.tmux
```

Once you reloaded your tmux configuration, all the format strings in the status
bar should be updated automatically.

## Troubleshoots

### Playing status is not update

First, locate the temporary directory that use for storing caches by running

```
echo "${TMPDIR:-${TMP:-${TEMP:-/tmp}}}"
```

If the temporary directory located above does not exists, try checking on `~/.tmp`.

Then remove all the files under `tmux-now-playing-XXX` where `XXX` is any number.

This should remove all the caches which plugin will regenerate itself when needed.

## License

MIT
