'╔══════════════════════════════╗
'║        -= ECS Test =-        ║
'║  (C)2026 - MasterMIB.com.br  ║
'╚══════════════════════════════╝
'

DIM ConsoleOn, EcsOn, MelodyIdx, NoteTimer, VoiceOn, VolumePSG
DIM NOTE_HOLD_FRAMES, #BASS_DRONE_VALUE
DIM #MelNote1, #MelNote2, #MelNote3

CONST MELODY_STEPS     = 8
CONST CONSOLE_REF_VOL  = 10
CONST ECS_NOTE_VOL     = 10

VOLUME_CAL_SCREEN: PROCEDURE
    IF NTSC THEN
        NOTE_HOLD_FRAMES = 20
        #BASS_DRONE_VALUE = 641
    ELSE
        NOTE_HOLD_FRAMES = 17
        #BASS_DRONE_VALUE = 716
    END IF

    MODE 0,0,0,0,7
    WAIT
    CLS
    WAIT

    PI_SET_TVMODE(NTSC)
    PI_SET_ECS_PRES(ECS.AVAILABLE)
    PI_SET_VOICE_PRES(VOICE.AVAILABLE)
    Selected_Entry = PI_GETENTRY


    VolumeECS = PI_GET_AUDIO_VOL
    VolumePSG = 5
    WAIT

    IF idioma = 0 THEN
        PRINT AT SCREENPOS(0,0) COLOR CS_TAN, "Test & adjustment of"
        PRINT AT SCREENPOS(0,1) COLOR CS_TAN, "  ECS sound volume  "
        PRINT AT SCREENPOS(0,2) COLOR CS_TAN, "    & IntelliVoice  "

        PRINT AT SCREENPOS(0,4) COLOR CS_DARKGREEN,   "[1] 3ch Console  "  
        PRINT AT SCREENPOS(0,5) COLOR CS_BLUE,   "[2] 3ch ECS Emul."
        PRINT AT SCREENPOS(0,6) COLOR CS_DARKGREEN,   "[\63] Volume PSG   "
        PRINT AT SCREENPOS(0,7) COLOR CS_BLUE,   "[^] Volume ECS   "
        PRINT AT SCREENPOS(0,8) COLOR CS_TAN,   "[E] Apply & Exit "
    ELSE
        PRINT AT SCREENPOS(0,0) COLOR CS_TAN, " Teste e ajuste de  "
        PRINT AT SCREENPOS(0,1) COLOR CS_TAN, " volume do som ECS  "
        PRINT AT SCREENPOS(0,2) COLOR CS_TAN, "    e IntelliVoice  "

        PRINT AT SCREENPOS(0,4) COLOR CS_DARKGREEN,   "[1] 3ch Console  "  
        PRINT AT SCREENPOS(0,5) COLOR CS_BLUE,   "[2] 3ch ECS Emul."
        PRINT AT SCREENPOS(0,6) COLOR CS_DARKGREEN,   "[\63] Volume PSG   "
        PRINT AT SCREENPOS(0,7) COLOR CS_BLUE,   "[^] Volume ECS   "
        PRINT AT SCREENPOS(0,8) COLOR CS_TAN,   "[E] Aplica e Sai   "
    END IF

    IF NTSC THEN
        PRINT AT SCREENPOS(0,10) COLOR CS_TAN,   "NTSC"
    ELSE
        PRINT AT SCREENPOS(0,10) COLOR CS_TAN,   "PAL"
    END IF

    IF PI_GET_JLP_EMU THEN
        PRINT AT SCREENPOS(5, 10) COLOR CS_GREEN,"JPL"
    ELSE
        PRINT AT SCREENPOS(5, 10) COLOR CS_RED,"JLP"
    END IF

    IF PI_GET_ECS_EMU THEN
        PRINT AT SCREENPOS(9, 10) COLOR CS_GREEN,"ECS"
    ELSE
        PRINT AT SCREENPOS(9, 10) COLOR CS_RED,"ECS"
    END IF

    IF PI_GET_VOICE_EMU THEN
        PRINT AT SCREENPOS(13, 10) COLOR CS_GREEN,"IVoice"   
    ELSE
        PRINT AT SCREENPOS(13, 10) COLOR CS_RED,"IVoice"   
    END IF 

    PRINT AT SCREENPOS( 1, 11) COLOR CS_TAN, "Max:", <3>PI_GET_MAXSIZE,"KB"

    PRINT AT SCREENPOS(15,11) COLOR CS_TAN,"v",<1>PI_GET_MAJOR,".",<1>PI_GET_MINOR

    WHILE CONT<>0: WAIT: WEND
    
    ConsoleOn = 0
    EcsOn = 0
    MelodyIdx = 0
    NoteTimer = 0
    Debounce = 0

    II = 0
    GOSUB VOLCAL_UPDATE_DISPLAY
    GOSUB VOLCAL_UPDATE_SOUND    
    
VOLCAL_LOOP:
    WAIT


    NoteTimer = NoteTimer + 1
    IF NoteTimer >= NOTE_HOLD_FRAMES THEN
        NoteTimer = 0
        MelodyIdx = (MelodyIdx + 1) % MELODY_STEPS
        GOSUB VOLCAL_UPDATE_SOUND
    END IF

    IF Debounce > 0 THEN
        Debounce = Debounce - 1
        GOTO VOLCAL_LOOP
    END IF

    GOSUB GetAction

    IF Action = ACTION_DISPHELP THEN 
        WHILE CONT<>0: WAIT: WEND
        ConsoleOn = 1 - ConsoleOn
        GOSUB VOLCAL_UPDATE_SOUND
        GOSUB VOLCAL_UPDATE_DISPLAY
        Debounce = DEBOUNCE_DELAY
    END IF

    IF Action = ACTION_DISPINFO THEN
        WHILE CONT<>0: WAIT: WEND    
        IF EcsOn = 0 THEN
            EcsOn = 1
            PI_PLAY_AUDIO_TEST(VolumeECS)

            II = 180
            GOSUB VOLCAL_UPDATE_SOUND
            GOSUB VOLCAL_UPDATE_DISPLAY
            Debounce = DEBOUNCE_DELAY
        END IF

    END IF

    IF (Action = ACTION_UP) AND (VolumeECS < 255) THEN
        WHILE CONT<>0: WAIT: WEND
        #tmp = (VolumeECS / 10) * 10 + 10
        IF #tmp > 255 THEN #tmp = 255
        VolumeECS = #tmp
        PI_SET_AUDIO_VOL(VolumeECS)
        GOSUB VOLCAL_UPDATE_DISPLAY
        Debounce = DEBOUNCE_DELAY
    END IF

    IF (Action = ACTION_DOWN) AND (VolumeECS > 0) THEN
        WHILE CONT<>0: WAIT: WEND
        IF VolumeECS % 10 = 0 THEN
            VolumeECS = VolumeECS - 10
        ELSE
            VolumeECS = (VolumeECS / 10) * 10
        END IF
        IF VolumeECS < 0 THEN VolumeECS = 0
        PI_SET_AUDIO_VOL(VolumeECS)
        GOSUB VOLCAL_UPDATE_DISPLAY
        Debounce = DEBOUNCE_DELAY
    END IF

    IF (Action = ACTION_PAGEDOWN) AND (VolumePSG < 15) THEN
        VolumePSG = VolumePSG + 1
        GOSUB VOLCAL_UPDATE_DISPLAY
        Debounce = DEBOUNCE_DELAY
    END IF

    IF (Action = ACTION_PAGEUP) AND (VolumePSG > 0) THEN
        VolumePSG = VolumePSG - 1
        GOSUB VOLCAL_UPDATE_DISPLAY
        Debounce = DEBOUNCE_DELAY
    END IF

    IF (Action = ACTION_SELECT) OR (Action = ACTION_EXIT) THEN
        SOUND 0,1,0 : SOUND 1,1,0 : SOUND 2,1,0
        SOUND 5,1,0 : SOUND 6,1,0 : SOUND 7,1,0
        PI_SET_AUDIO_VOL(VolumeECS)
        Debounce = DEBOUNCE_DELAY
        WHILE CONT<>0: WAIT: WEND

    PI_CMD(CMD_UPDIRECTORY)
    GOSUB WAIT_CARD_ANSWER

    WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT:WAIT
    POKE(ADDRESS_cmd), CMD_RESET

    RETURN
    END IF    

    IF II > 0 THEN
        II = II - 1
        GOSUB VOLCAL_UPDATE_DISPLAY
    END IF

    GOTO VOLCAL_LOOP

    END

VOLCAL_UPDATE_SOUND: PROCEDURE
    IF NTSC THEN
        #MelNote1 = MelodyDataNTSC(MelodyIdx*3+0)
        #MelNote2 = MelodyDataNTSC(MelodyIdx*3+1)
        #MelNote3 = MelodyDataNTSC(MelodyIdx*3+2)
    ELSE
        #MelNote1 = MelodyDataPAL(MelodyIdx*3+0)
        #MelNote2 = MelodyDataPAL(MelodyIdx*3+1)
        #MelNote3 = MelodyDataPAL(MelodyIdx*3+2)
    END IF

    IF ConsoleOn THEN
        SOUND 0, #MelNote1, VolumePSG
        SOUND 1, #MelNote2, VolumePSG
        SOUND 2, #MelNote3, VolumePSG
    ELSE
        SOUND 0,1,0 : SOUND 1,1,0 : SOUND 2,1,0
    END IF

    RETURN

    END

VOLCAL_UPDATE_DISPLAY: PROCEDURE
    IF ConsoleOn = 1 THEN
        PRINT AT SCREENPOS(17,4) COLOR CS_GREEN, "ON "
    ELSE
        PRINT AT SCREENPOS(17,4) COLOR CS_RED,   "OFF"
    END IF

    IF EcsOn = 1 THEN
        IF II = 0 THEN
            EcsOn = 0
            PRINT AT SCREENPOS(17,5) COLOR CS_RED,   "OFF"
        ELSE
            PRINT  AT SCREENPOS(17,5) COLOR CS_GREEN, "ON "
        END IF
    ELSE
        PRINT AT SCREENPOS(17,5) COLOR CS_RED,   "OFF"
    END IF

VolumeECS = PI_GET_AUDIO_VOL

    PRINT AT SCREENPOS(17,7) COLOR CS_GREEN, <3>VolumeECS

    PRINT AT SCREENPOS(18,6) COLOR CS_GREEN, <2>VolumePSG

    RETURN

    END

MelodyDataNTSC:
    DATA 320,641,1281   ' F4(349.23) / F3(174.61) / F2(87.31)
    DATA 285,571,1141   ' G4(392.00) / G3(196.00) / G2(98.00)
    DATA 254,508,1017   ' A4(440.00) / A3(220.00) / A2(110.00)
    DATA 214,428,855    ' C5(523.25) / C4(261.63) / C3(130.81)
    DATA 190,381,762    ' D5(587.33) / D4(293.66) / D3(146.83)
    DATA 214,428,855    ' C5(523.25) / C4(261.63) / C3(130.81)
    DATA 254,508,1017   ' A4(440.00) / A3(220.00) / A2(110.00)
    DATA 285,571,1141   ' G4(392.00) / G3(196.00) / G2(98.00)

MelodyDataPAL:
    DATA 358,716,1432   ' F4(349.23) / F3(174.61) / F2(87.31)
    DATA 319,638,1276   ' G4(392.00) / G3(196.00) / G2(98.00)
    DATA 284,568,1136   ' A4(440.00) / A3(220.00) / A2(110.00)
    DATA 239,478,956    ' C5(523.25) / C4(261.63) / C3(130.81)
    DATA 213,426,851    ' D5(587.33) / D4(293.66) / D3(146.83)
    DATA 239,478,956    ' C5(523.25) / C4(261.63) / C3(130.81)
    DATA 284,568,1136   ' A4(440.00) / A3(220.00) / A2(110.00)
    DATA 319,638,1276   ' G4(392.00) / G3(196.00) / G2(98.00)
