# Tradu ꕤ
Traduções **pt-br** de jogos para backup pessoal. 

Site: [tradu.pages.dev](https://tradu.pages.dev/)

## Atalhos shell
Para configurar atalhos de acesso direto no terminal (detecta bash/zsh automaticamente).
```bash
curl -sSL tradu.pages.dev/install.sh | bash
```
Pra ativar sem abrir um terminal novo:
```bash
source ~/.bashrc   # ~/.zshrc
```

| Atalho | Comando |
| :--- | :--- |
| **Lista as traduções** | `tradu` |
| **Baixa a tradução direto (.zip/.rar)** | `tradu -d [nome-do-jogo]` |
| **Mostra as instruções** | `tradu -t [nome-do-jogo]` |
| **Abre a tela de ajuda** | `tradu -h` |

## Remoção de atalhos
```bash
for f in ~/.bashrc ~/.zshrc; do sed -i '/# === CONFIG TRADU ===/,/# === FIM TRADU ===/d' "$f" 2>/dev/null; done; exec $SHELL
```

## Créditos
Os créditos constam nas [releases](https://github.com/aglairdev/Tradu/releases) e diretamente no site [tradu.pages.dev](https://tradu.pages.dev/).