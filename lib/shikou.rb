# -*- coding: utf-8 -*-

class Shikou
  
  def negamax
    return if depth == max_depth
    next_te = make_moves(sengo)
    return Integer::MIN if next_te.size == 0 # 合法手がない == 詰み
    
    best_te = nil
    max_eval = Integer::MAX
    next_te.each do |te|
      move(te)
      negamax(sengo, depth1, max_depth)
      eval = evaluate
      if (sengo == :sente)
        if max_eval > cur_eval
          max_eval = cur_eval
          best_te = te
        end
      else
        if max_eval < cur_eval
          max_eval = cur_eval
          best_te = te
        end
      end
      back(te)
    end
  end
end

