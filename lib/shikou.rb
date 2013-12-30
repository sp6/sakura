# -*- coding: utf-8 -*-

class Shikou
  attr_reader :best_sashite

  def initialize
    @best_sashite = Array.new
  end
  
  def next_te(teban, kyokumen)
    negamax(teban, kyokumen, Float::MIN, Float::MAX, 0)
    te = @best_sashite.shift
  end
  
  def negamax(teban, kyokumen, alpha, beta, depth, max_depth=2)
    kyokumen.teban = teban
    other_teban = (teban == :sente ? :gote : :sente)
    
    if depth >= max_depth
      return kyokumen.evaluate
    end
    
    next_te = kyokumen.generate_legal_moves
    # 合法手がない == 詰み
    if next_te.size == 0
      return -Float::MAX
    end
    
    best_te = nil
    best_eval = -Float::MAX
    next_te.each do |te|
      kyokumen.move te
      eval = -negamax(other_teban, kyokumen, -beta, -[alpha, best_eval].max, depth + 1, max_depth)
      if eval >= best_eval
        best_te = te
        best_eval = eval
      end
      kyokumen.back te

      if best_eval >= beta
        while @best_sashite.size >= max_depth - depth
          @best_sashite.pop
        end
        @best_sashite.unshift best_te
        return best_eval
      end
    end
    
    while @best_sashite.size >= max_depth - depth
      @best_sashite.pop
    end
    @best_sashite.unshift best_te
    return best_eval
  end
end
