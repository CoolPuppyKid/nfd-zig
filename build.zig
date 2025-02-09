const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const nfd_mod = b.addModule("nfd", .{ .root_source_file = b.path("src/lib.zig"), .target = target, .optimize = optimize, .link_libc = true });

    const cflags = [_][]const u8{"-Wall"};
    nfd_mod.addIncludePath(b.path("nativefiledialog/src/include"));
    nfd_mod.addCSourceFile(.{ .file = b.path("nativefiledialog/src/nfd_common.c"), .flags = &cflags });
    switch (target.result.os.tag) {
        .macos => nfd_mod.addCSourceFile(.{ .file = b.path("nativefiledialog/src/nfd_cocoa.m"), .flags = &cflags }),
        .windows => nfd_mod.addCSourceFile(.{ .file = b.path("nativefiledialog/src/nfd_win.cpp"), .flags = &cflags }),
        .linux => nfd_mod.addCSourceFile(.{ .file = b.path("nativefiledialog/src/nfd_gtk.c"), .flags = &cflags }),
        else => @panic("Unsupported OS list of supported devices:\nwindows,\nlinux,\nmac"),
    }

    switch (target.result.os.tag) {
        .macos => nfd_mod.linkFramework("AppKit", .{}),
        .windows => {
            nfd_mod.linkSystemLibrary("shell32", .{});
            nfd_mod.linkSystemLibrary("ole32", .{});
            nfd_mod.linkSystemLibrary("uuid", .{}); // needed by MinGW
        },
        .linux => {
            nfd_mod.linkSystemLibrary("atk-1.0", .{});
            nfd_mod.linkSystemLibrary("gdk-3", .{});
            nfd_mod.linkSystemLibrary("gtk-3", .{});
            nfd_mod.linkSystemLibrary("glib-2.0", .{});
            nfd_mod.linkSystemLibrary("gobject-2.0", .{});
        },
        else => @panic("Unsupported OS list of supported devices:\nwindows,\nlinux,\nmac"),
    }

    var example = b.addExecutable(.{
        .name = "nfd-example",
        .root_source_file = b.path("src/example.zig"),
        .target = target,
        .optimize = optimize,
    });
    example.root_module.addImport("nfd", nfd_mod);
    b.installArtifact(example);
}
