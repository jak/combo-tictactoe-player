
require './../player_base'

class Idiot < PlayerBase
  def make_move
    self.set(rand(3), rand(3))
  end
end

