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
pub fn REGXY(opcode: u16) Operand {
    return Operand{ .XReg = utils.readNibble(opcode, 1, 1), .YReg = utils.readNibble(opcode, 2, 1), .Layout = OperandLayout.REGXY };
}

pub fn REGV(opcode: u16) Operand {
    return Operand{ .XReg = utils.readNibble(opcode, 1, 1), .Abs = utils.readNibble(opcode, 2, 2), .Layout = OperandLayout.REGV };
}

pub fn REG(opcode: u16) Operand {
    return Operand{ .XReg = utils.readNibble(opcode, 1, 1), .Layout = OperandLayout.REG };
}

pub fn ABS(opcode: u16) Operand {
    return Operand{ .Abs = utils.readNibble(opcode, 1, 3), .Layout = OperandLayout.ABS };
}

pub fn NONE(_: u16) Operand {
    return Operand{ .Layout = OperandLayout.NONE };
}
