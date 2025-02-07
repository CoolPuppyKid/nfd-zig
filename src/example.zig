const std = @import("std");
const nfd = @import("nfd");

pub fn main() !void {
    _ = try nfd.openFileDialog("txt", "/");
}
