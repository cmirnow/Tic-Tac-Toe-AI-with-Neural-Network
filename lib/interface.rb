# frozen_string_literal: true

require_relative 'game_board.rb'
class Interface
  @spots
  @board_all
  @players_move_order
  @count_spots
  @forks
  attr_accessor :spots, :board_all, :players_move_order, :count_spots, :forks

  def initialize
    @game = GameBoard.new(@players)
    @spots = []
    @board_all = []
    @players_move_order = []
    @count_spots = []
    @forks = []
  end

  def start
    puts 'The Artificial Intelligence training process works...'
    puts 'Please wait...'
    auxiliary
  end

  def auxiliary
    i = 0
    9.times do |i|
      @board_all.push(@game.board[i])
      i + 1
    end
    @count_spots.push(@game.counter)
  end

  def turn
    spot_tmp = rand(1..9)
    spot = @game.board_index(spot_tmp)
    if @game.move_allowed?(spot)
      @game.enter_move(spot, @game.current_player)
      @spots.push(spot_tmp)
      @players_move_order.push(@game.current_player_vv)
      if move_number_fork.nil?
        @forks.push(10)
      else
        @forks.push(move_number_fork)
    end
      start
    else
      turn
    end
  end

  # Find a move number of a possible fork:
  def move_number_fork
    current = @game.current_player
    if current == :O
      @count_spots.last if @game.fork?.size > 1
    end
  end

  def play
    turn until @game.total
  end

  def check
    turn until @game.total
    if @game.won?
      @game.who_has_won?
    elsif @game.draw?
      'draw'
    end
  end
  end
