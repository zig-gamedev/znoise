const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("root", .{
        .root_source_file = b.path("src/znoise.zig"),
    });

    const fnl = b.addLibrary(.{
        .name = "FastNoiseLite",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });
    fnl.linkLibC();
    fnl.addIncludePath(b.path("libs/FastNoiseLite"));
    fnl.addCSourceFile(.{
        .file = b.path("libs/FastNoiseLite/FastNoiseLite.c"),
        .flags = &.{ "-std=c99", "-fno-sanitize=undefined" },
    });
    b.installArtifact(fnl);

    const test_step = b.step("test", "Run znoise tests");

    const tests = b.addTest(.{
        .name = "znoise-tests",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/znoise.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    tests.linkLibrary(fnl);
    b.installArtifact(tests);

    test_step.dependOn(&b.addRunArtifact(tests).step);
}
