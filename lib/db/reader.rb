# -*- coding: utf-8 -*-

require '../koma'
require '../board'
require '../kyokumen'
require '../shogi'
require 'pp'

class Kifu
  attr_accessor :sente, :gote
  attr_accessor :event, :site
  attr_accessor :start_time, :end_time, :time_limit
  attr_accessor :opening, :others

  attr_accessor :sashite, :kyokumen, :cur_idx
  
  def initialize
    @cur_idx = 0
  end
  
  def forward
    return if @cur_idx > @sashite.size
    @kyokumen.move sashite[@cur_idx]
    @cur_idx += 1
  end

  def back
    return if @cur_idx <= 0
    @cur_idx -= 1
    @kyokumen.back sashite[@cur_idx]
  end

  def jump(idx)
    @cur_idx = idx
  end

  def cur_te
    @sashite[@cur_idx]
  end
  
  def sashite_each
    @sashite.each_with_index do |te, idx|
      forward
      yield @kyokumen, te, idx + 1
    end
  end
  
  def view
    @kyokumen.to_csa
  end
  
  def console_view
    loop do
      puts "f:forward,b:back,q:quit"
      go = gets.chomp
      if go == "f"
        forward
        puts "#{@cur_idx}:#{cur_te}"
        puts view
      elsif go == "b"
        back
        puts "#{@cur_idx} #{cur_te}"
        puts view
      elsif go == "q"
        break
      end
    end
  end
end

def create(csa_name)
  case csa_name
  when "FU"
    Fu.new
  when "KY"
    Kyosha.new
  when "KE"
    Keima.new
  when "GI"
    Gin.new
  when "KI"
    Kin.new
  when "KA"
    Kaku.new
  when "HI"
    Hisha.new
  when "OU"
    Ou.new
  when "TO"
    To.new
  when "NY"
    Narikyo.new
  when "NK"
    Narikei.new
  when "NG"
    Narigin.new
  when "UM"
    Uma.new
  when "RY"
    Ryu.new
  else
  end
end

dir_name = "../../data/"
file_name = "example.csa"
file_name = "Semifinal_tsutsukana+yss.csa"

kifu = Kifu.new
sashite = Array.new
File.foreach(dir_name + file_name) do |line|
  case line
  when /^'.*/ # コメント
    ;
  when /^N\+(.*)/ # 先手
    kifu.sente = $1
  when /^N\-(.*)/ # 後手
    kifu.gote = $1
  when /\$EVENT:(.*)/ # 棋戦名
    kifu.event = $1
  when /\$SITE:(.*)/ # 対局場所
    kifu.site = $1
  when /\$START_TIME:(.*)/ # 対局開始日時
    kifu.start_time = $1
  when /\$END_TIME:(.*)/ # 対局終了日時
    kifu.end_time = $1
  when /\$TIME_LIMIT:(.*)/ # 持ち時間
    kifu.time_limit = $1
  when /\$OPENING:(.*)/ # 戦型
    kifu.opening = $1
  when /\$(.*):(.*)/ # 補足
    kifu.others ||= Hash.new
    kifu.others[$1] = $2
  when /^\+(\d{2})(\d{2})(\w{2})/
    from = $1
    to = $2
    koma = create($3)
    sashite << Te.new(:sente, Pos.new(from[0].to_i, from[1].to_i),
                       Pos.new(to[0].to_i, to[1].to_i), koma)
  when /^\-(\d{2})(\d{2})(\w{2})/
    from = $1
    to = $2
    koma = create($3)
    sashite << Te.new(:gote, Pos.new(from[0].to_i, from[1].to_i),
                       Pos.new(to[0].to_i, to[1].to_i), koma)
  # 平手初期配置と駒落ち
  end
end

kifu.sashite = sashite
kifu.kyokumen = Kyokumen.new
kifu.console_view
=begin
kifu.sashite_each do |kyokumen, te, tesuu|
  puts "#{tesuu}:#{te}"
  puts kyokumen.to_csa
  gets
end
=end