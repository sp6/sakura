# -*- coding: utf-8 -*-

class Board
  def initialize(board=nil)
    @board = board
    @board ||= init_ban
  end

  def init_ban
    ban = [[:ekyosha, :ekeima, :egin, :ekin, :eou, :ekin, :egin, :ekeima, :ekyosha],
           [:empty, :ehisha, :empty, :empty, :empty, :empty, :empty, :ekaku, :empty],
           [:efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu],
           [:empty, :kaku, :empty, :empty, :empty, :empty, :empty, :hisha, :empty],
           [:kyosha, :keima, :gin, :kin, :ou, :kin, :gin, :keima, :kyosha]]
    Board.convert_class(ban)
  end

  def self.convert_class(board)
    id = 1
    board.map do |dan|
      dan.map do |koma|
        cls_name = ""
        klass = nil
        if koma == :empty
          cls_name = "Empty"
          klass = Object.const_get(cls_name).new
        elsif koma =~ /^e(.+)/
          cls_name = $1.capitalize
          klass = Object.const_get(cls_name).new(id, :gote)
          id += 1
        else
          cls_name = koma.capitalize
          klass = Object.const_get(cls_name).new(id, :sente)
          id += 1
        end
        klass
      end
    end
  end

  def self.create(board=nil)
    board == nil ? Board.new : Board.new(Board.convert_class(board))
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
        res += self[suji, dan].to_csa
      end
      res += "\n"
    end
    res
  end
end
