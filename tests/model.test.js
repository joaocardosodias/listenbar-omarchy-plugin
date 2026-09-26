const assert = require("node:assert/strict")
const model = require("../Model.js")

function player(overrides = {}) {
  return {
    dbusName: "",
    desktopEntry: "",
    identity: "",
    trackTitle: "",
    trackArtist: "",
    trackAlbum: "",
    trackArtUrl: "",
    isPlaying: false,
    canTogglePlaying: true,
    canPlay: true,
    canPause: true,
    canGoNext: true,
    canGoPrevious: true,
    ...overrides
  }
}

const spotify = player({
  dbusName: "org.mpris.MediaPlayer2.spotify",
  identity: "Spotify",
  trackTitle: "Harder Better Faster Stronger",
  trackArtist: "Daft Punk"
})
const spotifast = player({
  dbusName: "org.mpris.MediaPlayer2.spotifast",
  desktopEntry: "spotifast",
  trackTitle: "Digital Love"
})
const fastpotify = player({
  dbusName: "org.mpris.MediaPlayer2.fastpotify",
  desktopEntry: "fastpotify"
})
const youtube = player({
  dbusName: "org.mpris.MediaPlayer2.firefox.instance_1_2",
  identity: "Firefox",
  trackTitle: "YouTube video",
  isPlaying: true
})

assert.equal(model.isSpotify(spotify), true)
assert.equal(model.isSpotify(spotifast), false)
assert.equal(model.isSpotifast(spotifast), true)
assert.equal(model.isSpotifast(fastpotify), true)
assert.equal(model.isBrowser(youtube), true)

assert.equal(model.selectPlayer([spotify, youtube], "Automático"), youtube)
assert.equal(model.selectPlayer([youtube, spotify], "Spotify"), spotify)
assert.equal(model.selectPlayer([spotify, spotifast], "Spotifast"), spotifast)
assert.equal(model.selectPlayer([spotify, youtube], "Navegador/YouTube"), youtube)
assert.equal(model.selectPlayer([spotify], "Spotifast"), spotify)

assert.equal(model.trackLabel(spotify, true), "Harder Better Faster Stronger  ·  Daft Punk")
assert.equal(model.trackLabel(spotify, false), "Harder Better Faster Stronger")
assert.equal(model.playerLabel(spotifast), "Spotifast")
assert.equal(model.playerTabLabel(spotifast), "Spotifast")
assert.equal(model.playerTabLabel(youtube), "Firefox")
assert.equal(model.playerGlyph(youtube), "󰈹")

assert.equal(model.formatTime(0), "0:00")
assert.equal(model.formatTime(65.9), "1:05")
assert.equal(model.formatTime(3661), "1:01:01")
assert.equal(model.formatTime(-12), "0:00")

console.log("model tests: ok")
