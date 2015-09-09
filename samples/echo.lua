local lpc = require"lpc-emul"
local pid, stdin, stdout, stderr = lpc.run("echo", "aa", "bb")
lpc.wait(pid)

printf = function(fmt, ...) io.stdout:write( (fmt:format(...)) ) end
printf( '%s', stdout:read("*all") ) -- aa bb

