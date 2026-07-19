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
echo -e "  Verificando conexão com o servidor..."
if ! curl -s --connect-timeout 5 https://tradu.pages.dev/ > /dev/null; then
    echo -e "  ${RED}${CROSS}${RESET} Erro: Não foi possível alcançar https://tradu.pages.dev"
    echo -e "  Verifique sua conexão com a internet e tente novamente."
    exit 1
fi
echo -e "  ${GREEN}${CHECK}${RESET} Conexão estabelecida!\n"

case "$SHELL" in
    */zsh)
        RC_FILE="$HOME/.zshrc"
        ;;
    */bash)
        RC_FILE="$HOME/.bashrc"
        ;;
    *)
        RC_FILE="$HOME/.bashrc"
        ;;
esac

echo -e "  Configurando o comando ${TEAL}tradu${RESET}..."
echo -e "  ${GREEN}${CHECK}${RESET} PATH configurado em: ${YELLOW}$RC_FILE${RESET}\n"

if [ ! -w "$HOME" ]; then
    echo -e "  ${RED}${CROSS}${RESET} Erro: Sem permissão de escrita no diretório root do usuário ($HOME)."
    exit 1
fi

mkdir -p "$HOME/.local/bin"

echo -e "  Baixando script tradu..."
if ! curl -sL https://raw.githubusercontent.com/aglairdev/tradu/main/tradu -o "$HOME/.local/bin/tradu"; then
    echo -e "  ${RED}${CROSS}${RESET} Erro: Falha ao baixar o script tradu."
    exit 1
fi
chmod +x "$HOME/.local/bin/tradu"
echo -e "  ${GREEN}${CHECK}${RESET} Script instalado em: ${YELLOW}$HOME/.local/bin/tradu${RESET}\n"

touch "$RC_FILE"
sed -i '/# === CONFIG TRADU ===/,/# === FIM TRADU ===/d' "$RC_FILE" 2>/dev/null

if ! grep -q '# === CONFIG TRADU ===' "$RC_FILE" 2>/dev/null; then
    if ! cat << 'EOF' >> "$RC_FILE"

# === CONFIG TRADU ===
[ -d "$HOME/.local/bin" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
# === FIM TRADU ===
EOF
    then
        echo -e "  ${RED}${CROSS}${RESET} Erro crítico: Falha ao escrever as variáveis no arquivo $RC_FILE."
        exit 1
    fi
fi

echo -e "  O comando ${TEAL}tradu${RESET} foi adicionado no seu sistema.\n"
echo -e "  ┌──────────────────────────────────────────────────┐"
echo -e "  │                                                  │"
echo -e "  │  Atalhos:                                        │"
echo -e "  │                                                  │"
echo -e "  │  ${TEAL}tradu${RESET}                       : Lista             │"
echo -e "  │  ${TEAL}tradu${RESET} -d [nome-do-jogo]     : Baixa             │"
echo -e "  │  ${TEAL}tradu${RESET} -t [nome-do-jogo]     : Tutoriais         │"
echo -e "  │  ${TEAL}tradu${RESET} -h                    : Ajuda             │"
echo -e "  │                                                  │"
echo -e "  └──────────────────────────────────────────────────┘"
echo ""
read -p "  Pressione Enter para recarregar o shell..."
exec "$SHELL"