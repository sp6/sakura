# -*- coding: utf-8 -*-

require './lib/shogi'
require './lib/koma'
require './lib/board'
require './lib/kyokumen'

require 'pp'

if __FILE__ == $0
  ban = [[:empty, :empty, :empty, :empty, :ehisha, :empty, :empty, :empty, :empty],
         [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
         [:empty, :empty, :empty, :empty, :fu, :empty, :ehisha, :ryu, :empty],
         [:empty, :empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty],
         [:empty, :empty, :empty, :empty, :ou, :empty, :empty, :empty, :empty],
         [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
         [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
         [:empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty, :empty],
         [:empty, :empty, :empty, :empty, :ehisha, :empty, :empty, :empty, :empty]]
  k = Kyokumen.new
  k.ban = Board.create(ban)
  #  pins = k.search_pins :sente
  puts te = k.generate_legal_moves(:gote)
  pp te.size
end
