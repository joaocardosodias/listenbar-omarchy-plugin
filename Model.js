// Pure helpers kept separate from the QML view so player selection and text
// formatting can be tested without a running shell.

function text(value) {
  return String(value || "").toLowerCase()
}

function playerKey(player) {
  if (!player) return ""
  return String(player.dbusName || player.desktopEntry || player.identity || "")
}

function playerSearchText(player) {
  if (!player) return ""
  return [player.dbusName, player.desktopEntry, player.identity].map(text).join(" ")
}

function isProxy(player) {
  return playerSearchText(player).indexOf("playerctld") !== -1
}

function isSpotifast(player) {
  var haystack = playerSearchText(player)
  return haystack.indexOf("spotifast") !== -1 || haystack.indexOf("fastpotify") !== -1
}

function isSpotify(player) {
  if (isSpotifast(player)) return false
  return playerSearchText(player).indexOf("spotify") !== -1
}

function isBrowser(player) {
  var haystack = playerSearchText(player)
  var names = ["chromium", "chrome", "brave", "firefox", "zen", "vivaldi", "edge"]
  for (var i = 0; i < names.length; i++) {
    if (haystack.indexOf(names[i]) !== -1) return true
  }
  return false
}

function hasTrack(player) {
  return !!(player && (player.trackTitle || player.trackArtist || player.trackAlbum || player.trackArtUrl))
}

function canControl(player) {
  return !!(player && (player.canTogglePlaying || player.canPlay || player.canPause
    || player.canGoNext || player.canGoPrevious))
}

function matchesPreference(player, preference) {
  var choice = text(preference)
  if (!choice || choice === "automatic" || choice.indexOf("autom") === 0) return true
  if (choice === "spotify") return isSpotify(player)
  if (choice === "spotifast") return isSpotifast(player)
  if (choice.indexOf("browser") !== -1 || choice.indexOf("navegador") !== -1
      || choice.indexOf("youtube") !== -1) return isBrowser(player)
  return true
}

function playerScore(player, preference) {
  if (!player) return -1
  var score = 0
  if (player.isPlaying) score += 1000
  if (hasTrack(player)) score += 200
  if (player.trackArtUrl) score += 30
  if (canControl(player)) score += 20
  if (!isProxy(player)) score += 10
  if (matchesPreference(player, preference)) score += 500
  return score
}

function usablePlayers(players) {
  var input = players && players.length !== undefined ? players : []
  var output = []
  for (var i = 0; i < input.length; i++) {
    if (input[i] && (hasTrack(input[i]) || canControl(input[i]))) output.push(input[i])
  }
  return output
}

function findByKey(players, key) {
  if (!key) return null
  var list = usablePlayers(players)
  for (var i = 0; i < list.length; i++) {
    if (playerKey(list[i]) === key) return list[i]
  }
  return null
}

function selectPlayer(players, preference) {
  var list = usablePlayers(players)
  if (!list.length) return null

  var preferred = []
  for (var i = 0; i < list.length; i++) {
    if (matchesPreference(list[i], preference)) preferred.push(list[i])
  }
  var candidates = preferred.length ? preferred : list
  var winner = candidates[0]
  var winnerScore = playerScore(winner, preference)

  for (var j = 1; j < candidates.length; j++) {
    var score = playerScore(candidates[j], preference)
    if (score > winnerScore) {
      winner = candidates[j]
      winnerScore = score
    }
  }
  return winner
}

function playerLabel(player) {
  if (!player) return "Nenhum player"
  if (isSpotifast(player)) return "Spotifast"
  if (isSpotify(player)) return "Spotify"
  if (isBrowser(player)) {
    var browser = String(player.identity || player.desktopEntry || "Navegador")
    return "YouTube / " + browser
  }
  return String(player.identity || player.desktopEntry || playerKey(player) || "Player")
}

function playerGlyph(player) {
  if (isSpotifast(player) || isSpotify(player)) return ""
  if (isBrowser(player)) return ""
  return "󰝚"
}

function trackLabel(player, showArtist) {
  if (!player) return ""
  var title = String(player.trackTitle || "")
  var artist = String(player.trackArtist || "")
  if (!title) return artist
  if (!showArtist || !artist) return title
  return title + "  ·  " + artist
}

function formatTime(seconds) {
  var total = Math.max(0, Math.floor(Number(seconds) || 0))
  var hours = Math.floor(total / 3600)
  var minutes = Math.floor((total % 3600) / 60)
  var secs = total % 60
  if (hours > 0) return hours + ":" + pad(minutes) + ":" + pad(secs)
  return minutes + ":" + pad(secs)
}

function pad(value) {
  return value < 10 ? "0" + value : String(value)
}

if (typeof module !== "undefined") {
  module.exports = {
    playerKey: playerKey,
    isProxy: isProxy,
    isSpotifast: isSpotifast,
    isSpotify: isSpotify,
    isBrowser: isBrowser,
    hasTrack: hasTrack,
    canControl: canControl,
    matchesPreference: matchesPreference,
    playerScore: playerScore,
    usablePlayers: usablePlayers,
    findByKey: findByKey,
    selectPlayer: selectPlayer,
    playerLabel: playerLabel,
    playerGlyph: playerGlyph,
    trackLabel: trackLabel,
    formatTime: formatTime
  }
}
