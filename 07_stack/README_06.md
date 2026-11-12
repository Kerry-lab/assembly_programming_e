# 06.asm - Push and Pop with Big Values and Little-Endian (32-bit)

## What the Program Does
This is the 32-bit version of the previous program. It puts a 32-bit number (`0x11223344`) in `eax` and a small number (`0x1234`) in `ebx`. It pushes both onto the stack, then pops them back into the **same** registers, in reverse order. It shows that the stack is **LIFO** and that numbers are stored in **little-endian** order.

## How to Build and Run
This file uses `BITS 32`, so it must be built as a 32-bit program:

```bash
nasm -f elf32 06.asm -o 06.o
ld -m elf_i386 06.o -o 06
./06
```

## Code
```nasm
BITS 32
section .text
    global _start

_start:
    mov eax, 0x11223344
    mov ebx, 0x1234

    push eax
    push ebx
    nop

    pop ebx
    pop eax

    mov eax, 1
    xor ebx, ebx
    int 0x80
```

## 32-bit vs 64-bit
- The registers are `EAX`, `EBX` and `ESP` (not `RAX`, `RBX` and `RSP`).
- Each stack slot is **4 bytes**, so every `push` lowers ESP by 4 and every `pop` raises it by 4.
- The program exits with `int 0x80` and syscall number 1, not `syscall` and 60.

## How the Stack Works, Step by Step

The stack grows **downward**. Let's say ESP is `S` when the program begins at `_start`.

| Step | Instruction | What happens | ESP |
|------|-------------|--------------|-----|
| 1 | `mov eax, 0x11223344` | `eax` gets the number. The stack is not used. | `S` |
| 2 | `mov ebx, 0x1234` | `ebx = 0x1234`. The stack is not used. | `S` |
| 3 | `push eax` | ESP goes down by 4, then `0x11223344` is written at the new top. | `S - 4` |
| 4 | `push ebx` | ESP goes down by 4 again, then `0x1234` is written at the new top. | `S - 8` |
| 5 | `nop` | Does nothing. Good place to look at the stack. | `S - 8` |
| 6 | `pop ebx` | The top value (`0x1234`) is read into `ebx`, then ESP goes up by 4. | `S - 4` |
| 7 | `pop eax` | The next value (`0x11223344`) is read into `eax`, then ESP goes up by 4. | `S` |
| 8 | `mov eax, 1` | Sets the syscall number for `exit`. | `S` |
| 9 | `xor ebx, ebx` | Sets `ebx = 0` (exit code 0). | `S` |
| 10 | `int 0x80` | The program exits. | `S` |

## What the Stack Looks Like

After both pushes (at the `nop`), the stack looks like this, with the top first:

```
Address     Value
S - 8       0x00001234   (pushed from ebx)  <- ESP
S - 4       0x11223344   (pushed from eax)
S           argc (put there by Linux before _start runs)
```

`0x1234` is on top because it was pushed last, so it comes out first. The value at `S` is not from our code, and the program never touches it.

## Little-Endian: How the Number Is Stored
After `push eax`, the 4 bytes at the top of the stack are:

```
44  33  22  11
```

The number is `0x11223344`, but the **smallest byte (`44`) is stored at the lowest address** and the biggest byte (`11`) at the highest. This is **little-endian**, and it is how x86 stores numbers. When the 4 bytes are read back as one value, with `pop` or `x/wx`, the number looks normal again.

## Why the Values Go Back to the Same Registers
The push order is `eax` then `ebx`, and the pop order is `ebx` then `eax`. The pops are in the reverse order of the pushes, so each value returns to the register it came from. After the pops, `ebx = 0x1234` and `eax = 0x11223344`, the same as before the pushes.

## Observations from Running
- After the two `mov`s, `eax = 0x11223344` and `ebx = 0x1234`. ESP did not change.
- `push eax` lowered ESP by 4, and the bytes at the top of the stack were `44 33 22 11` (little-endian).
- `push ebx` lowered ESP by 4 more (8 below the start). `x/3wx $esp` showed `0x1234`, then `0x11223344`, then `argc`.
- `pop ebx` raised ESP by 4, and `ebx = 0x1234`.
- `pop eax` raised ESP by 4 more, back to the start value, and `eax = 0x11223344`.

## Key Points
- In 32-bit code, each `push` lowers ESP by 4 and each `pop` raises it by 4.
- The stack is LIFO: the last value pushed is the first value popped.
- Numbers are stored in little-endian order: the smallest byte is at the lowest address.
- Popping in the reverse order of pushing puts each value back in its original register.
- Two pushes and two pops cancel out, so ESP ends at the same value it started with.
- The program ends with `int 0x80` and syscall number 1, with exit code 0.