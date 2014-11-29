
require './goforthewin'

class Block < GoForTheWin

  def make_move
    0..8.each do |pos|
      set_loc(pos, opponent_xo)
      if winning_board?
        set_loc(pos)
        break
      end
      set_loc(pos, nil)
    end
    super
  end

  private

  def opponent_xo
    return :o if is_x?
    return :x
  end

end
