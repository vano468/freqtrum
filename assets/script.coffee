'use strict'

class Drawler

  hot = new chroma.ColorScale
    colors: ['#000000', '#ff0000', '#ffff00', '#ffffff']
    positions: [0, .25, .75, 1]
    mode: 'rgb'
    limits: [0, 300]

  config =
    frqBased:
      width: 1000
      height: 330
    timeBased:
      width: 999
      height: 330

  # init for frequency based
  ctxFrqBased = $('#frequency-based').get()[0].getContext '2d'

  gradient = ctxFrqBased.createLinearGradient 0, 0, 0, 300
  gradient.addColorStop 1,    '#000000'
  gradient.addColorStop 0.75, '#ff0000'
  gradient.addColorStop 0.25, '#ffff00'
  gradient.addColorStop 0,    '#ffffff'

  # init for time based
  ctxTimeBased = $("#time-based").get()[0].getContext '2d'

  tempCanvasTimeBased = document.createElement 'canvas'
  tempCtxTimeBased = tempCanvasTimeBased.getContext '2d'
  tempCanvasTimeBased.width  = config.timeBased.width
  tempCanvasTimeBased.height = config.timeBased.height

  setTitle: (title) ->
    $('#title').text title

  setVisibility: ->
    $('#time-based').css 'display', 'block'

  drawFrequencyBased: (array) ->
    ctxFrqBased.clearRect 0, 0,
      config.frqBased.width, config.frqBased.height
    ctxFrqBased.fillStyle = gradient
    for value, i in array
      ctxFrqBased.fillRect i * 5, config.frqBased.height - value,
        4, config.frqBased.height

  drawTimeBased: (array) ->
    canvas = document.getElementById 'time-based'
    tempCtxTimeBased.drawImage canvas, 0, 0,
      config.timeBased.width, config.timeBased.height

    for value, i in array
      ctxTimeBased.fillStyle = hot.getColor(value).hex()
      ctxTimeBased.fillRect config.timeBased.width - 1,
        config.timeBased.height - i, 1, 1

    ctxTimeBased.translate -1, 0
    ctxTimeBased.drawImage tempCanvasTimeBased,
      0, 0, config.timeBased.width, config.timeBased.height,
      0, 0, config.timeBased.width, config.timeBased.height
    ctxTimeBased.setTransform 1, 0, 0, 1, 0, 0


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
    analyser.fftSize = 1024

    sourceNode = context.createBufferSource()
    sourceNode.connect analyser
    analyser.connect javascriptNode
    sourceNode.connect context.destination

    javascriptNode.onaudioprocess = ->
      data = new Uint8Array analyser.frequencyBinCount
      analyser.getByteFrequencyData data
      drawler.drawFrequencyBased data
      drawler.drawTimeBased data

  loadThenPlay = (song) ->
    request = new XMLHttpRequest()
    request.open 'GET', song.path, true
    request.responseType = 'arraybuffer'

    request.onload = ->
      context.decodeAudioData request.response, (buffer) ->
        drawler.setTitle song.title
        drawler.setVisibility()
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
    @currentPlaying = 0
    init()

  playRandom: ->
    @currentPlaying = Math.floor(Math.random() * @playlist.length)
    loadThenPlay @playlist[@currentPlaying]

  playNext: ->
    @currentPlaying++
    @currentPlaying = 0 if @currentPlaying >= @playlist.length
    loadThenPlay @playlist[@currentPlaying]


unless window.AudioContext
  unless window.webkitAudioContext
    alert 'Audiocontext not found'
  window.AudioContext = window.webkitAudioContext

player = new Player [
  { path: 'media/drink.mp3', title: 'Alestorm - Drink' }
  { path: 'media/survives.mp3', title: 'Nekrogoblikon - No One Survives' }
  { path: 'media/everything.mp3', title: 'Derdian - In Everything' }
  { path: 'media/attero.mp3', title: 'Sabaton - Attero Dominatus' }
  { path: 'media/eternity.mp3', title: 'Freedom Call - Beyond Eternity' }
]
player.playRandom()

$(document).keydown (e) ->
  player.playNext() if e.keyCode == 13