'use strict'

class Player

  # private

  context = new AudioContext()
  sourceNode = undefined

  init = ->
    sourceNode = context.createBufferSource()
    sourceNode.connect context.destination

  loadThenPlay = (song) ->
    request = new XMLHttpRequest()
    request.open 'GET', song.path, true
    request.responseType = 'arraybuffer'

    request.onload = ->
      context.decodeAudioData request.response, (buffer) ->
        playSound buffer
      , onError
    request.send()

  playSound = (buffer) ->
    sourceNode.buffer = buffer
    sourceNode.start 0

  onError = (e) ->
    console.log e

  # public

  constructor: (@playlist) ->
    init()

  playRandom: ->
    loadThenPlay @playlist[0]


unless window.AudioContext
  unless window.webkitAudioContext
    alert('Audiocontext not found')
  window.AudioContext = window.webkitAudioContext

new Player [
  { path: 'media/drink.mp3', title: 'Alestorm - Drink' }
]
.playRandom()