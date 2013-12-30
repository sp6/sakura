# -*- coding: utf-8 -*-

require './lib/shogi'
require './lib/koma'
require './lib/board'
require './lib/kyokumen'
require './lib/evaluator'
require './lib/shikou'
require './lib/human'

require 'pp'

module Kernel
  def loop_with_index
    index = 0
    loop do
      yield index
      index += 1
    end
  end
end

if __FILE__ == $0
=begin
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
  puts shikou.alphabeta(teban, k, 0, 0, 0)
  pp shikou.best_sashite
=end

  players = {
    sente: Shikou.new,
#    sente: Human.new,
    gote: Shikou.new,
#    gote: Human.new
  }
  
  kyokumen = Kyokumen.new(teban: :sente)
  puts kyokumen.to_csa
  teban = :sente
  loop_with_index do |index|
    # 終局判定
    next_te = kyokumen.generate_legal_moves
    if next_te.size == 0
      if teban == :gote
        puts "win sente"
      else
        puts "win gote"
      end
      break
    end
    
    # TODO
    # 千日手判定
    
    te = players[teban].next_te(teban, kyokumen)
    kyokumen.move te
    puts "#{index+1}手目"
    puts kyokumen.to_csa
    teban = (teban == :sente ? :gote : :sente)
    kyokumen.teban = teban
  end
end
