module main

fn main() {
	err := vlibc_write_file('/tmp/vcompat_smoke.txt', 'hello'.bytes())
	println('err written')
	if err != .enoerror { exit(1) }
}
