# -*- coding: utf-8 -*-

require './lib/shogi'
require './lib/koma'
require './lib/board'
require './lib/kyokumen'

require 'pp'

if __FILE__ == $0
  ban = [[:ekyosha, :empty, :empty, :empty, :empty, :empty, :empty, :ekeima, :ekyosha],
         [:empty, :empty, :empty, :empty, :empty, :to, :empty, :ekin, :eou],
         [:empty, :empty, :ekeima, :efu, :empty, :gin, :empty, :empty, :empty],
         [:efu, :empty, :efu, :empty, :empty, :empty, :empty, :fu, :efu],
         [:empty, :empty, :empty, :fu, :empty, :empty, :gin, :efu, :empty],
         [:empty, :fu, :fu, :ekaku, :empty, :empty, :fu, :empty, :fu],
         [:fu, :empty, :empty, :empty, :empty, :empty, :kin, :gin, :empty],
         [:hisha, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
         [:kyosha, :keima, :empty, :empty, :empty, :empty, :ekaku, :ou, :kyosha]]
  k = Kyokumen.new
  k.ban = Board.create(ban)
  k.sente_hand = { fu: [], kyosha: [], keima: [], gin: [],
    kin: [Kin.new], kaku: [], hisha: [Hisha.new] }
  k.gote_hand = { fu: [Fu.new, Fu.new, Fu.new, Fu.new, Fu.new], kyosha: [],
    keima: [Keima.new], gin: [Gin.new], kin: [Kin.new], kaku: [], hisha: [] }
  #pins = k.search_pins :sente
  puts te = k.generate_legal_moves(:sente)
  pp te.size
end
