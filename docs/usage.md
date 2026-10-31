# Usage

## C (static linking)

```c
#include <stdio.h>

extern int vc_strlen(const char* s);
extern int vc_write_file(const char* path, const char* data);
extern const char* vc_read_file(const char* path);

int main(void) {
    const char* msg = "hello from consumer";
    printf("len=%d\n", vc_strlen(msg));

    if (vc_write_file("/tmp/out.txt", msg) != 0) {
        fprintf(stderr, "write failed\n");
        return 1;
    }
    printf("read=%s\n", vc_read_file("/tmp/out.txt"));
    return 0;
}
```

```sh
gcc -o consumer consumer.c build/libvcompat.a
./consumer
```

## C (dynamic linking)

```sh
gcc -o consumer consumer.c -Lbuild -lvcompat -Wl,-rpath,build
./consumer
```

## Python (ctypes)

```python
import ctypes
lib = ctypes.CDLL("./build/libvcompat.so")
lib.vc_strlen.restype = ctypes.c_int
lib.vc_strlen.argtypes = [ctypes.c_char_p]
lib.vc_write_file.restype = ctypes.c_int
lib.vc_write_file.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
lib.vc_read_file.restype = ctypes.c_char_p
lib.vc_read_file.argtypes = [ctypes.c_char_p]

print(lib.vc_strlen(b"hello"))
lib.vc_write_file(b"/tmp/py.txt", b"from python")
print(lib.vc_read_file(b"/tmp/py.txt"))
```

## Go (cgo)

```go
package main

/*
#cgo LDFLAGS: -L./build -lvcompat
#include <stdlib.h>
extern int vc_strlen(const char* s);
extern int vc_write_file(const char* path, const char* data);
extern const char* vc_read_file(const char* path);
*/
import "C"
import "fmt"

func main() {
    msg := C.CString("hello from go")
    fmt.Println("len=", C.vc_strlen(msg))
    C.vc_write_file(C.CString("/tmp/go.txt"), msg)
    fmt.Println("read=", C.GoString(C.vc_read_file(C.CString("/tmp/go.txt"))))
}
```

## Rust

```rust
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

extern "C" {
    fn vc_strlen(s: *const c_char) -> i32;
    fn vc_write_file(path: *const c_char, data: *const c_char) -> i32;
    fn vc_read_file(path: *const c_char) -> *const c_char;
}

fn main() {
    let msg = CString::new("hello from rust").unwrap();
    unsafe {
        println!("len={}", vc_strlen(msg.as_ptr()));
        vc_write_file(CString::new("/tmp/rs.txt").unwrap().as_ptr(), msg.as_ptr());
        let r = vc_read_file(CString::new("/tmp/rs.txt").unwrap().as_ptr());
        println!("read={}", CStr::from_ptr(r).to_str().unwrap());
    }
}
```

## Node.js (ffi-napi)

```js
const ffi = require('ffi-napi');
const lib = ffi.Library('./build/libvcompat.so', {
  vc_strlen: ['int', ['string']],
  vc_write_file: ['int', ['string', 'string']],
  vc_read_file: ['string', ['string']],
});
console.log('len=', lib.vc_strlen('hello from node'));
lib.vc_write_file('/tmp/node.txt', 'hello from node');
console.log('read=', lib.vc_read_file('/tmp/node.txt'));
```

## Notes

- The library is `ldd`-clean, so `dlopen` works on both glibc and musl
  hosts without loader errors.
- Strings are null-terminated (`const char*`). V's native `string` is
  never exposed across the ABI.
- v1 does not export a free function; buffers returned by
  `vc_read_file` are leaked. This is acceptable for short-lived
  processes; a `vc_free` export is on the roadmap.
