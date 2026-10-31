module main

fn main() {
	vlibc_write_file('/tmp/vcompat_smoke.txt', 'hello'.bytes())
	data, fe := vlibc_read_file('/tmp/vcompat_smoke.txt')
	if fe != .enoerror { exit(1) }
	assert data.bytestr() == 'hello'
	println('file=' + data.bytestr())
}
