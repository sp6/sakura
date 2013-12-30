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
