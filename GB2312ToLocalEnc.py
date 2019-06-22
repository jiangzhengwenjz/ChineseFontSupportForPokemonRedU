#!/usr/bin/env python3

section = 0xA3
offset = 0xA1
bank = (section - 0xA1) // 5
char_idx = (section - 0xA1) % 5 * 94 + (offset - 0xA1)
high = 0xFF & char_idx
low = (char_idx >> 8) | (bank << 1)

print(hex(low))
print(hex(high))