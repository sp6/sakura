# -*- coding: utf-8 -*-

require './lib/shogi'
require './lib/koma'
require './lib/board'
require './lib/kyokumen'
require './lib/shikou'

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
  #k = Kyokumen.new
  #k.ban = Board.new
  k.ban = Board.create(ban)
  k.sente_hand = {
    fu: [], kyosha: [], keima: [], gin: [], kin: [Kin.new(1, :sente)],
    kaku: [], hisha: [Hisha.new(1, :sente)], ou: [] }
  k.gote_hand = {
    fu: [Fu.new(1, :gote), Fu.new(1, :gote), Fu.new(1, :gote),
         Fu.new(1, :gote), Fu.new(1, :gote)],
    kyosha: [], keima: [Keima.new(1, :gote)], gin: [Gin.new(1, :gote)],
    kin: [Kin.new(1, :gote)], kaku: [], hisha: [], ou: []
  }
  teban = :sente
  shikou = Shikou.new
  puts shikou.negamax(teban, k, 0, 0, 0)
  pp shikou.best_sashite
end
