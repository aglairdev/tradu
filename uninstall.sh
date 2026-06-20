#!/bin/bash

YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
TEAL="\e[38;2;13;148;136m"
RESET="\e[0m"
CHECK="✓"
CROSS="✗"
AGL="ꕤ"

clear

echo -e "${TEAL}Tradu ${AGL}${RESET}"

echo -e "${YELLOW}Removendo o comando ${TEAL}tradu${YELLOW} do seu sistema...${RESET}"

REMOVIDO=false

for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$RC_FILE" ] && grep -q "# === CONFIG TRADU ===" "$RC_FILE" 2>/dev/null; then
        if [ ! -w "$RC_FILE" ]; then
            echo -e " ${RED}${CROSS} Erro: Sem permissão de escrita em $RC_FILE.${RESET}"
            exit 1
        fi
        if ! sed -i '/# === CONFIG TRADU ===/,/# === FIM TRADU ===/d' "$RC_FILE" 2>/dev/null; then
            echo -e " ${RED}${CROSS} Erro: Falha ao editar $RC_FILE (verifique espaço em disco).${RESET}"
            exit 1
        fi
        echo -e " ${GREEN}${CHECK} Removido de: $RC_FILE${RESET}"
        REMOVIDO=true
    fi
done

if [ "$REMOVIDO" = false ]; then
    echo -e "${YELLOW}Nenhuma configuração do tradu foi encontrada. Nada a remover.${RESET}"
    exit 0
fi

echo ""
exec "$SHELL"