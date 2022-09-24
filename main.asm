INCLUDE "../hardware.inc"

SECTION "Header", ROM0[$100]

	jp EntryPoint
	
	ds $150 - @, 0 ; room for header

EntryPoint:
	; disable audio
	ld a, 0
	ld [rNR52], a

; wait for vblank
WaitVBlank:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank
	
	; disable display
	ld a, 0
	ld [rLCDC], a
	
	; copy tile data
	ld de, Tiles
	ld hl, $9000
	ld bc, TilesEnd - Tiles
CopyTiles:
	ld a, [de]
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTiles
	
	; empty tilemap
	ld hl, $9800
	ld bc, $400
CopyTilemap:
	ld a, $10
	ld [hli], a
	inc de
	dec bc
	ld a, b
	or a, c
	jp nz, CopyTilemap
	
	; enable display
	ld a, LCDCF_ON | LCDCF_BGON
	ld [rLCDC], a
	
	; load palette data
	ld a, %10010011
	ld [rBGP], a

Loop:
; wait for end of vblank so code is only ran once per frame
.waitVblankEnd:
	ld a, [rLY]
	cp 144
	jp nc, .waitVblankEnd
; wait for vblank before editing visuals
.waitVblankStart:
	ld a, [rLY]
	cp 144
	jp c, .waitVblankStart
	
	; do stuff
	call readInput
	ld b, 0
	ld hl, $9800
.loop:
	ld c, b
	rla
	jp c, .skip
	ld d, a
	ld a, $08
	add c
	ld c, a
	ld a, d
.skip:
	ld d, a
	ld a, c
	ld [hli], a
	ld a, d
	inc b
	ld d, a
	ld a, b
	cp 8
	ld a, d
	jp c, .loop
	
	jp Loop

; store button inputs as a bit field in a register
readInput:
	ld a, %00100000
	ld [rP1], a
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	and $0f
	swap a
	ld b, a
	ld a, %00010000
	ld [rP1], a
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	ld a, [rP1]
	and $0f
	or b
	ret

SECTION "Tile data", ROM0

Tiles:
INCBIN "tiles.bin"
TilesEnd: