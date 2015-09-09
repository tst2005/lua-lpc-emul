local lpc = require"lpc-emul"
printf = function(fmt, ...) io.stdout:write( (fmt:format(...)) ) end

local pid, stdin, stdout, stderr = lpc.run("cat")
stdin:write("aa bb\n") ; stdin:close()
local a = stdout:read("*a")
assert( lpc.wait(pid) == 0 )

assert( a == "aa bb\n" and a)

printf('%s',a) -- aa bb
