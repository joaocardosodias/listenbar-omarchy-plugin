# Listenbar para Omarchy

O Listenbar mostra o nome da faixa na barra do Omarchy. Clique no nome para
abrir um painel com a capa, os dados da faixa, o progresso e os controles de
reprodução. O widget usa MPRIS, a interface de mídia padrão do Linux.

É compatível com Spotify para Linux, Spotifast/Fastpotify, YouTube e YouTube
Music reproduzidos em navegadores que publiquem MPRIS, além de outros players
Linux compatíveis.

> O Omarchy 4 desenha a barra pelo Omarchy Shell/Quickshell. O Listenbar é um
> plugin desse shell, não um módulo da Waybar tradicional.

## Recursos

- Mostra somente o nome da faixa na barra, com rolagem para títulos longos.
- Abre o painel ao clicar no widget; as fontes de áudio aparecem em abas no
  topo, com larguras iguais.
- Exibe capa, título, artista, tempo decorrido, duração e barra de progresso.
- Permite voltar, pausar/retomar, avançar e buscar uma posição na faixa.
- Tem um botão junto ao título para abrir a mídia ou trazer a janela do player
  para o workspace atual.
- Mostra um indicador giratório discreto enquanto Matugen ou `yt-dlp` está
  processando a capa ou a duração da faixa.
- Gera o fundo e a borda do painel com Matugen usando as cores da capa.
- Mantém as cores atuais enquanto Matugen processa a capa seguinte, evitando
  uma troca temporária para as cores do tema.
- Recupera a duração de vídeos do YouTube pelo título quando o Firefox não a
  envia pelo MPRIS.
- Seleciona automaticamente o player em reprodução ou permite escolher uma
  preferência nas configurações do widget.

## Requisitos

- Omarchy 4 ou superior e um player que publique dados MPRIS.
- `matugen` para gerar as cores do painel a partir da capa.
- `yt-dlp` para recuperar a duração de vídeos quando o Firefox não fornece esse
  dado.

Instale as dependências pelo Omarchy:

```bash
omarchy pkg add matugen yt-dlp
```

Não é necessário instalar `playerctl` nem uma extensão do Spotify.

## Instalação

```bash
omarchy plugin add https://github.com/joaocardosodias/listenbar-omarchy-plugin.git --enable
```

O widget é colocado no centro da barra por padrão. Para movê-lo, por exemplo,
para a direita:

```bash
omarchy bar move io.github.joaocardosodias.listenbar --section right
```

Atualize uma instalação existente com:

```bash
omarchy plugin update io.github.joaocardosodias.listenbar
```

## Controles

| Ação | Resultado |
| --- | --- |
| Clique esquerdo no nome da faixa | Abre ou fecha o painel |
| Clique direito | Pausa ou retoma a reprodução |
| Roda para cima | Faixa anterior |
| Roda para baixo | Próxima faixa |
| Clique ou arraste na barra de progresso | Busca a posição escolhida |
| Clique em uma aba | Seleciona aquela fonte de áudio |
| Botão ao lado do título | Abre a mídia no navegador/player e traz a janela para o workspace atual |

As configurações do widget permitem escolher Automático, Spotify, Spotifast ou
Navegador/YouTube, ocultar o widget quando não houver mídia e ajustar a largura
máxima do título.

## YouTube no navegador

O Firefox e navegadores baseados em Chromium podem publicar a faixa ativa pelo
MPRIS. Se o vídeo não aparecer, verifique se a integração de mídia do navegador
está habilitada e se há um player MPRIS:

```bash
busctl --user list | grep org.mpris.MediaPlayer2
```

Algumas versões/configurações do Firefox não enviam a duração ou a posição da
faixa. Nesses casos, o Listenbar usa `yt-dlp` para encontrar a duração pelo
título e artista, e mantém o contador avançando localmente durante a reprodução.
Esse fallback depende de `yt-dlp` e de o título identificar um resultado
correspondente no YouTube. Após buscar uma posição no Firefox, o widget mantém
essa posição localmente porque algumas versões do navegador passam a reportar
zero pelo MPRIS mesmo com a reprodução ativa.

## Desenvolvimento

Valide o manifesto, os scripts, os helpers e o QML com:

```bash
omarchy plugin validate .
bash -n scripts/generate-palette scripts/media-duration
node tests/model.test.js
qmllint -I /usr/share/omarchy/shell Main.qml ThemedPopupCard.qml
```

O shell recarrega plugins locais editados em
`~/.config/omarchy/plugins/`. Para solicitar uma nova varredura:

```bash
omarchy-shell shell rescanPlugins
```

## Remoção

```bash
omarchy plugin remove io.github.joaocardosodias.listenbar
```

## Licença

[MIT](LICENSE)
