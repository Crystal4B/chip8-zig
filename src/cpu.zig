const std = @import("std");
const bus_pkg = @import("bus.zig");
const operands = @import("operands.zig");
const utils = @import("utils.zig");

const NUMBER_OF_REGISTERS: u8 = 16;
const FLAG_REGISTER: u8 = 0xF;
const STACK_SIZE: u8 = 16;
const PC_INCREMENT: u8 = 2;

pub const Cpu = struct {
    // Connecting to rest of system
    bus: *bus_pkg.Bus,

    // CPU features
    // general purpose registers
    v: [NUMBER_OF_REGISTERS]u8,
    // index register
    i: u16,
    // program counter
    pc: u16,
    stack: [STACK_SIZE]u16,
    // stack pointer
    sp: u16,

    // Counters
    delay_timer: u8,
    sound_timer: u8,
};

pub fn init(bus: *bus_pkg.Bus) Cpu {
    return Cpu{
        .bus = bus,

        .v = std.mem.zeroes([NUMBER_OF_REGISTERS]u8),
        .stack = std.mem.zeroes([STACK_SIZE]u16),

        .i = 0x0000,
        .pc = 0x0000,
        .sp = 0x0000,

        .delay_timer = 0,
        .sound_timer = 0,
    };
}

pub fn tick(cpu: *Cpu) void {
    const opcode = fetchOp(cpu);
    const instruction = decodeOp(opcode);
    executeInstruction(cpu, opcode, instruction);

    tickTimers(cpu);
    cpu.pc += 2;
}

fn tickTimers(cpu: *Cpu) void {
    if (cpu.delay_timer > 0) {
        cpu.delay_timer -= 1;
    }

    if (cpu.sound_timer > 0) {
        cpu.sound_timer -= 1;
    }
}

fn fetchOp(cpu: *Cpu) u16 {
    // opcode is a u16 meaning it takes up 2 memory slots
    const opcode_bytes = cpu.bus.readMemorySection(cpu.pc, 2);
    return utils.mergeBytes(opcode_bytes[0], opcode_bytes[1]);
}

const Operation = fn (*Cpu, operands.Operand) void;
const Instruction = struct {
    operation: Operation,
    operand_decoder: operands.OperandDecoder,
};

fn decodeOp(opcode: u16) Instruction {
    // List of instructions found here: http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#3.1
    const nibble = utils.readNibble(opcode, 0, 1);
    return switch (nibble) {
        0x0 => {
            const low_byte = utils.readNibble(opcode, 2, 2);
            return switch (low_byte) {
                // FIXME: 2nd nibble should be 0 for CLS and RET
                // 0x00E0
                0xE0 => Instruction{ .operation = CLS },
                // 0x00EE
                0xEE => Instruction{ .operation = RET },
                // 0x0NNN
                else => Instruction{ .operation = SYS, .operand_decoder = operands.ABS },
            };
        },
        // 0x1NNN
        0x1 => Instruction{ .operation = JP, .operand_decoder = operands.ABS },
        // 0x2NNN
        0x2 => Instruction{ .operation = CALL, .operand_decoder = operands.ABS },
        // 0x3XNN
        0x3 => Instruction{ .operation = SE, .operand_decoder = operands.REGV },
        // 0x4XNN
        0x4 => Instruction{ .operation = SNE, .operand_decoder = operands.REGV },
        // 0x5XY0
        0x5 => Instruction{ .operation = SE, .operand_decoder = operands.REGXY },
        // 0x6XNN
        0x6 => Instruction{ .operation = LD, .operand_decoder = operands.REGV },
        // 0x7XNN
        0x7 => Instruction{ .operation = ADD, .operand_decoder = operands.REGV },
        0x8 => {
            const low_nibble = utils.readNibble(opcode, 3, 1);
            return switch (low_nibble) {
                // 0x8XY0
                0x0 => Instruction{ .operation = LD, .operand_decoder = operands.REGXY },
                // 0x8XY1
                0x1 => Instruction{ .operation = OR, .operand_decoder = operands.REGXY },
                // 0x8XY2
                0x2 => Instruction{ .operation = AND, .operand_decoder = operands.REGXY },
                // 0x8XY3
                0x3 => Instruction{ .operation = XOR, .operand_decoder = operands.REGXY },
                // 0x8XY4
                0x4 => Instruction{ .operation = ADD, .operand_decoder = operands.REGXY },
                // 0x8XY5
                0x5 => Instruction{ .operation = SUB, .operand_decoder = operands.REGXY },
                // 0x8XY6
                0x6 => Instruction{ .operation = SHR, .operand_decoder = operands.REGXY },
                // 0x8XY7
                0x7 => Instruction{ .operation = SUBN, .operand_decoder = operands.REGXY },
                // 0x8XYE
                0xE => Instruction{ .operation = SHL, .operand_decoder = operands.REGXY },
                else => {
                    @panic("unknown opcode");
                },
            };
        },
        // 0x9XY0
        0x9 => Instruction{ .operation = SNE, .operand_decoder = operands.REGXY },
        // 0xANNN
        0xA => Instruction{ .operation = LDI, .operand_decoder = operands.ABS },
        // 0xBNNN
        0xB => Instruction{ .operation = JP0, .operand_decoder = operands.ABS },
        // 0xCXNN
        0xC => Instruction{ .operation = RND, .operand_decoder = operands.REGV },
        // 0xDXYN
        0xD => Instruction{ .operation = DRW, .operand_decoder = operands.REGXY },
        0xE => {
            const low_byte = utils.readNibble(opcode, 2, 2);
            return switch (low_byte) {
                // 0xEX9E
                0x9E => Instruction{ .operation = SKP, .operand_decoder = operands.REG },
                // 0xEXA1
                0xA1 => Instruction{ .operation = SKNP, .operand_decoder = operands.REG },
                else => {
                    @panic("unkown opcode");
                },
            };
        },
        0xF => {
            const low_byte = utils.readNibble(opcode, 2, 2);
            return switch (low_byte) {
                // 0xFX07
                0x07 => return,
                // 0xFX0A
                0x0A => return,
                // 0xFX15
                0x15 => return,
                // 0xFX18
                0x18 => return,
                // 0xFX1E
                0x1E => return,
                // 0xFX29
                0x29 => return,
                // 0xFX33
                0x33 => return,
                // 0xFX55
                0x55 => return,
                // 0xFX65
                0x65 => return,
                else => {
                    @panic("unkown opcode");
                },
            };
        },
        else => {
            @panic("unknown opcode");
        },
    };
}

fn executeInstruction(cpu: *Cpu, opcode: u16, instruction: Instruction) void {
    const operand = instruction.operand_decoder(opcode);
    instruction.operation(operand);

    cpu.pc += PC_INCREMENT;
}

// Chip8 CPU Operations
/// Performs a clear to the display
fn CLS(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.NONE) {
        @panic("incorrect operand layout");
    }

    cpu.bus.clearVideoMemory();

    DRW(cpu, operand);
}

/// Performs a returns from a subroutine
fn RET(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.NONE) {
        @panic("incorrect operand layout");
    }

    cpu.sp -= 1;
    cpu.pc = cpu.stack[cpu.sp] - PC_INCREMENT;
}

/// Performs a call to machine code subroutine
fn SYS(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.ABS) {
        @panic("incorrect operand layout");
    }

    // This should call sys function, for now assume address is valid
    CALL(cpu, operand);
}

/// Performs a jump to an address
fn JP(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.ABS) {
        @panic("incorrect operand layout");
    }

    cpu.pc = operand.Abs - PC_INCREMENT;
}

/// Performs a jump to an address offset by the VF
fn JP0(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.ABS) {
        @panic("incorrect operand layout");
    }

    cpu.pc = cpu.v[FLAG_REGISTER] + operand.Abs - PC_INCREMENT;
}

/// Performs a call to a subroutine
fn CALL(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.ABS) {
        @panic("incorrect operand layout");
    }

    cpu.stack[cpu.sp] = cpu.pc;
    cpu.sp += 1;
    JP(operand);
}

/// Performs a conditional equality check, skips next instruction if true
fn SE(cpu: *Cpu, operand: operands.Operand) void {
    var value = null;
    if (operand.Layout == operands.OperandLayout.REGXY) {
        value = cpu.v[operand.YReg];
    } else if (operand.Layout == operands.OperandLayout.REGV) {
        value = operand.Abs;
    }

    if (operand.XReg == null or value == null) {
        @panic("incorrect operand layout");
    }

    if (cpu.v[operand.XReg] == value) {
        cpu.pc += PC_INCREMENT;
    }
}

/// Performs a conditional equality check, skips next instruction if false
fn SNE(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGV) {
        @panic("incorrect operand layout");
    }

    if (cpu.v[operand.XReg] != operand.Abs) {
        cpu.pc += PC_INCREMENT;
    }
}

fn LD(cpu: *Cpu, operand: operands.Operand) void {
    var value = null;
    if (operand.Layout == operands.OperandLayout.REGXY) {
        value = cpu.v[operand.YReg];
    } else if (operand.Layout == operands.OperandLayout.REGV) {
        value = operand.Abs;
    }

    if (operand.XReg == null or value == null) {
        @panic("incorrect operand layout");
    }

    cpu.v[operand.XReg] = value;
}

fn LDI(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.ABS) {
        @panic("incorrect operand layout");
    }

    cpu.i = operand.Abs;
}

/// Performs and add operation where Vx and Vy are added together and stored in Vx,
/// flag is set if overflow happens
fn ADD(cpu: *Cpu, operand: operands.Operand) void {
    var value = null;
    if (operand.Layout == operands.OperandLayout.REGXY) {
        value = cpu.v[operand.YReg];
    } else if (operand.Layout == operands.OperandLayout.REGV) {
        value = operand.Abs;
    }

    if (operand.XReg == null or value == null) {
        @panic("incorrect operand layout");
    }

    // TODO: better way to activate overflow detection
    if (operand.Layout == operands.OperandLayout.REGXY) {
        const U8_MAX = 0xFF;
        cpu.v[FLAG_REGISTER] = cpu.v[operand.YReg] > (U8_MAX - cpu.v[operand.XReg]);
    }

    cpu.v[operand.XReg] += value;
}

/// Performs bitwise OR on values of Vx and Vy, store result in Vx
fn OR(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGXY) {
        @panic("incorrect operand layout");
    }

    cpu.v[operand.XReg] = cpu.v[operand.XReg] | cpu.v[operand.YReg];
}

/// Performs bitwise AND on values of Vx and Vy, store in Vx
fn AND(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGXY) {
        @panic("incorrect operand layout");
    }

    cpu.v[operand.XReg] = cpu.v[operand.XReg] & cpu.v[operand.YReg];
}

/// Performs bitwise XOR on values of Vx and Vy, store in Vx
fn XOR(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGXY) {
        @panic("incorrect operand layout");
    }

    cpu.v[operand.XReg] = cpu.v[operand.XReg] ^ cpu.v[operand.YReg];
}

/// Performs subtraction where Vy is subtracted from Vx, store in Vx
fn SUB(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGXY) {
        @panic("incorrect operand layout");
    }

    cpu.v[FLAG_REGISTER] = cpu.v[operand.XReg] > cpu.v[operand.YReg];
    cpu.v[operand.XReg] -= cpu.v[operand.YReg];
}

fn SHR(_: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGXY) {
        @panic("incorrect operand layout");
    }

    @panic("unimplemented");
}

/// Performs subtraction where Vx is subtracted from Vy, store in Vx
fn SUBN(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGXY) {
        @panic("incorrect operand layout");
    }

    cpu.v[FLAG_REGISTER] = cpu.v[operand.YReg] > cpu.v[operand.XReg];
    cpu.v[operand.XReg] = cpu.v[operand.YReg] - cpu.v[operand.XReg];
}

fn SHL(_: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGXY) {
        @panic("incorrect operand layout");
    }

    @panic("unimplemented");
}

/// Generates a random value, by getting a random byte and ANDing it with an absolute value
fn RND(cpu: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGV) {
        @panic("incorrect operand layout");
    }

    var rand = std.rand.DefaultPrng.init(std.heap.page_allocator);
    const random = rand.int(u8);

    cpu.v[operand.XReg] = operand.Abs & random;
}

/// Performs a draw of an n-byte sprite starting at memory location (Vx, Vy)
/// VF set to 1 on collision
fn DRW(_: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REGXY) {
        @panic("incorrect operand layout");
    }

    @panic("unimplemented");
}

/// Skip next instruction if key with the value Vx is pressed
fn SKP(_: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REG) {
        @panic("incorrect operand layout");
    }

    @panic("unimplemented");
}

/// Skip next instruction if key with the value Vx is not pressed
fn SKNP(_: *Cpu, operand: operands.Operand) void {
    if (operand.Layout != operands.OperandLayout.REG) {
        @panic("incorrect operand layout");
    }

    @panic("unimplemented");
}
