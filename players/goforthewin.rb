
require '../player_base.rb'

class GoForTheWin < GameBase

  @wins = [[0, 1 ,2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]

  def winning_board?
    @wins.each do |w|
      combination = []
      w.each { |p| combination << board[p] }
      return true if combination.join =~ /(.)\1\1/
    end
  end

  def make_move
    (0..8).each do |p|
      self.set_loc(p)
      return if winning_board?
      self.set_loc(p, nil)
    end
    # still here? no immediate winning move.
    self.set(rand(3), rand(3))
  end

end

