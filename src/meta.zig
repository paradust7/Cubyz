const std = @import("std");

// MARK: functionPtrCast()
fn FnParamTypes(comptime info: std.builtin.Type.Fn) [info.params.len]type {
	var types: [info.params.len]type = undefined;
	for (info.params, 0..) |p, i| {
		types[i] = p.type.?;
	}
	return types;
}

fn FnParamAttrs(comptime info: std.builtin.Type.Fn) [info.params.len]std.builtin.Type.Fn.Param.Attributes {
	var attrs: [info.params.len]std.builtin.Type.Fn.Param.Attributes = undefined;
	for (info.params, 0..) |p, i| {
		attrs[i] = .{ .@"noalias" = p.is_noalias };
	}
	return attrs;
}

fn FnAttrs(comptime info: std.builtin.Type.Fn) std.builtin.Type.Fn.Attributes {
	return .{
		.@"callconv" = info.calling_convention,
		.varargs = info.is_var_args,
	};
}

fn CastFunctionSelfToConstAnyopaqueType(Fn: type) type {
	const info = @typeInfo(Fn).@"fn";
	const isMutablePointer = @typeInfo(info.params[0].type.?) == .pointer and !@typeInfo(info.params[0].type.?).pointer.is_const;
	if (@sizeOf(info.params[0].type.?) != @sizeOf(*const anyopaque) or @alignOf(info.params[0].type.?) != @alignOf(*const anyopaque) or isMutablePointer) {
		@compileError(std.fmt.comptimePrint("Cannot convert {} to *const anyopaque", .{info.params[0].type.?}));
	}
	var param_types = FnParamTypes(info);
	param_types[0] = *const anyopaque;
	const param_attrs = FnParamAttrs(info);
	return @Fn(&param_types, &param_attrs, info.return_type.?, FnAttrs(info));
}
/// Turns the first parameter into a *const anyopaque
pub fn castFunctionSelfToConstAnyopaque(function: anytype) *const CastFunctionSelfToConstAnyopaqueType(@TypeOf(function)) {
	return @ptrCast(&function);
}

// MARK: functionPtrCast()
fn CastFunctionSelfToAnyopaqueType(Fn: type) type {
	const info = @typeInfo(Fn).@"fn";
	if (@sizeOf(info.params[0].type.?) != @sizeOf(*anyopaque) or @alignOf(info.params[0].type.?) != @alignOf(*anyopaque)) {
		@compileError(std.fmt.comptimePrint("Cannot convert {} to *anyopaque", .{info.params[0].type.?}));
	}
	var param_types = FnParamTypes(info);
	param_types[0] = *anyopaque;
	const param_attrs = FnParamAttrs(info);
	return @Fn(&param_types, &param_attrs, info.return_type.?, FnAttrs(info));
}
/// Turns the first parameter into a *anyopaque
pub fn castFunctionSelfToAnyopaque(function: anytype) *const CastFunctionSelfToAnyopaqueType(@TypeOf(function)) {
	return @ptrCast(&function);
}

fn CastFunctionReturnToAnyopaqueType(Fn: type) type {
	const info = @typeInfo(Fn).@"fn";
	if (@sizeOf(info.return_type.?) != @sizeOf(*anyopaque) or @alignOf(info.return_type.?) != @alignOf(*anyopaque) or @typeInfo(info.return_type.?) == .optional) {
		@compileError(std.fmt.comptimePrint("Cannot convert {} to *anyopaque", .{info.return_type.?}));
	}
	const param_types = FnParamTypes(info);
	const param_attrs = FnParamAttrs(info);
	return @Fn(&param_types, &param_attrs, *anyopaque, FnAttrs(info));
}

fn CastFunctionReturnToOptionalAnyopaqueType(Fn: type) type {
	const info = @typeInfo(Fn).@"fn";
	if (@sizeOf(info.return_type.?) != @sizeOf(?*anyopaque) or @alignOf(info.return_type.?) != @alignOf(?*anyopaque) or @typeInfo(info.return_type.?) != .optional) {
		@compileError(std.fmt.comptimePrint("Cannot convert {} to ?*anyopaque", .{info.return_type.?}));
	}
	const param_types = FnParamTypes(info);
	const param_attrs = FnParamAttrs(info);
	return @Fn(&param_types, &param_attrs, ?*anyopaque, FnAttrs(info));
}
/// Turns the return parameter into a *anyopaque
pub fn castFunctionReturnToAnyopaque(function: anytype) *const CastFunctionReturnToAnyopaqueType(@TypeOf(function)) {
	return @ptrCast(&function);
}
pub fn castFunctionReturnToOptionalAnyopaque(function: anytype) *const CastFunctionReturnToOptionalAnyopaqueType(@TypeOf(function)) {
	return @ptrCast(&function);
}
