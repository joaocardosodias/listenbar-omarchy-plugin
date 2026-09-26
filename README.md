# Listenbar para Omarchy

Um widget de mídia para a barra do Omarchy com capa, título, artista, posição,
duração e controles de reprodução. Ele usa MPRIS, a interface de mídia padrão
do Linux, e funciona com:

- Spotify para Linux;
- Spotifast (e o nome antigo Fastpotify);
- YouTube, YouTube Music e outros sites reproduzidos em navegadores com MPRIS;
- outros players Linux que publiquem metadados MPRIS.

> O Omarchy 4 usa o Omarchy Shell/Quickshell para desenhar a barra. Embora ela
> cumpra o papel da Waybar, este plugin segue o formato nativo atual do Omarchy.

## Recursos

- capa da faixa com fallback para o ícone do aplicativo;
- título e artista com rolagem suave para nomes longos;
- posição, duração e barra de progresso clicável;
- botões de faixa anterior, play/pause e próxima faixa;
- painel com capa ampliada e lista de players disponíveis;
- clique esquerdo na faixa para play/pause;
- clique direito para abrir o painel;
- roda do mouse para trocar de faixa;
- seleção automática do player em reprodução;
- preferências editáveis nas configurações da barra do Omarchy.

## Requisitos

- Omarchy 4.0 ou superior;
- um player com suporte a MPRIS.

Não é necessário instalar `playerctl`, extensões do Spotify nem scripts de
consulta em segundo plano.

## Instalação

```bash
omarchy plugin add https://github.com/joaocardosodias/listenbar-omarchy-plugin.git --enable
```

O widget é adicionado ao centro da barra por padrão. Para movê-lo:

```bash
omarchy bar move io.github.joaocardosodias.listenbar --section right
```

Se o plugin já estiver instalado:

```bash
omarchy plugin update io.github.joaocardosodias.listenbar
```

## Uso

| Ação | Resultado |
| --- | --- |
| Clique esquerdo nos dados da faixa | Play/pause |
| Clique direito | Abre ou fecha o painel |
| Roda para cima | Faixa anterior |
| Roda para baixo | Próxima faixa |
| Clique na barra de progresso do painel | Avança para o ponto escolhido |

As opções do widget permitem escolher o player preferido, ocultar o widget
quando não há mídia, ajustar a largura do título e mostrar ou esconder capa,
artista, minutagem, progresso e controles.

### YouTube no navegador

Chrome/Chromium e Firefox normalmente expõem a mídia ao MPRIS
automaticamente. Se o YouTube não aparecer, confira se a integração de mídia
do navegador não foi desativada e teste se o player aparece em:

```bash
busctl --user list | grep org.mpris.MediaPlayer2
```

### Mais de um player aberto

O modo **Automático** prioriza o player que está tocando. No painel, clique em
outro player para fixá-lo temporariamente. Também é possível escolher
Spotify, Spotifast ou navegador/YouTube nas configurações do widget.

## Desenvolvimento

Valide o plugin e execute os testes do modelo com:

```bash
omarchy plugin validate .
node tests/model.test.js
qmllint -I /usr/share/omarchy/shell Main.qml TransportButton.qml
```

Para testar uma cópia local sem alterar os arquivos deste repositório, clone o
repositório para `~/.config/omarchy/plugins/io.github.joaocardosodias.listenbar`
e rode:

```bash
omarchy-shell shell rescanPlugins
omarchy plugin enable io.github.joaocardosodias.listenbar --section center
```

## Remoção

```bash
omarchy plugin remove io.github.joaocardosodias.listenbar
```

## Licença

[MIT](LICENSE)
