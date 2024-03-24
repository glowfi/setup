# hkd: hotkey deamon
hkd allows to define system-wide hotkeys independent from the graphical session,
this means, that hotkeys will work in x11, wayland and even in a tty.

## Compatibility
hkd only works on linux as it uses the linux-specific epoll and inotify APIs
as well as the evdev interface for input recognition.

## Compiling
hkd doesn't require any libraries and has no dependency other than a standard C
library, `musl` should work too (altough I have not yet tested it).

Run `make` to compile, `make clean` to remove the mess and `make debug` to 
compile a debug binary to use with gdb. To install run `make install` and 
`make uninstall` if you re done with it.

## Documentation
The [man page](hkd.1) is (at least in my opinion) pretty simple and explanatory,
the program itself is very small (under 600 loc excluding comments and blanks)
and the config file is documented trough an [example](template.conf). That said
if I recive enough requests for further documentation I'll provide it. 

## Similar projects
[triggerhappy](https://github.com/wertarbyte/triggerhappy)
