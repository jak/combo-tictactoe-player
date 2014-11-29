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

class Player
  attr_reader :id, :name, :game, :object
  
  def initialize(id, name, game_class)
    @id = id
    @name = name
    @game_class = game_class
    
    @object = {uuid: @id, name: @name}
  end
  
  def start_game(id, is_x)
    @game = @game_class.new(id, is_x)
    new_game
  end
  
  def new_game
    @game.new_game
  end
  
  def end_game
    @game. end_game
  end
end

class GameBase
  attr_reader :id, :board
  
  def initialize(id, is_x, size=3)
    @id = id
    
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
  
  def make_move(meta)
    raise NotImplementedError, 'Implement make_move!'
  end
  
  def new_game
    puts 'Starting new game.'
  end
  
  def end_game(win)
    puts "Game complete. Did#{win ? "" : "n't"} win."
  end
end
