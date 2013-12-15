# -*- coding: utf-8 -*-
require 'set'
require 'pp'

DIRECTIONS = {
  up: {suji: 0, dan: -1},
  upright: {suji: 1, dan: -1},
  right: {suji: 1, dan: 0},
  downright: {suji: 1, dan: 1},
  down: {suji: 0, dan: 1},
  downleft: {suji: -1, dan: 1},
  left: {suji: -1, dan: 0},
  upleft: {suji: -1, dan: -1}
}

class TebanException < Exception; end

class Board
  def initialize(board=nil)
    @board = board
    @board ||= [[:ekyo, :ekei, :egin, :ekin, :eou, :ekin, :egin, :ekei, :ekyo],
                [:empty, :ehisya, :empty, :empty, :empty, :empty, :empty, :ekaku, :empty],
                [:efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu],
                [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
                [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
                [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
                [:fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu],
                [:empty, :kaku, :empty, :empty, :empty, :empty, :empty, :hisya, :empty],
                [:kyo, :kei, :gin, :kin, :ou, :kin, :gin, :kei, :kyo]]
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
end

Pos = Struct.new("Pos", :suji, :dan)
class Te < Struct.new(:teban, :from, :to, :koma, :promote, :capture)
  def initialize(teban, from, to, koma, promote=false, capture=nil)
    super(teban, from, to, koma, promote, capture)
  end

  def teban_to_csa
    case teban
    when :sente
      "+"
    when :gote
      "-"
    else
      ""
    end
  end

  def to_s
    "#{teban_to_csa}#{from.suji}#{from.dan}#{to.suji}#{to.dan}#{koma}"
  end
end

class Kyokumen
  DIRECTIONS = {
    up: [0, -1], # suji, dan
    upright: [1, -1],
    right: [1, 0],
    downright: [1, 1],
    down: [0, 1],
    downleft: [-1, 1],
    left: [-1, 0],
    upleft: [-1, -1]
  }
  
  FU_MOVEMENTS = [[0, -1]] # [suji, dan]
  KYO_MOVEMENTS = [(1..8).map { |h| [0, -h] }]
  KEI_MOVEMENTS = [[-1, -2], [1, -2]]
  GIN_MOVEMENTS = [[-1, -1], [0, -1], [1, -1], [-1, 1], [1, 1]]
  KIN_MOVEMENTS = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [0, 1]]
  KAKU_MOVEMENTS = [(1..8).map { |m| [m, -m] }, (1..8).map { |m| [m, m] },
                    (1..8).map { |m| [-m, m] }, (1..8).map { |m| [-m, -m] }]
  HISYA_MOVEMENTS = [(1..8).map { |h| [0, -h] }, (1..8).map { |h| [0, h] },
                     (1..8).map { |w| [w, 0] }, (1..8).map { |w| [-w, 0] }]
  OU_MOVEMENTS = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
  TO_MOVEMENTS = KIN_MOVEMENTS
  NKYO_MOVEMENTS = KIN_MOVEMENTS
  NKEI_MOVEMENTS = KIN_MOVEMENTS
  NGIN_MOVEMENTS = KIN_MOVEMENTS
  UMA_MOVEMENTS = KAKU_MOVEMENTS | [[[-1, 0], [1, 0], [0, -1], [0, 1]]]
  RYU_MOVEMENTS = HISYA_MOVEMENTS | [[[-1, -1], [1, -1], [-1, 1], [1, 1]]]
  
  MOVEMENTS = {
    fu: FU_MOVEMENTS, kyo: KYO_MOVEMENTS, kei: KEI_MOVEMENTS, gin: GIN_MOVEMENTS, kin: KIN_MOVEMENTS,
    kaku: KAKU_MOVEMENTS, hisya: HISYA_MOVEMENTS, ou: OU_MOVEMENTS, to: TO_MOVEMENTS, nkyo: NKYO_MOVEMENTS,
    nkei: NKEI_MOVEMENTS, ngin: NGIN_MOVEMENTS, uma: UMA_MOVEMENTS, ryu: RYU_MOVEMENTS
  }

  # koma info
  player_koma = [:fu, :kyo, :kei, :gin, :kin, :kaku, :hisya, :ou,
                 :to, :nkyo, :nkei, :ngin, :uma, :ryu]
  enemy_koma = player_koma.map { |k| :"e#{k}" }
  promote_koma = { fu: :to, kyo: :nkyo, kei: :nkei, gin: :ngin, kaku: :uma, hisya: :ryu }
  define_method(:promote) do |koma|
    promote_koma[koma]
  end

  direct_jump_koma = {
    up: Set.new([:kyo, :hisya, :ryu]),
    upright: Set.new([:kaku, :uma]),
    right: Set.new([:hisya, :ryu]),
    downright: Set.new([:kaku, :uma]),
    down: Set.new([:hisya, :ryu]),
    downleft: Set.new([:kaku, :uma]),
    left: Set.new([:hisya, :ryu]),
    upleft: Set.new([:kaku, :uma])
  }
  define_method(:jumpable?) do |direct, koma|
    direct_jump_koma[direct].include? koma
  end



  player_koma_set = Set.new(player_koma)
  enemy_koma_set = Set.new(enemy_koma)

  player_koma.each do |koma|
    define_method("#{koma}?") do |k|
      k == :"#{koma}" || k == :"e#{koma}"
    end
  end
  def empty?(koma)
    koma == :empty
  end

  koma_types = Hash.new
  player_koma.each do |koma|
    koma_types[:"e#{koma}"] = koma_types[koma] = koma
  end
  
  define_method(:koma_type) do |koma|
    koma_types[koma]
  end
  
  define_method(:player_koma?) do |teban, koma|
    if teban == :sente
      player_koma_set.include? (koma)
    elsif teban == :gote
      enemy_koma_set.include? (koma)
    else
      raise TebanException
    end
  end

  define_method(:enemy_koma?) do |teban, koma|
    if teban == :sente
      enemy_koma_set.include? (koma)
    elsif teban == :gote
      player_koma_set.include? (koma)
    else
      raise TebanException
    end
  end
  
  # koma kind
  {
    step_koma: [:fu, :kei, :gin, :kin, :ou, :to, :nkyo, :nkei, :ngin],
    jump_koma: [:kyo, :kaku, :hisya, :uma, :ryu],
    promotable_koma: [:fu, :kyo, :kei, :gin, :kaku, :hisya],
  }.each do |name, komas|
    koma_set = Set.new(komas.map { |k| [k, :"e#{k}"] }.flatten)
    define_method("#{name}?") do |koma|
      koma_set.include?(koma)
    end
  end

  # rules
  def promotable?(teban, koma, from_dan, to_dan)
    return false unless promotable_koma?(koma)
    
    if teban == :sente
      from_dan.between?(1, 3) || to_dan.between?(1, 3)
    elsif teban == :gote
      from_dan.between?(7, 9) || to_dan.between?(7, 9)
    else
      raise TebanException
    end
  end

  # rule fu
  def fu_prohibited_move?(teban, dan)
    if teban == :sente
      return dan == 1
    elsif teban == :gote
      return dan == 9
    else
      raise TebanException
    end
  end
  
  def nifu?(teban, suji)
    from = (teban == :sente) ? 2 : 1
    to = (teban == :sente) ? 9 : 8
    (from..to).each do |dan|
      return true if fu? @ban[suji, dan]
    end

    return false
  end

  alias_method :kyo_prohibited_move?, :fu_prohibited_move?
  alias_method :fu_must_promote?, :fu_prohibited_move?
  alias_method :kyo_must_promote?, :fu_prohibited_move?

  def kei_prohibited_move?(teban, dan)
    if teban == :sente
      return dan.between(1, 2)
    elsif teban == :gote
      return dan.between(8, 9)
    else
      false
    end
  end

  alias_method :kei_must_promote?, :kei_prohibited_move?

  def must_promote?(teban, koma, dan)
    if fu?(koma) && fu_must_promote?(teban, dan)
      true
    elsif kyo?(koma) && kyo_must_promote?(teban, dan)
      true
    elsif kei?(koma) && kei_must_promote?(teban, dan)
      true
    else
      false
    end
  end

  def movable?(move, direct)
    DIRECTIONS[direct] == move
  end


  def initialize
    @ban = Board.new
    
    @sente_hand =  { fu: 0, kyo: 0, kei: 0, gin: 0, kin: 0, kaku: 0, hisya: 0 }
    @gote_hand =  { fu: 0, kyo: 0, kei: 0, gin: 0, kin: 0, kaku: 0, hisya: 0 }
  end

  # 合法手を生成
  def generate_legal_moves(teban)
    set_pins(teban)

    te_next = []
    # 王手がかかっていたら防ぐ手を生成
    # if make_anti_oute
    
    # 盤上の駒を進める手の生成
    @ban.each do |suji, dan, koma|
      if empty?(koma)
        # 盤に持ち駒を打つ手を生成
        te_next += hit_koma(teban, suji, dan)
      elsif player_koma?(teban, koma) # 自分の駒であるかどうかを確認
        if step_koma?(koma_type(koma))
          te_next += step_koma(teban, suji, dan, koma)
        elsif jump_koma?(koma_type(koma))
          te_next += jump_koma(teban, suji, dan, koma)
        end
      end
    end

    te_next
  end

  # 打つ手を生成
  def hit_koma(teban, suji, dan)
    te_next = []
    hand = (teban == :sente) ? @sente_hand : @gote_hand
    
    hand.each do |mochigoma, num|
      # 駒数が0の場合は次へ
      next if num == 0
      
      if fu?(mochigoma)
        # 歩を打てるか
        next if fu_prohibited_move?(teban, dan)
        next if nifu?(teban, suji)
      elsif kyo?(mochigoma)
        # 香を打てるか
        next if kyo_prohibited_move?(teban, dan)
      elsif kei?(mochigoma)
        # 桂を打てるか
        next if kei_prohibited_move?(teban, dan)
      end
      te_next << create_te(teban, -1, -1, suji, dan, mochigoma)
    end
    te_next
  end

  def step_koma(teban, suji, dan, koma)
    te_next = []
    
    MOVEMENTS[koma_type(koma)].each do |move|
      if teban == :sente
        next_suji = suji + move[0]
        next_dan = dan + move[1]
      elsif teban == :gote
        next_suji = suji - move[0]
        next_dan = dan - move[1]
      end

      # 移動先が盤外の場合は手は生成しない
      next unless @ban.on_board?(next_suji, next_dan)

      # 移動先に自分の駒がある場合は手は生成しない
      next if player_koma?(teban, @ban[next_suji, next_dan])

      # PINの場合は移動不可
      next if pin_guard?(teban, suji, dan, koma, move)

      # 手を生成
      te_next += create_te_including_promote(teban, suji, dan, next_suji, next_dan, koma)
    end
    te_next
  end

  def jump_koma(teban, suji, dan, koma)
    te_next = []

    MOVEMENTS[koma_type(koma)].each do |movements|
      movements.each do |move|
        if teban == :sente
          next_suji = suji + move[0]
        next_dan = dan + move[1]
        elsif teban == :gote
          next_suji = suji - move[0]
          next_dan = dan - move[1]
        end
        
        # 移動先が盤外の場合は手の生成を打ち切る
        break unless @ban.on_board?(next_suji, next_dan)
        
        # 自分の駒がある場合は手の生成を打ち切る
        break if player_koma?(teban, @ban[next_suji, next_dan])

        # PINの場合は移動不可
        next if pin_guard?(teban, suji, dan, koma, move)
        
        # 手を生成
        te_next += create_te_including_promote(teban, suji, dan, next_suji, next_dan, koma)

        # 敵の駒がある場合は手の生成を打ち切る
        break if enemy_koma?(teban, @ban[next_suji, next_dan])
      end
    end
    te_next
  end

  def search_koma(suji, dan, direct)
    begin
      suji += DIRECTIONS[direct][0]
      dan += DIRECTIONS[direct][1]
    end while @ban.on_board?(suji, dan) && empty?(@ban[suji, dan])
    return suji, dan
  end

  def set_pins(teban)
    @pin_info = Hash.new
    @ban.each do |suji, dan, koma|
      if ou?(koma_type(koma))
        DIRECTIONS.each_key do |direct|
          # 味方の駒があるか
          pin_suji, pin_dan = search_koma(suji, dan, direct)
          if @ban.on_board?(pin_suji, pin_dan) && player_koma?(teban, @ban[pin_suji, pin_dan])
            # 敵の飛び駒があるか
            e_suji, e_dan = search_koma(pin_suji, pin_dan, direct)
            if @ban.on_board?(e_suji, e_dan) &&
                enemy_koma?(teban, @ban[pin_suji, pin_dan]) &&
                jumpable?(direct, koma_type(@ban[e_suji, e_dan]))
              @pin_info["#{pin_suji}#{pin_dan}"] = direct
            end
          end
        end
      end
    end
    @pin_info
  end

  def pin_guard?(teban, suji, dan, koma, move)
    return false unless @pin_info.has_key?("#{suji}#{dan}")

    koma = koma_type(koma)
    if fu? koma
      if !(@pin_info["#{suji}#{dan}"] == :up || @pin_info["#{suji}#{dan}"] == :down)
        return true
      end
    elsif kyo? koma
      if !(@pin_info["#{suji}#{dan}"] == :up || @pin_info["#{suji}#{dan}"] == :down)
        return true
      end
    elsif keima? koma
      return true
    elsif kaku?(koma) || uma?(koma)
      if @pin_info["#{suji}#{dan}"] == :upright || @pin_info["#{suji}#{dan}"] == :downright
        unless (1..8).map { |m| [m, m] }.include?(move) || (1..8).map { |m| [-m, m] }.include?(move)
          return true
        end
      elsif @pin_info["#{suji}#{dan}"] == :downleft || @pin_info["#{suji}#{dan}"] == :upleft
        unless(1..8).map { |m| [-m, -m] }.include?(move) || (1..8).map { |m| [m, -m] }.include?(move)
          return true
        end
      end
      if uma? koma
        if @pin_info["#{suji}#{dan}"] == :up && move == [0, -1]
        elsif @pin_info["#{suji}#{dan}"] == :right && move == [1, 0]
        elsif @pin_info["#{suji}#{dan}"] == :down && move == [0, 1]
        elsif @pin_info["#{suji}#{dan}"] == :left && move == [-1, 0]
        else
          return true
        end
      end
    elsif hisya?(koma) || ryu?(koma)
      if @pin_info["#{suji}#{dan}"] == :up || @pin_info["#{suji}#{dan}"] == :down 
        unless (1..8).map { |h| [h, 0] }.include?(move) || (1..8).map { |h| [-h, 0] }.include?(move)
          return true
        end
      elsif @pin_info["#{suji}#{dan}"] == :right || @pin_info["#{suji}#{dan}"] == :left
        unless (1..8).map { |w| [0, w] }.include?(move) || (1..8).map { |w| [0, -w] }.include?(move)
          return true
        end
      end
      if ryu? koma
        if @pin_info["#{suji}#{dan}"] == :upright && move == [1, -1]
        elsif @pin_info["#{suji}#{dan}"] == :downright && move == [1, 1]
        elsif @pin_info["#{suji}#{dan}"] == :downleft && move == [-1, 1]
        elsif @pin_info["#{suji}#{dan}"] == :upleft && move == [-1, -1]
        else
          return true
        end
      end
    else
      return true unless movable?(move, @pin_info["#{suji}#{dan}"])
    end

    false
  end
  
  def create_te_including_promote(teban, from_suji, from_dan, to_suji, to_dan, koma)
    te_next = []

    # 移動先が鳴りが必須
    if must_promote?(teban, koma, from_dan)
      te_next << create_te(teban, from_suji, from_dan, to_suji, to_dan, koma, true) 
      return te_next
    end
    
    # 手の生成
    te_next << create_te(teban, from_suji, from_dan, to_suji, to_dan, koma)
    if promotable?(teban, koma, from_dan, to_dan)
      # 鳴れる場合は鳴る手も指す
      te_next << create_te(teban, from_suji, from_dan, to_suji, from_dan, koma, true) 
    end
    te_next
  end

  def create_te(teban, from_suji, from_dan, to_suji, to_dan, koma, promote=false, capture=nil)
    koma = promote(koma) if promote
    Te.new(teban, Pos.new(from_suji, from_dan), Pos.new(to_suji, to_dan),
           koma, promote, capture)
  end
end

k = Kyokumen.new
puts te = k.generate_legal_moves(:gote)
pp te.size
