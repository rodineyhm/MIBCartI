'╔══════════════════════════════╗
'║        -= MIBCartI =-        ║
'║   Baseado no projeto Minty   ║
'║  (C)2026 - MasterMIB.com.br  ║
'╚══════════════════════════════╝
'

OPTION MAP 2

GOTO pulaS0
SEGMENT 0
pulaS0:

    ASM MEMATTR $8000, $9fff, "+RWN"

    OPTION EXPLICIT

    INCLUDE "constants.bas"
    
    INCLUDE "SndPlayer.bas"

    DIM I,J,K,WaveFrame,Action,I2
    DIM #F_FROM, #F_TO, #F_TOTAL
    DIM Input, Debounce
    DIM Selected_Entry, Max_Entry
    DIM #Disp_Color, #tmp
    DIM SelEnt_Start,SelEnt_Length
    DIM VolumeECS
    DIM InfoTimer, InfoShown
    
    ' Controlar Idioma
    DIM IDIOMA '0=en 1=pt
    IDIOMA = 1
    

    CONST DEBOUNCE_DELAY  = 4                   ' Number of cycles to detect button press
    CONST FRAMES_5SEC     = 300                 ' 5 seconds @ 60fps (NTSC)

    ' RAM addresses for exchanges with PI
    CONST ADDRESS_MAJOR     = $80FE
    CONST ADDRESS_MINOR     = $80FF
    CONST ADDRESS_TVMODE    = $8100
    CONST ADDRESS_ECS_PRES  = $8101
    CONST ADDRESS_MaxSize   = $8102 ' Max supported ROM size in kB (16 bits)
    CONST ADDRESS_AUDIO_VOL = $8104
    CONST ADDRESS_JLP_EMU   = $8105
    CONST ADDRESS_ECS_EMU   = $8106
    CONST ADDRESS_VOICE_PRES= $8107
    CONST ADDRESS_VOICE_EMU = $8108
    CONST ADDRESS_status    = $8119
    CONST ADDRESS_dev       = $8120
    CONST ADDRESS_has_sd    = $8121
    CONST ADDRESS_hw        = $8122
    CONST ADDRESS_sdpres    = $8123
    CONST ADDRESS_flist     = $817F ' 10 files * 64 characters per file (640 bytes), end address is $83FF
    CONST ADDRESS_INFO_NUM  = $8400 ' address to store the total number of info pages
    CONST ADDRESS_INFO_DISP = $8401 ' address to store the current displayed info page
    CONST ADDRESS_INFO_PAGE = $8402 ' 10 lines of 19 characters = 190 bytes, end address is $84C0
    CONST ADDRESS_cmd       = $8889
    CONST ADDRESS_err       = $888A
    CONST ADDRESS_Select    = $8899
    CONST ADDRESS_ftype     = $9000
    CONST ADDRESS_ffrom     = $9028 ' First displayed entry (16 bits)
    CONST ADDRESS_fto       = $9030 ' Last displayed entry (16 bits)
    CONST ADDRESS_ftotal    = $9032 ' Total number of entries (16 bits)
    CONST ADDRESS_path      = $9100
    CONST ADDRESS_section   = $9300
    
    ' PI current status
    CONST PI_STAT_BUZZY     = 1
    CONST PI_STAT_READY     = 0
    ' Commands that can be sent to PI
    CONST CMD_NONE          = 0
    CONST CMD_READFILELIST  = 1
    CONST CMD_RUNFILE       = 2
    CONST CMD_NEXTPAGE      = 3
    CONST CMD_PREVIOUSPAGE  = 4
    CONST CMD_UPDIRECTORY   = 5
    CONST CMD_READINFO      = 7
    CONST CMD_NEXTINFO      = 8
    CONST CMD_PREVINFO      = 9

    ' Interface actions
    CONST ACTION_NONE          = 0
    CONST ACTION_SELECT        = 1
    CONST ACTION_UP            = 2
    CONST ACTION_DOWN          = 3
    CONST ACTION_PAGEUP        = 4
    CONST ACTION_PAGEDOWN      = 5
    CONST ACTION_EXIT          = 6
    CONST ACTION_DISPHELP      = 7
    CONST ACTION_DISPINFO      = 8
    CONST ACTION_DISPSETTINGS  = 9

    ' Type of mass storage devices
    CONST DEV_FLASH         = 0
    CONST DEV_SD            = 1
    ' Type of entry
    CONST TYPE_FILE         = 0
    CONST TYPE_DIR          = 1
    ' HW
    CONST PI_HW_UNKNOWN     = 0
    CONST PI_HW_PIRTO       = 1
    CONST PI_HW_PIRTO2      = 2
    CONST PI_HW_PIRTO2SD    = 3
    CONST PI_HW_PIRTO2DUO   = 4
    CONST PI_HW_PINTY       = 5
    ' ERROR codes
    CONST ERR_NO_ERROR            = 0
    CONST ERR_COULD_NOT_OPEN_FILE = 1
    CONST ERR_FILE_TO_BIG         = 2
    ' TV MODE
    CONST isPAL          = 0
    CONST isNTSC         = 1

    CONST FNAME_LENGTH   = 64
    CONST INFO_LENGTH    = 19

    DEF FN PI_STATUS = PEEK(ADDRESS_status)
    DEF FN PI_CMD(command) = POKE(ADDRESS_cmd),command
    DEF FN PI_HAS_SD = PEEK(ADDRESS_has_sd)
    DEF FN PI_SD_PRESENT = PEEK(ADDRESS_sdpres)
    DEF FN PI_SELECTDEVICE(device) = POKE(ADDRESS_dev),device
    DEF FN PI_CURRENTDEVICE = PEEK(ADDRESS_dev)
    DEF FN PI_SELECTENTRY(entry) = POKE(ADDRESS_Select),(entry+1)
    DEF FN PI_GETENTRY = PEEK(ADDRESS_Select)
    DEF FN PI_GET_FTYPE(file) = PEEK(ADDRESS_ftype+file)
    DEF FN PI_GET_FFROM  = ((PEEK(ADDRESS_ffrom)  * 256) + PEEK(ADDRESS_ffrom+1))
    DEF FN PI_GET_FTO    = ((PEEK(ADDRESS_fto)    * 256) + PEEK(ADDRESS_fto+1))
    DEF FN PI_GET_FTOTAL = ((PEEK(ADDRESS_ftotal) * 256) + PEEK(ADDRESS_ftotal+1))
    DEF FN PI_GET_HW     = PEEK(ADDRESS_hw)
    DEF FN PI_GET_ERROR  = PEEK(ADDRESS_err)
    DEF FN PI_GET_INFO_NUM = PEEK(ADDRESS_INFO_NUM)
    DEF FN PI_GET_INFO_DISP = PEEK(ADDRESS_INFO_DISP)
    DEF FN PI_SET_TVMODE(mode) = POKE(ADDRESS_TVMODE),mode
    DEF FN PI_SET_ECS_PRES(presence) = POKE(ADDRESS_ECS_PRES),presence
    DEF FN PI_SET_VOICE_PRES(presence) = POKE(ADDRESS_VOICE_PRES),presence
    DEF FN PI_SET_AUDIO_VOL(v) = POKE(ADDRESS_AUDIO_VOL),v
    DEF FN PI_GET_AUDIO_VOL = PEEK(ADDRESS_AUDIO_VOL)
    DEF FN PI_GET_MAXSIZE = ((PEEK(ADDRESS_MaxSize) * 256) + PEEK(ADDRESS_MaxSize+1))
    DEF FN PI_GET_JLP_EMU = PEEK(ADDRESS_JLP_EMU)
    DEF FN PI_GET_ECS_EMU = PEEK(ADDRESS_ECS_EMU)
    DEF FN PI_GET_VOICE_EMU = PEEK(ADDRESS_VOICE_EMU)
    DEF FN PI_GET_MAJOR = PEEK(ADDRESS_MAJOR)
    DEF FN PI_GET_MINOR = PEEK(ADDRESS_MINOR)

    DIM TIMER

' --- Novo Comando de Áudio ---
CONST CMD_AUDIO_TEST = 10
CONST CMD_RESET = 11

' --- Macro para atualizar volume e disparar tom no Pico ---
DEF FN PI_PLAY_AUDIO_TEST(v) = POKE(ADDRESS_AUDIO_VOL), v : POKE(ADDRESS_cmd), CMD_AUDIO_TEST

    MODE 1
    WAIT
    DEFINE 0,4,bitmaps_MIBCartI
    WAIT
    PRINT AT SCREENPOS( 14,11), $1800,$1808,$1810,$1818

    IF PI_GET_MAJOR = 2 THEN
        IDIOMA = 0 '0=en 1=pt
    END IF

    PI_SET_TVMODE(NTSC)
    PI_SET_ECS_PRES(ECS.AVAILABLE)
    PI_SET_VOICE_PRES(VOICE.AVAILABLE)

    ' ABERTURA MIBCartI ==================
    INCLUDE "abertura.bas"
    ' ABERTURA MIBCartI ==================

    ' Display splash screen
    MODE 0,0,0,0,7
    WAIT

    I = 0
    TIMER = 10 ' Define o tempo inicial para 1/3 de segundo (20 frames)
    WHILE PI_STATUS <> PI_STAT_READY
        ' Atualiza o desenho e a posição do sprite continuamente
        DEFINE 63, 1, VARPTR In_Progress(I * 4)
        SPRITE 0, 152 + VISIBLE, 8 + ZOOMY2, SPR63 + SPR_RED
        ' Aguarda o próximo frame do console
        WAIT
        ' Reduz o cronômetro a cada frame
        TIMER = TIMER - 1
        ' Quando atingir 1/3 de segundo, troca o sprite
        IF TIMER = 0 THEN
            I = I + 1
            IF I = 4 THEN I = 0          
            TIMER = 10 ' Reinicia o cronômetro para mais 1/3 de segundo
        END IF
    WEND
    ResetSprite(0)

    I2 = 0
    TIMER = 10 ' Define o tempo inicial para 1/3 de segundo (20 frames)
    #f_total = PI_GET_FTOTAL
    WHILE (#f_total = 0) AND (I < 250)
        WAIT
        I = I + 1
        #f_total = PI_GET_FTOTAL

        ' Atualiza o desenho e a posição do sprite continuamente
        DEFINE 63, 1, VARPTR In_Progress(I2 * 4)
        SPRITE 0, 152 + VISIBLE, 8 + ZOOMY2, SPR63 + SPR_RED
        ' Aguarda o próximo frame do console
        WAIT
        ' Reduz o cronômetro a cada frame
        TIMER = TIMER - 1
        ' Quando atingir 1/3 de segundo, troca o sprite
        IF TIMER = 0 THEN
            I2 = I2 + 1
            IF I2 = 4 THEN I2 = 0          
            TIMER = 10 ' Reinicia o cronômetro para mais 1/3 de segundo
        END IF
    WEND
    ResetSprite(0)

    CLS
    DEFINE 0,2,Icons
    WAIT
    DEFINE 2,5,Slider
    WAIT

    ' load font into grams (23 to 63 are occupied)
    GOSUB Init_font

    ' Start up with selecting the last used entry
    Selected_Entry = PI_GETENTRY

START:

    GOSUB DISPLAY_HEADER

    ' Display current path
    #tmp = PEEK(ADDRESS_path + 1)
    ' First letter need to change Color Stack
    #BACKTAB(20) = ASCII_table(#tmp) + CS_DARKGREEN + $2000
    FOR I = 1 TO 19
        #tmp = PEEK(ADDRESS_path + I + 1)
        #BACKTAB(20+I) = ASCII_table(#tmp) + CS_DARKGREEN
    NEXT I

    ' Get current directory informations and display slider
    #f_from  = PI_GET_FFROM
    #f_to    = PI_GET_FTO
    #f_total = PI_GET_FTOTAL  

    ' Diplay Slider
    GOSUB DISPLAY_SLIDER

    ' Display file list
    GOSUB DISPLAY_FILELIST    
    
MENU_LOOP:
    WAIT

    ' Update selected file display is length > display size
    IF FRAME%16 = 0 THEN
        GOSUB DISPLAY_SELECTED_ENTRY
    END IF

    IF Debounce>0 THEN Debounce = Debounce-1:GOTO MENU_LOOP

    GOSUB GetAction

    ON Action GOTO M_NONE,M_SELECT,M_UP,M_DOWN,M_PAGEUP,M_PAGEDOWN,M_EXIT,M_DISPHELP,M_DISPINFO,M_DISPSETTINGS
M_NONE:
    GOTO MENU_LOOP
M_SELECT:
    GOSUB SELECT_ENTRY
    WHILE CONT: WAIT: WEND
    GOTO START
M_UP:
    IF (Selected_Entry=0 and #f_from>0) THEN 
        ' last entry of previous page will be selected
        Selected_Entry = 9
        GOSUB PREVIOUS_PAGE
        WHILE CONT: WAIT: WEND
        GOTO START
    END IF
    IF Selected_Entry>0 THEN
        GOSUB UNSELECT_ENTRY
        Selected_Entry=Selected_Entry-1 
        PlaySnd(InputSound)
        GOSUB DISPLAY_FILELIST
        WHILE CONT: WAIT: WEND
    END IF
    GOTO MENU_LOOP
M_DOWN:
    IF ((Selected_Entry=Max_Entry) AND (#f_to < #f_total)) THEN
        ' first entry of next page will be selected
        GOSUB NEXT_PAGE
        WHILE CONT: WAIT: WEND
        GOTO START
    END IF
    IF Selected_Entry < Max_Entry THEN
        GOSUB UNSELECT_ENTRY
        Selected_Entry=Selected_Entry+1
        PlaySnd(InputSound)
        GOSUB DISPLAY_FILELIST
        WHILE CONT: WAIT: WEND
    END IF
    GOTO MENU_LOOP
M_PAGEUP:
    IF (#f_from > 0) THEN
        GOSUB PREVIOUS_PAGE
        WHILE CONT: WAIT: WEND
        GOTO START
    END IF
    GOTO MENU_LOOP
M_PAGEDOWN:
    IF (#f_to < #f_total) THEN 
        GOSUB NEXT_PAGE
        WHILE CONT: WAIT: WEND
        GOTO START
    END IF
    GOTO MENU_LOOP
M_EXIT:
    GOSUB UP_DIRECTORY
    WHILE CONT: WAIT: WEND
    GOTO START
M_DISPHELP:
    GOTO START
M_DISPINFO:
    GOTO START
M_DISPSETTINGS:
    GOTO START

GetAction: PROCEDURE
    ' Get user input and return it in CONT variable
    Input = CONT
    Action = ACTION_NONE
    IF Input <> 0 THEN
        FOR I = 0 TO 30
            IF Input = ContCode(I) THEN Action = MainAction(I):Debounce = DEBOUNCE_DELAY:RETURN
        NEXT I
    END IF
    END

NEXT_PAGE: PROCEDURE
    PI_CMD(CMD_NEXTPAGE)
    PlaySnd(InputSound)
    GOSUB WAIT_CARD_ANSWER
    Selected_Entry = 0
    END

PREVIOUS_PAGE: PROCEDURE
    PI_CMD(CMD_PREVIOUSPAGE)
    PlaySnd(InputSound)
    GOSUB WAIT_CARD_ANSWER
    END

SELECT_ENTRY: PROCEDURE
    IF #f_from < #f_to THEN
        PI_SELECTENTRY(Selected_Entry)
        PI_CMD(CMD_RUNFILE)
        IF PI_GET_FTYPE(Selected_Entry) = TYPE_DIR THEN 
            GOSUB WAIT_CARD_ANSWER
            Selected_Entry = 0
        ELSE
            ' RUN GAME
            GOSUB WAIT_CARD_ANSWER
            
            ' If error display error message and wait for user to press clear
            IF PI_GET_ERROR <> ERR_NO_ERROR THEN
                GOSUB UNSELECT_ENTRY
                PRINT AT SCREENPOS(0,4)  COLOR CS_RED, "                   "
                PRINT AT SCREENPOS(0,6)  COLOR CS_RED, "                   "
                PRINT AT SCREENPOS(0,10) COLOR CS_RED, "                   "
                IF IDIOMA = 1 THEN
                    PRINT AT SCREENPOS(0,11) COLOR CS_RED, "<CLEAR> p/ retornar"
                ELSE
                    PRINT AT SCREENPOS(0,11) COLOR CS_RED, " <CLEAR> to return "                    
                END IF
                
                IF PI_GET_ERROR = ERR_FILE_TO_BIG THEN 
                    
                    IF IDIOMA = 1 THEN
                        PRINT AT SCREENPOS(0,11) COLOR CS_RED, "Arquivo muito grande!"
                    ELSE
                        PRINT AT SCREENPOS(0,5)  COLOR CS_RED, "   File too big!   "                  
                    END IF                    
                    
                ELSE
                        IF IDIOMA = 1 THEN
                            PRINT AT SCREENPOS(0,11) COLOR CS_RED, "Arquivo invalido!"
                        ELSE
                            PRINT AT SCREENPOS(0,5)  COLOR CS_RED, "Couldn't open file!"
                        END IF                     
                    
                END IF
                WHILE (CONT <> $88)  'CLEAR
                    WAIT
                WEND
                Debounce = DEBOUNCE_DELAY
            ELSE
                ' Infinite loop till getting reseted by card
                ASM InfiniteLoop:
                ASM    B InfiniteLoop
            END IF
        END IF
    END IF
    END

UP_DIRECTORY: PROCEDURE
    PI_CMD(CMD_UPDIRECTORY)
    PlaySnd(InputSound)
    GOSUB WAIT_CARD_ANSWER
    Selected_Entry = PI_GETENTRY
    END


WAIT_CARD_ANSWER: PROCEDURE
    I = 0
'     PRINT AT SCREENPOS(8, 0) COLOR CS_TAN,"Carregando.."
    WHILE PI_STATUS = PI_STAT_BUZZY
        ' Atualiza o desenho e a posição do sprite continuamente
        DEFINE 63, 1, VARPTR In_Progress(I * 4)
        SPRITE 0, 152 + VISIBLE, 8 + ZOOMY2, SPR63 + SPR_RED
        ' Aguarda o próximo frame do console
        WAIT
        ' Reduz o cronômetro a cada frame
        TIMER = TIMER - 1
        ' Quando atingir 1/3 de segundo, troca o sprite
        IF TIMER = 0 THEN
            I = I + 1
            IF I = 4 THEN I = 0          
            TIMER = 10 ' Reinicia o cronômetro para mais 1/3 de segundo
        END IF
    WEND
    ResetSprite(0)
'     PRINT AT SCREENPOS(8, 0) COLOR CS_TAN,"            "
    END

UNSELECT_ENTRY:PROCEDURE
    #BACKTAB(41 + Selected_Entry*20) = #BACKTAB(41 + Selected_Entry*20) AND $DFFF
    #BACKTAB(41 + Selected_Entry*20 + 18) = #BACKTAB(41 + Selected_Entry*20 + 18) AND $DFFF
    END

DISPLAY_FILELIST: PROCEDURE
    Max_Entry = #f_to - #f_from
    SelEnt_Start = 0
    SelEnt_Length = 0

    
    IF Max_Entry > 0 THEN
        Max_Entry = Max_Entry - 1
        FOR J=0 TO Max_Entry
            ' First icon needs also to change colorstack
            IF J = 0 THEN #tmp = $2000 else #tmp = 0
            IF PI_GET_FTYPE(J) = TYPE_DIR THEN
                #Disp_Color = CS_TAN
                #BACKTAB(J*20 + 40) = BG00 + CS_YELLOW + #tmp
            ELSE
                #Disp_Color = CS_TAN
                #BACKTAB(J*20 + 40) = BG01 + CS_PURPLE + #tmp
            END IF
            IF J = Selected_Entry THEN           
                FOR I=0 TO 17
                    #tmp = PEEK((ADDRESS_flist+I)+FNAME_LENGTH*J)
                    IF #tmp = 255 THEN #tmp = 0
                    IF I = 0 THEN 
                        #BACKTAB(41 + J*20 + I) = ASCII_table(#tmp) + CS_BLACK + $2000
                        #BACKTAB(41 + J*20 + 18) = #BACKTAB(41 + J*20 + 18) + $2000
                    ELSE
                        #BACKTAB(41 + J*20 + I) = ASCII_table(#tmp) + CS_BLACK
                    END IF
                NEXT I   
            ELSE
                FOR I=0 TO 17
                    #tmp = PEEK((ADDRESS_flist+I)+FNAME_LENGTH*J)
                    IF #tmp = 255 THEN #tmp = 0
                    #BACKTAB(41 + J*20 + I) = ASCII_table(#tmp) + #Disp_Color
                NEXT I
            END IF
        NEXT J
        WHILE ((PEEK((ADDRESS_flist+SelEnt_Length)+FNAME_LENGTH*Selected_Entry)<>255) AND (SelEnt_Length<FNAME_LENGTH))
            SelEnt_Length = SelEnt_Length + 1 
        WEND
    ELSE
        ' Change background color
        #BACKTAB(40) = $2000
        IF ((PI_CURRENTDEVICE = DEV_SD) AND (PI_SD_PRESENT = 0)) THEN
            IF IDIOMA = 0 THEN
                PRINT AT SCREENPOS(2,5) COLOR CS_RED, "<NO SD CARD>"
            ELSE
                PRINT AT SCREENPOS(2,5) COLOR CS_RED, "<SEM CARTAO SD>"
            END IF
        ELSE
            IF IDIOMA = 0 THEN
                PRINT AT SCREENPOS(2,5) COLOR CS_RED, "<EMPTY>"
            ELSE
                PRINT AT SCREENPOS(2,5) COLOR CS_RED, "<LOCAL VAZIO>"
            END IF
        END IF
    END IF
    END

DISPLAY_SELECTED_ENTRY: PROCEDURE
    ' Scroll selected entry display if it doesn't fit on screen
    IF SelEnt_Length > 18 THEN
        SelEnt_Start = SelEnt_Start + 1
        IF SelEnt_Start > SelEnt_Length THEN SelEnt_Start = 0
        FOR I = 0 TO 17
            IF I =  0 then #Disp_Color = $2000 ELSE #Disp_Color = $0000
            #tmp = SelEnt_Start + I
            IF #tmp = SelEnt_Length THEN
                #BACKTAB(41 + Selected_Entry*20 + I) = ASCII_table(0) + CS_BLACK + #Disp_Color
            ELSE
                IF #tmp > SelEnt_Length THEN #tmp = #tmp - SelEnt_Length -1
                #tmp = PEEK((ADDRESS_flist+#tmp)+FNAME_LENGTH*Selected_Entry)
                #BACKTAB(41 + Selected_Entry*20 + I) = ASCII_table(#tmp) + CS_BLACK + #Disp_Color
            END IF
        NEXT I
    END IF
    END

DISPLAY_SLIDER: PROCEDURE
    IF #f_from < #f_to THEN ' Not an Empty list
        I = ((79 * #f_from) / #f_total)
        J = ((79 * #f_to)   / #f_total)
        IF I > 71   THEN I = 71
        IF J < I+8  THEN J = I+8
        K = J-I

        IF K > 64 THEN
            SPRITE 3, 160 + VISIBLE, 25      + I + ZOOMY8 + DOUBLEY, SPR02 + SPR_GREY
            SPRITE 2, 160 + VISIBLE, 25 - 64 + J + ZOOMY8 + DOUBLEY, SPR02 + SPR_GREY
        ELSEIF K > 32 THEN
            SPRITE 3, 160 + VISIBLE, 25       + I + ZOOMY8, SPR02 + SPR_GREY
            SPRITE 2, 160 + VISIBLE, 25  - 32 + J + ZOOMY8, SPR02 + SPR_GREY
        ELSEIF K > 16 THEN
            SPRITE 3, 160 + VISIBLE, 25      + I + ZOOMY4, SPR02 + SPR_GREY
            SPRITE 2, 160 + VISIBLE, 25 - 16 + J + ZOOMY4, SPR02 + SPR_GREY
        ELSE
            SPRITE 3, 160 + VISIBLE, 25     + I + ZOOMY2, SPR02 + SPR_GREY
            SPRITE 2, 160 + VISIBLE, 25 - 8 + J + ZOOMY2, SPR02 + SPR_GREY
        END IF

        SPRITE 1, 160 + VISIBLE, 25 - 4 + (I+J) / 2 + ZOOMY2,  $20E8 'Using "=" character from GROM
    ELSE
        ' Empty list => Display empty slider
        ResetSprite(1)
        ResetSprite(2)
        ResetSprite(3)
    END IF

'     FOR I=59 TO 219 STEP 20:#BACKTAB(I)=$0827:NEXT I
    FOR I=79 TO 219 STEP 20:#BACKTAB(I)=$0827:NEXT I
    #BACKTAB(239) = $082F
    '#BACKTAB(59) = $0810 + FG_WHITE + BG_BLACK
    PRINT AT SCREENPOS(19,2) , BG06 + FG_WHITE

    END

DISPLAY_HEADER: PROCEDURE
    CLS
    ResetSprite(1)
    ResetSprite(2)
    ResetSprite(3)

    DEFINE 7,4,bitmaps_MIBCartI_Blue
    PRINT AT SCREENPOS( 7,0), BG07 + FG_BLUE, BG08 + FG_BLUE, BG09 + FG_BLUE, BG10 + FG_BLUE

    END

    INCLUDE "Sounds.bas"
    INCLUDE "font.bas"

Icons:
    DATA $E000,$E2FE,$8282,$00FE
'     DATA $3800,$D644,$54CE,$0038
    BITMAP "...##..."
    BITMAP "...##.#."
    BITMAP ".######."
    BITMAP ".#.##..."
    BITMAP "...##..."
    BITMAP "...##..."
    BITMAP "....#..."
    BITMAP "........"

Slider:
    DATA $7C7C,$7C7C,$7C7C,$7C7C
    DATA $7C7C,$7C7C,$7C7C,$7C7C
    DATA $8282,$8282,$8282,$8282
    DATA $8282,$8282,$8282,$FE82
    DATA $82FE,$8282,$8282,$8282 ' Word: $0810

In_Progress:
BITMAP "...##..."
BITMAP "...##.#."
BITMAP ".######."
BITMAP ".#.##..."
BITMAP "...##..."
BITMAP "...##..."
BITMAP "....#..."
BITMAP "....#..."

BITMAP "...##..."
BITMAP "...##..."
BITMAP ".######."
BITMAP ".#.##..."
BITMAP "...##..."
BITMAP "...##..."
BITMAP "....#..."
BITMAP "........"

BITMAP "...##..."
BITMAP "...##.#."
BITMAP ".######."
BITMAP "...##..."
BITMAP "...##..."
BITMAP "...##..."
BITMAP "...#...."
BITMAP "........"

BITMAP "...##..."
BITMAP ".#.##..."
BITMAP ".######."
BITMAP "...##.#."
BITMAP "...##..."
BITMAP "...##..."
BITMAP "...#...."
BITMAP "...#...."

bitmaps_MIBCartI:
    DATA $2575,$5505,$7555,$FF75
    DATA $6B1C,$1B6B,$6B6B,$FF1C
    DATA $FFFF,$EA88,$AB8B,$FF8B
    DATA $BDF8,$BD8D,$BDBD,$FF88

bitmaps_MIBCartI_Blue:
    BITMAP "#...#.#."
    BITMAP "##.##.#."
    BITMAP "#####.#."
    BITMAP "#.#.#.#."
    BITMAP "#.#.#.#."
    BITMAP "#...#.#."
    BITMAP "#...#.#."
    BITMAP "........"

    BITMAP "###...##"
    BITMAP "#..#.#.."
    BITMAP "#..#.#.."
    BITMAP "###..#.."
    BITMAP "#..#.#.."
    BITMAP "#..#.#.."
    BITMAP "###...##"
    BITMAP "........"

    BITMAP "........"
    BITMAP "........"
    BITMAP ".###.###"
    BITMAP "...#.#.#"
    BITMAP ".###.#.."
    BITMAP ".#.#.#.."
    BITMAP ".###.#.."
    BITMAP "........"

    BITMAP ".....###"
    BITMAP ".#....#."
    BITMAP ".###..#."
    BITMAP ".#....#."
    BITMAP ".#....#."
    BITMAP ".#....#."
    BITMAP ".###.###"
    BITMAP "........"

ContCode:
    DATA 129,65,33,130,66,34,132,68,36,136,72,40,160,96,192,4,20,22,6,2,18,19,3,1,17,25,9,8,24,28,12

MainAction:
    DATA ACTION_DISPHELP        ' 1
    DATA ACTION_DISPINFO        ' 2
    DATA ACTION_DISPSETTINGS    ' 3
    DATA ACTION_NONE            ' 4
    DATA ACTION_NONE            ' 5
    DATA ACTION_NONE            ' 6
    DATA ACTION_NONE        ' 7
    DATA ACTION_NONE              ' 8
    DATA ACTION_NONE          ' 9
    DATA ACTION_EXIT            ' CLR
    DATA ACTION_NONE            ' 0
    DATA ACTION_SELECT          ' ENT
    DATA ACTION_SELECT          ' BUT_UP
    DATA ACTION_EXIT        ' BUT_LEFT
    DATA ACTION_EXIT        ' BUT_RIGHT
    DATA ACTION_UP              ' N
    DATA ACTION_UP              ' NNE
    DATA ACTION_NONE            ' NE
    DATA ACTION_NONE            ' NEE
    DATA ACTION_PAGEDOWN        ' E
    DATA ACTION_NONE            ' SEE
    DATA ACTION_NONE            ' SE
    DATA ACTION_DOWN            ' SSE
    DATA ACTION_DOWN            ' S
    DATA ACTION_DOWN            ' SSW
    DATA ACTION_NONE            ' SW
    DATA ACTION_NONE            ' SWW
    DATA ACTION_PAGEUP          ' W
    DATA ACTION_NONE            ' NWW
    DATA ACTION_NONE            ' NW
    DATA ACTION_UP              ' NNW
