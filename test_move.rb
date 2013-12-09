# -*- coding: utf-8 -*-

require 'test/unit'
require './shogi'

class TC_Shogi < Test::Unit::TestCase
  
  def setup
    @k = Kyokumen.new
    @ban = [[:eky, :eke, :egi, :eki, :eou, :eki, :egi, :eke, :eky],
           [:empty, :ehi, :empty, :empty, :empty, :empty, :empty, :eka, :empty],
           [:efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu, :efu],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu, :fu],
           [:empty, :ka, :empty, :empty, :empty, :empty, :empty, :hi, :empty],
           [:ky, :ke, :gi, :ki, :ou, :ki, :gi, :ke, :ky]]
  end
  
  def test_move
    ban = [[:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:ky, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty]]
    @k.ban = ban
    te = @k.make_moves(0)
    assert_equal(9, te.size, mu_pp(te))
    
    ban = [[:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:ke, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty]]
    @k.ban = ban
    te = @k.make_moves(0)
    assert_equal(1, te.size, mu_pp(te))

    ban = [[:empty, :empty, :empty, :empty, :ehi, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :ehi, :ry, :empty],
           [:empty, :empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ou, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ehi, :empty, :empty, :empty, :empty]]
    @k.ban = ban
    te = @k.make_moves(0)
    assert_equal(26, te.size, mu_pp(te))

    ban = [[:empty, :empty, :empty, :empty, :ehi, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :hi, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ou, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty]]
    @k.ban = ban
    te = @k.make_moves(0)
    assert_equal(16, te.size, mu_pp(te))
  end

  def test_make_pin_info
    ban = [[:empty, :empty, :empty, :empty, :ehi, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :ehi, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :ou, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :fu, :empty, :empty, :empty, :empty, :empty, :empty],
           [:empty, :empty, :empty, :empty, :fu, :empty, :empty, :empty, :empty],
           [:eka, :empty, :empty, :empty, :ehi, :empty, :empty, :empty, :empty]]
    @k.ban = ban
    pin_info = @k.make_pin_info
    assert_equal({"24" => :up, "74" => :down, "62" => :downleft}, pin_info, mu_pp(pin_info))
  end
end
