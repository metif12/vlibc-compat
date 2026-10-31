module vlibc_compat

// Pure-V API backed by vlibc syscalls. No libc, no GC, no threads.

@[export: 'vc_strlen']
pub fn vc_strlen(s string) int {
	return s.len
}

@[export: 'vc_write_file']
pub fn vc_write_file(path string, data string) int {
	err := vlibc_write_file(path, data.bytes())
	if err != .enoerror {
		return -1
	}
	return 0
}

@[export: 'vc_read_file']
pub fn vc_read_file(path string) string {
	data, _ := vlibc_read_file(path)
	return data.bytestr()
}
