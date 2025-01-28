const memory_pkg = @import("memory.zig");
const video_pkg = @import("video.zig");
const input_pkg = @import("input.zig");
const bus_pkg = @import("bus.zig");
const cpu_pkg = @import("cpu.zig");

pub const TestEnv = struct {
    memory: memory_pkg.Memory,
    video: video_pkg.Video,
    input: input_pkg.Input,
    bus: bus_pkg.Bus,
    cpu: cpu_pkg.Cpu,
};

pub fn createTestEnv() TestEnv {
    var memory = memory_pkg.init();
    var video = video_pkg.init();
    var input = input_pkg.init();
    var bus = bus_pkg.init(&memory, &video, &input);
    const cpu = cpu_pkg.init(&bus);

    return TestEnv{
        .memory = memory,
        .video = video,
        .input = input,
        .bus = bus,
        .cpu = cpu,
    };
}
