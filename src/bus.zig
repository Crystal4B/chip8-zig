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
