#!/bin/bash

YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
RESET="\e[0m"
CHECK="✓"
CROSS="✗"
AGL="ꕤ"

clear

echo -e "${BLUE}Tradu ${AGL}${RESET}"

#  verifica conectividade
echo -e "${YELLOW}Verificando conexão com o servidor...${RESET}"
if ! curl -s --connect-timeout 5 https://tradu.pages.dev/ > /dev/null; then
    echo -e " ${RED}${CROSS} Erro: Não foi possível alcançar https://tradu.pages.dev${RESET}"
    echo -e " Verifique sua conexão com a internet e tente novamente."
    exit 1
fi
echo -e " ${GREEN}${CHECK} Conexão estabelecida!${RESET}\n"

# detecta o terminal 
if [ -n "$ZSH_VERSION" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    RC_FILE="$HOME/.bashrc"
else
    RC_FILE="$HOME/.bashrc"
fi

echo -e "${YELLOW}Configurando o comando 'tradu' em: ${BLUE}$RC_FILE${RESET}"

# permissão de escrita
if [ ! -w "$HOME" ]; then
    echo -e " ${RED}${CROSS} Erro: Sem permissão de escrita no diretório root do usuário ($HOME).${RESET}"
    exit 1
fi

# garante que o arquivo exista antes de mexer nele
touch "$RC_FILE"

# remove duplicados
if ! sed -i '/# === CONFIG TRADU ===/,/# === FIM TRADU ===/d' "$RC_FILE" 2>/dev/null; then
    echo -e " ${RED}${CROSS} Erro: Falha ao limpar configurações antigas usando o comando 'sed'.${RESET}"
    echo -e " Certifique-se de que seu sistema possui o utilitário 'sed' instalado."
    exit 1
fi

if ! cat << 'EOF' >> "$RC_FILE"

# === CONFIG TRADU ===
tradu() {
    local URL_BASE="https://tradu.pages.dev"
    local DOWNLOAD_DIR="$HOME/Downloads"
    
    # Cores internas da função
    local YEL="\e[33m"
    local GRE="\e[32m"
    local RED_C="\e[31m"
    local BLU="\e[34m"
    local RES="\e[0m"

    # Se rodar apenas 'tradu', lista o acervo
    if [ -z "$1" ]; then
        echo -e "${BLU}Traduções disponíveis:${RES}"
        # Filtra apenas as linhas com links/arquivos e limpa as tags HTML do index
        curl -s "$URL_BASE/" | grep -E '\.zip' | sed -e 's/<[^>]*>//g' -e 's/^[ \t]*//'
        return 0
    fi

    local acao=$1
    local jogo=$2

    # Ajusta a ordem caso o usuário digite "tradu jogo -flag"
    if [[ "$acao" != "-d" && "$acao" != "-t" && "$acao" != "-h" && "$acao" != "--help" ]]; then
        jogo=$1; acao=$2
    fi

    case $acao in
        -d)
            echo -e "${YEL}Baixando $jogo.zip para $DOWNLOAD_DIR...${RES}"
            mkdir -p "$DOWNLOAD_DIR"
            if curl -L "$URL_BASE/arquivos/$jogo.zip" -o "$DOWNLOAD_DIR/$jogo.zip"; then
                echo -e "${GRE}✓ Download concluído com sucesso!${RES}"
            else
                echo -e "${RED_C}✗ Erro ao baixar o arquivo. Verifique se o nome do jogo está correto.${RES}"
            fi
            ;;
        -t)
            echo -e "${BLU}=== Tutorial para $jogo ===${RES}"
            local status=$(curl -s -o /dev/null -w "%{http_code}" "$URL_BASE/tutoriais/$jogo.txt")
            if [ "$status" = "200" ]; then
                curl -s "$URL_BASE/tutoriais/$jogo.txt"
            else
                echo -e "${YEL}[Aviso: Sem tutorial específico. Exibindo tutorial genérico]${RES}"
                curl -s "$URL_BASE/tutoriais/generico.txt"
            fi
            echo ""
            ;;
        -h|--help)
            echo -e "${BLU}TRADU - AJUDA${RES}"
            echo -e "  tradu                      : Lista todos os jogos do acervo"
            echo -e "  tradu -d [nome-do-jogo]    : Baixa o .zip em ~/Downloads"
            echo -e "  tradu -t [nome-do-jogo]    : Exibe o tutorial"
            echo -e "  tradu -h | --help          : Exibe atalhos"
            ;;
        *)
            echo -e "${RED_C}Opção inválida.${RES} Digite '${YEL}tradu -h${RES}' para ver as opções disponíveis."
            ;;
    esac
}
# === FIM TRADU ===
EOF
then
    echo -e " ${RED}${CROSS} Erro crítico: Falha ao escrever as variáveis no arquivo $RC_FILE.${RESET}"
    exit 1
fi

clear
echo -e "${GREEN}${CHECK} CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!${RESET}"
echo -e "O comando '${YELLOW}tradu${RESET}' foi adicionado com sucesso no seu sistema."
echo ""
echo -e "${BLUE}ATALHOS DISPONÍVEIS:${RESET}"
echo -e "  ${YELLOW}tradu${RESET}                      -> Lista apenas as traduções"
echo -e "  ${YELLOW}tradu -d [nome-do-jogo]${RESET}    -> Baixa a tradução direto"
echo -e "  ${YELLOW}tradu -t [nome-do-jogo]${RESET}    -> Mostra as instruções"
echo -e "  ${YELLOW}tradu -h${RESET}                   -> Abre a tela de ajuda"
echo ""
echo -e "Para ativar agora sem deslogar, rode: ${YELLOW}source $RC_FILE${RESET}"