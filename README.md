### Dependencies

- [Zig](https://ziglang.org)
- [WASM-4](https://wasm4.org)
- [Binaryen](https://github.com/WebAssembly/binaryen) (for `wasm-opt`)
- [Wasmtime](https://wasmtime.dev) (to run tests)

### Optimize build

```
wasm-opt -Oz --strip-dwarf --strip-producers --zero-filled-memory  -o zig-out/lib/small.wasm zig-out/lib/cart.wasm
```

### Run tests

```
zig build test
```
