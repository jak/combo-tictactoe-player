
require '../player_base.rb'

class Idiot < GameBase
  def make_move
    self.set(rand(3), rand(3))
  end
end

