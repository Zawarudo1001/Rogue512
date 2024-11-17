;dedicated to Boltik
Rogue512: 
  lda #154
  sta $31
initscreen: 
  inc $31
  bne init 
  jmp endgame
init:
  ldx #255
  txs
  inx
  txa
  pha
  pha
  plp
  tay
  lda $fe
  and #3
  adc #3
  sta $32
  sta $33
  lda $31
  lsr
  lsr
  lsr
  lsr
  sta $34
  stx $0
  lda #2
  sta $1
clearloop: 
  txa
  sta ($0),y
  iny
  bne clearloop
  inc $1
  lda $1
  cmp #6
  bne clearloop

create_dungeon:
  lda #3
  sta $1
  lda #$ef
  sta $0
create_wall:
  jsr clear
  jsr random_direction 
  lda $1
  cmp #1
  beq create_dungeon 
  cmp #6
  bpl create_dungeon   
  lda $0
  and #31
  beq create_dungeon  
  lda ($0),y
  bne create_wall 
  inc $2 
  beq create_dungeon 
  lda $2
  and #63
  bne create_wall
create_entity:
  jsr set
  lsr
  and #1
  adc $34
sub:
  clc
  adc #255
  cmp #16
  bpl sub
continue:
  sta $13,x
  lsr
  sta $12, x
  inx
  inx
  inx
  inx  
  dec $33
  bne create_wall 
  lda $34
  sta $12
  lda #7
  sta $13
  lsr
  sta $f,x
  sta ($0),y

loop:
  jmp start

random_direction:
  lda $fe
  and #3
  beq down
  lsr
  bcc right
  beq left
  bne up

getkey:
  cmp #$64
  beq move_right
  cmp #$61
  beq move_left
  cmp #$73
  beq move_down 
  cmp #$77
  beq move_up
  rts

clear:
  lda #6
  sta ($0),y
  rts 
  
right:
  inc $0
  rts

left:
  dec $0
  rts

down:
  clc
  lda $0
  adc #32
  sta $0
  bcc down_c 
  inc $01
down_c:
  rts

up: 
  clc
  lda $0
  sbc #31
  sta $0
  bcs up_c
  dec $01
up_c:
  rts

x_recompute:
  lda $7
  cmp $5
  beq nextX
  bpl move_right 

move_left:
  jsr left
  jsr fight_check
  bne right

nextX:
  rts    

move_right:
  jsr right
  jsr fight_check
  bne left
  rts
 
move_down:
  jsr down
  jsr fight_check
  bne up
  cmp $1
  beq up
  rts

y_recompute:
  lda $6
  cmp $4
  beq nextY
  bpl move_down
 
move_up:
  jsr up
  jsr fight_check
  bne down
  bit $1
  beq down

nextY:
  rts

fight_check:
  lda $32
  sta $33
  lda $13, x
  stx $3
  ldx #0
fight:
  inx
  inx
  inx
  inx
  dec $33
  bmi fight_ret
  ldy $c,x
  cpy $0
  bne fight 
  ldy $d,x
  cpy $1
  bne fight
  tay
  eor $f,x
  cmp #4
  bne ffire 
  jmp initscreen 
ffire:
  and #8
  beq collis
  tya
  lsr
  and #3
  eor #255
  sta $35
calculate_damage:
  lda $fe
  bmi fight_ret 
  ora #252
  cmp $35
  bmi calculate_damage 
  clc
  adc $e,x
  sta $e,x
  beq rest
  bmi rest 
fight_ret:
  lda #6
collis:
  ldy #0
  ldx $3
  cmp ($0),y
  rts
rest:
  ldy #0
  sty $e,x 
  ldx $3
  bne fight_ret
  lda $34
  sta $12
  bne fight_ret
 
update_game:
  lda $ff
  beq update_game
  pha
start:
  ldx #0
  jsr get
  jsr clear
  sty $ff 
  pla
  jsr getkey
  jsr coord
  sta $6
  lda $5
  sta $7
  lda #7
  sta ($0),y  
  jsr set
  lda $32
  sbc #1
  sta $2
update_entity:
  inx
  inx
  inx 
  inx
  jsr get  
  beq next
update: 
  jsr clear
  lda $12, x
  beq del_entity
  jsr coord
  jsr x_recompute 
  jsr y_recompute 
  lda $13, x
  sta ($0),y 
  jsr set
next:
  dec $2
  bne update_entity
  ldx $12
health_loop:
  tya
  dex
  bmi next_point
  dex
  lda #2
next_point:
  sta $200, y
  tya
  clc
  adc #32
  tay
  bne health_loop
  lda $12
  beq endgame
  bne update_game

get:
  lda $10, x  
  sta $0
  lda $11, x
  sta $1
  rts

set: 
  lda $1
  sta $11, x
  lda $0
  sta $10, x 
  rts

del_entity:
  sty $11, x
  beq next

coord:
  lda $0
  and #31
  sta $5
  eor $0
  lsr
  ora $1
  ror
  ror
  ror
  ror
  sta $4
  rts

endgame:
  lda $ff
  beq endgame
  dcb $00  ;equivalent to brk instruction
  ;brk 
