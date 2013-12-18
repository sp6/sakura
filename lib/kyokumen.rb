# -*- coding: utf-8 -*-

class Kyokumen
  attr_accessor :ban

  def initialize(ban=nil, sente_hand=nil, gote_hand=nil)
    @ban ||= Board.new
    @sente_hand ||=  { fu: [], kyosha: [], keima: [], gin: [], kin: [], kaku: [], hisha: [] }
    @gote_hand ||=  { fu: [], kyosha: [], keima: [], gin: [], kin: [], kaku: [], hisha: [] }
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
        when :kyosha, :kaku, :hisha, :uma, :ryu
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
    
    hand.each do |mochigoma, ary|
      # 駒数が0の場合は次へ
      next if ary.size == 0
      
      case mochigoma.kaind_of?
      when :fu
        next if mochigoma.move_prohibited?(teban, dan)
        next if nifu?(teban, suji)
      when :kyosha, :keima
        next if mochigoma.move_prohibited?(teban, dan)
      end
      te_next << gen_te(teban, 0, 0, suji, dan, mochigoma)
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

      # 王の場合，桂馬の効きがあると移動できない
      next if koma.type == :ou && keima_kiki?(teban, next_suji, next_dan)
      
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
      suji += Shogi::DIRECTIONS[direct][:suji]
      dan += Shogi::DIRECTIONS[direct][:dan]
    end while @ban.on_board?(suji, dan) && @ban[suji, dan].type == :empty
    return suji, dan
  end

  def search_pins(teban)
    pins = Hash.new
    @ban.each do |suji, dan, koma|
      next unless koma.type == :ou

      Shogi::DIRECTIONS.each_key do |direct|
        pin_suji, pin_dan = search_koma(suji, dan, direct)
        
        # 味方の駒があるか
        if @ban.on_board?(pin_suji, pin_dan) &&
            @ban[pin_suji, pin_dan].belongs_to_player?(teban)
          
          # 敵の飛び駒があるか
          e_suji, e_dan = search_koma(pin_suji, pin_dan, direct)
          if @ban.on_board?(e_suji, e_dan) &&
              @ban[e_suji, e_dan].belongs_to_enemy?(teban) &&
              jump_koma?(direct, @ban[e_suji, e_dan].type)
            pins["#{pin_suji}#{pin_dan}"] = direct
          end
        end
      end
    end
    pins
  end
  
  def pin_guard?(teban, suji, dan, koma, move)
    if @pins.has_key?("#{suji}#{dan}")
      koma.pin_guard?(@pins["#{suji}#{dan}"], move)
    else
      false
    end
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
      te_next << gen_te(teban, from_suji, from_dan, to_suji, to_dan, koma, true) 
    end
    te_next
  end

  def gen_te(teban, from_suji, from_dan, to_suji, to_dan, koma, promote=false, capture=nil)
    koma = promote(koma) if promote
    Te.new(teban, Pos.new(from_suji, from_dan), Pos.new(to_suji, to_dan),
           koma, promote, capture)
  end

  def move(te)
    teban = te.teban
    from_masu = @ban[te.from.suji, te.from.dan]
    to_masu = @ban[te.to.suji, te.to.dan]
    hand = case teban
    when :sente
      hand = @sente_hand 
    when :gote
      hand = @gote_hand
    else
      raise TebanExcepton
    end
    
    if te.from.suji == 0 && te.from.dan == 0
      # 駒を打つ
      koma = hand[te.koma.type].shift
      @ban[te.to.suji, te.to.dan] = koma
    else
      # 駒を進める
      # 持ち駒とする
      if to_masu.belongs_to_enemy?(teban)
        to_masu.sengo = teban
        # 成りの場合は成らずに戻す
        capture = unpromote(to_masu)
        te.capture = capture
        hand[capture.type] << capture
        @ban[te.to.suji, te.to.dan] = Empty.new
      end
      if @ban[te.from.suji, te.from.dan].type != te.koma.type
        # 成り
        @ban[te.from.suji, te.from.dan] = promote(@ban[te.from.suji, te.from.dan])
      end
      @ban[te.from.suji, te.from.dan], @ban[te.to.suji, te.to.dan] =
        @ban[te.to.suji, te.to.dan], @ban[te.from.suji, te.from.dan]
    end
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
  
  def jump_koma?(direct, koma)
    Shogi::JUMP_KOMA[direct].include? koma
  end

  def promote(koma)
    id = koma.id
    sengo = koma.sengo
    case koma.type
    when :fu; To.new(id, sengo)
    when :kyosha; Narikyo.new(id, sengo)
    when :keima; Narikei.new(id, sengo)
    when :gin; Narigin.new(id, sengo)
    when :kaku; Uma.new(id, sengo)
    when :hisha; Ryu.new(id, sengo)
    else
      koma
    end
  end

  def unpromote(koma)
    id = koma.id
    sengo = koma.sengo
    case koma.type
    when :to; Fu.new(id, sengo)
    when :narikyo; Kyosha.new(id, sengo)
    when :narikei; Keima.new(id, sengo)
    when :narigin; Gin.new(id, sengo)
    when :uma; Kaku.new(id, sengo)
    when :ryu; Hisha.new(id, sengo)
    else
      koma
    end
  end
  
  def keima_kiki?(teban, suji, dan)
    if teban == :sente
      if @ban.on_board?(suji - 1, dan - 2)
        koma = @ban[suji - 1, dan - 2]
        if koma.type == :keima && koma.sengo == :gote
          true
        end
      elsif
        @ban.on_board?(suji + 1, dan - 2)
        koma = @ban[suji + 1, dan - 2]
        if koma.type == :keima && koma.sengo == :gote
          true
        end
      else
        false
      end
    elsif teban == :gote
      if @ban.on_board?(suji - 1, dan + 2)
        koma = @ban[suji - 1, dan + 2]
        if koma.type == :keima && koma.sengo == :sente
          true
        end
      elsif
        @ban.on_board?(suji + 1, dan + 2)
        koma = @ban[suji + 1, dan + 2]
        if koma.type == :keima && koma.sengo == :sente
          true
        end
      else
        false
      end
    else
      raise TebanException
    end
  end

  def to_csa
    csa_names = {
      fu: "FU", kyosha: "KY", keima: "KE", gin: "GI", kin: "KI", kaku: "KA", hisha: "HI"
    }
    puts_hand = lambda do |hand|
      hand.map { |koma, ary|
        csa_names[koma] + sprintf("%02d", ary.size) unless ary.size == 0
      }
    end
    res = @ban.to_csa
    res += "P+#{puts_hand.call(@sente_hand).join}\n"
    res += "P-#{puts_hand.call(@gote_hand).join}\n"
    res
  end
end
