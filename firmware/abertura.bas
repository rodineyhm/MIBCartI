'╔══════════════════════════════╗
'║        -= Abertura =-        ║
'║  (C)2026 - MasterMIB.com.br  ║
'╚══════════════════════════════╝
'

OPTION EXPLICIT

mode 0, 8,0,11,10

WAIT
DEFINE 0,16,scr_bitmaps
WAIT
DEFINE 16,16,scr_bitmaps_1
WAIT
DEFINE 32,16,scr_bitmaps_2
WAIT
DEFINE 48,10,scr_bitmaps_3
WAIT

DEFINE 58,4,scr_bitmaps_4
WAIT

DIM #banner_i  
DIM banner_fim
DIM banner_esp
#banner_i   = 0
banner_fim = 0
banner_esp = 0
CONST BANNER_LIN = 220
CONST BANNER_COL_INI = 1
CONST BANNER_COL_FIM = 18
CONST #BANNER_COMP = 960 

DIM BANNER_TICK
DIM DIRECAO1
DIM DIRECAO2
DIM PX1
DIM PY1
DIM PCOR1
DIM PX2
DIM PY2
DIM PCOR2
DIM BANNER_COL
DIM BANNER_CHAR
DIM II

DIM #addr, #val, #i, #x, #y, #BYTE, #POS
DIM #high, #low, #CARDH, #CARDL

SCREEN screen_cards_1

PRINT AT SCREENPOS( 2,1) COLOR CS_WHITE,     "\165"
PRINT AT SCREENPOS( 4,1) COLOR CS_YELLOW,    "\165"
PRINT AT SCREENPOS( 6,1) COLOR CS_GREEN,     "\165"
PRINT AT SCREENPOS( 8,1) COLOR CS_DARKGREEN, "\165"
PRINT AT SCREENPOS(11,1) COLOR CS_TAN,       "\164"
PRINT AT SCREENPOS(13,1) COLOR CS_RED,       "\164"
PRINT AT SCREENPOS(15,1) COLOR CS_BLUE,      "\164"
PRINT AT SCREENPOS(17,1) COLOR CS_BLACK,     "\164"


PRINT AT SCREENPOS(6,3)  COLOR CS_BLACK,"MIB" 
WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT
PRINT AT SCREENPOS(9,3)  COLOR CS_BLUE ,"Cart"
WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT
PRINT AT SCREENPOS(13,3) COLOR CS_RED  ,"I"


loop_abertura:    
    WAIT

    banner_tick = banner_tick + 1
    IF banner_tick >= 8 THEN banner_tick = 0
    
    GOSUB banner
    
    IF CONT = KEYPAD_1 THEN
        GOTO teste_controle
        GOTO fim_abertura
    END IF
    
    IF CONT = KEYPAD_2 THEN    
        GOSUB VOLUME_CAL_SCREEN
        GOTO fim_abertura
    END IF    

    IF CONT = KEYPAD_3 THEN    
        GOSUB COLOR_TEST
        GOTO fim_abertura
    END IF  

    IF CONT = KEYPAD_PAUSE THEN
        GOSUB MOSTRAID
        GOTO loop_abertura
    END IF

    IF CONT = 0 AND banner_fim = 0 THEN
        GOTO loop_abertura
    END IF
    

IF banner_fim = 1 THEN
    GOTO teste_controle
END IF    
    
PRINT AT SCREENPOS(0, 11) , "                    "
WAIT
PRINT AT SCREENPOS(17, 7), BG58 
PRINT AT SCREENPOS(18, 7), BG59 + BG_BLACK
PRINT AT SCREENPOS(17, 8), BG60 + BG_BLACK
PRINT AT SCREENPOS(18, 8), BG61 + BG_BLACK
WAIT

FOR II=0 TO 90
    WAIT
NEXT II

GOTO fim_abertura
 
teste_controle:

    MODE 0,0,0,0,0

    SOUND 0,100,15
    WAIT
    WAIT
    WAIT
    SOUND 0,,0 
    
    DEFINE DEF00,1,Disco
    CLS
    WAIT

    IF idioma = 0 THEN
        PRINT AT SCREENPOS(0, 0) COLOR CS_TAN,   "  Left1      Right2 "
    ELSE
        PRINT AT SCREENPOS(0, 0) COLOR CS_TAN,   "Esquerdo1   Direito2 "
    END IF
    PRINT AT SCREENPOS(0, 2) COLOR CS_TAN,   " |     |    |     |"
    PRINT AT SCREENPOS(0, 3) COLOR CS_TAN,   " |     |    |     |"
    PRINT AT SCREENPOS(0, 4) COLOR CS_TAN,   " |     |    |     |"
    PRINT AT SCREENPOS(0, 5) COLOR CS_TAN,   " |     |    |     |"
    PRINT AT SCREENPOS(0, 8) COLOR CS_TAN,   " |     |    |     |"
    PRINT AT SCREENPOS(0, 9) COLOR CS_TAN,   " |     |    |     |"
    PRINT AT SCREENPOS(0,10) COLOR CS_TAN,   " |     |    |     |"
    
    IF idioma = 0 THEN
        PRINT AT SCREENPOS(4,11) COLOR CS_WHITE, "1+9 to Exit"
    ELSE
        PRINT AT SCREENPOS(3,11) COLOR CS_WHITE, "1+9 para Sair"
    END IF

    loopTeste:
        IF CONT1 = KEYPAD_1 THEN PRINT AT SCREENPOS(2, 2) COLOR CS_RED, "1" ELSE PRINT AT SCREENPOS(2, 2) COLOR CS_WHITE, "1" 
        IF CONT1 = KEYPAD_2 THEN PRINT AT SCREENPOS(4, 2) COLOR CS_RED, "2" ELSE PRINT AT SCREENPOS(4, 2) COLOR CS_WHITE, "2" 
        IF CONT1 = KEYPAD_3 THEN PRINT AT SCREENPOS(6, 2) COLOR CS_RED, "3" ELSE PRINT AT SCREENPOS(6, 2) COLOR CS_WHITE, "3" 
        IF CONT1 = KEYPAD_4 THEN PRINT AT SCREENPOS(2, 3) COLOR CS_RED, "4" ELSE PRINT AT SCREENPOS(2, 3) COLOR CS_WHITE, "4" 
        IF CONT1 = KEYPAD_5 THEN PRINT AT SCREENPOS(4, 3) COLOR CS_RED, "5" ELSE PRINT AT SCREENPOS(4, 3) COLOR CS_WHITE, "5" 
        IF CONT1 = KEYPAD_6 THEN PRINT AT SCREENPOS(6, 3) COLOR CS_RED, "6" ELSE PRINT AT SCREENPOS(6, 3) COLOR CS_WHITE, "6" 
        IF CONT1 = KEYPAD_7 THEN PRINT AT SCREENPOS(2, 4) COLOR CS_RED, "7" ELSE PRINT AT SCREENPOS(2, 4) COLOR CS_WHITE, "7" 
        IF CONT1 = KEYPAD_8 THEN PRINT AT SCREENPOS(4, 4) COLOR CS_RED, "8" ELSE PRINT AT SCREENPOS(4, 4) COLOR CS_WHITE, "8" 
        IF CONT1 = KEYPAD_9 THEN PRINT AT SCREENPOS(6, 4) COLOR CS_RED, "9" ELSE PRINT AT SCREENPOS(6, 4) COLOR CS_WHITE, "9" 
        IF CONT1 = KEYPAD_CLEAR THEN PRINT AT SCREENPOS(2, 5) COLOR CS_RED, "C" ELSE PRINT AT SCREENPOS(2, 5) COLOR CS_WHITE, "C" 
        IF CONT1 = KEYPAD_0 THEN PRINT AT SCREENPOS(4, 5) COLOR CS_RED, "0" ELSE PRINT AT SCREENPOS(4, 5) COLOR CS_WHITE, "0" 
        IF CONT1 = KEYPAD_ENTER THEN PRINT AT SCREENPOS(6, 5) COLOR CS_RED, "E" ELSE PRINT AT SCREENPOS(6, 5) COLOR CS_WHITE, "E" 
        IF CONT1 = BUTTON_1 THEN PRINT AT SCREENPOS(1, 6) COLOR CS_RED, "F" : PRINT AT SCREENPOS(7, 6) COLOR CS_RED, "F"  ELSE PRINT AT SCREENPOS(1, 6) COLOR CS_WHITE, "F" : PRINT AT SCREENPOS(7, 6) COLOR CS_WHITE, "F"
        IF CONT1 = BUTTON_2 THEN PRINT AT SCREENPOS(1, 7) COLOR CS_RED, "L" ELSE PRINT AT SCREENPOS(1, 7) COLOR CS_WHITE, "L" 
        IF CONT1 = BUTTON_3 THEN PRINT AT SCREENPOS(7, 7) COLOR CS_RED, "R" ELSE PRINT AT SCREENPOS(7, 7) COLOR CS_WHITE, "R" 
        IF CONT1 = KEYPAD_PAUSE THEN 
            WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT
            POKE(ADDRESS_cmd), CMD_RESET
            GOTO fim_abertura
        END IF
        
        direcao1 = 0    
        IF CONT1 = DISC_N     THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "01" : direcao1 = 1 
        IF CONT1 = DISC_NNE   THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "02" : direcao1 = 2
        IF CONT1 = DISC_NE    THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "03" : direcao1 = 3
        IF CONT1 = DISC_ENE   THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "04" : direcao1 = 4
        IF CONT1 = DISC_EAST  THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "05" : direcao1 = 5
        IF CONT1 = DISC_ESE   THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "06" : direcao1 = 6
        IF CONT1 = DISC_SE    THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "07" : direcao1 = 7
        IF CONT1 = DISC_SSE   THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "08" : direcao1 = 8
        IF CONT1 = DISC_SOUTH THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "09" : direcao1 = 9
        IF CONT1 = DISC_SSW   THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "10" : direcao1 = 10
        IF CONT1 = DISC_SW    THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "11" : direcao1 = 11
        IF CONT1 = DISC_WSW   THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "12" : direcao1 = 12
        IF CONT1 = DISC_WEST  THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "13" : direcao1 = 13
        IF CONT1 = DISC_WNW   THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "14" : direcao1 = 14
        IF CONT1 = DISC_NW    THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "15" : direcao1 = 15
        IF CONT1 = DISC_NNW   THEN PRINT AT SCREENPOS(4,8) COLOR CS_RED, "16" : direcao1 = 16
        IF direcao1 = 0 THEN PRINT AT SCREENPOS(4,8) COLOR CS_WHITE, "  " '"00"

        Px1 = 40
        Py1 = 72
        IF direcao1 =  0 THEN Px1=Px1     : Py1=Py1 +00 : Pcor1 = CS_WHITE
        IF direcao1 =  1 THEN Px1=Px1 +00 : Py1=Py1 -12 : Pcor1 = CS_RED
        IF direcao1 =  2 THEN Px1=Px1 +05 : Py1=Py1 -11 : Pcor1 = CS_RED
        IF direcao1 =  3 THEN Px1=Px1 +10 : Py1=Py1 -09 : Pcor1 = CS_RED
        IF direcao1 =  4 THEN Px1=Px1 +14 : Py1=Py1 -05 : Pcor1 = CS_RED
        IF direcao1 =  5 THEN Px1=Px1 +15 : Py1=Py1 -00 : Pcor1 = CS_RED
        IF direcao1 =  6 THEN Px1=Px1 +14 : Py1=Py1 +05 : Pcor1 = CS_RED
        IF direcao1 =  7 THEN Px1=Px1 +10 : Py1=Py1 +08 : Pcor1 = CS_RED
        IF direcao1 =  8 THEN Px1=Px1 +05 : Py1=Py1 +11 : Pcor1 = CS_RED
        IF direcao1 =  9 THEN Px1=Px1 +00 : Py1=Py1 +12 : Pcor1 = CS_RED
        IF direcao1 = 10 THEN Px1=Px1 -05 : Py1=Py1 +11 : Pcor1 = CS_RED
        IF direcao1 = 11 THEN Px1=Px1 -10 : Py1=Py1 +08 : Pcor1 = CS_RED
        IF direcao1 = 12 THEN Px1=Px1 -14 : Py1=Py1 +05 : Pcor1 = CS_RED
        IF direcao1 = 13 THEN Px1=Px1 -15 : Py1=Py1 +00 : Pcor1 = CS_RED
        IF direcao1 = 14 THEN Px1=Px1 -14 : Py1=Py1 -05 : Pcor1 = CS_RED
        IF direcao1 = 15 THEN Px1=Px1 -10 : Py1=Py1 -09 : Pcor1 = CS_RED
        IF direcao1 = 16 THEN Px1=Px1 -05 : Py1=Py1 -11 : Pcor1 = CS_RED

        SPRITE 0, Px1 + VISIBLE, Py1 + ZOOMY2, SPR00 + Pcor1 + BEHIND


        IF CONT2 = KEYPAD_1 THEN PRINT AT SCREENPOS(13, 2) COLOR CS_RED, "1" ELSE PRINT AT SCREENPOS(13, 2) COLOR CS_WHITE, "1" 
        IF CONT2 = KEYPAD_2 THEN PRINT AT SCREENPOS(15, 2) COLOR CS_RED, "2" ELSE PRINT AT SCREENPOS(15, 2) COLOR CS_WHITE, "2" 
        IF CONT2 = KEYPAD_3 THEN PRINT AT SCREENPOS(17, 2) COLOR CS_RED, "3" ELSE PRINT AT SCREENPOS(17, 2) COLOR CS_WHITE, "3" 
        IF CONT2 = KEYPAD_4 THEN PRINT AT SCREENPOS(13, 3) COLOR CS_RED, "4" ELSE PRINT AT SCREENPOS(13, 3) COLOR CS_WHITE, "4" 
        IF CONT2 = KEYPAD_5 THEN PRINT AT SCREENPOS(15, 3) COLOR CS_RED, "5" ELSE PRINT AT SCREENPOS(15, 3) COLOR CS_WHITE, "5" 
        IF CONT2 = KEYPAD_6 THEN PRINT AT SCREENPOS(17, 3) COLOR CS_RED, "6" ELSE PRINT AT SCREENPOS(17, 3) COLOR CS_WHITE, "6" 
        IF CONT2 = KEYPAD_7 THEN PRINT AT SCREENPOS(13, 4) COLOR CS_RED, "7" ELSE PRINT AT SCREENPOS(13, 4) COLOR CS_WHITE, "7" 
        IF CONT2 = KEYPAD_8 THEN PRINT AT SCREENPOS(15, 4) COLOR CS_RED, "8" ELSE PRINT AT SCREENPOS(15, 4) COLOR CS_WHITE, "8" 
        IF CONT2 = KEYPAD_9 THEN PRINT AT SCREENPOS(17, 4) COLOR CS_RED, "9" ELSE PRINT AT SCREENPOS(17, 4) COLOR CS_WHITE, "9" 
        IF CONT2 = KEYPAD_CLEAR THEN PRINT AT SCREENPOS(13, 5) COLOR CS_RED, "C" ELSE PRINT AT SCREENPOS(13, 5) COLOR CS_WHITE, "C" 
        IF CONT2 = KEYPAD_0 THEN PRINT AT SCREENPOS(15, 5) COLOR CS_RED, "0" ELSE PRINT AT SCREENPOS(15, 5) COLOR CS_WHITE, "0" 
        IF CONT2 = KEYPAD_ENTER THEN PRINT AT SCREENPOS(17, 5) COLOR CS_RED, "E" ELSE PRINT AT SCREENPOS(17, 5) COLOR CS_WHITE, "E" 
        IF CONT2 = BUTTON_1 THEN PRINT AT SCREENPOS(12, 6) COLOR CS_RED, "F" : PRINT AT SCREENPOS(18, 6) COLOR CS_RED, "F"  ELSE PRINT AT SCREENPOS(12, 6) COLOR CS_WHITE, "F" : PRINT AT SCREENPOS(18, 6) COLOR CS_WHITE, "F"
        IF CONT2 = BUTTON_2 THEN PRINT AT SCREENPOS(12, 7) COLOR CS_RED, "L" ELSE PRINT AT SCREENPOS(12, 7) COLOR CS_WHITE, "L" 
        IF CONT2 = BUTTON_3 THEN PRINT AT SCREENPOS(18, 7) COLOR CS_RED, "R" ELSE PRINT AT SCREENPOS(18, 7) COLOR CS_WHITE, "R" 
        IF CONT2 = KEYPAD_PAUSE THEN 
            WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT
            POKE(ADDRESS_cmd), CMD_RESET
            GOTO fim_abertura
        END IF
        
        direcao2 = 0    
        IF CONT2 = DISC_N     THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "01" : direcao2 = 1 
        IF CONT2 = DISC_NNE   THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "02" : direcao2 = 2
        IF CONT2 = DISC_NE    THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "03" : direcao2 = 3
        IF CONT2 = DISC_ENE   THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "04" : direcao2 = 4
        IF CONT2 = DISC_EAST  THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "05" : direcao2 = 5
        IF CONT2 = DISC_ESE   THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "06" : direcao2 = 6
        IF CONT2 = DISC_SE    THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "07" : direcao2 = 7
        IF CONT2 = DISC_SSE   THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "08" : direcao2 = 8
        IF CONT2 = DISC_SOUTH THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "09" : direcao2 = 9
        IF CONT2 = DISC_SSW   THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "10" : direcao2 = 10
        IF CONT2 = DISC_SW    THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "11" : direcao2 = 11
        IF CONT2 = DISC_WSW   THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "12" : direcao2 = 12
        IF CONT2 = DISC_WEST  THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "13" : direcao2 = 13
        IF CONT2 = DISC_WNW   THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "14" : direcao2 = 14
        IF CONT2 = DISC_NW    THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "15" : direcao2 = 15
        IF CONT2 = DISC_NNW   THEN PRINT AT SCREENPOS(15,8) COLOR CS_RED, "16" : direcao2 = 16
        IF direcao2 = 0 THEN PRINT AT SCREENPOS(15,8) COLOR CS_WHITE, "  " '"00"

        Px2 = 128 
        Py2 = 200 
        IF direcao2 =  0 THEN Px2=Px2     : Py2=Py2 +00 : Pcor2 = CS_WHITE
        IF direcao2 =  1 THEN Px2=Px2 +00 : Py2=Py2 -12 : Pcor2 = CS_RED
        IF direcao2 =  2 THEN Px2=Px2 +05 : Py2=Py2 -11 : Pcor2 = CS_RED
        IF direcao2 =  3 THEN Px2=Px2 +10 : Py2=Py2 -09 : Pcor2 = CS_RED
        IF direcao2 =  4 THEN Px2=Px2 +14 : Py2=Py2 -05 : Pcor2 = CS_RED
        IF direcao2 =  5 THEN Px2=Px2 +15 : Py2=Py2 -00 : Pcor2 = CS_RED
        IF direcao2 =  6 THEN Px2=Px2 +14 : Py2=Py2 +05 : Pcor2 = CS_RED
        IF direcao2 =  7 THEN Px2=Px2 +10 : Py2=Py2 +08 : Pcor2 = CS_RED
        IF direcao2 =  8 THEN Px2=Px2 +05 : Py2=Py2 +11 : Pcor2 = CS_RED
        IF direcao2 =  9 THEN Px2=Px2 +00 : Py2=Py2 +12 : Pcor2 = CS_RED
        IF direcao2 = 10 THEN Px2=Px2 -05 : Py2=Py2 +11 : Pcor2 = CS_RED
        IF direcao2 = 11 THEN Px2=Px2 -10 : Py2=Py2 +08 : Pcor2 = CS_RED
        IF direcao2 = 12 THEN Px2=Px2 -14 : Py2=Py2 +05 : Pcor2 = CS_RED
        IF direcao2 = 13 THEN Px2=Px2 -15 : Py2=Py2 +00 : Pcor2 = CS_RED
        IF direcao2 = 14 THEN Px2=Px2 -14 : Py2=Py2 -05 : Pcor2 = CS_RED
        IF direcao2 = 15 THEN Px2=Px2 -10 : Py2=Py2 -09 : Pcor2 = CS_RED
        IF direcao2 = 16 THEN Px2=Px2 -05 : Py2=Py2 -11 : Pcor2 = CS_RED

        SPRITE 1, Px2 + VISIBLE, Py2 +  DOUBLEY, SPR00 + Pcor2 + BEHIND

        WAIT

GOTO loopTeste
    
INCLUDE "testeecs.bas"

GOTO pulaS1
SEGMENT 1
pulaS1:

INCLUDE "colortest.bas"

MOSTRAID: PROCEDURE
    #addr = $8020
    #x = 0
    #y = 5

    CLS
    WAIT

    PRINT AT (#y * 20 + #x) COLOR 7, "ID: "

    FOR #i = 0 TO 7
        #val = PEEK(#addr + #i)

        #pos = #y * 20 + #x + 4 + (#i * 2)

        #high = (#val / 16) AND $0F
        #low  = #val AND $0F

        IF #high < 10 THEN #cardH = 16 + #high ELSE #cardH = 23 + #high
        IF #low  < 10 THEN #cardL = 16 + #low  ELSE #cardL = 23 + #low

        #BACKTAB(#pos)     = (#cardH * 8) + 5
        #BACKTAB(#pos + 1) = (#cardL * 8) + 5
    NEXT

    WHILE CONT: WAIT: WEND   
    WHILE CONT = 0: WAIT: WEND
    CLS

    POKE(ADDRESS_cmd), CMD_RESET

    RETURN
    END
    
scr_bitmaps:
    DATA $0000,$1F00,$7F3F,$F078
    DATA $0000,$FF00,$FFFF,$0000
    DATA $0000,$F800,$FEFC,$0F1E
    DATA $0100,$0303,$0607,$0C0C
    DATA $E0F0,$FFFF,$00FF,$C03F
    DATA $0000,$FFFF,$00FF,$18F0
    DATA $0000,$FFFF,$00FF,$201F
    DATA $0000,$FFFF,$00FF,$00FF
    DATA $0000,$FFFF,$01FF,$8101
    DATA $0000,$FFFF,$FFFF,$F5F5
    DATA $0000,$FFFF,$FFFF,$AFAF
    DATA $0000,$FFFF,$80FF,$8180
    DATA $0000,$FFFF,$00FF,$04F8
    DATA $0000,$FFFF,$00FF,$100F
    DATA $070F,$FFFF,$00FF,$03FC
    DATA $8000,$C0C0,$60E0,$3030
scr_bitmaps_1:    
    DATA $1919,$3131,$6061,$C0C0
    DATA $0000,$8000,$FFC0,$003F
    DATA $0206,$0602,$F81E,$00F0
    DATA $2020,$4040,$4040,$3F7F
    DATA $6161,$C300,$00C3,$FFFF
    DATA $8686,$0C00,$000C,$FFFF
    DATA $3030,$6000,$0161,$FEFF
    DATA $8181,$8181,$0101,$0303
    DATA $F5F5,$FFFF,$F5F5,$F5F5
    DATA $AFAF,$FFFF,$AFAF,$AFAF
    DATA $8181,$8181,$8080,$C0C0
    DATA $0606,$0300,$8083,$7FFF
    DATA $1818,$0C00,$000C,$FFFF
    DATA $6363,$3100,$0031,$FFFF
    DATA $0404,$8202,$0282,$FCFE
    DATA $4060,$6040,$1E78,$000F
scr_bitmaps_2:    
    DATA $0000,$0100,$0F03,$00FC
    DATA $9898,$8C8C,$0686,$0303
    DATA $FF80,$FFFF,$C0C0,$8080
    DATA $FF00,$FFFF,$0000,$0000
    DATA $FF03,$FFFF,$0000,$0000
    DATA $FFC0,$FFFF,$0000,$0000
    DATA $FF00,$FFFF,$0000,$303F
    DATA $FF00,$FFFF,$0000,$1FFF
    DATA $FF00,$FFFF,$0000,$FFFF
    DATA $FF00,$FFFF,$0000,$00FF
    DATA $FF01,$FFFF,$0303,$79F9
    DATA $1F1F,$3F3E,$607F,$FFFF
    DATA $0000,$FF00,$00FF,$FFFF
    DATA $1F38,$FF00,$00FF,$FFFF
    DATA $FF0F,$FF00,$00FF,$FFFF
    DATA $FFFF,$FF00,$00FF,$FFFF
scr_bitmaps_3:    
    DATA $FF80,$FF00,$00FF,$FFFF
    DATA $FC3C,$FF00,$00FF,$FFFF
    DATA $F8F8,$FC7C,$06FE,$FFFF
    DATA $7F3F,$7F7F,$7F7F,$1F3F
    DATA $07FF,$FFF0,$C7FF,$FFFF
    DATA $FFFF,$FF1F,$83F0,$FFFF
    DATA $0103,$0101,$0101,$0703
    DATA $3F7F,$0307,$0001,$0000
    DATA $FFFF,$FFFF,$00FF,$0000
    DATA $FCFE,$C0E0,$0080,$0000
    
scr_bitmaps_4:
    BITMAP "........"
    BITMAP "########"
    BITMAP "########"
    BITMAP "########"
    BITMAP "........"
    BITMAP "........"
    BITMAP "########"
    BITMAP "###....."

    BITMAP ".......#"
    BITMAP "########"
    BITMAP "########"
    BITMAP "########"
    BITMAP "......##"
    BITMAP "......##"
    BITMAP "#####..#"
    BITMAP "....#..#"

    BITMAP "####...."
    BITMAP "########"
    BITMAP "........"
    BITMAP "########"
    BITMAP "########"
    BITMAP "........"
    BITMAP "########"
    BITMAP "########"

    BITMAP ".....#.."
    BITMAP "######.."
    BITMAP "........"
    BITMAP "########"
    BITMAP "########"
    BITMAP "........"
    BITMAP "########"
    BITMAP "########"
    
Disco:
BITMAP "........"
BITMAP "........"
BITMAP "...##..."
BITMAP "..####.."
BITMAP "..####.."
BITMAP "...##..."
BITMAP "........"
BITMAP "........"    

    
screen_cards_1:
    DATA $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
    DATA $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
    DATA $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
    DATA $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
    DATA $0000,$0000,$0800,$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0810,$0000,$0000
    DATA $0000,$0818,$0820,$0828,$0830,$0838,$0838,$0838,$0840,$0848,$0850,$0858,$0838,$0838,$0838,$0860,$0868,$0870,$0878,$0000
    DATA $0000,$0880,$0888,$0890,$0898,$08A0,$08A8,$08B0,$08B8,$08C0,$08C8,$08D0,$08D8,$08E0,$08E8,$08F0,$08F8,$0900,$0908,$0000
    DATA $0420,$0910,$0918,$0918,$0918,$0918,$0918,$0918,$0920,$0680,$0680,$0928,$0918,$0918,$0930,$0938,$0940,$0948,$0950,$0428
    DATA $0958,$0960,$0960,$0960,$0960,$0960,$0960,$0960,$0960,$0960,$0960,$0960,$0960,$0960,$0968,$0970,$0978,$0980,$0988,$0990
    DATA $399A,$39A2,$19AA,$19A2,$19AA,$19A2,$19AA,$19A2,$19AA,$19A2,$19AA,$19A2,$19AA,$19A2,$19AA,$19A2,$19AA,$19A2,$19AA,$29B0
    DATA $29B8,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C0,$09C8
    DATA $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
    

BANNER_TXT_pt:
    DATA "* MIBCartI * Cartucho Everdrive multi-jogos para seu console Intellivision * [1] (ou aguarde) Teste de Controles [2] Teste e ajuste de volume ECS [3] Teste de cores - Qualquer outro comando inicia a listagem"
    DATA " de jogos - Botao RESET do cartucho ou [1]+[9] seguido de [4]+[ENTER] reinicia - "
    DATA "Botoes superiores ou [ENTER] abre a pasta ou inicia o jogo - Botoes inferiores ou [CLEAR] retorna para a pasta anterior - Direcoes do disco navega pelos itens e paginas de itens"
    DATA " - Formate seu cartao SD no padrao FAT32 - Grave nele os arquivos dos seus jogos em .ROM / .BIN ou .INT ou .ITV ou .MIB + .CFG - Na raiz ou organizados em pastas e sub-pastas - Alguma configuracao nos"
    DATA " arquivos .CFG pode ser necessaria para executar / ativar o uso do JLP e da emulacao de som ECS / IntelliVoice (consulte)"
    DATA " - Desenvolvido por MasterMIB.com.br (RodineyHM) em 2026 baseado nos projetos PiRTOII-Duo e Minty - Divirta-se!!                        Entrando no teste de controles...     "


BANNER_TXT_en:
    DATA "* MIBCartI * Everdrive multi-game cartridge for your Intellivision console * [1] (or wait) Controller Test [2] ECS Test and volume adjustment [3] Color Test - Any other command starts the game list - Cartridge "
    DATA "RESET button or [1]+[9] followed by [4]+[ENTER] restarts - Upper buttons or [ENTER] opens the folder or starts the game - Lower buttons or [CLEAR] go back to the previous folder - Disk directions navigate "
    DATA "through items and item pages - Format your SD card in FAT32 standard - Save your game files on it in .ROM / .BIN or .INT ou .ITV or .MIB + .CFG - In the root or organized in folders and subfolders - Some configuration "
    DATA "in the .CFG files may be necessary to run/enable the use of JLP and ECS / IntelliVoice sound emulation (check) - Developed by MasterMIB.com.br (RodineyHM) in 2026 based on the PiRTOII-Duo and Minty projects - "
    DATA "Have fun!!                                                                         Entering the controller test...     "


banner: PROCEDURE
    IF banner_tick <> 0 THEN RETURN

    FOR banner_col = BANNER_COL_INI TO BANNER_COL_FIM - 1
        #BACKTAB(BANNER_LIN + banner_col) = #BACKTAB(BANNER_LIN + banner_col + 1)
    NEXT banner_col

    IF banner_fim = 0 THEN
        IF idioma = 1 THEN
            banner_char = BANNER_TXT_pt(#banner_i)
        ELSE
            banner_char = BANNER_TXT_en(#banner_i)
        END IF
        #BACKTAB(BANNER_LIN + BANNER_COL_FIM) = (banner_char * 8) + CS_DARKGREEN 
        #banner_i = #banner_i + 1
        IF #banner_i >= #BANNER_COMP THEN
            banner_fim = 1
            banner_esp = 0
        END IF
    ELSE
        banner_esp = banner_esp + 1
        IF banner_esp >= 16 THEN
            #banner_i   = 0
            banner_fim = 0
            banner_esp = 0
        END IF
    END IF
    RETURN
END    
    
fim_abertura:
    ResetSprite(0)
    ResetSprite(1)
    CLS
    WAIT
    