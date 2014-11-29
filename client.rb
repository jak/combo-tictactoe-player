#!/usr/bin/env ruby
require 'active_support/all'
require 'state_machine'

require 'comboclient'

require './player_base'

COMBO = 'http://combo-squirrel.herokuapp.com'

def combo(topic)
  ComboClient.new(COMBO, topic.to_s)
end

class Client
  state_machine :state, :initial => :disconnected do
    before_transition :on => :connect, :do => :combo_connect
    
    before_transition :on => :join, :do => :player_join
    before_transition :on => :get_ready, :do => :player_ready
    
    before_transition :move_zero => any, :do => :create_game
    
    around_transition :hook_transition
    
    state :disconnected do
      def connected?
        false
      end
    end
    
    event :connect do
      transition :disconnected => :inactive
    end
    after_transition :on => :connect, :do => :join
    
    state any - :disconnected do
      def connected?
        true
      end
    end
    
    event :join do
      transition :inactive => :joined
    end
    after_transition :on => :join, :do => :get_ready
    
    event :get_ready do
      transition :joined => :ready
    end
    
    event :start_game do
      transition :ready => :move_zero
    end
    
    event :we_play do
      transition [:move_zero, :ours] => :theirs
    end
    
    event :they_play do
      transition [:move_zero, :theirs] => :ours
    end
    
    event :end_game do
      transition [:move_zero, :theirs, :ours] => :inactive
    end
    
    after_failure do |transition|
      puts "Transition failed: #{transition}"
    end
  end
  
  def initialize(game_class)
    @id = SecureRandom.uuid.gsub('-', '')
    @player = Player.new(@id, game_class.name, game_class)
    
    super()
  end
  
  def hook_transition(transition)
    print "#{transition.from} => #{transition.to}... "
    yield
    puts "Done"
  end
  
  def combo_connect
    # Publish
    @player_joined = combo('player.joined')
    @player_ready = combo('player.ready')
    @player_quit = combo('player.quit')
    
    # Subscribe
    subs = {}
    subs[:game_start] = combo('game.start')
    subs[:game_end] = combo('game.end')
    subs[:invalid_move] = combo('game.invalidmove')
    subs[:accepted_move] = combo('game.acceptedmove')
    
    client = self
    subs.each do |k, v|
      meth = client.method(:"on_#{k}")
      Thread.new do
        v.subscribe do |msg, mgr|
          meth[msg, mgr]
        end
      end
    end
  end
  
  # {transition/event}-triggered methods
  def player_join
    @player_joined.add({player: @player.object})
  end
  
  def player_ready
    @player_ready.add({player: @player.object})
  end
  
  def player_quit
    @player_quit.add({player: @player.object})
  end
  
  def create_game(transition)
    @player.start_game(
      @game_id,
      transition.from_name == :move_zero && transition.to_name == :theirs
    )
  end
  
  # Network-triggered methods
  def on_game_start(msg, mgr)
    return unless @player.id.in? msg.values
    @game_id = msg['game_id']
    start_game
  end
  
  def on_game_end(msg, mgr)
    end_game
  end
  
  def on_invalid_move(msg, mgr)
    end_game
  end
  
  def on_accepted_move(msg, mgr)
    return unless @game_id.in? msg.values
  end
end

class Game < GameBase
end

client = Client.new(Game)
client.connect