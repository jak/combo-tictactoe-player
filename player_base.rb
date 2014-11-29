require 'state_machine'

require 'comboclient'

class BoardPos
  attr_reader :size
  
  def initialize(size)
    @size = size
  end
  
  def to_loc(x, y)
    x*@size + y
  end
  
  def from_loc(loc)
    loc.divmod @size
  end
end

class PlayerBase
  attr_reader :id
  attr_accessor :board
  
  def initialize(id, is_x, size=3)
    @id = id
    @pos = BoardPos.new(size)
    @board = Array.new(size*size)
    @is_x = is_x
  end
  
  def is_x?
    @is_x
  end
  
  def get(x, y)
    @board[@pos.to_loc(x, y)]
  end
  
  def set(x, y, v)
    @board[@pos.to_loc(x, y)] = v
  end
  
  def opponent_move(move)
    loc = @pos.to_loc(move['x'], move['y'])
    @board[loc] ||= @is_x ? :o : :x
  end
  
  def make_move(meta)
    raise NotImplementedError, 'Implement make_move!'
  end
end
