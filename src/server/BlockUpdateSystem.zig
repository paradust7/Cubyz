const std = @import("std");

const main = @import("main");
const BlockPos = main.chunk.BlockPos;
const ZonElement = main.ZonElement;
const vec = main.vec;
const Vec3i = vec.Vec3i;
const NeverFailingAllocator = main.heap.NeverFailingAllocator;

list: main.ListUnmanaged(BlockPos) = .{},
mutex: std.Io.Mutex = .init,

pub fn init() @This() {
	return .{};
}
pub fn deinit(self: *@This()) void {
	self.mutex = undefined;
	self.list.deinit(main.globalAllocator);
}
pub fn add(self: *@This(), position: BlockPos) void {
	self.mutex.lockUncancelable(main.io);
	defer self.mutex.unlock(main.io);
	self.list.append(main.globalAllocator, position);
}
pub fn update(self: *@This(), ch: *main.chunk.ServerChunk) void {
	// swap
	self.mutex.lockUncancelable(main.io);
	const list = self.list;
	defer list.deinit(main.globalAllocator);
	self.list = .{};
	self.mutex.unlock(main.io);

	// handle events
	for (list.items) |event| {
		ch.mutex.lockUncancelable(main.io);
		const block = ch.getBlock(event.x, event.y, event.z);
		ch.mutex.unlock(main.io);

		_ = block.onUpdate().run(.{
			.block = block,
			.chunk = ch,
			.blockPos = event,
		});
	}
}
