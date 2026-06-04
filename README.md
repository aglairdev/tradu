# Tradu ꕤ

Traduções **pt-br** de jogos para backup pessoal. 

Site: [tradu.pages.dev](https://tradu.pages.dev/)

## Atalhos shell

Para configurar atalhos de acesso direto no terminal.

```bash
curl -sSL tradu.pages.dev/install.sh | bash
```

```bash
source ~/.bashrc
```

| Atalho | Comando |
| :--- | :--- |
| **Lista as traduções** | `tradu` |
| **Baixa a tradução direto** | `tradu -d [nome-do-jogo]` |
| **Mostra as instruções** | `tradu -t [nome-do-jogo]` |
| **Abre a tela de ajuda** | `tradu -h` |

## Remoção de atalhos

```bash
sed -i '/# === CONFIG TRADU ===/,/# === FIM TRADU ===/d' ~/.bashrc && source ~/.bashrc
```

## Créditos

Os créditos constam nas [releases](https://github.com/aglairdev/Tradu/releases) e diretamente no site [tradu.pages.dev](https://tradu.pages.dev/).