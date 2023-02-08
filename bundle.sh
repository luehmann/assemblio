git log -1 --format=format:"%H"
zig build -Drelease-small
ls -l zig-out/lib/cart.wasm
wasm-opt -Oz --strip-dwarf --strip-producers --zero-filled-memory  -o zig-out/lib/small.wasm zig-out/lib/cart.wasm
ls -lh zig-out/lib/small.wasm
ls -l zig-out/lib/small.wasm
w4 bundle --html zig-out/index.html --title Assemblio zig-out/lib/small.wasm
