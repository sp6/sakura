# -*- coding: utf-8 -*-

class Board
  include Koma
  
  def initialize(board=nil)
    @board = board
    @board ||= initialized_board
  end
  
  def initialized_board
    [GKY, GKE, GGI, GKI, GOU, GKI, GGI, GKE, GKY,
     EMP, GHI, EMP, EMP, EMP, EMP, EMP, GKA, EMP,
     GFU, GFU, GFU, GFU, GFU, GFU, GFU, GFU, GFU,
     EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP,
     EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP,
     EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP,
     SFU, SFU, SFU, SFU, SFU, SFU, SFU, SFU, SFU,
     EMP, SKA, EMP, EMP, EMP, EMP, EMP, SHI, EMP,
     SKY, SKE, SGI, SKI, SOU, SKI, SGI, SKE, SKY]
  end
  
  def self.convert_koma(board)
    board.map do |koma|
      if koma == :empty
        Koma::EMP
      elsif koma =~ /^e(.+)/
        Koma.create($1.to_sym, :gote)
      else
        Koma.create(koma, :sente)
      end
    end
  end
  
  def self.create(board=nil)
    board == nil ? Board.new : Board.new(Board.convert_koma(board))
  end
  
  def each
    1.upto(9) do |suji|
      1.upto(9) do |dan|
        yield suji, dan, self[suji, dan] # suji dan koma
      end
    end
  end
  
  def [](suji, dan)
    @board[(9 * (dan - 1)) + (9 - suji)]
  end

  def []=(suji, dan, koma)
    @board[(9 * (dan - 1)) + (9 - suji)] = koma
  end
  
  def on_board?(suji, dan)
    suji.between?(1, 9) and dan.between?(1, 9)
  end

  def to_csa
    res = ""
    1.upto(9) do |dan|
      res += "P#{dan}"
      9.downto(1) do |suji|
        res += self[suji, dan].to_csa_name
      end
      res += "\n"
    end
    res
  end
end
