# 04.asm - Stack Frame and Local Variables (32-bit)

## What the Program Does
This program is the 32-bit version of the stack frame example. It calls a function named `work`. Inside `work`, it builds a **stack frame**, saves two local variables on the stack (100 and 200), reads them back into registers, cleans up the stack, and returns to `_start`. Then the program exits using the 32-bit Linux system call `int 0x80`.

## How to Build and Run
This file uses `BITS 32`, so it must be built as a 32-bit program:

```bash
nasm -f elf32 04.asm -o 04.o
ld -m elf_i386 04.o -o 04
./04
```

## Code
```nasm
BITS 32
section .text
    global _start

_start:
    call work

    mov eax, 1
    xor ebx, ebx
    int 0x80

work:
    push ebp
    mov ebp, esp
    sub esp, 8

    mov dword [ebp - 4], 100
    mov dword [ebp - 8], 200

    mov eax, [ebp - 4]
    mov ebx, [ebp - 8]
    nop

    mov esp, ebp
    pop ebp
    ret
```

## 32-bit vs 64-bit
- The stack registers are `ESP` and `EBP` (not `RSP` and `RBP`).
- Each slot on the stack is **4 bytes**, so `push`, `pop`, `call` and `ret` change ESP by 4.
- Local variables are `dword` (4 bytes), so they are at `[ebp - 4]` and `[ebp - 8]`.
- The program exits with `int 0x80` and syscall number 1, not `syscall` and 60.

## How the Stack Works, Step by Step

The stack grows **downward**. `push` and `call` make ESP smaller. `pop` and `ret` make ESP bigger.

Let's say ESP is `S` when the program begins at `_start`.

| Step | Instruction | What happens | ESP |
|------|-------------|--------------|-----|
| 1 | `call work` | Pushes the return address (the address of `mov eax, 1`) onto the stack, then jumps to `work`. | `S - 4` |
| 2 | `push ebp` | Saves the caller's `ebp` on the stack. | `S - 8` |
| 3 | `mov ebp, esp` | `ebp` now equals ESP. This is the anchor of the frame. ESP does not change. | `S - 8` |
| 4 | `sub esp, 8` | Makes room for 8 bytes of local variables (two 4-byte values). | `S - 16` |
| 5 | `mov dword [ebp - 4], 100` | Writes 100 at 4 bytes below `ebp`. ESP does not change. | `S - 16` |
| 6 | `mov dword [ebp - 8], 200` | Writes 200 at 8 bytes below `ebp`. ESP does not change. | `S - 16` |
| 7 | `mov eax, [ebp - 4]` | Reads 100 into `eax`. | `S - 16` |
| 8 | `mov ebx, [ebp - 8]` | Reads 200 into `ebx`. | `S - 16` |
| 9 | `nop` | Does nothing. Good place to look at the stack. | `S - 16` |
| 10 | `mov esp, ebp` | Moves ESP back up to `ebp`. This throws away the local variable space. | `S - 8` |
| 11 | `pop ebp` | Restores the caller's `ebp` from the stack. | `S - 4` |
| 12 | `ret` | Pops the return address and jumps back to `_start`. | `S` |
| 13 | `mov eax, 1` | Sets the syscall number for `exit`. | `S` |
| 14 | `xor ebx, ebx` | Sets `ebx = 0` (exit code 0). | `S` |
| 15 | `int 0x80` | The program exits. | `S` |

## What the Stack Looks Like

At the `nop` inside `work`, the stack looks like this, with the lowest address first:

```
Address     Value
S - 16      200                    <- ESP    ([ebp - 8])
S - 12      100                              ([ebp - 4])
S - 8       saved ebp                        <- EBP
S - 4       return address (back to _start)
S           argc (put there by Linux before _start runs)
```

The saved `ebp` and the return address are not our variables. `call` and `push ebp` put them there so the function can find its way back. The value at `S` is put on the stack by Linux, and our program never touches it.

## Why Use ebp?
ESP can move around inside a function, but `ebp` stays the same. That is why the local variables are reached with `ebp` and negative offsets (`[ebp - 4]` and `[ebp - 8]`). The address of each variable stays fixed while the function runs.

## Observations from Running
- `call work` lowered ESP by 4, and the return address was on top of the stack.
- `push ebp` lowered ESP by 4 more (8 below the start). After `mov ebp, esp`, `ebp` and ESP were equal.
- `sub esp, 8` lowered ESP to 16 below the start. This is where the two local variables live.
- The two `mov` stores into `[ebp - 4]` and `[ebp - 8]` did not change ESP.
- At the `nop`, `eax = 100` and `ebx = 200`.
- `mov esp, ebp` raised ESP by 8, `pop ebp` raised it by 4, and `ret` raised it by 4 more. ESP ended at the same value it started with.
- When I first linked this file as a 64-bit program, the stack slots were 8 bytes wide and the program crashed with a segmentation fault. It only works when built with `-f elf32` and `-m elf_i386`.

## Key Points
- In 32-bit code, every stack slot is 4 bytes. ESP changes by 4 for each `push`, `pop`, `call` and `ret`.
- `call` pushes the return address, and `ret` pops it. This is how the program finds its way back.
- `push ebp` and `mov ebp, esp` build the stack frame. `mov esp, ebp` and `pop ebp` take it down.
- `sub esp, 8` reserves space for local variables. The `mov` stores do not change ESP.
- ESP goes down by 16 in total inside `work` and comes back to the start value after `ret`.
- The stack is balanced: everything that was pushed or reserved is released before the program exits.