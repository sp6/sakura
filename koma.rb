# -*- coding: utf-8 -*-

require 'pp'

class TebanException < Exception; end

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

class Board
  def initialize(board=nil)
    @board = board
    @board ||= init_ban
  end

  def init_ban
    id = 1
     [[:ekyosha, :ekeima, :egin, :ekin, :eou, :ekin, :egin, :ekeima, :ekyosha],
      [:empty, :ehisha, :empty, :empty, :empty, :empty, :empty, :ekaku, :empty],
      [:efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu],
      [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
      [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
      [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
      [:fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu],
      [:empty, :kaku, :empty, :empty, :empty, :empty, :empty, :hisha, :empty],
      [:kyosha, :keima, :gin, :kin, :ou, :kin, :gin, :keima, :kyosha]].map do |dan|
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

  def initialize
    @ban = Board.new
    
    @sente_hand =  { fu: 0, kyo: 0, kei: 0, gin: 0, kin: 0, kaku: 0, hisya: 0 }
    @gote_hand =  { fu: 0, kyo: 0, kei: 0, gin: 0, kin: 0, kaku: 0, hisya: 0 }
  end

  # 合法手を生成
  def generate_legal_moves(teban)
    @pins = search_pins(teban)

    te_next = []
    # 王手がかかっていたら防ぐ手を生成
    # if make_anti_oute
    
    # 盤上の駒を進める手の生成
    @ban.each do |suji, dan, koma|
      if koma.type == :empty
        # 盤に持ち駒を打つ手を生成
        te_next += hit_koma(teban, suji, dan)
      else
        # 自分の駒であるかどうかを確認
        next unless koma.belongs_to_player?(teban)
        
        case koma.type
        when :fu, :keima, :gin, :kin, :ou
          te_next += gen_legal_step_moves(teban, suji, dan, koma)
        when :kyosha, :kaku, :hisya, :uma, :ryu
          te_next += gen_legal_jump_moves(teban, suji, dan, koma)
        end
      end
    end
      
    te_next
  end

  # 打つ手を生成
  def hit_koma(teban, suji, dan)
    te_next = []
    hand = case teban
    when :sente
      hand = @sente_hand 
    when :gote
      hand = @gote_hand
    else
      raise TebanExcepton
    end
    
    hand.each do |mochigoma, num|
      # 駒数が0の場合は次へ
      next if num == 0
      
      case mochigoma.kaind_of?
      when :fu
        next if mochigoma.move_prohibited?(teban, dan)
        next if nifu?(teban, suji)
      when :kyosha, :keima
        next if mochigoma.move_prohibited?(teban, dan)
      end
      te_next << gen_te(teban, -1, -1, suji, dan, mochigoma)
    end
    te_next
  end

  def gen_legal_step_moves(teban, suji, dan, koma)
    te_next = []
    
    koma.movements.each do |move|
      next_suji, next_dan = do_move(teban, suji, dan, move)

      # 移動先が盤外の場合は手は生成しない
      next unless @ban.on_board?(next_suji, next_dan)
      
      # 移動先に自分の駒がある場合は手は生成しない
      next if @ban[next_suji, next_dan].belongs_to_player?(teban)
      # PINの場合は移動不可
      next if pin_guard?(teban, suji, dan, koma, move)
      
      # 手を生成
      te_next += gen_te_with_promote(teban, suji, dan, next_suji, next_dan, koma)
    end
    te_next
  end

  def gen_legal_jump_moves(teban, suji, dan, koma)
    te_next = []

    koma.movements.each do |movements|
      movements.each do |move|
        next_suji, next_dan = do_move(teban, suji, dan, move)
        
        # 移動先が盤外の場合は手の生成を打ち切る
        break unless @ban.on_board?(next_suji, next_dan)
        
        # 自分の駒がある場合は手の生成を打ち切る
        break if @ban[next_suji, next_dan].belongs_to_player?(teban)

        # PINの場合は移動不可
        next if pin_guard?(teban, suji, dan, koma, move)
        
        # 手を生成
        te_next += gen_te_with_promote(teban, suji, dan, next_suji, next_dan, koma)

        # 敵の駒がある場合は手の生成を打ち切る
        break if @ban[next_suji, next_dan].belongs_to_enemy?(teban)
      end
    end
    te_next
  end
  
  def do_move(teban, suji, dan, move)
    if teban == :sente
      next_suji = suji + move[0]
      next_dan = dan + move[1]
    elsif teban == :gote
      next_suji = suji - move[0]
      next_dan = dan - move[1]
    else
      raise TebanException
    end
    [next_suji, next_dan]
  end

  def search_koma(suji, dan, direct)
    begin
      suji += DIRECTIONS[direct][0]
      dan += DIRECTIONS[direct][1]
    end while @ban.on_board?(suji, dan) && @ban[suji, dan].type == :empty
    return suji, dan
  end

  def search_pins(teban)
    pins = Hash.new
    @ban.each do |suji, dan, koma|
      next unless koma.type == :ou

      DIRECTIONS.each_key do |direct|
        pin_suji, pin_dan = search_koma(suji, dan, direct)
        
        # 味方の駒があるか
        if @ban.on_board?(pin_suji, pin_dan) &&
            @ban[pin_suji, pin_dan].belongs_to_player?(teban)
          
          # 敵の飛び駒があるか
          e_suji, e_dan = search_koma(pin_suji, pin_dan, direct)
          if @ban.on_board?(e_suji, e_dan) &&
              @ban[pin_suji, pin_dan].belongs_to_enemy?(teban) &&
              jumpable?(direct, koma_type(@ban[e_suji, e_dan]))
            pins["#{pin_suji}#{pin_dan}"] = direct
          end
        end
      end
    end
    pins
  end

  def pin_guard?(teban, suji, dan, koma, move)
    return false unless @pins.has_key?("#{suji}#{dan}")
=begin    
    if koma.pin_guard?(move, pins)
      true
    else
      false
    end
=end
    true
  end

  def promotable?(teban, koma, from_dan, to_dan)
    case koma.type
    when :fu, :kyosha, :keima, :gin, :kaku, :hisha
      case teban
      when :sente
        from_dan.between?(1, 3) || to_dan.between?(1, 3)
      when :gote
        from_dan.between?(7, 9) || to_dan.between?(7, 9)
      else
        raise TebanException
      end
    else
      false
    end
  end
  
  def gen_te_with_promote(teban, from_suji, from_dan, to_suji, to_dan, koma)
    te_next = []

    # 移動先が鳴りが必須
    if koma.must_promote?(teban, from_dan)
      te_next << gen_te(teban, from_suji, from_dan, to_suji, to_dan, koma, true) 
      return te_next
    end
    
    # 手の生成
    te_next << gen_te(teban, from_suji, from_dan, to_suji, to_dan, koma)
    if promotable?(teban, koma, from_dan, to_dan)
      # 鳴れる場合は鳴る手も指す
      te_next << gen_te(teban, from_suji, from_dan, to_suji, from_dan, koma, true) 
    end
    te_next
  end

  def gen_te(teban, from_suji, from_dan, to_suji, to_dan, koma, promote=false, capture=nil)
    koma = promote(koma) if promote
    Te.new(teban, Pos.new(from_suji, from_dan), Pos.new(to_suji, to_dan),
           koma, promote, capture)
  end
end
