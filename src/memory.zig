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

pub fn read(memory: *Memory, at: u16) u8 {
    return memory.memory[at];
}

pub fn readSection(memory: *Memory, start: u16, len: u16) ![]u8 {
    if (len <= 0) {
        return error.OutOfBounds;
    }

    if (start + len > MEMORY_SIZE) {
        return error.OutOfBounds;
    }

    return memory.memory[start .. start + len];
}

pub fn write(memory: *Memory, at: u16, data: u8) void {
    memory.memory[at] = data;
}

pub fn writeSection(memory: *Memory, start: u16, data: []const u8) !void {
    if (MEMORY_SIZE - start < data.len) {
        return error.OutOfBounds;
    }

    memory.memory[start .. start + data.len].* = data;
}
