local lpc = require"lpc-emul"
printf = function(fmt, ...) io.stdout:write( (fmt:format(...)) ) end


local pid, stdin, stdout, stderr = lpc.run("ls")
print(pid, stdin, stdout, stderr)

stdin.write = "toto"
assert(stdin.write=="toto")
stdin.write = nil
assert(stdin.write ~= nil)

--stdin:close()
--stdin:close()

--stdout:close()
--stderr:close()
assert( lpc.wait(pid) == 0 )

