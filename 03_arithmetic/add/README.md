# Add Operations - EFLAGS Analysis

## Program 1: add1.asm

### Execution Details
- **Instruction:** `add al, [num2]`
- **Result (`al`):** `0x82` (-126 signed, 130 unsigned)

### Flag Status & Explanations
- **SF (Sign Flag) = 1 (Set):** Bit 7 of `0x82` (`10000010`) is 1, indicating a negative result in 8-bit signed representation.
- **OF (Overflow Flag) = 1 (Set):** Signed overflow occurred because the sum exceeded the signed 8-bit range (-128 to +127).
- **PF (Parity Flag) = 1 (Set):** The lowest byte has an even number (two) of `1` bits (`10000010`).
- **AF (Auxiliary Flag) = 1 (Set):** A carry occurred from bit 3 to bit 4.
- **ZF (Zero Flag) = 0 (Cleared):** The result (`0x82`) is not zero.
- **CF (Carry Flag) = 0 (Cleared):** No unsigned carry out of bit 7 occurred.

---

## Program 2: add2.asm

### Execution Details
- **Instruction:** `add ax, [num2]`
- **Result (`ax`):** `0x00f4` (244 decimal)

### Flag Status & Explanations
- **ZF (Zero Flag) = 0 (Cleared):** The result is non-zero (`0x00f4`).
- **SF (Sign Flag) = 0 (Cleared):** The most significant bit of `ax` is 0, indicating a positive signed result.
- **CF (Carry Flag) = 0 (Cleared):** No unsigned carry/overflow occurred out of bit 15.
- **OF (Overflow Flag) = 0 (Cleared):** No signed overflow occurred; the result fits within the 16-bit signed range (-32,768 to +32,767).
- **PF (Parity Flag) = 0 (Cleared):** The lowest byte (`0xf4` = `11110100`) has 5 set bits (odd parity).
