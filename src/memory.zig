const std = @import("std");

const MEMORY_SIZE = 4096;

pub const Memory = struct {
    memory: [MEMORY_SIZE]u8,
};

pub fn init() Memory {
    return Memory{
        .memory = std.mem.zeroes([MEMORY_SIZE]u8),
    };
}
