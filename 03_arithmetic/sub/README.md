# Subtraction Operations - EFLAGS Analysis

## Program 1: sub1.asm

### Execution Details
- **Instruction:** `sub al, [num2]`
- **Operation:** `50 - 80`
- **Result (`al`):** `0xe2` (-30 signed, 226 unsigned)

### Flag Status & Explanations
- **CF (Carry Flag) = 1 (Set):** Set because 50 < 80, causing an unsigned borrow.
- **SF (Sign Flag) = 1 (Set):** Bit 7 of `0xe2` (`11100010`) is 1, indicating a negative signed result.
- **PF (Parity Flag) = 1 (Set):** The result (`11100010`) contains an even number (4) of set bits.
- **OF (Overflow Flag) = 0 (Cleared):** No signed overflow occurred; -30 fits within the 8-bit signed range (-128 to +127).
- **ZF (Zero Flag) = 0 (Cleared):** The result is non-zero.

---

## Program 2: sub2.asm

### Execution Details
- **Instruction:** `sub ax, [num2]`
- **Operation:** `1000 - 2000`
- **Result (`ax`):** `0xfc18` (-1000 signed, 64536 unsigned)

### Flag Status & Explanations
- **CF (Carry Flag) = 1 (Set):** Set because 1000 < 2000, causing an unsigned borrow.
- **SF (Sign Flag) = 1 (Set):** The most significant bit of `ax` (bit 15) is 1, indicating a negative signed result.
- **PF (Parity Flag) = 1 (Set):** The lower byte (`0x18` = `00011000`) contains 2 set bits (even parity).
- **OF (Overflow Flag) = 0 (Cleared):** No signed overflow occurred; -1000 fits within the 16-bit signed range (-32,768 to +32,767).
- **ZF (Zero Flag) = 0 (Cleared):** The result is non-zero.
