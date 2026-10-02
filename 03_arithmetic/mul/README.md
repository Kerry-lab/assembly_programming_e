# Multiplication Operations - EFLAGS Analysis

## Program 1: mul1.asm

### Execution Details
- **Instruction:** `mul byte [num2]`
- **Operation:** `25 * 10`
- **Result (`ax`):** `0x00fa` (250 decimal)

### Flag Status & Explanations
- **CF (Carry Flag) = 0 (Cleared):** The upper byte (`ah`) is `0x00`, meaning the result fits completely inside `al`.
- **OF (Overflow Flag) = 0 (Cleared):** Matches **CF**; no overflow into the upper register byte (`ah`).

---

## Program 2: mul2.asm

### Execution Details
- **Instruction:** `mul word [num2]`
- **Operation:** `3000 * num2`
- **Result (`DX:AX`):** `0x000927C0` (600,000 decimal)
  - **`dx` (Upper 16 bits):** `0x0009`
  - **`ax` (Lower 16 bits):** `0x27c0`

### Flag Status & Explanations
- **CF (Carry Flag) = 1 (Set):** The upper register (`dx`) contains a non-zero value (`0x0009`), indicating the product spilled beyond 16 bits.
- **OF (Overflow Flag) = 1 (Set):** Matches **CF**; indicates significant bits exist in the high-order register (`dx`).
