# -*- coding: utf-8 -*-
require 'pp'

class Kyokumen
  def fu?(koma) koma == :fu || koma == :efu end
  def ky?(koma) koma == :ky || koma == :eky end
  def ke?(koma) koma == :ke || koma == :eke end
  def gi?(koma) koma == :gi || koma == :egi end
  def ki?(koma) koma == :ki || koma == :eki end
  def ka?(koma) koma == :ka || koma == :eka end
  def hi?(koma) koma == :hi || koma == :ehi end
  def ou?(koma) koma == :ou || koma == :eou end
  def to?(koma) koma == :to || koma == :eto end
  def ny?(koma) koma == :ny || koma == :eny end
  def nk?(koma) koma == :nk || koma == :enk end
  def ng?(koma) koma == :ng || koma == :eng end
  def um?(koma) koma == :um || koma == :eum end
  def ry?(koma) koma == :ry || koma == :ery end

  def hit_koma(suji, dan, teban)
    te_next = []
    hand = (teban == :sente) ? @player_hand : @enemy_hand
    
    hand.each do |mochigoma, num|
      # 駒数が0の場合は次へ
      next if num == 0

      case mochigoma
      when :fu, :efu
        # 歩
        # 先手 1段には打たない
        next if teban == :sente && dan == 1
        # 後手 9段には打たない
        next if teban == :gote && dan == 9
        
        # 二歩になるなら打たない
        from = (teban == :sente) ? 2 : 1
        to = (teban == :sente) ? 9 : 8
        fu = (teban == :sente) ? :fu : :efu
        nifu = false
        (from..to).each do |d|
          if @ban[suji, d] == fu
            nifu = true
            break
          end
        end
        next if nifu
      when :ky, :eky
        # 香
        # 先手 1段には打たない
        next if teban == :sente && dan == 1
        # 後手 9段には打たない
        next if teban == :gote && dan == 9
      when :ke, :eke
        # 桂
        # 先手 1～2段には打たない
        next if teban == :sente && (1..2).include?(dan)
        # 後手 8～9段には打たない
        next if teban == :gote && (8..9).include?(dan)
      end
      te_next << create_te(-1, -1, suji, dan, mochigoma)
    end
    te_next
  end
  
  def fu_move(suji, dan, koma, sengo)
    te_next = []

    if @pin_info.has_key?("#{suji}#{dan}") && !(@pin_info["#{suji}#{dan}"] == :up || @pin_info["#{suji}#{dan}"] == :down)
      return te_next
    end

    Tables::MOVEMENTS[:fu].each do |move|
      next_suji = suji + move[0]          
      next_dan = dan + move[1]
      
      break unless @ban.on_board?(next_suji, next_dan)

      if next_dan == 1
        te_next << create_te(suji, dan, next_suji, next_dan, koma, true)
        break
      end

      # 手の生成
      te_next << create_te(suji, dan, next_suji, next_dan, koma)
      # 鳴れる場合は鳴る手も指す
      te_next << create_te(suji, dan, next_suji, next_dan, koma, true) if promotable?(next_dan)
    end
    te_next
  end

  def ky_move(suji, dan, koma, sengo)
    te_next = []
    
    # PINが効いているなだ移動できない
    if @pin_info.has_key?("#{suji}#{dan}") && !(@pin_info["#{suji}#{dan}"] == :up || @pin_info["#{suji}#{dan}"] == :down)
      return te_next
    end
    
    Tables::MOVEMENTS[:ky].each do |move|
      next_suji = suji + move[0]          
      next_dan = dan + move[1]
      
      # 盤外なら手を生成しない
      break unless @ban.on_board?(next_suji, next_dan)

      # 自分の駒がある場合は手は生成しない
      if player_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :sente
        break
      elsif enemy_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :gote
        break
      end
      
      # 敵の駒がある場合は手の生成を打ち切る
      if (enemy_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :sente) || (player_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :gote)
        te_next << create_te(suji, dan, next_suji, next_dan, koma)
        if promotable?(next_dan)
          te_next << create_te(suji, dan, next_suji, next_dan, koma, true)
        end
        break
      end

      # 1段の場合は必ず鳴る
      if next_dan == 1
        te_next << create_te(suji, dan, next_suji, next_dan, koma, true)
        break
      end

      # 手の生成
      te_next << create_te(suji, dan, next_suji, next_dan, koma)
      # 鳴れる場合は鳴る手も指す
      te_next << create_te(suji, dan, next_suji, next_dan, koma, true) if promotable?(next_dan)
    end
    te_next
  end

  def ke_move(suji, dan, koma, sengo)
    te_next = []
    
    if @pin_info.has_key?("#{suji}#{dan}")
      return te_next
    end

    Tables::MOVEMENTS[:ke].each do |move|
      next_suji = suji + move[0]
      next_dan = dan + move[1]

      # 自分の駒がある場合は手は生成しない
      if player_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :sente
        break
      elsif enemy_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :gote
        break
      end
    
      # 1～2段の場合は必ず鳴る
      if (1..2).include?(next_dan)
        te_next << create_te(suji, dan, next_suji, next_dan, koma, true)
        next
      end

      # 手の生成
      te_next << create_te(suji, dan, next_suji, next_dan, koma)
      # 鳴れる場合は鳴る手も指す
      te_next << create_te(suji, dan, next_suji, next_dan, koma, true) if promotable?(next_dan)
    end
    te_next
  end

  def gi_move(suji, dan, koma, sengo)
    te_next = []
    
    Tables::MOVEMENTS[:gi].each do |move|
      next_suji = suji + move[0]
      next_dan = dan + move[1]
      
      next unless @ban.on_board?(next_suji, next_dan)
      
      if @pin_info.has_key?("#{suji}#{dan}")
        next te_next unless movable?(move, @pin_info["#{suji}#{dan}"])
      end

      # 自分の駒がある場合は手は生成しない
      if player_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :sente
        next
      elsif enemy_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :gote
        next
      end

      # 手の生成
      te_next << create_te(suji, dan, next_suji, next_dan, koma)
      # 鳴れる場合は鳴る手も指す
      te_next << create_te(suji, dan, next_suji, next_dan, koma, true) if promotable?(next_dan)
    end
    te_next
  end

  def ki_move(suji, dan, koma, sengo)
    te_next = []
    
    Tables::MOVEMENTS[:ki].each do |move|
      next_suji = suji + move[0]
      next_dan = dan + move[1]
      
      next unless @ban.on_board?(next_suji, next_dan)
      
      if @pin_info.has_key?("#{suji}#{dan}")
        next te_next unless movable?(move, @pin_info["#{suji}#{dan}"])
      end

      # 自分の駒がある場合は手は生成しない
      if player_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :sente
        next
      elsif enemy_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :gote
        next
      end
      
      # 手の生成
      te_next << create_te(suji, dan, next_suji, next_dan, koma)
    end
    te_next
  end

  def ou_move(suji, dan, koma, sengo)
    te_next = []
    
    Tables::MOVEMENTS[:ou].each do |move|
      next_suji = suji + move[0]
      next_dan = dan + move[1]
      
      next unless @ban.on_board?(next_suji, next_dan)
      
      if @pin_info.has_key?("#{suji}#{dan}")
        next te_next unless movable?(move, @pin_info["#{suji}#{dan}"])
      end

      # 自分の駒がある場合は手は生成しない
      if player_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :sente
        next
      elsif enemy_koma?(sengo, @ban[next_suji, next_dan]) && sengo == :gote
        next
      end
      
      # 手の生成
      te_next << create_te(suji, dan, next_suji, next_dan, koma)
    end
    te_next
  end

  def ka_move(suji, dan, koma, sengo)
    te_next = []
    
    Tables::MOVEMENTS[:ka].each do |move|
      move.each do |mv|
        next_suji = suji - mv[0]
        next_dan = dan + mv[1]
        
        next unless @ban.on_board?(next_suji, next_dan)
        
        # pinの判断
        if @pin_info.has_key?("#{suji}#{dan}")
          if @pin_info["#{suji}#{dan}"] == :upright || @pin_info["#{suji}#{dan}"] == :downright
            unless (1..8).map { |m| [m, m] }.include?(mv) || (1..8).map { |m| [-m, m] }.include?(mv)
              next
            end
          elsif @pin_info["#{suji}#{dan}"] == :downleft || @pin_info["#{suji}#{dan}"] == :upleft
            unless(1..8).map { |m| [-m, -m] }.include?(mv) || (1..8).map { |m| [m, -m] }.include?(mv)
              next
            end
          else
            next
          end
        end
        
        # 自分の駒がある場合は手は生成しない
        if player_koma?(sengo, @ban[next_suji, next_dan])
          break
        end
        # 敵の駒がある場合は手の生成を打ち切る
        if enemy_koma?(sengo, @ban[next_suji, next_dan])
          te_next << create_te(suji, dan, next_suji, next_dan, koma)
          if promotable?(next_dan)
            te_next << create_te(suji, dan, next_suji, next_dan, koma, true)
          end
          break
        end
        # 手の生成
        te_next << create_te(suji, dan, next_suji, next_dan, koma)
        # 鳴れる場合は鳴る手も指す
        te_next << create_te(suji, dan, next_suji, next_dan, koma, true) if promotable?(next_dan)
      end
    end

    te_next
  end

  def hi_move(suji, dan, koma, sengo)
    te_next = []
    
    Tables::MOVEMENTS[:hi].each do |move|
      move.each do |mv|
        next_suji = suji + mv[0]
        next_dan = dan + mv[1]

        next unless @ban.on_board?(next_suji, next_dan)
            
        # pinの判断
        if @pin_info.has_key?("#{suji}#{dan}")
          if @pin_info["#{suji}#{dan}"] == :up || @pin_info["#{suji}#{dan}"] == :down 
            unless (1..8).map { |h| [h, 0] }.include?(mv) || (1..8).map { |h| [-h, 0] }.include?(mv)
              next
            end
          elsif @pin_info["#{suji}#{dan}"] == :right ||  @pin_info["#{suji}#{dan}"] == :left
            unless (1..8).map { |w| [0, w] }.include?(mv) || (1..8).map { |w| [0, -w] }.include?(mv)
              next
            end
          end
        end
        
        # 自分の駒がある場合は手は生成しない
        if player_koma?(sengo, @ban[next_suji, next_dan])
          break
        end
        # 敵の駒がある場合は手の生成を打ち切る
        if enemy_koma?(sengo, @ban[next_suji, next_dan])
          te_next << create_te(suji, dan, next_suji, next_dan, koma)
          if promotable?(next_dan)
            te_next << create_te(suji, dan, next_suji, next_dan, koma, true)
          end
          break
        end
        # 手の生成
        te_next << create_te(suji, dan, next_suji, next_dan, koma)
        # 鳴れる場合は鳴る手も指す
        te_next << create_te(suji, dan, next_suji, next_dan, koma, true) if promotable?(next_dan)
      end
    end
    te_next
  end

  def um_move(suji, dan, koma, sengo)
    te_next = []
    te_next += ka_move(suji, dan, :um, sengo)

    Tables::MOVEMENTS[:um].each do |move|
      next_suji = suji + move[0]
      next_dan = dan + move[1]

      next unless @ban.on_board?(next_suji, next_dan)
            
      # pinの判断
      if @pin_info.has_key?("#{suji}#{dan}")
        if @pin_info["#{suji}#{dan}"] == :up && move == [0, -1]
        elsif @pin_info["#{suji}#{dan}"] == :right && move == [1, 0]
        elsif @pin_info["#{suji}#{dan}"] == :down && move == [0, 1]
        elsif @pin_info["#{suji}#{dan}"] == :left && move == [-1, 0]
        else
          next
        end
      end
      # 手の生成
      te_next << create_te(suji, dan, next_suji, next_dan, koma)
    end
    te_next
  end

  def ry_move(suji, dan, koma, sengo)
    te_next = []
    te_next += hi_move(suji, dan, :ry, sengo)

    Tables::MOVEMENTS[:ry].each do |move|
      next_suji = suji + move[0]
      next_dan = dan + move[1]

      next unless @ban.on_board?(next_suji, next_dan)
      
      # pinの判断
      if @pin_info.has_key?("#{suji}#{dan}")
        if @pin_info["#{suji}#{dan}"] == :upright && move == [1, -1]
        elsif @pin_info["#{suji}#{dan}"] == :downright && move == [1, 1]
        elsif @pin_info["#{suji}#{dan}"] == :downleft && move == [-1, 1]
        elsif @pin_info["#{suji}#{dan}"] == :upleft && move == [-1, -1]
        else
          next
        end
      end
      # 手の生成
      te_next << create_te(suji, dan, next_suji, next_dan, koma)
    end
    te_next
  end
end
