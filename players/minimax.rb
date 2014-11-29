
require '../player_base.rb'

class Minimax < GameBase

  def make_move
    set_loc(get_next_move)
  end

  private

  def get_next_move(depth = 0)
    available_spaces.each do |space|
      set_loc(space)
      best_score[space] = -1 * get_next_move(depth + 1)
      set_loc(space, nil)
    end

    best_move = best_score.max_by { |k,v| v }[0]
    highest_score = best_score.max_by { |k, v| v }[1]

    if depth == 0
      return best_move
    elsif depth > 0
      return highest_score
    end
  end

  def available_spaces
    spaces = []
    board.each_with_index do |mark, index|
      spaces << index if mark == nil
    end
    spaces
  end

end

