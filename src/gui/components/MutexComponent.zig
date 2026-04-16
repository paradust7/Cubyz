const std = @import("std");

const main = @import("main");
const graphics = main.graphics;
const draw = graphics.draw;
const TextBuffer = graphics.TextBuffer;
const vec = main.vec;
const Vec2f = vec.Vec2f;

const gui = @import("../gui.zig");
const GuiComponent = gui.GuiComponent;
const ScrollBar = GuiComponent.ScrollBar;

const MutexComponent = @This();

const scrollBarWidth = 5;
const border: f32 = 3;

pos: Vec2f = undefined,
size: Vec2f = undefined,
child: GuiComponent = undefined,
mutex: std.Io.Mutex = .init,

pub fn updateInner(self: *MutexComponent, _other: anytype) void {
	main.utils.assertLocked(&self.mutex);
	var other: GuiComponent = undefined;
	if (@TypeOf(_other) == GuiComponent) {
		other = _other;
	} else {
		other = _other.toComponent();
	}
	self.child = other;
	self.pos = other.pos();
	self.size = other.size();
}

pub fn deinit(self: *MutexComponent) void {
	main.utils.assertLocked(&self.mutex);
	self.child.deinit();
}

pub fn toComponent(self: *MutexComponent) GuiComponent {
	return .{.mutexComponent = self};
}

pub fn updateSelected(self: *MutexComponent) void {
	self.mutex.lockUncancelable(main.io);
	defer self.mutex.unlock(main.io);
	self.child.updateSelected();
}

pub fn updateHovered(self: *MutexComponent, mousePosition: Vec2f) main.callbacks.Result {
	self.mutex.lockUncancelable(main.io);
	defer self.mutex.unlock(main.io);
	return self.child.updateHovered(mousePosition);
}

pub fn render(self: *MutexComponent, mousePosition: Vec2f) void {
	self.mutex.lockUncancelable(main.io);
	defer self.mutex.unlock(main.io);
	self.child.render(mousePosition);
	self.pos = self.child.pos();
	self.size = self.child.size();
}

pub fn mainButtonPressed(self: *MutexComponent, mousePosition: Vec2f) main.callbacks.Result {
	self.mutex.lockUncancelable(main.io);
	defer self.mutex.unlock(main.io);
	return self.child.mainButtonPressed(mousePosition);
}

pub fn mainButtonReleased(self: *MutexComponent, mousePosition: Vec2f) void {
	self.mutex.lockUncancelable(main.io);
	defer self.mutex.unlock(main.io);
	self.child.mainButtonReleased(mousePosition);
}
