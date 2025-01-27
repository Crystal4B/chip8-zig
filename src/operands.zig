const std = @import("std");
const utils = @import("utils.zig");

// Operand Handling
pub const OperandLayout = enum {
    REGXY,
    REGV,
    REG,
    ABS,
    NONE,
};

pub const Operand = struct {
    Layout: OperandLayout,

    // FIXME: Should I shrink these somehow ?
    XReg: ?u16 = null,
    YReg: ?u16 = null,
    Abs: ?u16 = null,
};

pub const OperandDecoder = fn (u16) void;

// Chip8 Operand Decoding
test "REGXY layout has register x at 2nd nibble and y on the 3rd" {
    const opcode: u16 = 0xA2F3;
    const operand = REGXY(opcode);

    try std.testing.expect(operand.Layout == OperandLayout.REGXY);
    try std.testing.expect(operand.XReg == 0x2);
    try std.testing.expect(operand.YReg == 0xF);

    try std.testing.expect(operand.Abs == null);
}

pub fn REGXY(opcode: u16) Operand {
    return Operand{ .XReg = utils.readNibble(opcode, 1, 1), .YReg = utils.readNibble(opcode, 2, 1), .Layout = OperandLayout.REGXY };
}

test "REGV layout has 1 register at 2nd nibble and an absolute value at the lower byte" {
    const opcode: u16 = 0xBF32;
    const operand = REGV(opcode);

    try std.testing.expect(operand.Layout == OperandLayout.REGV);
    try std.testing.expect(operand.XReg == 0xF);
    try std.testing.expect(operand.Abs == 0x32);

    try std.testing.expect(operand.YReg == null);
}

pub fn REGV(opcode: u16) Operand {
    return Operand{ .XReg = utils.readNibble(opcode, 1, 1), .Abs = utils.readNibble(opcode, 2, 2), .Layout = OperandLayout.REGV };
}

test "REG layout has 1 register at the 2nd nibble" {
    const opcode: u16 = 0x2FD5;
    const operand = REG(opcode);

    try std.testing.expect(operand.Layout == OperandLayout.REG);
    try std.testing.expect(operand.XReg == 0xF);

    try std.testing.expect(operand.YReg == null);
    try std.testing.expect(operand.Abs == null);
}

pub fn REG(opcode: u16) Operand {
    return Operand{ .XReg = utils.readNibble(opcode, 1, 1), .Layout = OperandLayout.REG };
}

test "ABS layout only contains an absolute value" {
    const opcode: u16 = 0x7ABC;
    const operand = ABS(opcode);

    try std.testing.expect(operand.Layout == OperandLayout.ABS);
    try std.testing.expect(operand.Abs == 0xABC);

    try std.testing.expect(operand.XReg == null);
    try std.testing.expect(operand.YReg == null);
}

pub fn ABS(opcode: u16) Operand {
    return Operand{ .Abs = utils.readNibble(opcode, 1, 3), .Layout = OperandLayout.ABS };
}

test "NONE layout has no operand at all" {
    const opcode: u16 = 0xABCD;
    const operand = NONE(opcode);

    try std.testing.expect(operand.Layout == OperandLayout.NONE);

    try std.testing.expect(operand.XReg == null);
    try std.testing.expect(operand.YReg == null);
    try std.testing.expect(operand.Abs == null);
}

pub fn NONE(_: u16) Operand {
    return Operand{ .Layout = OperandLayout.NONE };
}
