require 'rack'
require './surfing_app'

surfing_app = Surfing.new
run surfing_app