# -*- coding: utf-8 -*-

class Board
  def initialize(board=nil)
    @board = board
    @board ||= Board.create(init_ban)
  end

  def init_ban
    [[:ekyosha, :ekeima, :egin, :ekin, :eou, :ekin, :egin, :ekeima, :ekyosha],
     [:empty, :ehisha, :empty, :empty, :empty, :empty, :empty, :ekaku, :empty],
     [:efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu],
     [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
     [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
     [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
     [:fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu],
     [:empty, :kaku, :empty, :empty, :empty, :empty, :empty, :hisha, :empty],
     [:kyosha, :keima, :gin, :kin, :ou, :kin, :gin, :keima, :kyosha]]
  end

  def self.create(board)
    id = 1
    board = board.map do |dan|
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
    Board.new(board)
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

  def view_csa
    puts <<EOS
P1#{self[9, 1].to_csa}#{self[8, 1].to_csa}#{self[7, 1].to_csa}#{self[6, 1].to_csa}#{self[5, 1].to_csa}#{self[4, 1].to_csa}#{self[3, 1].to_csa}#{self[2, 1].to_csa}#{self[1, 1].to_csa}
P2#{self[9, 2].to_csa}#{self[8, 2].to_csa}#{self[7, 2].to_csa}#{self[6, 2].to_csa}#{self[5, 2].to_csa}#{self[4, 2].to_csa}#{self[3, 2].to_csa}#{self[2, 2].to_csa}#{self[1, 2].to_csa}
P3#{self[9, 3].to_csa}#{self[8, 3].to_csa}#{self[7, 3].to_csa}#{self[6, 3].to_csa}#{self[5, 3].to_csa}#{self[4, 3].to_csa}#{self[3, 3].to_csa}#{self[2, 3].to_csa}#{self[1, 3].to_csa}
P4#{self[9, 4].to_csa}#{self[8, 4].to_csa}#{self[7, 4].to_csa}#{self[6, 4].to_csa}#{self[5, 4].to_csa}#{self[4, 4].to_csa}#{self[3, 4].to_csa}#{self[2, 4].to_csa}#{self[1, 4].to_csa}
P5#{self[9, 5].to_csa}#{self[8, 5].to_csa}#{self[7, 5].to_csa}#{self[6, 5].to_csa}#{self[5, 5].to_csa}#{self[4, 5].to_csa}#{self[3, 5].to_csa}#{self[2, 5].to_csa}#{self[1, 5].to_csa}
P6#{self[9, 6].to_csa}#{self[8, 6].to_csa}#{self[7, 6].to_csa}#{self[6, 6].to_csa}#{self[5, 6].to_csa}#{self[4, 6].to_csa}#{self[3, 6].to_csa}#{self[2, 6].to_csa}#{self[1, 6].to_csa}
P7#{self[9, 7].to_csa}#{self[8, 7].to_csa}#{self[7, 7].to_csa}#{self[6, 7].to_csa}#{self[5, 7].to_csa}#{self[4, 7].to_csa}#{self[3, 7].to_csa}#{self[2, 7].to_csa}#{self[1, 7].to_csa}
P8#{self[9, 8].to_csa}#{self[8, 8].to_csa}#{self[7, 8].to_csa}#{self[6, 8].to_csa}#{self[5, 8].to_csa}#{self[4, 8].to_csa}#{self[3, 8].to_csa}#{self[2, 8].to_csa}#{self[1, 8].to_csa}
P9#{self[9, 9].to_csa}#{self[8, 9].to_csa}#{self[7, 9].to_csa}#{self[6, 9].to_csa}#{self[5, 9].to_csa}#{self[4, 9].to_csa}#{self[3, 9].to_csa}#{self[2, 9].to_csa}#{self[1, 9].to_csa}
EOS
  end
end
