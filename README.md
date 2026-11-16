# MIBCartI
Cartucho Everdrive Intellivision

## Introdução
Cartucho Everdrive baseado no hardware com a Raspberry Pi Pico2 RP2350 do projeto PiRTOII-Duo (https://github.com/aotta/PiRTOIIDuo),
e no firmware do projeto Minty (https://github.com/gtortone/Minty)

## Recursos
Funciona nos consoles originais Intellivision 1 ou 2.
Roda os jogos diretamente do cartão de memória Micro SD.
Suporta arquivos organizados em pastas, nos formatos: .ROM ou .BIN, .INT, .ITV ou .MIB + .CFG
Suporta recurso estendidos JLP.
Emulação do sintetizador de voz IntelliVoice, emulação de som ECS.
Todas as mensagens da interface estão em português.
Tem integrado o Teste de controles, teste de cores de vídeo, teste e ajuste de volume de som ECS / IntelliVoice emulado.

## Compilação
Developer Command Prompt for VS 2022
rmdir /s /q build
cmake -G Ninja -B build/pirto_ii_duo/release -DPICO_BOARD=pirto_ii_duo -DCMAKE_BUILD_TYPE=Release
ninja -C build/pirto_ii_duo/release
