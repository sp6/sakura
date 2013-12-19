# -*- coding: utf-8 -*-

class Shikou
  attr_reader :best_sashite

  def initialize
    @best_sashite = Array.new
  end
  
  def negamax(teban, kyokumen, alpha, beta, depth, max_depth=3)
    other_teban = (teban == :sente ? :gote : :sente)
    
    if depth >= max_depth
      return kyokumen.evaluate teban
    end
    
    next_te = kyokumen.generate_legal_moves teban
    # 合法手がない == 詰み
    if next_te.size == 0
      return -Float::INFINITY
    end
    
    best_te = nil
    best_eval = -Float::INFINITY
    next_te.each do |te|
      kyokumen.move te
      eval = -negamax(other_teban, kyokumen, alpha, beta, depth + 1, max_depth)
      if eval >= best_eval
        best_te = te
        best_eval = eval
      end
      kyokumen.back te
    end
    unless @best_sashite.size == depth
      @best_sashite.pop
    end
    @best_sashite.unshift best_te
    
    best_eval
  end
end
