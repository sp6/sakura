# -*- coding: utf-8 -*-

class Evaluator
  
  def self.evaluate(kyokumen, teban)
    piece_val = {
      fu: 120, kyosha: 550, keima: 660, gin: 880, kin: 990, kaku: 1400, hisha: 1400, ou: 99999,
      to: 1100, narikyo: 1000, narikei: 1000, narigin: 1000, uma: 1500, ryu: 1700
    }
    hand_val = {
      fu: 120, kyosha: 550, keima: 660, gin: 880, kin: 900, kaku: 1400, hisha: 1400
    }
    hand = case teban
           when :sente
             hand = kyokumen.sente_hand 
           when :gote
             hand = kyokumen.gote_hand
           else
             raise TebanExcepton
           end
    
    eval = 0
    kyokumen.ban.each do |suji, dan, koma|
      if koma.belongs_to_player?(teban)
        eval += piece_val[koma.type]
      elsif koma.belongs_to_enemy?(teban)
        eval -= piece_val[koma.type]
      end
    end
    
    hand.each do |koma, ary|
      eval += hand_val[koma] * ary.size unless ary.size == 0
    end
    
    if teban == :sente
      eval
    else
      -eval
    end
  end
end

