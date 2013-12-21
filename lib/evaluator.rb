# -*- coding: utf-8 -*-

class Evaluator
  
  @@koma_dan = {
    fu: [0, 0, 15, 15, 15, 3, 1, 0, 0, 0],
    kyosha: [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    keima: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    gin: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    kin: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    kaku: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    hisha: [0, 10, 10, 10, 0, 0, 0, -5, 0, 0],
    ou: [0, 1200, 1200, 900, 600, 300, -10, 0, 0, 0],
    to: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    narikyo: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    narikei: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    narigin: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    uma: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ryu: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  }

  @@joseki_gi = {
    # IvsFURI 舟囲い、美濃、銀冠
    ibisha_vs_furibisha: [
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10, -7,-10,-10,-10,-10,-10,  7,-10],
      [-10,  7, -8, -7, 10,-10, 10,  6,-10],
      [-10, -2, -6, -5,-10,  6,-10,-10,-10],
      [-10, -7,  0,-10,-10,-10,-10,-10,-10]
    ]
  }
  
  @@joseki_ki = {
    # IvsFURI 舟囲い、美濃、銀冠
    ibisha_vs_furibisha: [
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,  1,  2,-10,-10,-10,-10],
      [-10,-10,-10,  0,-10, -4,-10,-10,-10],
    ]
  }

  @@joseki_ou = {
    # IvsFURI 舟囲い、美濃、銀冠
    ibisha_vs_furibisha: [
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [-10,-10,-10,-10,-10,-10,-10,-10,-10],
      [- 7,  9,-10,-10,-10,-10,-10,-10,-10],
      [  5,  7,  8,  4,-10,-10,-10,-10,-10],
      [ 10,  5,  3,-10,-10,-10,-10,-10,-10]
    ]
  }
  def evaluate(kyokumen, teban)
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
        @@koma_dan[koma.type]
        case koma.type
        when :gin
          eval += @@joseki_gi[:ibisha_vs_furibisha][dan-1][suji-1]
        when :kin
          eval += @@joseki_ki[:ibisha_vs_furibisha][dan-1][suji-1]
        when :ou
          eval += @@joseki_ou[:ibisha_vs_furibisha][dan-1][suji-1]
        end
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

