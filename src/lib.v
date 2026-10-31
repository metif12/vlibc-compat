module vlibc_compat

// Pure-V, C-compatible API backed by vlibc syscalls.
// No libc, no GC, no threads. All strings are null-terminated (cstring).

@[export: 'vc_strlen']
pub fn vc_strlen(s &u8) int {
	mut n := 0
	for unsafe { s[n] } != 0 {
		n++
	}
	return n
}

@[export: 'vc_write_file']
pub fn vc_write_file(path &u8, data &u8) int {
	p := unsafe { tos(path, vc_strlen(path)) }
	// data is null-terminated; write without the terminator
	n := vc_strlen(data)
	d := unsafe { tos(data, n) }
	err := vlibc_write_file(p, d.bytes())
	if err != .enoerror {
		return -1
	}
	return 0
}

@[export: 'vc_read_file']
pub fn vc_read_file(path &u8) &u8 {
	p := unsafe { tos(path, vc_strlen(path)) }
	data, _ := vlibc_read_file(p)
	// allocate a null-terminated buffer
	buf := unsafe { malloc(data.len + 1) }
	for i := 0; i < data.len; i++ {
		unsafe { buf[i] = data[i] }
	}
	unsafe { buf[data.len] = 0 }
	return buf
}
