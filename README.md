# kitty_keys.sh

A POSIX function to print the current keybindings for [the `kitty` terminal emulator](https://sw.kovidgoyal.net/kitty/).

To use it, source this repository's `kitty_keys.sh` file, e.g. as part of your shell's startup procedure. This will make the `kitty_keys` function available.

When called without arguments, or with any unknown arguments, `kitty_keys` will print the default keybindings, followed by any custom keybindings specified in the user's kitty configuration file.

With a single argument of one of `copypaste`, `debugging`, `layouts`, `miscellaneous`, `scrolling`, `tabs`, `windows`, print the default keybindings for that category. With a single argument of `custom`, print only the user's custom keybindings.

Completion can be added in zsh via:

```
function _kitty_keys {
    compadd 'copypaste' 'debugging' 'layouts' 'miscellaneous' 'scrolling' 'tabs' 'windows' 'custom'
}
compdef _kitty_keys kitty_keys
```

Limited configuration over the output format is available via the `KITTY_KEYS_LEADING`, `KITTY_KEYS_TRAILING`, `KITTY_KEYS_MAX_WIDTH` and `KITTY_KEYS_CONF` environment variables. Details in comments in the source.

This function has been lightly tested in the zsh, bash and dash shells. Any non-POSIX shell behaviour is a bug.

## Design notes

* POSIX shell doesn't provide associative arrays ('dictionaries', 'hashes', etc.), which would allow for a more concise script via the use of keybinding categories as keys in a loop.

* `echo` is notoriously inconsistent across platforms and shells, so `printf(1)` is used instead in an attempt to reduce issues. Calling it via `env` ensures we get the command/utility, rather than the builtin. The `print1` function provides a convenience wrapper.

* `column(1)` is not part of POSIX, but was introduced in 4.3BSD-Reno (July 1990), and is assumed to be widely available.

* Setting `IFS` to `''` is used to try to make field splitting behaviour more uniform across shells.
