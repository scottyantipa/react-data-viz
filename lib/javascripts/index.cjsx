React = require 'react'


Index = React.createClass
  render: ->
    <div>hello</div>

$ ->
  React.render <Index/>, $('body')[0]