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
      koma = Koma.create_from_csa_name($3, teban)
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
end
