### Optimize build

```
wasm-opt -Oz --strip-dwarf --strip-producers --zero-filled-memory  -o zig-out/lib/small.wasm zig-out/lib/cart.wasm
```
