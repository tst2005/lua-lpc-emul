Lua Process Call Emulation
==========================

The original lpc was wrote in C.
I tried to emul his API in lua by using lua-posix.

API
===

lpc.run
-------

Usage: `lpc.run( cmd[, arg1[, arg2[, ...]]] )`

Returns 4 items:
 * `pid`
 * `stdin`
 * `stdout`
 * `stderr`

lpc.wait
--------

Usage: `lpc.wait( pid )`

Returns: 1 item:
 * the cmd return code


```lua
local pid, stdin, stdout, stderr = lpc.run("echo", "aa", "bb")
lpc.wait(pid)
print( stdout:read("*all") ) -- aa bb
```


