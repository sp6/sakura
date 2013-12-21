# -*- coding: utf-8 -*-

class Human
  
  def next_te(teban, kyokumen)
    loop do
      input = gets.chomp
      unless input =~ /(\d{2})(\d{2})(\w{2})/
        puts "#{input}: 手を読み込めません"
        next
      end

      from = $1
      to = $2
      koma = create($3)
      if koma.nil?
        puts "#{input}: 手を読み込めません"
        next
      end

      te = Te.new(teban, Pos.new(from[0].to_i, from[1].to_i),
                  Pos.new(to[0].to_i, to[1].to_i), koma)
      te_valid = true
      begin
        kyokumen.move te
        kyokumen.back te
      rescue TeException
        te_valid = false
        puts "#{input}: 合法手ではありません"
      end
      return te if te_valid
    end
  end
  
  # TODO module?
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
      nil
    end
  end
end
