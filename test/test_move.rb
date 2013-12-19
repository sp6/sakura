# -*- coding: utf-8 -*-

require '../lib/shogi'
require '../lib/koma'
require '../lib/board'
require '../lib/kyokumen'

require 'test/unit'
require 'pp'

class TC_Shogi < Test::Unit::TestCase
  def setup
    @k = Kyokumen.new
  end
  
  def test_move
    ban = [[:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:kyosha, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty]]
    @k.ban = Board.create(ban)
    te = @k.generate_legal_moves :sente
    assert_equal(10, te.size)

    ban = [[:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:keima, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty]]
    @k.ban = Board.create(ban)
    te = @k.generate_legal_moves :sente
    assert_equal(1, te.size)

    ban = [[:empty, :empty, :empty, :empty, :ehisha, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :ehisha, :ryu, :empty],
           [:empty, :empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ou, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ehisha, :empty, :empty, :empty, :empty]]
    @k.ban = Board.create(ban)
    te = @k.generate_legal_moves :sente
    assert_equal(26, te.size)
    
=begin
    http://d.hatena.ne.jp/ak11/20091107
    後手の持駒：金　銀　桂　歩五
      ９ ８ ７ ６ ５ ４ ３ ２ １
    +---------------------------+
    |v香 ・ ・ ・ ・ ・ ・v桂v香|一
    | ・ ・ ・ ・ ・ と ・v金v玉|二
    | ・ ・v桂v歩 ・ 銀 ・ ・ ・|三
    |v歩 ・v歩 ・ ・ ・ ・ 歩v歩|四
    | ・ ・ ・ 歩 ・ ・ 銀v歩 ・|五
    | ・ 歩 歩v角 ・ ・ 歩 ・ 歩|六
    | 歩 ・ ・ ・ ・ ・ 金 銀 ・|七
    | 飛 ・ ・ ・ ・ ・ ・ ・ ・|八
    | 香 桂 ・ ・ ・ ・v角 玉 香|九
    +---------------------------+
    先手の持駒：飛　金
=end
    ban = [[:ekyosha, :empty, :empty, :empty, :empty, :empty, :empty, :ekeima, :ekyosha],
           [:empty, :empty, :empty, :empty, :empty, :to, :empty, :ekin, :eou],
           [:empty, :empty, :ekeima, :efu, :empty, :gin, :empty, :empty, :empty],
           [:efu, :empty, :efu, :empty, :empty, :empty, :empty, :fu, :efu],
           [:empty, :empty, :empty, :fu, :empty, :empty, :gin, :efu, :empty],
           [:empty, :fu, :fu, :ekaku, :empty, :empty, :fu, :empty, :fu],
           [:fu, :empty, :empty, :empty, :empty, :empty, :kin, :gin, :empty],
           [:hisha, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:kyosha, :keima, :empty, :empty, :empty, :empty, :ekaku, :ou, :kyosha]]
    @k.ban = Board.create(ban)
    @k.sente_hand = {
      fu: [], kyosha: [], keima: [], gin: [], kin: [Kin.new(1, :sente)],
      kaku: [], hisha: [Hisha.new(1, :sente)], ou: [] }
    @k.gote_hand = {
      fu: [Fu.new(1, :gote), Fu.new(1, :gote), Fu.new(1, :gote),
           Fu.new(1, :gote), Fu.new(1, :gote)],
      kyosha: [], keima: [Keima.new(1, :gote)], gin: [Gin.new(1, :gote)],
      kin: [Kin.new(1, :gote)], kaku: [], hisha: [], ou: []
    }
    te = @k.generate_legal_moves :sente
    assert_equal(143, te.size)

    ban = [[:empty, :empty, :empty, :empty, :ehisha, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :hisha, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ou, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty]]
    @k = Kyokumen.new
    @k.ban = Board.create(ban)
    te = @k.generate_legal_moves :sente
    assert_equal(16, te.size)
  end

  def test_search_pins
    ban = [[:empty, :empty, :empty, :empty, :ehisha, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :ehisha, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ou, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :fu, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty, :empty],
           [:ekaku, :empty, :empty, :empty, :ehisha, :empty, :empty, :empty, :empty]]
    @k.ban = Board.create(ban)
    pins = @k.search_pins :sente
    assert_equal({"53" => :up, "58" => :down, "77" => :downleft}, pins)
  end

  def test_move_back
    @k.ban = Board.create
   kifu = <<EOS
P1-KY-KE-GI-KI-OU-KI-GI-KE-KY
P2 * -HI *  *  *  *  * -KA * 
P3-FU-FU-FU-FU-FU-FU-FU-FU-FU
P4 *  *  *  *  *  *  *  *  * 
P5 *  *  *  *  *  *  *  *  * 
P6 *  *  *  *  *  *  *  *  * 
P7+FU+FU+FU+FU+FU+FU+FU+FU+FU
P8 * +KA *  *  *  *  * +HI * 
P9+KY+KE+GI+KI+OU+KI+GI+KE+KY
EOS
    te = Te.new(:sente, Pos.new(7, 7), Pos.new(7, 6), Fu.new)
    @k.move te
   kifu = <<EOS
P1-KY-KE-GI-KI-OU-KI-GI-KE-KY
P2 * -HI *  *  *  *  * -KA * 
P3-FU-FU-FU-FU-FU-FU-FU-FU-FU
P4 *  *  *  *  *  *  *  *  * 
P5 *  *  *  *  *  *  *  *  * 
P6 *  * +FU *  *  *  *  *  * 
P7+FU+FU * +FU+FU+FU+FU+FU+FU
P8 * +KA *  *  *  *  * +HI * 
P9+KY+KE+GI+KI+OU+KI+GI+KE+KY
EOS
    assert_equal(kifu, @k.ban.to_csa)

    te = Te.new(:sente, Pos.new(7, 7), Pos.new(7, 6), Fu.new)
    @k.back te
   kifu = <<EOS
P1-KY-KE-GI-KI-OU-KI-GI-KE-KY
P2 * -HI *  *  *  *  * -KA * 
P3-FU-FU-FU-FU-FU-FU-FU-FU-FU
P4 *  *  *  *  *  *  *  *  * 
P5 *  *  *  *  *  *  *  *  * 
P6 *  *  *  *  *  *  *  *  * 
P7+FU+FU+FU+FU+FU+FU+FU+FU+FU
P8 * +KA *  *  *  *  * +HI * 
P9+KY+KE+GI+KI+OU+KI+GI+KE+KY
EOS
    assert_equal(kifu, @k.ban.to_csa)
  end
end
