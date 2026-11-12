# 01.asm - Push and Pop on the Stack (64-bit)

## What the Program Does
This program puts two numbers in registers, pushes them onto the stack, pops them back into different registers, and then exits. It shows that the stack is **LIFO** (Last In, First Out): the last value pushed is the first value popped.

## Code
```nasm
section .text
    global _start

_start:
    mov rax, 100
    mov rbx, 200

    push rax
    push rbx
    nop

    pop rcx
    pop rdx
    nop

    mov rax, 60
    xor rdi, rdi
    syscall
```

## How the Stack Works, Step by Step

On x86-64, the stack grows **downward**. Every `push` makes RSP smaller, and every `pop` makes RSP bigger. Each one changes RSP by 8 bytes.

When the program starts at `_start` (address `0x401000`), RSP is `0x7fffffffd920`.

| Step | Instruction | What happens | RSP |
|------|-------------|--------------|-----|
| 1 | `mov rax, 100` | `rax = 100`. The stack is not used. | `0x7fffffffd920` |
| 2 | `mov rbx, 200` | `rbx = 200`. The stack is not used. | `0x7fffffffd920` |
| 3 | `push rax` | RSP goes down by 8, then 100 is written at the new top. | `0x7fffffffd918` |
| 4 | `push rbx` | RSP goes down by 8 again, then 200 is written at the new top. | `0x7fffffffd910` |
| 5 | `nop` | Does nothing. Good place to look at the stack. | `0x7fffffffd910` |
| 6 | `pop rcx` | The top value (200) is read into `rcx`, then RSP goes up by 8. | `0x7fffffffd918` |
| 7 | `pop rdx` | The next value (100) is read into `rdx`, then RSP goes up by 8. | `0x7fffffffd920` |
| 8 | `nop` | Does nothing. Good place to check the final state. | `0x7fffffffd920` |
| 9 | `mov rax, 60` | Sets the syscall number for `exit`. | `0x7fffffffd920` |
| 10 | `xor rdi, rdi` | Sets `rdi = 0` (exit code 0). | `0x7fffffffd920` |
| 11 | `syscall` | The program exits. | `0x7fffffffd920` |

## What the Stack Looks Like

After both pushes (at the first `nop`), the stack looks like this, with the top first:

```
Address            Value
0x7fffffffd910     200   (pushed from rbx)  <- RSP
0x7fffffffd918     100   (pushed from rax)
0x7fffffffd920     1     (argc, put there by Linux before the program starts)
0x7fffffffd928     pointer to the program name (argv[0])
```

200 is on top because it was pushed last. That is why it comes out first.

The values below 100 (`argc` and the pointer) are not from our code. Linux places them on the stack before `_start` runs. Our program never touches them.

## Why the Values Come Out Reversed
- Pushed in this order: `rax` (100), then `rbx` (200)
- Popped in this order: `rcx` gets 200, then `rdx` gets 100

So after the pops, `rcx = 200` and `rdx = 100`. The order is reversed because the stack is LIFO.

## Observations from Running

I ran the program in GDB and checked RSP after each step.

- **At `_start`:** RSP = `0x7fffffffd920`
- **After `push rax`:** RSP = `0x7fffffffd918` (8 lower). `x/4gx $rsp` showed `0x64` (100) on top, then `0x1`, which is `argc`.
- **After `push rbx`:** RSP = `0x7fffffffd910` (16 lower than the start). At this point `rcx` and `rdx` were still 0 because no pops had run yet.
- **After `pop rcx`:** RSP = `0x7fffffffd918`, and `rcx = 200`.
- **After `pop rdx`:** RSP = `0x7fffffffd920` (back to the start value), and `rdx = 100`.

## Key Points
- Each `push` lowers RSP by 8 bytes. Each `pop` raises RSP by 8 bytes.
- The stack is LIFO: the last value pushed is the first value popped.
- Two pushes and two pops cancel out, so RSP ends at the same value it started with.
- Popping does not erase memory. RSP just moves back up, and the old values stay there until something overwrites them.
- The program never uses `rbp`, `call`, or `ret`. It only uses `push` and `pop`.
- The program ends with the Linux `exit` syscall (number 60) and exit code 0.