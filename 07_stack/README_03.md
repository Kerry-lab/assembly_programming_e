# 03.asm - Call and Return with a Simple Function (64-bit)

## What the Program Does
This program puts 10 in `rax`, calls a function named `calculate`, and the function adds 5 to `rax`. When the function returns, `rax` is 15. The program then exits. The stack is used only to remember where to come back to after the call.

## Code
```nasm
section .text
    global _start

_start:
    mov rax, 10
    call calculate

after_call:
    ; RAX should now be 15
    nop

    mov rax, 60
    xor rdi, rdi
    syscall

calculate:
    add rax, 5
    ret
```

## How the Stack Works, Step by Step

On x86-64, the stack grows **downward**. `call` makes RSP smaller by 8. `ret` makes RSP bigger by 8.

When the program starts at `_start` (address `0x401000`), RSP is `0x7fffffffd920`.

| Step | Instruction | What happens | RSP |
|------|-------------|--------------|-----|
| 1 | `mov rax, 10` | `rax = 10`. The stack is not used. | `0x7fffffffd920` |
| 2 | `call calculate` | Pushes the return address (the address of `after_call`, `0x40100a`) onto the stack, then jumps to `calculate`. | `0x7fffffffd918` |
| 3 | `add rax, 5` | `rax = 15`. The stack does not change. | `0x7fffffffd918` |
| 4 | `ret` | Pops the return address off the stack and jumps to it. | `0x7fffffffd920` |
| 5 | `nop` | Does nothing. We are back at `after_call` and `rax = 15`. | `0x7fffffffd920` |
| 6 | `mov rax, 60` | Sets the syscall number for `exit`. | `0x7fffffffd920` |
| 7 | `xor rdi, rdi` | Sets `rdi = 0` (exit code 0). | `0x7fffffffd920` |
| 8 | `syscall` | The program exits. | `0x7fffffffd920` |

## What the Stack Looks Like

Inside `calculate`, the stack looks like this:

```
Address            Value
0x7fffffffd918     0x40100a   (return address, the instruction after call)  <- RSP
0x7fffffffd920     1          (argc, put there by Linux)
```

The return address is how `ret` knows where to go. The `1` (`argc`) is not from our code. Linux puts it on the stack before `_start` runs.

## Why the Stack Is Needed Here
A function can be called from many places. The CPU has to remember where to go back to. `call` saves that address on the stack, and `ret` reads it back. This function has no `push rbp`, no local variables and no stack frame, because it only needs one instruction to do its work.

## Observations from Running

I ran the program in GDB and checked RSP and RAX after each step.

- **At `_start`:** RSP = `0x7fffffffd920`
- **After `mov rax, 10`:** `rax = 10`, RSP unchanged
- **After `call calculate`:** RSP = `0x7fffffffd918` (8 lower). `x/2gx $rsp` showed `0x40100a` on top. That is the return address. Next to it was `0x1`, which is `argc`.
- **After `add rax, 5`:** `rax = 15`, RSP unchanged
- **After `ret`:** RSP = `0x7fffffffd920` (back to the start value), and execution continues at `after_call` with `rax = 15`

## Key Points
- `call` pushes the return address and jumps to the function. `ret` pops it and jumps back.
- RSP goes down by 8 during the call and comes back up by 8 after `ret`.
- The function did not touch the stack itself. Only `call` and `ret` used it.
- The stack is balanced: RSP is the same before the call and after the return.
- The program ends with the Linux `exit` syscall (number 60) and exit code 0.