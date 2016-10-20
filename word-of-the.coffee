options =
  type         : 'adjective' # Part of Speech (noun, adverb, adjective, and so on...)
  frequencymax : '4.00' # Range from 1.74 - 8.03, with higher numbers being more frequently used words.
  syllablesMin : '3' # Minium syllables to return
  mashapeKey   : 'API_KEY_FROM_MASHAPE' # You'll need an api key linked to https://market.mashape.com/wordsapi/wordsapi

command: ''
refreshFrequency: '1h'

# Initial Render.
render: () -> """
  <div id='word' class='card'></div>
"""

# Update function.
update: (output, domEl) ->
  if !output
    @run(@buildRequest(options.type, options.frequencymax, options.syllablesMin, ''), (error, data) =>
      if !error
        @update(data)
    )
  else
    dom = $(domEl)

    # Parse the JSON created by the shell script.
    data = JSON.parse output

    # Loop through the results in the JSON.
    definitions = []
    similarTos = []
    synonyms = []
    for part in data.results
      if part.partOfSpeech == options.type
        definitions.push(part.definition)
        if part.similarTo
          for similarTo in part.similarTo
            span = "<span>#{ similarTo }</span>"
            similarTos.push(span)
        if part.synonyms
          for synonym in part.synonyms
            span = "<span>#{ synonym }</span>"
            synonyms.push(span)

    # Build the html
    html = "<div class='wrap'>"
    html += "<h1 class='word'>#{ data.word }</h1>"
    html += "<p class='pronunciation'>( #{ data.pronunciation.all } )</p>" if data.pronunciation
    html += "</div>"
    html += "<h2 class='title'>#{ options.type } of the hour</h2>"
    html += "<ul class='definitions d#{ definitions.length }'>"
    for definition in definitions
      html += "<li class='definition'>#{ definition }</li>"
    html += "</ul>"
    if similarTos.length
      html += "<div class='alike'><h3>Similar To:</h3>"
      html += "<p class='alike_words'>#{ similarTos.join(', ') }</p>"
      html += "</div>"
    if synonyms.length
      html += "<div class='alike'><h3>Synonyms:</h3>"
      html += "<p class='alike_words'>#{ synonyms.join(', ') }</p>"
      html += "</div>"

    # Set our output.
    $(word).html(html)

    $('.alike_words span').on 'click', (event) =>
      new_word = event.target.textContent
      @run(@buildRequest('', '', '', new_word), (error, data) =>
          if !error
            @update(data)
      )

buildRequest: (partOfSpeech, frequencymax, syllablesMin, newWord) =>
  request = "curl --get --silent 'https://wordsapiv1.p.mashape.com/words/"
  if newWord != ''
    request += "#{newWord}' "
  else
    request += "?random=true"
    request += "&frequencymax=#{frequencymax}"
    request += "&syllablesMin=#{syllablesMin}"
    request += "&partOfSpeech=#{partOfSpeech}' "
    type = partOfSpeech
  request += "-H 'X-Mashape-Key: #{options.mashapeKey}' -H 'Accept: application/json'"
  return request

# CSS Style
style: """
  right: 20px
  top: 20px
  -webkit-font-smoothing: antialiased
  -moz-osx-font-smoothing: grayscale

  @font-face
    font-family: 'NotoSans'
    src: url('word-of-the.widget/assets/NotoSans-Regular-webfont.woff') format('woff')
    font-weight: normal
    font-style: normal

  @font-face
    font-family: 'NotoSans'
    src: url('word-of-the.widget/assets/NotoSans-Italic-webfont.woff') format('woff')
    font-weight: normal
    font-style: italic

  @font-face
    font-family: 'NotoSans'
    src: url('word-of-the.widget/assets/NotoSans-Bold-webfont.woff') format('woff')
    font-weight: bold

  @font-face
    font-family: 'Klasik Rough'
    src: url('word-of-the.widget/assets/klasik_rough-webfont.woff') format('woff')
    font-weight: normal
    font-style: normal

  .card
    background-image: url("word-of-the.widget/assets/amoebae.png")
    border: 3px solid #434343
    box-shadow: 0px 5px 11px 5px rgba(#1a1a1a, 0.71)
    color: #d0d0d0
    font-family: 'NotoSans'
    margin:0
    width: 560px
    padding: 15px

  p
    margin: 0

  .wrap
    width: 100%
    height: 50px
    display: flex
    justify-content: space-between
    align-items: baseline
    overflow: hidden

  h1.word
    font-family: 'Klasik Rough'
    font-size: 2.6em
    line-height: 50px
    font-weight: normal
    margin: 0

  .pronunciation
    font-size: 1.2em
    font-style: italic

  h2.title
    font-weight: normal
    margin: 0
    font-size: 0.8em
    padding-left: 20px
    text-transform: uppercase

  .definitions
    margin: 0
    padding: 20px 20px 30px 40px
    font-size: 1.4em
    font-style: italic
    list-style: circle outside

  .definitions.d1
    font-size: 1.8em
    list-style: none

  .definitions.d2
    font-size: 1.4em

  .definitions.d3
    font-size: 1em

  .definition:not(:last-child)
    padding-bottom: 15px

  .alike
    display: flex
    justify-content: flex-start
    align-items: flex-start
    width: 100%
    text-transform: uppercase

  .alike:not(:last-child)
    padding-bottom: 15px

  .alike h3
    font-size: 0.8em
    margin: 0
    width: 120px
    padding-right: 10px
    text-align: right
    font-weight: normal

  .alike_words
    font-size: 0.8em
    font-weight: bold
    padding-right: 30px
    width: 410px

  .alike_words span:hover
    cursor: pointer
"""
