# -*- coding: utf-8 -*-

require './exception'
require './board'
require './koma'
require './kyokumen'

require 'pp'

if __FILE__ == $0
  k = Kyokumen.new
  puts te = k.generate_legal_moves(:sente)
  pp te.size
end
