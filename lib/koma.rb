# -*- coding: utf-8 -*-

module Koma
  EMP = 0x00
  FU = 0x01
  KY = 0x02
  KE = 0x03
  GI = 0x04
  KI = 0x05
  KA = 0x06
  HI = 0x07
  OU = 0x08
  
  Promote = 0x80
  
  TO = FU | Promote
  NY = KY | Promote
  NK = KE | Promote
  NG = GI | Promote
  UM = KA | Promote
  RY = HI | Promote
  
  Sente = 0x10
  Gote = 0x20
  
  [:FU, :KY, :KE, :GI, :KI, :KA, :HI, :OU,
   :TO, :NY, :NK, :NG, :UM, :RY].each do |koma|
    const_set("S#{koma}", const_get(koma) | Sente)
    const_set("G#{koma}", const_get(koma) | Gote)
  end
  
  Koma_to_Type = {
    EMP => :empty,
    FU => :fu, KY => :kyosha, KE => :keima, GI => :gin, KI => :kin,
    KA => :kaku, HI => :hisha, OU => :ou,
    TO => :to, NY => :narikyo, NK => :narikei, NG => :narigin,
    UM => :uma, RY => :ryu
  }
  Type_to_Koma = Koma_to_Type.invert
  
  CSA = {
    fu: "FU", kyosha: "KY", keima: "KE", gin: "GI", kin: "KI", kaku: "KA", hisha: "HI",
    ou: "OU", to: "TO", narikyo: "NY", narikei: "NK",  narigin: "NG", uma: "UM", ryu: "RY",
    empty: " * "
  }
  
  def self.create(type, sengo)
    koma = Type_to_Koma[type]
    case sengo
    when :sente
      koma | Sente
    when :gote
      koma | Gote
    end
  end
  
  def self.create_from_csa_name(csa_name, sengo)
    create(CSA.invert[csa_name], sengo)
  end

  def self.promote(koma)
    koma | Promote
  end
  
  def self.unpromote(koma)
    koma & ~Promote
  end
end

class Integer
  def sente?
    self & Koma::Sente != 0
  end
  
  def gote?
    self & Koma::Gote != 0
  end
  
  def belongs_to_player?(teban)
    (teban == :sente && sente?) || (teban == :gote && gote?)
  end
  
  def belongs_to_enemy?(teban)
    (teban == :sente && gote?) || (teban == :gote && sente?)
  end
    
  def type
    Koma::Koma_to_Type[self & 0xCf]
  end
  
  # [suji, dan]
  fu_movements = [[0, -1]]
  ky_movements = [(1..8).map { |h| [0, -h] }]
  ke_movements = [[-1, -2], [1, -2]]
  gi_movements = [[-1, -1], [0, -1], [1, -1], [-1, 1], [1, 1]]
  ki_movements = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [0, 1]]
  ka_movements = [(1..8).map { |m| [m, -m] }, (1..8).map { |m| [m, m] },
                  (1..8).map { |m| [-m, m] }, (1..8).map { |m| [-m, -m] }]
  hi_movements = [(1..8).map { |h| [0, -h] }, (1..8).map { |h| [0, h] },
                  (1..8).map { |w| [w, 0] }, (1..8).map { |w| [-w, 0] }]
  ou_movements = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
  to_movements = ki_movements
  ny_movements = ki_movements
  nk_movements = ki_movements
  ng_movements = ki_movements
  um_movements = ka_movements | [[[-1, 0], [1, 0], [0, -1], [0, 1]]]
  ry_movements = hi_movements | [[[-1, -1], [1, -1], [-1, 1], [1, 1]]]
  
  movements = {
    fu: fu_movements, kyosha: ky_movements, keima: ke_movements,
    gin: gi_movements, kin: ki_movements, kaku: ka_movements,
    hisha: hi_movements, ou: ou_movements, to: to_movements,
    narikyo: ny_movements, narikei: nk_movements, narigin: ng_movements,
    uma: um_movements, ryu: ry_movements
  }
  
  define_method(:movements) do
    movements[self.type]
  end
  
  def to_csa_name
    teban = ""
    if sente?
      teban = "+"
    elsif gote?
      teban = "-"
    end
    "#{teban}#{Koma::CSA[type]}"
  end
end
