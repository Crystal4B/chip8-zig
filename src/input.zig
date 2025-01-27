const std = @import("std");

pub const NUMBER_OF_KEYS = 16;

pub const Input = struct {
    // HEX based keypad (0x0-0xF)
    keys: [NUMBER_OF_KEYS]u1,
};

pub fn init() Input {
    return Input{
        .keys = std.mem.zeroes([NUMBER_OF_KEYS]u1),
    };
}
