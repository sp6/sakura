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

    ban = [[:empty, :empty, :empty, :empty, :ehisha, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :hisha, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ou, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty]]
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
end
