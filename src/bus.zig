const memory_pkg = @import("memory.zig");
const video_pkg = @import("video.zig");
const input_pkg = @import("input.zig");

pub const Bus = struct {
    memory: *memory_pkg.Memory,
    video: *video_pkg.Video,
    input: *input_pkg.Input,
};

pub fn init(memory: *memory_pkg.Memory, video: *video_pkg.Video, input: *input_pkg.Input) Bus {
    return Bus{
        .memory = memory,
        .video = video,
        .input = input,
    };
}

pub fn readMemory(bus: *Bus, at: u16) u8 {
    return memory_pkg.read(bus.memory, at);
}

pub fn readMemorySection(bus: *Bus, start: u16, len: u16) ![]u8 {
    return memory_pkg.readSection(bus.memory, start, len);
}

pub fn writeMemory(bus: *Bus, at: u16, data: u8) void {
    memory_pkg.write(bus.memory, at, data);
}

pub fn writeMemorySection(bus: *Bus, start: u16, data: []const u8) !void {
    return memory_pkg.writeSection(bus.memory, start, data);
}

pub fn clearVideoMemory(bus: *Bus) void {
    video_pkg.clear(bus.video);
}
