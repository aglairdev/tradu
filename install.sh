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

# verifica conectividade
echo -e "${YELLOW}Verificando conexão com o servidor...${RESET}"
if ! curl -s --connect-timeout 5 https://tradu.pages.dev/ > /dev/null; then
    echo -e " ${RED}${CROSS} Erro: Não foi possível alcançar https://tradu.pages.dev${RESET}"
    echo -e " Verifique sua conexão com a internet e tente novamente."
    exit 1
fi
echo -e " ${GREEN}${CHECK} Conexão estabelecida!${RESET}\n"

# detecta o terminal 
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

    # extensões suportadas
    local EXTENSOES=("zip" "rar")
    local EXT_REGEX=$(IFS='|'; echo "${EXTENSOES[*]}")

    # se rodar apenas 'tradu', lista o acervo
    if [ -z "$1" ]; then
        echo -e "${BLU}Traduções disponíveis:${RES}"
        # Filtra linhas .zip, remove tags HTML, aspas, espaços e caracteres de árvore (│, ├──)
        curl -s "$URL_BASE/" | grep -E "\.(${EXT_REGEX})" | sed -E -e 's/<[^>]*>//g' -e "s/['\"]//g" -e 's/[│├─]//g' -e 's/^[ \t]*//'        
        return 0
    fi

    local acao=$1
    local jogo=$2

    # ajusta a ordem caso o usuário digite "tradu jogo -flag"
    if [[ "$acao" != "-d" && "$acao" != "-t" && "$acao" != "-h" && "$acao" != "--help" ]]; then
        jogo=$1; acao=$2
    fi

    # remove a extensão do final do nome do jogo, caso o usuário tenha digitado com ela
    for ext in "${EXTENSOES[@]}"; do
        jogo="${jogo%.$ext}"
    done

    case $acao in
        -d)
            mkdir -p "$DOWNLOAD_DIR"

            local link_direto=$(curl -s "$URL_BASE/" | grep -E "${jogo}\.(${EXT_REGEX})" | sed -E -e 's/.*href="([^"]*)".*/\1/')

            if [ -z "$link_direto" ]; then
                echo -e "${RED_C}✗ Erro ao baixar o arquivo. Verifique se o nome do jogo está correto.${RES}"
                return 1
            fi

            if [[ "$link_direto" != http* ]]; then
                link_direto="${URL_BASE}/${link_direto#/}"
            fi

            # extensão real do arquivo, descoberta a partir do link encontrado
            local extensao="${link_direto##*.}"

            echo -e "${YEL}Baixando $jogo.$extensao para $DOWNLOAD_DIR...${RES}"

            # executa o download com o curl tradicional exibindo a barra de progresso original
            if curl -L "$link_direto" -o "$DOWNLOAD_DIR/$jogo.$extensao"; then
                # Proteção caso o link retornado caia numa página 404/HTML mascarada
                if head -n 1 "$DOWNLOAD_DIR/$jogo.$extensao" | grep -qE -i '<!DOCTYPE|<html'; then
                    echo -e "${RED_C}✗ Erro ao baixar o arquivo. Verifique se o nome do jogo está correto.${RES}"
                    rm -f "$DOWNLOAD_DIR/$jogo.$extensao"
                else
                    echo -e "${GRE}✓ Download concluído com sucesso!${RES}"
                fi
            else
                echo -e "${RED_C}✗ Erro ao baixar o arquivo. Verifique se o nome do jogo está correto.${RES}"
            fi
            ;;
        -t)
            echo -e "${BLU}=== Tutorial para $jogo ===${RES}"
            # mudança de 'status' para 'http_status' para evitar conflito de variável reservada
            local conteudo_tutorial=$(curl -s "$URL_BASE/tutoriais/$jogo.txt")
            local http_status=$(curl -s -o /dev/null -w "%{http_code}" "$URL_BASE/tutoriais/$jogo.txt")
            
            # se o arquivo existe e NÃO for um HTML falso enviado pelo Cloudflare, mostra o tutorial puro
            if [ "$http_status" = "200" ] && ! echo "$conteudo_tutorial" | grep -qE -i '<!DOCTYPE|<html'; then
                echo "$conteudo_tutorial"
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
echo ""
echo -e "O comando ${YELLOW}tradu${RESET} foi adicionado no seu sistema."
echo ""
echo -e "${BLUE}ATALHOS DISPONÍVEIS:${RESET}"
echo ""
echo -e "  ${YELLOW}tradu${RESET}                      -> Lista as traduções"
echo -e "  ${YELLOW}tradu -d [nome-do-jogo]${RESET}    -> Baixa a tradução direto"
echo -e "  ${YELLOW}tradu -t [nome-do-jogo]${RESET}    -> Mostra as instruções"
echo -e "  ${YELLOW}tradu -h${RESET}                   -> Abre a tela de ajuda"
echo ""
echo -e "Para ativar agora sem deslogar, rode: ${YELLOW}source $RC_FILE${RESET}"