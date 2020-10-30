# frozen_string_literal: true

require_relative './player.rb'
class GameBoard
  attr_reader :board, :player1, :player2, :X, :O
  def initialize(players, board = (1..9).to_a)
    @board = board
    @player1 = Player.new(players)
    @player2 = Player.new(players)
  end

  WINNING_TRIADS = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [6, 4, 2],
    [0, 4, 8]
  ].freeze

  def won?
    WINNING_TRIADS.detect do |x|
      @board[x[0]] == @board[x[1]] &&
        @board[x[1]] == @board[x[2]] &&
        place?(x[0])
    end
  end

  DANGEROUS_SITUATIONS_1 = [
    [6, 4, 2],
    [0, 4, 8]
  ].freeze

  DANGEROUS_SITUATIONS_2 = [
    [0, 4, 7],
    [0, 4, 5],
    [2, 4, 3],
    [2, 4, 7],
    [3, 4, 8],
    [1, 4, 8],
    [1, 4, 6],
    [5, 4, 6]
  ].freeze

  def fork_danger_1?
    DANGEROUS_SITUATIONS_1.detect do |x|
      @board[x[0]] == @board[x[2]] &&
        @board[x[0]] != @board[x[1]] &&
        @board[x[0]].class == @board[x[1]].class
    end
  end

  def fork_danger_2?
    DANGEROUS_SITUATIONS_2.detect do |x|
      @board[x[0]] == @board[x[2]] &&
        @board[x[0]] != @board[x[1]] &&
        @board[x[0]].class == @board[x[1]].class
    end
  end

  # Find a fork:
  def fork?
    WINNING_TRIADS.select do |x|
      @board[x[0]] == @board[x[1]] && @board[x[2]].class != @board[x[0]].class &&
        place_x?(x[0]) ||
        @board[x[1]] == @board[x[2]] && @board[x[0]].class != @board[x[2]].class &&
          place_x?(x[1]) ||
        @board[x[0]] == @board[x[2]] && @board[x[1]].class != @board[x[2]].class &&
          place_x?(x[0])
    end
  end

  def place?(index)
    @board[index] == :X || @board[index] == :O
  end

  def place_x?(index)
    @board[index] == :X
  end

  def counter
    @board.select { |v| v == :X || v == :O }.size
  end

  def enter_move(index, input)
    @board[index] = input
  end

  def board_index(index)
    index.to_i - 1
  end

  def move_allowed?(spot)
    spot.between?(0, 8) && !place?(spot)
  end

  def current_player
    (:X if counter.even?) || :O
  end

  def current_player_vv
    (:O if counter.even?) || :X
  end

  def no_seats?
    counter == 9
  end

  def draw?
    !won? && no_seats?
  end

  def total
    won? || no_seats? || draw?
  end

  def who_has_won?
    if @board[won?.first] == :X
      :X
    else
      :O
    end
  end
end
