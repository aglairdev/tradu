#!/bin/bash
#
# © 2026 tradu ~ AGL ~ github.com/aglairdev
#

YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
TEAL="\e[38;2;13;148;136m"
RESET="\e[0m"
CHECK="✓"
CROSS="✗"
AGL="ꕤ"

clear
echo ""
echo -e "  ${TEAL}tradu ${AGL}${RESET}\n"
echo -e "  Removendo o comando ${TEAL}tradu${RESET} do seu sistema...\n"

if [ -f "$HOME/.local/bin/tradu" ]; then
    rm -f "$HOME/.local/bin/tradu"
    echo -e "  ${GREEN}${CHECK}${RESET} Removido de: ${YELLOW}$HOME/.local/bin/tradu${RESET}"
else
    echo -e "  Script tradu não encontrado em ${YELLOW}~/.local/bin/${RESET}"
fi

REMOVIDO=false

for RC_FILE in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$RC_FILE" ] && grep -q "# === CONFIG TRADU ===" "$RC_FILE" 2>/dev/null; then
        if [ ! -w "$RC_FILE" ]; then
            echo -e "  ${RED}${CROSS}${RESET} Erro: Sem permissão de escrita em $RC_FILE."
            exit 1
        fi
        if ! sed -i '/# === CONFIG TRADU ===/,/# === FIM TRADU ===/d' "$RC_FILE" 2>/dev/null; then
            echo -e "  ${RED}${CROSS}${RESET} Erro: Falha ao editar $RC_FILE (verifique espaço em disco)."
            exit 1
        fi
        echo -e "  ${GREEN}${CHECK}${RESET} Removido de: ${YELLOW}$RC_FILE${RESET}"
        REMOVIDO=true
    fi
done

if [ "$REMOVIDO" = false ] && [ ! -f "$HOME/.local/bin/tradu" ]; then
    echo -e "  Nenhuma configuração do ${TEAL}tradu${RESET} foi encontrada. Nada a remover.\n"
    exit 0
fi

echo ""
read -p "  Pressione Enter para recarregar o shell..."
exec "$SHELL"