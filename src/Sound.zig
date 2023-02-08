const w4 = @import("wasm4.zig");

freq1: u32,
freq2: u32,
attack: u32,
decay: u32,
sustain: u32,
release: u32,
channel: u32,
mode: u32,

const Sound = @This();

pub fn play(self: Sound, volume: u32) void {
    const freq = self.freq1 | self.freq2 << 16;
    const duration = self.attack << 24 | self.decay << 16 | self.sustain | self.release << 8;
    const flags = self.channel | self.mode << 2;

    w4.tone(freq, duration, volume, flags);
}
