# 05.asm - Push and Pop with Big Values and Little-Endian (64-bit)

## What the Program Does
This program puts a large 64-bit number (`0x1122334455667788`) in `rax` and a small number (`0x1234`) in `rbx`. It pushes both onto the stack, then pops them back into the **same** registers they came from, in reverse order. It shows two things: the stack is **LIFO** (Last In, First Out), and numbers are stored in memory in **little-endian** order.

## Code
```nasm
section .text
    global _start

_start:
    mov rax, 0x1122334455667788
    mov rbx, 0x1234

    push rax
    push rbx
    nop

    pop rbx
    pop rax

    mov rax, 60
    xor rdi, rdi
    syscall
```

## How the Stack Works, Step by Step

On x86-64, the stack grows **downward**. Every `push` makes RSP smaller by 8, and every `pop` makes RSP bigger by 8.

When the program starts at `_start` (address `0x401000`), RSP is `0x7fffffffd920`.

| Step | Instruction | What happens | RSP |
|------|-------------|--------------|-----|
| 1 | `mov rax, 0x1122334455667788` | `rax` gets the big number. The stack is not used. | `0x7fffffffd920` |
| 2 | `mov rbx, 0x1234` | `rbx = 0x1234`. The stack is not used. | `0x7fffffffd920` |
| 3 | `push rax` | RSP goes down by 8, then the big number is written at the new top. | `0x7fffffffd918` |
| 4 | `push rbx` | RSP goes down by 8 again, then `0x1234` is written at the new top. | `0x7fffffffd910` |
| 5 | `nop` | Does nothing. Good place to look at the stack. | `0x7fffffffd910` |
| 6 | `pop rbx` | The top value (`0x1234`) is read into `rbx`, then RSP goes up by 8. | `0x7fffffffd918` |
| 7 | `pop rax` | The next value (`0x1122334455667788`) is read into `rax`, then RSP goes up by 8. | `0x7fffffffd920` |
| 8 | `mov rax, 60` | Sets the syscall number for `exit`. | `0x7fffffffd920` |
| 9 | `xor rdi, rdi` | Sets `rdi = 0` (exit code 0). | `0x7fffffffd920` |
| 10 | `syscall` | The program exits. | `0x7fffffffd920` |

## What the Stack Looks Like

After both pushes (at the `nop`), `x/4gx $rsp` showed this, with the top first:

```
Address            Value
0x7fffffffd910     0x0000000000001234   (pushed from rbx)  <- RSP
0x7fffffffd918     0x1122334455667788   (pushed from rax)
0x7fffffffd920     0x0000000000000001   (argc, put there by Linux)
0x7fffffffd928     0x00007fffffffdc10   (pointer to the program name, argv[0])
```

`0x1234` is on top because it was pushed last. That is why it comes out first. The last two lines are not from our code. Linux puts them on the stack before `_start` runs, and our program never touches them.

## Little-Endian: How the Big Number Is Stored
After `push rax`, I looked at the stack one byte at a time with `x/8bx $rsp`:

```
0x7fffffffd918:  0x88  0x77  0x66  0x55  0x44  0x33  0x22  0x11
```

The number is `0x1122334455667788`, but the **smallest byte (`88`) is stored at the lowest address**, and the biggest byte (`11`) is at the highest. This is called **little-endian**, and it is how x86 stores numbers. When the 8 bytes are read back as one 64-bit value, with `x/4gx` or `pop`, the number looks normal again.

## Why the Values Go Back to the Same Registers
In this program, the push order is `rax` then `rbx`, and the pop order is `rbx` then `rax`. The pops are in the reverse order of the pushes, so each value returns to the register it came from. After the pops, `rbx = 0x1234` and `rax = 0x1122334455667788`, the same as before the pushes. This is the usual way to save registers on the stack and restore them later.

## Observations from Running

I ran the program in GDB and checked RSP and the registers after each step.

- **At `_start`:** RSP = `0x7fffffffd920`
- **After the two `mov`s:** `rax = 0x1122334455667788` and `rbx = 0x1234`. RSP did not change.
- **After `push rax`:** RSP = `0x7fffffffd918` (8 lower). `x/8bx $rsp` showed the bytes `88 77 66 55 44 33 22 11`, which is little-endian order.
- **After `push rbx`:** RSP = `0x7fffffffd910` (16 lower than the start). `x/4gx $rsp` showed `0x1234` on top, then `0x1122334455667788`, then `0x1` (`argc`).
- **After `pop rbx`:** RSP = `0x7fffffffd918`, and `rbx = 0x1234`.
- **After `pop rax`:** RSP = `0x7fffffffd920` (back to the start value), and `rax = 0x1122334455667788`.

## Key Points
- Each `push` lowers RSP by 8 bytes. Each `pop` raises RSP by 8 bytes.
- The stack is LIFO: the last value pushed is the first value popped.
- Even the small value `0x1234` takes a full 8-byte slot, because `push rbx` always pushes 64 bits.
- Numbers are stored in little-endian order: the smallest byte is at the lowest address.
- Popping in the reverse order of pushing puts each value back in its original register.
- Two pushes and two pops cancel out, so RSP ends at the same value it started with.
- The program ends with the Linux `exit` syscall (number 60) and exit code 0.