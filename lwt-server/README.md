# Simple Lwt servers

## Echo server

Echos whatever input it is given. 

To run: 

```
dune build echo.exe
_build/default/echo.exe
```

On another terminal

```
telnet localhost 1537
<your-inputs>
```

## Fib server

Returns fibonacci number of input