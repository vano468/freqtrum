'use strict'

class Drawler

  constructor: ->
    @ctx = $('#canvas').get()[0].getContext '2d'

    @gradient = @ctx.createLinearGradient 0, 0, 0, 300
    @gradient.addColorStop 1,    '#000000'
    @gradient.addColorStop 0.75, '#ff0000'
    @gradient.addColorStop 0.25, '#ffff00'
    @gradient.addColorStop 0,    '#ffffff'

  setTitle: (title) ->
    $('#title').text title

  drawSpectrum: (array) ->
    @ctx.clearRect 0, 0, 1000, 325
    @ctx.fillStyle = @gradient
    for value, i in array
      @ctx.fillRect i * 5, 325-value, 4, 325


class Player

  # private

  context = new AudioContext()
  drawler = new Drawler()
  sourceNode = undefined
  analyser   = undefined
  javascriptNode = undefined

  init = ->
    javascriptNode = context.createScriptProcessor 2048, 1, 1
    javascriptNode.connect context.destination

    analyser = context.createAnalyser()
    analyser.smoothingTimeConstant = 0.3
    analyser.fftSize = 512

    sourceNode = context.createBufferSource()
    sourceNode.connect analyser
    analyser.connect javascriptNode
    sourceNode.connect context.destination

    javascriptNode.onaudioprocess = ->
      data = new Uint8Array analyser.frequencyBinCount
      analyser.getByteFrequencyData data
      drawler.drawSpectrum data

  loadThenPlay = (song) ->
    request = new XMLHttpRequest()
    request.open 'GET', song.path, true
    request.responseType = 'arraybuffer'

    request.onload = ->
      context.decodeAudioData request.response, (buffer) ->
        drawler.setTitle song.title
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
    loadThenPlay @playlist[Math.floor(Math.random() * @playlist.length)]


unless window.AudioContext
  unless window.webkitAudioContext
    alert 'Audiocontext not found'
  window.AudioContext = window.webkitAudioContext

new Player [
  { path: 'media/drink.mp3', title: 'Alestorm - Drink' }
  { path: 'media/survives.mp3', title: 'Nekrogoblikon - No One Survives' }
  { path: 'media/tequila.mp3', title: 'Korpiklaani - Tequila' }
  { path: 'media/everything.mp3', title: 'Derdian - In Everything' }
  { path: 'media/speedhoven.mp3', title: 'Edguy - Speedhoven' }
  { path: 'media/eternity.mp3', title: 'Freedom Call - Beyond Eternity' }
]
.playRandom()