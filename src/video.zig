const std = @import("std");

pub const WIDTH = 64;
pub const HEIGHT = 32;
pub const RESOLUTION = WIDTH * HEIGHT;

pub const Video = struct {
    gfx: [RESOLUTION]u1,
};

pub fn init() Video {
    return Video{
        .gfx = std.mem.zeroes([RESOLUTION]u1),
    };
}

pub fn clear(video: *Video) void {
    video.gfx = std.mem.zeroes([RESOLUTION]u1);
}
