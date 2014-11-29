require 'state_machine'

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
  attr_reader :id, :name
  
  def initialize(id, name)
    @id = id
    @name = name
  end
end

class GameBase
  attr_accessor :board
  
  def initialize(size=3, is_x)
    @is_x = is_x
    @my_char = @is_x ? :x : :o
    @their_char = @is_x ? :o : :x
    
    @pos = BoardPos.new(size)
    @board = Array.new(size*size)
  end
  
  def is_x?
    @is_x
  end
  
  def get(x, y)
    @board[@pos.to_loc(x, y)]
  end
  
  def set(x, y, v=nil)
    @board[@pos.to_loc(x, y)] ||= v || @my_char
  end
  
  def get_loc(loc)
    @board[loc]
  end
  
  def set_loc(loc, v=nil)
    @board[loc] ||= v || @my_char
  end
  
  def opponent_move(move)
    set(move['x'], move['y'], @their_char)
  end
  
  def new_game
    puts 'Starting new game.'
  end
  
  def make_move(meta)
    raise NotImplementedError, 'Implement make_move!'
  end
end
