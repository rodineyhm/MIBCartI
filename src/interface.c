
#include <stdbool.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h" // Garante acesso às funções nativas de GPIO do SDK

#include "board.h"
#include "interface.h"

/*
void resetCart(void) {
   gpio_init(MSYNC);
   gpio_set_dir(MSYNC, false);
   gpio_set_pulls(MSYNC, false, true);
   gpio_put(LED, false);

   resetHigh();
   sleep_ms(30);                // was 20 for Model II; 30 works for both

   resetLow();
   sleep_ms(1);                 // was 1 for Model II; 

   resetHigh();
   gpio_put(LED, true);
}
*/

//MIBCart

void resetCart(void) {
   // --- INÍCIO DA CORREÇÃO PARA O RP2350 (ERRATA E9 NOS PINOS BC1 E BC2) ---
   gpio_init(BC1);
   gpio_init(BC2);
  
   gpio_set_dir(BC1, false); // Configura como Entrada
   gpio_set_dir(BC2, false); // Configura como Entrada  

   // Desativa pull-ups e pull-downs internos para evitar a trava de tensão fantasma
   gpio_set_pulls(BC1, false, false);
   gpio_set_pulls(BC2, false, false);

   // WORKAROUND DA ERRATA E9 USANDO COMANDOS NATIVOS DO SDK:
   // Desativa a histerese (Schmitt Trigger) que causa atraso de sinal nos pinos analógicos
   gpio_set_input_hysteresis_enabled(BC1, false);
   gpio_set_input_hysteresis_enabled(BC2, false);

   // --- FIM DA CORREÇÃO ---

   // Código original mantido integralmente
   gpio_init(MSYNC);
   gpio_set_dir(MSYNC, false);
   gpio_set_pulls(MSYNC, false, true);
   gpio_put(LED, false);

   resetHigh();
   sleep_ms(30);                // was 20 for Model II; 30 works for both

   resetLow();
   sleep_ms(1);                 // was 1 for Model II; 

   resetHigh();
   gpio_put(LED, true);
}









