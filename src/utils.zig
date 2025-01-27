const std = @import("std");

pub fn mergeBytes(high: u8, low: u8) u16 {
    return @as(u16, high) << 8 | @as(u16, low);
}

pub fn readNibble(value: u16, start: u4, len: u4) u16 {
    if (start >= 4 or len == 0 or start + len > 4) {
        @panic("Invalid nibble range");
    }

    const shift = (4 - start - len) * 4;
    var mask = @as(u16, 0xFFFF);
    if (len != 4) {
        mask = (@as(u16, 1) << (len * 4)) - 1;
    }

    return (value >> shift) & mask;
}
