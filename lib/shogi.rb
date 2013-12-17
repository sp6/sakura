# -*- coding: utf-8 -*-
require 'set'

class TebanException < Exception; end

Pos = Struct.new("Pos", :suji, :dan)
class Te < Struct.new(:teban, :from, :to, :koma, :promote, :capture)
  def initialize(teban, from, to, koma, promote=false, capture=nil)
    super(teban, from, to, koma, promote, capture)
  end

  def teban_to_csa
    case teban; when :sente; "+"; when :gote; "-"; else; ""; end
  end

  def to_s
    "#{teban_to_csa}#{from.suji}#{from.dan}#{to.suji}#{to.dan}#{koma.csa_name}"
  end
end

module Shogi
  DIRECTIONS = {
    up: {suji: 0, dan: -1},
    upright: {suji: -1, dan: -1},
    right: {suji: -1, dan: 0},
    downright: {suji: -1, dan: 1},
    down: {suji: 0, dan: 1},
    downleft: {suji: 1, dan: 1},
    left: {suji: 1, dan: 0},
    upleft: {suji: 1, dan: -1}
  }
  
  JUMP_KOMA = {
    up: Set.new([:kyosha, :hisha, :ryu]),
    upright: Set.new([:kaku, :uma]),
    right: Set.new([:hisha, :ryu]),
    downright: Set.new([:kaku, :uma]),
    down: Set.new([:hisha, :ryu]),
    downleft: Set.new([:kaku, :uma]),
    left: Set.new([:hisha, :ryu]),
    upleft: Set.new([:kaku, :uma])
  }
end
