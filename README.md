# tmux-now-playing

Showing currently playing track in tmux status bar with music controls

![Screenshot](https://raw.githubusercontent.com/spywhere/tmux-now-playing/master/images/screenshot.png)

## Integrations

- (macOS only) `osascript` (AppleScript) - enable Spotify, iTunes/Music
integration (and more in the future)
- `mpd` (Music Player Daemon) through `nc` (netcat)

## Configurations

Use `#{now-playing}` in `status-left` or `status-right` to show a currently
playing track in supported music player

### Status Format

- `@now-playing-status-format`  
Description: An interpolated string with components to show for `#{now-playing}`
component  
Default: `{icon} {scrollable} [{position}/{duration}]`  
Values: string with components
- `@now-playing-scrollable-format`  
Description: A scrolling interpolated string with components for `{scrollable}`
component  
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
- `{scrollable}` A scrolling interpolated string from `@now-playing-scrollable-format`
- `{title}` (Scrollable) A track title
- `{artist}` (Scrollable) A track artist
- `{position}` A playing position in `mm:ss` format with zero-padded
- `{position_sec}` A playing position in seconds
- `{duration}` A track duration in `mm:ss` format with zero-padded
- `{duration_sec}` A track duration in seconds

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

### Using TPM

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

## License

MIT
