# -*- coding: utf-8 -*-
require 'set'
require 'pp'

module Tables
  PKOMA = {
    empty: " * ",
    fu: "+FU", ky: "+KY", ke: "+KE", gi: "+GI", ki: "+KI", ka: "+KA", hi: "+HI", ou: "+OU",
    to: "+TO", ny: "+NY", nk: "+NK", ng: "+NG", um: "+UM", ry: "+RY",
    efu: "-FU", eky: "-KY", eke: "-KE", egi: "-GI", eki: "-KI", eka: "-KA", ehi: "-HI", eou: "-OU",
    eto: "-TO", eny: "-NY", enk: "-NK", eng: "-NG", eum: "-UM", ery: "-RY" 
  }

  TO_S = {
    fu: "FU", ky: "KY", ke: "KE", gi: "GI", ki: "KI", ka: "KA", hi: "HI", ou: "OU",
    to: "TO", ny: "NY", nk: "NK", ng: "NG", um: "UM", ry: "RY",
    efu: "FU", eky: "KY", eke: "KE", egi: "GI", eki: "KI", eka: "KA", ehi: "HI", eou: "OU",
    eto: "TO", eny: "NY", enk: "NK", eng: "NG", eum: "UM", ery: "RY",
  }
  
  PLAYER_KOMA = Set.new([:fu, :ky, :ke, :gi, :ki, :ka, :hi, :ou, :to, :ny, :nk, :ng, :um, :ry])
  ENEMY_KOMA = Set.new([:efu, :eky, :eke, :egi,:eki, :eka, :ehi, :eou, :eto, :eny, :enk, :eng, :eum, :ery])
  HAND_KOMA = {
    efu: :fu, eky: :ky, eke: :ke, egi: :gi, eki: :ki, eka: :ka, ehi: :hi,
    eto: :fu, eny: :ky, enk: :ke, eng: :gi, eum: :ka, ry: :hi
  }

  JUMP_KOMA = {
    up: Set.new([:ky, :hi, :ry, :ehy, :ehi, :ery]),
    upright: Set.new([:ka, :um, :eka, :eum]),
    right: Set.new([:hi, :ry, :ehi, :ery]),
    downright: Set.new([:ka, :um, :eka, :eum]),
    down: Set.new([:hi, :ry, :ehi, :ery]),
    downleft: Set.new([:ka, :um, :eka, :eum]),
    left: Set.new([:hi, :ry, :ehi, :ery]),
    upleft: Set.new([:ka, :um, :eka, :eum])
  }
  
  FU_MOVEMENTS = [[0, -1]] # [suji, dan]
  KY_MOVEMENTS = (1..8).map { |h| [0, -h] }
  KE_MOVEMENTS = [[-1, -2], [1, -2]]
  GI_MOVEMENTS = [[-1, -1], [0, -1], [1, -1], [-1, 1], [1, 1]]
  KI_MOVEMENTS = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [0, 1]]
  KA_MOVEMENTS = [(1..8).map { |m| [m, -m] }, (1..8).map { |m| [m, m] },
                  (1..8).map { |m| [-m, m] }, (1..8).map { |m| [-m, -m] }]
  HI_MOVEMENTS = [(1..8).map { |h| [0, -h] }, (1..8).map { |h| [0, h] },
                  (1..8).map { |w| [w, 0] }, (1..8).map { |w| [-w, 0] }]
  OU_MOVEMENTS = [[-1, -1], [0, -1], [1, -1], [-1, 0], [1, 0], [-1, 1], [0, 1], [1, 1]]
  TO_MOVEMENTS = KI_MOVEMENTS
  NY_MOVEMENTS = KI_MOVEMENTS
  NK_MOVEMENTS = KI_MOVEMENTS
  NG_MOVEMENTS = KI_MOVEMENTS
  UM_MOVEMENTS = [[-1, 0], [1, 0], [0, -1], [0, 1]]
  RY_MOVEMENTS = [[-1, -1], [1, -1], [-1, 1], [1, 1]]

  MOVEMENTS = {
    fu: FU_MOVEMENTS, ky: KY_MOVEMENTS, ke: KE_MOVEMENTS, gi: GI_MOVEMENTS, ki: KI_MOVEMENTS,
    ka: KA_MOVEMENTS, hi: HI_MOVEMENTS, ou: OU_MOVEMENTS, to: TO_MOVEMENTS, ny: NY_MOVEMENTS,
    nk: NK_MOVEMENTS, ng: NG_MOVEMENTS, um: UM_MOVEMENTS, ry: RY_MOVEMENTS
  }
  
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
end
