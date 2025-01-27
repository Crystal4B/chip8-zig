const std = @import("std");
const bus_pkg = @import("bus.zig");

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
    // TODO: fetch opcode, decode opcode, execute opcode
    tickTimers(cpu);
}

fn tickTimers(cpu: *Cpu) void {
    if (cpu.delay_timer > 0) {
        cpu.delay_timer -= 1;
    }

    if (cpu.sound_timer > 0) {
        cpu.sound_timer -= 1;
    }
}
