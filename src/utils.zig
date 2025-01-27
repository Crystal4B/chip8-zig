const std = @import("std");

test "mergeBytes combines two u8s into a u16" {
    const expected: u16 = 0xA1B2;
    const result = mergeBytes(0xA1, 0xB2);

    try std.testing.expect(result == expected);
}

pub fn mergeBytes(high: u8, low: u8) u16 {
    return @as(u16, high) << 8 | @as(u16, low);
}

test "readNibble extracts specified nibble from u16" {
    const base: u16 = 0xA1B2;

    try std.testing.expectEqual(0xA1B2, readNibble(base, 0, 4));
    try std.testing.expectEqual(0xA1B, readNibble(base, 0, 3));
    try std.testing.expectEqual(0x1B, readNibble(base, 1, 2));
    try std.testing.expectEqual(0xB2, readNibble(base, 2, 2));
    try std.testing.expectEqual(0xA, readNibble(base, 0, 1));
    try std.testing.expectEqual(0xB, readNibble(base, 2, 1));
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
