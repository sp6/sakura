# -*- coding: utf-8 -*-
require './tables'
require './moves'
require 'pp'

class Board
  def initialize(board=Array.new(9).map {Array.new(9, :empty)})
    @board = board
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
    1 <= suji && suji <= 9 && 1 <= dan && dan <= 9
  end
end

Pos = Struct.new("Pos", :suji, :dan)
class Te < Struct.new(:from, :to, :koma, :promote, :capture)
  def initialize(from, to, koma, promote=false, capture=nil)
    super(from, to, koma, promote, capture)
  end
  
  def to_s
    "#{from.suji}#{from.dan}#{to.suji}#{to.dan}#{Tables::TO_S[koma]}"
  end
end

class Kyokumen
  attr_accessor :ban

  def initialize
    @player_hand =  { fu: 0, ky: 0, ke: 0, gi: 0, ki: 0, ka: 0, hi: 0 }
    @enemy_hand =  { fu: 0, ky: 0, ke: 0, gi: 0, ki: 0, ka: 0, hi: 0 }
    @price_value = {
      empty: 0,
      fu: 0, ky: 120, ke: 550, gi: 660, ki: 880, ka: 990, hi: 1400, ou: 99999,
      to: 1100, ny: 1100, nk: 1000, ng: 1000, um: 1500, ry: 1700,
      efu: 0, eky: -120, eke: -550, egi: -660, eki: -880, eka: -990, ehi: -1400, eou: -99999,
      eto: -1100, eny: -1100, enk: -1000, eng: -1000, eum: -1500, ery: -1700
    }
  end
  
  def init
    ban = [[:eky, :eke, :egi, :eki, :eou, :eki, :egi, :eke, :eky],
           [:empty, :ehi, :empty, :empty, :empty, :empty, :empty, :eka, :empty],
           [:efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu],
           [:empty, :ka, :empty, :empty, :empty, :empty, :empty, :hi, :empty],
           [:ky, :ke, :gi, :ki, :ou, :ki, :gi, :ke, :ky]]
=begin
    ban = [[:ou, :empty, :empty, :empty, :ehi, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :ehi, :ry, :empty],
           [:empty, :empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty],
           [:ehi, :empty, :hi, :empty, :eou, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ehi, :empty, :empty, :empty, :empty]]
=end
    @ban = Board.new(ban)
  end
  
  def move(te)
    if @ban.on_board?(te.from.suji, te.from.dan)
      @ban[te.from.suji, te.from.dan] = :empty
      if enemy_koma?(:sente, @ban[te.to.suji, te.to.dan])
        # 持ち駒とする
        capture = @ban[te.to.suji, te.to.dan]
        te.capture = capture
        # TODO 後手の場合も
        @player_hand[Tables::HAND_KOMA[capture]] += 1
      end
    end
    @ban[te.to.suji, te.to.dan] = te.koma
  end

  def back(te)
    @ban[te.from.suji, te.from.dan] = te.koma
    if te.capture.nil?
      @ban[te.to.suji, te.to.dan] = :empty
    else
      @player_hand[te.capture] -= 1
      @ban[te.to.suji, te.to.dan] = te.capture
    end
  end
  
  def search_koma(suji, dan, direct)
    begin
      suji += Tables::DIRECTIONS[direct][0]
      dan += Tables::DIRECTIONS[direct][1]
    end while @ban.on_board?(suji, dan) && @ban[suji, dan] == :empty
    return suji, dan
  end
  
  def make_pin_info(teban)
    @pin_info = Hash.new
    @ban.each do |suji, dan, koma|
      if (koma == :ou && teban == :sente) || (koma == :eou && teban == :gote) # TODO
        Tables::DIRECTIONS.each_key do |direct|
          # 味方の駒があるか
          pin_suji, pin_dan = search_koma(suji, dan, direct)
          if @ban.on_board?(pin_suji, pin_dan) # TODO
            if (teban == :sente && player_koma?(teban, @ban[pin_suji, pin_dan])) ||
               (teban == :gote && enemy_koma?(teban, @ban[pin_suji, pin_dan]))
              # 敵の飛び駒があるか
              e_suji, e_dan = search_koma(pin_suji, pin_dan, direct)
              if @ban.on_board?(e_suji, e_dan) && jumpable?(direct, @ban[e_suji, e_dan])
                @pin_info["#{pin_suji}#{pin_dan}"] = direct
              end
            end
          end
        end
      end
    end
    @pin_info
  end
  
  def make_moves(teban)
    # TODO
    sengo = teban
    # PINを生成
    make_pin_info(teban)

    te_next = Array.new
    # 王手がかかっていたら防ぐ手を生成
    # if make_anti_oute
    
    # 盤上の駒を進める手の生成
    @ban.each do |suji, dan, koma|
      # 自分の駒であるかどうかを確認
      if player_koma?(teban, koma)
        if teban == :sente
          case koma
          when :empty
            # 盤に持ち駒を打つ手を生成
            te_next += hit_koma(suji, dan, teban)
          when :fu
            te_next += fu_move(suji, dan, koma, teban)
          when :ky
            te_next += ky_move(suji, dan, koma, teban)
          when :ke
            te_next += ke_move(suji, dan, koma, teban)
          when :ka
            te_next += ka_move(suji, dan, koma, teban)
          when :hi
            te_next += hi_move(suji, dan, koma, teban)
          when :ou
            te_next += ou_move(suji, dan, koma, teban)
          when :um
            te_next += um_move(suji, dan, koma, teban)
          when :ry
            te_next += ry_move(suji, dan, koma, teban)
          when :gi
            te_next += gi_move(suji, dan, koma, teban)
          when :ki, :to, :ny, :nk, :ng
            te_next += ki_move(suji, dan, koma, teban)
          end
        end
      end
    end

    te_next
  end

  def movable?(move, direct)
    Tables::DIRECTIONS[direct] == move
  end

  def create_te(from_suji, from_dan, to_suji, to_dan, koma, promote=false, capture=nil)
    if promote
      case koma
      when :fu
        promote_koma = :to
      when :ky
        promote_koma = :ny
      when :ke
        promote_koma = :nk
      when :gi
        promote_koma = :ng
      when :ka
        promote_koma = :um
      when :hi
        promote_koma = :ry
      end
      #"#{from_suji)}#{from_dan)}#{to_suji}#{to_dan}#{Tables::TO_S[promote_koma]}"
      Te.new(Pos.new(from_suji, from_dan), Pos.new(to_suji, to_dan), promote_koma, true)
    else
      #"#{from_suji)}#{from_dan)}#{to_suji}#{to_dan}#{Tables::TO_S[koma]}"
      Te.new(Pos.new(from_suji, from_dan), Pos.new(to_suji, to_dan), koma)
    end
  end
  
  def evaluate
    eval = 0
    king_king_piece = 0
    sp_bk = 0
    sp_wk = 0
    index = 0

    @ban.each do |suji, dan, koma|
      eval += @price_value[koma]
    end
    
    @player_hand.each do |koma, num|
      eval += @price_value[koma] * num
    end
    
    eval
  end

  def minmax(sengo, depth, max_depth)
    return if depth == max_depth

    next_te = make_moves(sengo)
    return Integer::MIN if next_te.size == 0 # 合法手がない == 詰み

    best_te = nil
    max_eval = Integer::MAX
    next_te.each do |te|
      move(te)
      minmax(sengo, depth + 1, max_depth)
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

  def player_koma?(teban, koma)
    if teban == :sente
      Tables::PLAYER_KOMA.include?(koma)
    else
      Tables::ENEMY_KOMA.include?(koma)
    end
  end

  def enemy_koma?(teban, koma)
    if teban == :sente
      Tables::ENEMY_KOMA.include?(koma)
    else
      Tables::PLAYER_KOMA.include?(koma)
    end
  end

  def jumpable?(direct, koma)
    Tables::JUMP_KOMA[direct].include? koma
  end
  
  def on_ban?(y, x)
    1 <= y && y <= 9 && 1 <= x && x <= 9
  end

  def promotable?(dan)
    (1..3).include?(dan)    
  end
  
  def p(koma)
    Tables::PKOMA[koma]
  end

  def view(ban=@ban)
    puts <<EOS
BEGIN Game_Summary
BEGIN Position
P1#{p(ban[9, 1])}#{p(ban[8, 1])}#{p(ban[7, 1])}#{p(ban[6, 1])}#{p(ban[5, 1])}#{p(ban[4, 1])}#{p(ban[3, 1])}#{p(ban[2, 1])}#{p(ban[1, 1])}
P2#{p(ban[9, 2])}#{p(ban[8, 2])}#{p(ban[7, 2])}#{p(ban[6, 2])}#{p(ban[5, 2])}#{p(ban[4, 2])}#{p(ban[3, 2])}#{p(ban[2, 2])}#{p(ban[1, 2])}
P3#{p(ban[9, 3])}#{p(ban[8, 3])}#{p(ban[7, 3])}#{p(ban[6, 3])}#{p(ban[5, 3])}#{p(ban[4, 3])}#{p(ban[3, 3])}#{p(ban[2, 3])}#{p(ban[1, 3])}
P4#{p(ban[9, 4])}#{p(ban[8, 4])}#{p(ban[7, 4])}#{p(ban[6, 4])}#{p(ban[5, 4])}#{p(ban[4, 4])}#{p(ban[3, 4])}#{p(ban[2, 4])}#{p(ban[1, 4])}
P5#{p(ban[9, 5])}#{p(ban[8, 5])}#{p(ban[7, 5])}#{p(ban[6, 5])}#{p(ban[5, 5])}#{p(ban[4, 5])}#{p(ban[3, 5])}#{p(ban[2, 5])}#{p(ban[1, 5])}
P6#{p(ban[9, 6])}#{p(ban[8, 6])}#{p(ban[7, 6])}#{p(ban[6, 6])}#{p(ban[5, 6])}#{p(ban[4, 6])}#{p(ban[3, 6])}#{p(ban[2, 6])}#{p(ban[1, 6])}
P7#{p(ban[9, 7])}#{p(ban[8, 7])}#{p(ban[7, 7])}#{p(ban[6, 7])}#{p(ban[5, 7])}#{p(ban[4, 7])}#{p(ban[3, 7])}#{p(ban[2, 7])}#{p(ban[1, 7])}
P8#{p(ban[9, 8])}#{p(ban[8, 8])}#{p(ban[7, 8])}#{p(ban[6, 8])}#{p(ban[5, 8])}#{p(ban[4, 8])}#{p(ban[3, 8])}#{p(ban[2, 8])}#{p(ban[1, 8])}
P9#{p(ban[9, 9])}#{p(ban[8, 9])}#{p(ban[7, 9])}#{p(ban[6, 9])}#{p(ban[5, 9])}#{p(ban[4, 9])}#{p(ban[3, 9])}#{p(ban[2, 9])}#{p(ban[1, 9])}
P+
P-
END Position
END Game_Summary
EOS
  end
end

if __FILE__ == $0
  k = Kyokumen.new
  k.init
=begin
  k.view
  puts "evaluate:#{k.evaluate}"
  #te = Te.new($pos.new(7, 7), $pos.new(7, 6), :fu, false)
  te = Te.new($pos.new(2, 8), $pos.new(3, 8), :hi, false)
  k.move(te)
  k.view
  puts "#{te} eval:#{k.evaluate}"
=end
  te_next = k.make_moves(:gote)
  te_next.each do |te|
    #k.move(te)
    #k.view
    puts "#{te}" # eval:#{k.evaluate}"
    #k.back(te)
    #k.view
  end
end

