# -*- coding: utf-8 -*-

class Board
  include Koma
  
  def initialize(board=nil)
    @board = board
    @board ||= init_ban
  end

  def init_ban
    ban = [[GKY, GKE, GGI, GKI, GOU, GKI, GGI, GKE, GKY],
           [EMP, GHI, EMP, EMP, EMP, EMP, EMP, GKA, EMP],
           [GFU, GFU, GFU, GFU, GFU, GFU, GFU, GFU, GFU],
           [EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP],
           [EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP],
           [EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP, EMP],
           [SFU, SFU, SFU, SFU, SFU, SFU, SFU, SFU, SFU],
           [EMP, SKA, EMP, EMP, EMP, EMP, EMP, SHI, EMP],
           [SKY, SKE, SGI, SKI, SOU, SKI, SGI, SKE, SKY]]
  end
    
  def each
    8.downto(0) do |x|
      0.upto(8) do |y|
        yield 9-x, y+1, @board[y][x] # suji dan koma
      end
    end
  end
  
  def [](suji, dan)
    @board[dan - 1][9 - suji]
  end

  def []=(suji, dan, koma)
    @board[dan - 1][9 - suji] = koma
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
