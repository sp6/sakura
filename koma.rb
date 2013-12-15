# -*- coding: utf-8 -*-

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
  uma: um_movements, ry: ry_movements
}

csa_names = {
  fu: "FU", kyosha: "KY", keima: "KE", gin: "GI", kin: "KI", kaku: "KA", hisha: "HI",
  ou: "OU", to: "TO", narikyo: "NY", narikei: "NK",  narigin: "NG", uma: "UM", ryu: "RY"
}

class Koma
  attr_reader :id

  def initialize(id=nil, sengo=nil)
    @id = id
    @sengo = sengo
  end

  def csa_name; ""; end
  def belongs_to_player?(teban); @sengo == teban; end
  def belongs_to_enemy?(teban); @sengo != teban; end
  def prohibited_move?(teban, dan); false; end
  def pin_guard?; false; end

  def must_promote?(teban, dan); false; end
  alias_method :must_promoted?, :prohibited_move?

  def to_csa
    teban = case @sengo
      when :sente; "+"
      when :gote; "-"
      else "" end
    "#{teban}#{csa_name}"
  end
end

[:fu, :kyosha, :keima, :gin, :kin, :kaku, :hisha, :ou,
 :to, :narikyo, :narikei, :narigin, :uma, :ryu].each do |koma|
  klass =  Class.new(Koma) {
    define_method(:csa_name) { csa_names[koma] }
    define_method(:movements) { movements[koma] }
    define_method(:type) { koma }
  }
  
  Object.const_set(koma.capitalize, klass)
end

class Empty < Koma
  def type; :empty; end
  def to_csa; " * "; end
end

class Fu
  def move_prohibited?(teban, dan)
    case teban
    when :sente
      dan == 1
    when :gote
      dan == 9
    else
      raise TebanException
    end
  end
end

class Kyosha
  def move_prohibited?(teban, dan)
    case teban
    when :sente
      dan == 1
    when :gote
      dan == 9
    else
      raise TebanException
    end
  end
end

class Keima
  def prohibited_move?(teban, dan)
    case teban
    when :sente
      dan.between?(1, 2)
    when :gote
      dan.between?(8, 9)
    else
      raise TebanException
    end
  end
end
