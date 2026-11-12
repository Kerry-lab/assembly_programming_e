# 02.asm - Stack Frame and Local Variables (64-bit)

## What the Program Does
This program calls a function named `work`. Inside `work`, it builds a **stack frame**, saves two local variables on the stack (100 and 200), reads them back into registers, then cleans up the stack and returns to `_start`. After that, the program exits.

## Code
```nasm
section .text
    global _start

_start:
    call work
    mov rax, 60
    xor rdi, rdi
    syscall

work:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov qword [rbp - 8], 100
    mov qword [rbp - 16], 200

    mov rax, [rbp - 8]
    mov rbx, [rbp - 16]
    nop

    mov rsp, rbp
    pop rbp
    ret
```

## How the Stack Works, Step by Step

On x86-64, the stack grows **downward**. `push` and `call` make RSP smaller. `pop` and `ret` make RSP bigger. Each one changes RSP by 8 bytes.

When the program starts at `_start` (address `0x401000`), RSP is `0x7fffffffd920`.

| Step | Instruction | What happens | RSP |
|------|-------------|--------------|-----|
| 1 | `call work` | Pushes the return address (`0x401005`) onto the stack, then jumps to `work`. | `0x7fffffffd918` |
| 2 | `push rbp` | Saves the caller's `rbp` on the stack. | `0x7fffffffd910` |
| 3 | `mov rbp, rsp` | `rbp` now equals RSP (`0x7fffffffd910`). This is the anchor of the frame. RSP does not change. | `0x7fffffffd910` |
| 4 | `sub rsp, 16` | Makes room for 16 bytes of local variables. | `0x7fffffffd900` |
| 5 | `mov qword [rbp - 8], 100` | Writes 100 at 8 bytes below `rbp`. RSP does not change. | `0x7fffffffd900` |
| 6 | `mov qword [rbp - 16], 200` | Writes 200 at 16 bytes below `rbp`. RSP does not change. | `0x7fffffffd900` |
| 7 | `mov rax, [rbp - 8]` | Reads 100 into `rax`. | `0x7fffffffd900` |
| 8 | `mov rbx, [rbp - 16]` | Reads 200 into `rbx`. | `0x7fffffffd900` |
| 9 | `nop` | Does nothing. Good place to look at the stack. | `0x7fffffffd900` |
| 10 | `mov rsp, rbp` | Moves RSP back up to `rbp`. This throws away the local variable space. | `0x7fffffffd910` |
| 11 | `pop rbp` | Restores the caller's `rbp` from the stack. | `0x7fffffffd918` |
| 12 | `ret` | Pops the return address and jumps back to `_start`. | `0x7fffffffd920` |
| 13 | `mov rax, 60` | Sets the syscall number for `exit`. | `0x7fffffffd920` |
| 14 | `xor rdi, rdi` | Sets `rdi = 0` (exit code 0). | `0x7fffffffd920` |
| 15 | `syscall` | The program exits. | `0x7fffffffd920` |

## What the Stack Looks Like

At the `nop` inside `work`, the stack looks like this, with the lowest address first:

```
Address            Value
0x7fffffffd900     200                  <- RSP    ([rbp - 16])
0x7fffffffd908     100                            ([rbp - 8])
0x7fffffffd910     saved rbp                      <- RBP
0x7fffffffd918     0x401005             (return address back into _start)
0x7fffffffd920     1                    (argc, put there by Linux)
```

The saved `rbp` and the return address are not our variables. `call` and `push rbp` put them there so the function can find its way back. The `1` (`argc`) is put on the stack by Linux before `_start` runs.

## Why Use rbp?
RSP can move around inside a function, but `rbp` stays the same. That is why the local variables are reached with `rbp` and negative offsets (`[rbp - 8]` and `[rbp - 16]`). The address of each variable stays fixed while the function runs.

## Observations from Running

I ran the program in GDB and checked RSP and RBP after each step.

- **At `_start`:** RSP = `0x7fffffffd920`
- **After `call work`:** RSP = `0x7fffffffd918` (8 lower). `x/2gx $rsp` showed `0x401005` on top. That is the return address, the instruction after `call` in `_start`. Next to it was `0x1`, which is `argc`.
- **After `push rbp`:** RSP = `0x7fffffffd910` (16 lower than the start)
- **After `mov rbp, rsp`:** RBP = `0x7fffffffd910`, the same as RSP
- **After `sub rsp, 16`:** RSP = `0x7fffffffd900` (32 lower than the start)
- **After the `mov` stores:** RSP stayed at `0x7fffffffd900`. Writing to `[rbp - 8]` and `[rbp - 16]` does not move RSP.
- **At the `nop`:** `rax = 100` and `rbx = 200`
- **After `mov rsp, rbp`:** RSP = `0x7fffffffd910`
- **After `pop rbp`:** RSP = `0x7fffffffd918`, and `rbp` is back to its old value
- **After `ret`:** RSP = `0x7fffffffd920` (back to the start value), and execution continues at `mov rax, 60` in `_start`

## Key Points
- `call` pushes the return address, and `ret` pops it. This is how the program finds its way back.
- `push rbp` and `mov rbp, rsp` build the stack frame. `mov rsp, rbp` and `pop rbp` take it down.
- `sub rsp, 16` reserves space for local variables. The `mov` instructions that store into `[rbp - 8]` and `[rbp - 16]` do not change RSP.
- RSP goes down by 32 in total inside `work` and comes back to the start value after `ret`.
- The stack is balanced: everything that was pushed or reserved is released before the program exits.