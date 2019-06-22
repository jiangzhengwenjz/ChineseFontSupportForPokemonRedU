SECTION "hook", ROM0[$1955]
; args: 
; hl = coord (tilemap buffer addr)
; de = text pointer (the bank should be already loaded)

; return:
; (hl) = bc = coord_next
; de = text_pointer_next
; Chinese char encoding format: (high) [8 bits: (char index low 8 bits)] [7 bits: (bank index - 0x80)] [1 bit: MSB of char index] (low)
ParseString:
    push hl
ParseStringStart:
    ;check termination
    ld a, [de]
    cp $50
    jr nz, .beginParse
    ld a, $A
    ld [$0000], a
    ld a, $1
    ld [$6000], a
    ld a, $F
    ld [$4000], a
    ld a, [$A000]
    ld b, a
    ld a, $0
    ld [$0000], a
    ld [$6000], a
    ld a, b
    ld b, h
    ld c, l
    pop hl
    ret
.beginParse:
    ; load var offset
    ld a, $A
    ld [$0000], a
    ld a, $1
    ld [$6000], a
    ld a, $F
    ld [$4000], a
    ld a, [$A000]
    cp $FF
    jr nz, .afterInit
    ld a, $0
    ld [$A000], a
; return to ROM bank mode
.afterInit:
    push af ; PUSH vram tile index to write
    ld a, $0
    ld [$0000], a
    ld [$6000], a
    ; the tile address will be sanitized in other ROM banks
    ; get original ROM bank
    ld a, [$FFB8]
    ld [$FF8B], a ; original ROM bank
    ; compare if it's chinese encoding
    ld a, [de]
    cp $40
    jr nc, .jumpToLastRomBank
    inc de
    ld a, [de]
    dec de
    ld c, a
    ld a, [de]
    and $1
    ld b, a
    push bc ; PUSH char index
    ld a, [de]
    rra
    and $7F
    add $80
    jr .jumpToRomBank
.jumpToLastRomBank:
    ld c, $0
    ld b, a
    push bc ; PUSH char index
    ld a, $92
.jumpToRomBank:
    push af ; PUSH font tile ROM bank
    ld a, $80
    ld [$FFB8], a
    ld [$2000], a
    jp DecoderMainRoutine
BackToParseString:
    ; a is new vram tile index
    ld b, a
    ld a, $A
    ld [$0000], a
    ld a, $1
    ld [$6000], a
    ld a, $F
    ld [$4000], a
    ld a, b
    ld [$A000], a
    ld a, $0
    ld [$0000], a
    ld [$6000], a
BackToParseStringWithoutInc:
    ; recover ROM bank
    ld a, [$FF8B]
    ld [$FFB8], a
    ld [$2000], a
    jp ParseStringStart
Return:
    ld a, [$FF8B]
    ld [$FFB8], a
    ld [$2000], a
    ret

SECTION "teststring", ROMX[$526C], BANK[$25]
    db $12, $31, $0B, $A4, $10, $84, $10, $7D, $0B, $60, $08, $39, $13, $92, $00, $BC, $50

SECTION "decode", ROMX[$4000], BANK[$80]
DecoderMainRoutine:
    pop af ; POP font tile ROM bank
    cp $92 ; last ROM bank?
    jr z, .notChineseChar
    ld b, a
    ld c, $4 ; 4 tile blocks per character
    push de
    push hl
    ld hl, sp+4
    ld e, [hl]
    inc hl
    ld d, [hl]
    ld h, d
    ld l, e
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, $4540 ; base addr of font tiles in the ROM bank
    add hl, de
    ld d, h
    ld e, l
    ld hl, sp+7
    ld a, [hl]
    ld h, $0
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    push de
    ld de, $8800
    add hl, de
    pop de
    ld a, [$FF8B]
    push af
    call $1886
    pop af
    ld [$FF8B], a
    pop hl
    pop de
    inc de
    inc de
    pop af ; who cares
    pop bc ; b = sram byte
    ld c, $0
    ld a, l
    sub $14
    ld l, a
    ld a, h
    sbc $0
    ld h, a
    ld a, b
    add $80
    ldi [hl], a
    inc a
    ld [hl], a
    ld a, l
    add $14
    ld l, a
    ld a, h
    adc $0
    ld h, a
    ld a, b
    add $83
    ldd [hl], a
    dec a
    ldi [hl], a
    inc hl ; next tilemap buffer addr
    ld a, b
    add $4
    cp $6A
    jr c, .back
    ld a, $0
.back:
    jp BackToParseString

.notChineseChar:
    pop af
    cp $4E
    jr nz, .nextCheck
    ld bc, $28
    ld a, [$FFF6]
    bit 2, a
    jr z, .ok
    ld bc, $14
.ok:
    pop af
    pop hl
    add hl, bc
    push hl
    inc de
    jp BackToParseString
.nextCheck:
    cp $4F
    jr nz, .checkDict
    pop af
    pop hl
    ld hl, $C4E1
    push hl
    inc de
    jp BackToParseString
.checkDict:
    and a
    cp $4C
    jp z, .case4C
    cp $4B
    jp z, .case4B
    cp $51
    jp z, .case51
    cp $49
    jp z, .case49
    cp $52
    jp z, .case52
    cp $53
    jp z, .case53
    cp $54
    jp z, .case54
    cp $5B
    jp z, .case5B
    cp $5E
    jp z, .case5E
    cp $5C
    jp z, .case5C
    cp $5D
    jp z, .case5D
    cp $55
    jp z, .case55
    cp $56
    jp z, .case56
    cp $57
    jp z, .case57
    cp $58
    jp z, .case58
    cp $4A
    jp z, .case4A
    cp $5F
    jp z, .case5F
    cp $59
    jp z, .case59
    cp $5A
    jp z, .case5A
    cp $80
    ;jr .skipTileLoad
    jr c, .skipTileLoad
    push de
    push hl
    ld bc, $9201
    ld de, $4540
    sub $80
    ld l, a
    ld h, $0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, de
    ld d, h
    ld e, l
    push de
    ld de, $8800
    ld hl, sp+7
    ld a, [hl]
    ld l, a
    ld h, $0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, de
    pop de
    ld a, [$FF8B]
    push af
    call $1886
    pop af
    ld [$FF8B], a
    pop hl
    pop de
    pop bc
    ld a, b
    add $80
    push bc
.skipTileLoad:
    pop bc
    ldi [hl], a
    ld b, a
    call $38D3
    inc de
    ld a, b
    inc a
    cp $81
    jp c, BackToParseStringWithoutInc
    sub $80
    cp $6A
    jr c, .backToParseString
    ld a, $0
.backToParseString:
    jp BackToParseString
.case4C:
    push de
    call $1B18
    call $1B18
    ld hl, $C4E1
    pop de
    inc de
    pop af
    jp BackToParseString
.case4B:
    ld a, $EE
    ld [$C4F2], a
    call $1B3A
    push de
    call $3898
    pop de
    ld a, $7F
    ld [$C4F2], a
    jr .case4C
.case51:
    push de
    ld a, $EE
    ld [$C4F2], a
    call $1B3A
    call $3898
    ld hl, $C4A5
    ld bc, $0412
    call $18C4
    ld c, $14
    call $3739
    pop de
    ld hl, $C4B9
    inc de
    pop af
    jp BackToParseString
.case49:
    push de
    ld a, $EE
    ld [$C4F2], a
    call $1B3A
    call $3898
    ld hl, $C469
    ld bc, $0712
    call $18C4
    ld c, $14
    call $3739
    pop de
    pop af
    pop hl
    ld hl, $C47D
    push hl
    inc de
    jp BackToParseString
.case52:
    push de
    ld de, $D158
    jr .parseSpecialWord
.case53:
    push de
    ld de, $D34A
    jr .parseSpecialWord
.case54:
    push de
    ld de, $1A6A
    jr .parseSpecialWord
.case5B:
    push de 
    ld de, $1A60
    jr .parseSpecialWord
.case5E:
    push de 
    ld de, $1A63
    jr .parseSpecialWord
.case5C:
    push de 
    ld de, $1A55
    jr .parseSpecialWord
.case5D:
    push de 
    ld de, $1A58
    jr .parseSpecialWord
.case56:
    push de 
    ld de, $1A6F
    jr .parseSpecialWord
.case4A:
    push de 
    ld de, $1A29
    jr .parseSpecialWord
.case59:
    ld a, [$FFF3]
    xor 1
    jr .monsterNameCharsCommon
.case5A:
    ld a, [$FFF3]
.monsterNameCharsCommon:
    push de
    and a
    jr nz, .enemy
    ld de, $D009
    jr .parseSpecialWord
.enemy:
    ld de, $1A72
    ld a, [$FF8B]
    push af
    call ParseString
    ld hl, sp+5
    ld [hl], a
    pop af
    ld [$FF8B], a
    ld h, b
    ld l, c
    ld de, $CFDA
.parseSpecialWord:
    ld a, [$FF8B]
    push af
    call ParseString
    ld hl, sp+5
    ld [hl], a
    pop af
    ld [$FF8B], a
    ld h, b
    ld l, c
    pop de
    inc de
    pop af
    cp $6A
    jp c, .backToParseString
    ld a, $0
    jp BackToParseString
.case58:
    ld a, [$D12B]
    cp $04
    jp z, .ok2
    ld a, $EE
    ld [$C4F2], a
.ok2:
    call $1B3A
    call $3898
    ld a, $7F
    ld [$C4F2], a
.case57:
    pop af
    pop hl
    ld de, $1AB3
    dec de
    jp Return
.case5F:
    pop af
    ld [hl], $E8
    pop hl
    jp Return
.case55:
    push de
    ld b, h
    ld c, l
    ld hl, $1A8C
    call $1B40
    ld h, b
    ld l, c
    pop de
    inc de
    pop af
    jp BackToParseString
