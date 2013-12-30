# -*- coding: utf-8 -*-

class Kyokumen
  attr_accessor :teban, :ban, :hand

  def initialize(args=nil)
    if args.nil?
      @teban = :sente
      @ban = Board.new
      @hand = {
        sente: {
          fu: 0, kyosha: 0, keima: 0, gin: 0, kin: 0, kaku: 0, hisha: 0
        },
        gote: {
          fu: 0, kyosha: 0, keima: 0, gin: 0, kin: 0, kaku: 0, hisha: 0
        }
      }
    else
      @teban = args[:teban] || :sente
      @ban = args[:ban] || Board.new
      @hand = args[:hand] || {
        sente: {
          fu: 0, kyosha: 0, keima: 0, gin: 0, kin: 0, kaku: 0, hisha: 0
        },
        gote: {
          fu: 0, kyosha: 0, keima: 0, gin: 0, kin: 0, kaku: 0, hisha: 0
        }
      }
      @evaluator = Evaluator.new
    end
  end
  
  # 合法手を生成
  def generate_legal_moves
    @pins = search_pins
    
    te_next = []
    # 王手がかかっていたら防ぐ手を生成
    # if make_anti_oute
    
    # 盤上の駒を進める手の生成
    @ban.each do |suji, dan, koma|
      if koma.type == :empty
        # 盤に持ち駒を打つ手を生成
        te_next += hit_koma(suji, dan)
      else
        # 自分の駒であるかどうかを確認
        next unless koma.belongs_to_player?(@teban)
        
        case koma.type
        when :fu, :keima, :gin, :kin, :ou
          te_next += genarate_legal_step_moves(suji, dan, koma)
        when :kyosha, :kaku, :hisha, :uma, :ryu
          te_next += genarate_legal_jump_moves(suji, dan, koma)
        end
      end
    end
      
    te_next
  end
  
   # 打つ手を生成
  def hit_koma(suji, dan)
    te_next = []
    
    player_hand.each do |koma, num|
      # 駒数が0の場合は次へ
      next if num == 0
      
      case koma
      when :fu
        next if fu_move_prohibited?(dan)
        next if nifu?(suji)
      when :kyosha
        next if kyosha_move_prohibited?(dan)
      when :keima
        next if keima_move_prohibited?(dan)
      end
      te_next << genarate_te(0, 0, suji, dan, Koma.create(koma, @teban))
    end
    te_next
  end
  
  def player_hand
    @hand[@teban]
  end
    
  def genarate_legal_step_moves(suji, dan, koma)
    te_next = []
    
    koma.movements.each do |move|
      next_suji, next_dan = add_move(suji, dan, move)
      
      # 移動先が盤外の場合は手は生成しない
      next unless @ban.on_board?(next_suji, next_dan)
      
      # 移動先に自分の駒がある場合は手は生成しない
      next if @ban[next_suji, next_dan].belongs_to_player?(@teban)
      
      # PINの場合は移動不可
      next if pin_defence?(suji, dan, koma, move)
      
      # 手を生成
      te_next += genarate_te_with_promote(suji, dan, next_suji, next_dan, koma)
    end
    te_next
  end
  
  def genarate_legal_jump_moves(suji, dan, koma)
    te_next = []
    
    koma.movements.each do |movements|
      movements.each do |move|
        next_suji, next_dan = add_move(suji, dan, move)
        
        # 移動先が盤外の場合は手の生成を打ち切る
        break unless @ban.on_board?(next_suji, next_dan)
        
        # 自分の駒がある場合は手の生成を打ち切る
        break if @ban[next_suji, next_dan].belongs_to_player?(@teban)
        
        # PINの場合は移動不可
        next if pin_defence?(suji, dan, koma, move)
        
        # 手を生成
        te_next += genarate_te_with_promote(suji, dan, next_suji, next_dan, koma)
        
        # 敵の駒がある場合は手の生成を打ち切る
        break if @ban[next_suji, next_dan].belongs_to_enemy?(@teban)
      end
    end
    
    te_next
  end
  
  def add_move(suji, dan, move)
    case @teban
    when :sente
      [suji + move[0], dan + move[1]]
    when :gote
      [suji - move[0], dan - move[1]]
    end
  end
  
  def search_koma(suji, dan, direct)
    begin
      suji += Shogi::DIRECTIONS[direct][:suji]
      dan += Shogi::DIRECTIONS[direct][:dan]
    end while @ban.on_board?(suji, dan) && @ban[suji, dan].type == :empty
    return suji, dan
  end
  
  def search_pins
    pins = Hash.new
    @ban.each do |suji, dan, koma|
      next unless koma.type == :ou
      
      Shogi::DIRECTIONS.each_key do |direct|
        pin_suji, pin_dan = search_koma(suji, dan, direct)
        
        # 味方の駒があるか
        if @ban.on_board?(pin_suji, pin_dan) &&
            @ban[pin_suji, pin_dan].belongs_to_player?(@teban)
          
          # 敵の飛び駒があるか
          e_suji, e_dan = search_koma(pin_suji, pin_dan, direct)
          if @ban.on_board?(e_suji, e_dan) &&
              @ban[e_suji, e_dan].belongs_to_enemy?(@teban) &&
              jump_koma?(direct, @ban[e_suji, e_dan].type)
            pins["#{pin_suji}#{pin_dan}"] = direct
          end
        end
      end
    end
    pins
  end
  
  # PINされている駒かどうか
  def pin_defence?(suji, dan, koma, move)
    return false unless @pins.has_key?("#{suji}#{dan}")
    
    case koma.type
    when :fu
      fu_pin_defence?(@pins["#{suji}#{dan}"], move)
    when :kyosha
      kyosha_pin_defence?(@pins["#{suji}#{dan}"], move)
    when :kaku
      kaku_pin_defence?(@pins["#{suji}#{dan}"], move)
    when :hisha
      hisha_pin_defence?(@pins["#{suji}#{dan}"], move)
    when :uma
      uma_pin_defence?(@pins["#{suji}#{dan}"], move)
    when :ryu
      ryu_pin_defence?(@pins["#{suji}#{dan}"], move)
    when :gin, :kin, :to, :narikyo, :narikei, :narigin
      other_pin_defence?(@pins["#{suji}#{dan}"], move)
    else
      true
    end
  end
  
  def fu_pin_defence?(direct, move)
    if direct == :up || direct == :down
      # 段方向の移動は可
      false
    else
      true
    end
  end
  
  alias_method :kyosha_pin_defence?, :fu_pin_defence?
  
  def kaku_pin_defence?(direct, move)
    if direct == :upright || direct == :downleft
      move[0] != move[1]
    elsif direct == :upleft || direct == :downright
      move[0] == move[1]
    else
      true
    end
  end
  
  def hisha_pin_defence?(direct, move)
    if direct == :up || direct == :down
      # 段方向の移動は可
      move[0] != 0
    elsif direct == :right || direct == :left
      # 筋方向の移動は可
      move[1] != 0
    else
      true
    end
  end
    
  def uma_pin_defence?(direct, move)
    if direct == :upright || direct == :downleft
      move[0] != move[1]
    elsif direct == :upleft || direct == :downright
      move[0] == move[1]
    else
      other_pin_defence?(direct, move)
    end
  end
  
  def ryu_pin_defence?(direct, move)
    if direct == :up || direct == :down
      # 段方向の移動は可
      move[0] != 0
    elsif direct == :right || direct == :left
      # 筋方向の移動は可
      move[1] != 0
    else
      other_pin_defence?(direct, move)
    end
  end
  
  def other_pin_defence?(direct, move)
    if Shogi::DIRECTIONS[direct] == move
      false
    else
      true
    end
  end
  
  # 成りが可能か
  def promotable?(koma, from_dan, to_dan)
    case koma.type
    when :fu, :kyosha, :keima, :gin, :kaku, :hisha
      case @teban
      when :sente
        from_dan.between?(1, 3) || to_dan.between?(1, 3)
      when :gote
        from_dan.between?(7, 9) || to_dan.between?(7, 9)
      end
    else
      false
    end
  end
  
  # 成る手も含めて手を生成する
  def genarate_te_with_promote(from_suji, from_dan, to_suji, to_dan, koma)
    te_next = []
    
    # 移動先が鳴りが必須
    promote_only = false
    case koma.type
    when :fu
      promote_only = true if fu_must_promote?(to_dan)
    when :kyosha
      promote_only = true if kyosha_must_promote?(to_dan)
    when :keima
      promote_only = true if keima_must_promote?(to_dan)
    end
    if promote_only
      te_next << genarate_te(from_suji, from_dan, to_suji, to_dan, koma, true) 
      return te_next
    end
    
    # 手の生成
    if promotable?(koma, from_dan, to_dan)
      # 鳴れる場合は鳴る手も指す
      te_next << genarate_te(from_suji, from_dan, to_suji, to_dan, koma)
      te_next << genarate_te(from_suji, from_dan, to_suji, to_dan, koma, true) 
    else
      te_next << genarate_te(from_suji, from_dan, to_suji, to_dan, koma)      
    end
    te_next
  end
  
  # 手を生成する
  def genarate_te(from_suji, from_dan, to_suji, to_dan, koma, promote=false, capture=nil)
    koma = Koma.promote(koma) if promote
    Te.new(@teban, Pos.new(from_suji, from_dan), Pos.new(to_suji, to_dan),
           koma, promote, capture)
  end
  
  # 1手進める
  def move(te)
    teban = te.teban
    from_masu = @ban[te.from.suji, te.from.dan]
    to_masu = @ban[te.to.suji, te.to.dan]
    return if to_masu.type == :ou # TODO
    
    raise TeException if to_masu.belongs_to_player?(teban)
    if te.from.suji == 0 && te.from.dan == 0
      # 持ち駒を打つ場合
      raise TeException if @hand[teban][te.koma.type] == 0
      @hand[teban][te.koma.type] -= 1
      @ban[te.to.suji, te.to.dan] = Koma.create(te.koma.type, teban)
    else
      # 駒を進める場合
      raise TeException unless from_masu.belongs_to_player?(teban)
      
      # 敵の駒がある場合は敵の駒を取る
      if to_masu.belongs_to_enemy?(teban)
        # 指し手に取った駒を記録する
        te.capture = to_masu
        # 駒が成りの場合は成らずに戻して持ち駒に加える
        @hand[teban][Koma.unpromote(to_masu).type] += 1
        @ban[te.to.suji, te.to.dan] = Koma::EMP
      end
      
      # 駒が成る場合
      if from_masu.type != te.koma.type
        # 駒を成る
        @ban[te.from.suji, te.from.dan] = Koma.promote(from_masu)
        # 指し手に駒の成りを記録する
        te.promote = true
      end
      
      # 駒を進める
      @ban[te.from.suji, te.from.dan], @ban[te.to.suji, te.to.dan] =
        @ban[te.to.suji, te.to.dan], @ban[te.from.suji, te.from.dan]
    end
    # 取った駒や駒の成りを更新した手を返す
    te
  end
  
  # 1手戻す  
  def back(te)
    teban = te.teban
    from_masu = @ban[te.from.suji, te.from.dan]
    to_masu = @ban[te.to.suji, te.to.dan]

    # TODO
    if to_masu.type == :ou
      if to_masu.gote? && teban == :sente
        return
      elsif to_masu.sente? && teban == :gote
        return
      end
    end
        
    # 移動先の駒が自分の駒か
    raise TeException unless to_masu.belongs_to_player?(teban)
    
    if te.from.suji == 0 && te.from.dan == 0
      # 打った駒を持ち駒に戻す場合
      @hand[teban][te.koma.type] += 1
      @ban[te.to.suji, te.to.dan] = Koma::EMP
    else
      # 進めた駒を戻す場合
      # 移動元の駒が自分の駒ではないか
      raise TeException if from_masu.belongs_to_player?(teban)
      
      # 駒を戻す
      @ban[te.from.suji, te.from.dan], @ban[te.to.suji, te.to.dan] =
        @ban[te.to.suji, te.to.dan], @ban[te.from.suji, te.from.dan]
      
      unless te.capture.nil?
        # 敵の駒を取っていた場合は持ち駒から戻す
        @ban[te.to.suji, te.to.dan] = te.capture
        @hand[teban][Koma.unpromote(te.capture).type] -= 1
      end
      
      if te.promote
        # 成っていた場合は成らずに戻す
        @ban[te.from.suji, te.from.dan] = Koma.unpromote(@ban[te.from.suji, te.from.dan])
      end
    end
  end
  
  def evaluate
    @evaluator.evaluate(self, @teban)
  end
  
  def jump_koma?(direct, koma)
    Shogi::JUMP_KOMA[direct].include? koma
  end
  
  def fu_move_prohibited?(dan)
    case @teban
    when :sente
      dan == 1
    when :gote
      dan == 9
    end
  end
  
  alias_method :kyosha_move_prohibited?, :fu_move_prohibited?
  alias_method :fu_must_promote?, :fu_move_prohibited?
  alias_method :kyosha_must_promote?, :fu_move_prohibited?
  
  def keima_move_prohibited?(dan)
    case @teban
    when :sente
      dan.between?(1, 2)
    when :gote
      dan.between?(8, 9)
    end
  end

  alias_method :keima_must_promote?, :keima_move_prohibited?
  
  def nifu?(suji)
    nifu = false
    (1..9).each do |dan|
      if @ban[suji, dan].type == :fu
        return true
      end
    end
    return false
  end
  
  def to_csa
    csa_names = {
      fu: "FU", kyosha: "KY", keima: "KE", gin: "GI", kin: "KI", kaku: "KA", hisha: "HI"
    }
    hand_to_s = lambda do |hand|
      hand.map { |koma, num|
        csa_names[koma] + sprintf("%02d", num) unless num == 0
      }.join
    end
    res = @ban.to_csa
    res += "P+#{hand_to_s.call(@hand[:sente])}\n"
    res += "P-#{hand_to_s.call(@hand[:gote])}\n"
    res
  end
end
