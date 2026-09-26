# Listenbar para Omarchy

Um widget de mídia discreto para a barra do Omarchy. A barra mostra somente o
nome da faixa; um clique abre um painel com capa, artista, posição, duração e
controles de reprodução. Ele usa MPRIS, a interface de mídia padrão do Linux,
e funciona com:

- Spotify para Linux;
- Spotifast (e o nome antigo Fastpotify);
- YouTube, YouTube Music e outros sites reproduzidos em navegadores com MPRIS;
- outros players Linux que publiquem metadados MPRIS.

> O Omarchy 4 usa o Omarchy Shell/Quickshell para desenhar a barra. Embora ela
> cumpra o papel da Waybar, este plugin segue o formato nativo atual do Omarchy.

## Recursos

- somente o nome da faixa na barra, com rolagem suave para nomes longos;
- abas no topo do painel para alternar entre as fontes de áudio;
- painel compacto com capa, título, artista e álbum;
- posição, duração e barra de progresso clicável dentro do painel;
- botões de faixa anterior, play/pause e próxima faixa dentro do painel;
- lista de players disponíveis;
- clique esquerdo para abrir ou fechar o painel;
- clique direito como atalho para play/pause;
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
| Clique esquerdo no nome da faixa | Abre ou fecha o painel |
| Clique direito | Play/pause |
| Roda para cima | Faixa anterior |
| Roda para baixo | Próxima faixa |
| Clique na barra de progresso do painel | Avança para o ponto escolhido |

As opções do widget permitem escolher o player preferido, ocultar o widget
quando não há mídia e ajustar a largura máxima do título.

### YouTube no navegador

Chrome/Chromium e Firefox normalmente expõem a mídia ao MPRIS
automaticamente. Se o YouTube não aparecer, confira se a integração de mídia
do navegador não foi desativada e teste se o player aparece em:

```bash
busctl --user list | grep org.mpris.MediaPlayer2
```

### Mais de um player aberto

O modo **Automático** prioriza o player que está tocando. Quando há mais de uma
fonte de áudio, elas aparecem como abas no topo do painel. Clique em uma aba
para fixar aquele player temporariamente. Também é possível escolher Spotify,
Spotifast ou navegador/YouTube nas configurações do widget.

## Desenvolvimento

Valide o plugin e execute os testes do modelo com:

```bash
omarchy plugin validate .
node tests/model.test.js
qmllint -I /usr/share/omarchy/shell Main.qml
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
