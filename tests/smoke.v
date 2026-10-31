module main

fn main() {
	vlibc_write_file('/tmp/vcompat_smoke.txt', 'hi'.bytes())
	data, _ := vlibc_read_file('/tmp/vcompat_smoke.txt')
	println(data.bytestr())
}
