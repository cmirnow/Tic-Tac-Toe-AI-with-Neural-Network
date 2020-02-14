# frozen_string_literal: true

require 'ruby-fann'
require 'csv'
require 'progress_bar'
require 'tty-pie'
require_relative '../lib/game_board.rb'
require_relative '../lib/progress_bar.rb'
require_relative '../lib/artificial_intelligence.rb'

class Interface
  def initialize
    @game = GameBoard.new(@players)
  end

  def start
    puts ' '
    puts '********* MASTERPRO.WS PROJECT ***********'
    puts 'Welcome to Tic Tac Toe with Artificial Intelligence!'
    puts '--------------------------------'
    @player1 = 'Human'
    @player2 = 'AI'
    puts "Player X is #{@player1} & Player O is #{@player2}"
    display_board
  end

  def display_board
    puts "\n"
    puts " #{@game.board[0]} | #{@game.board[1]} | #{@game.board[2]} "
    puts ' ---------- '
    puts " #{@game.board[3]} | #{@game.board[4]} | #{@game.board[5]} "
    puts ' ---------- '
    puts " #{@game.board[6]} | #{@game.board[7]} | #{@game.board[8]} "
    puts "\n"
  end

  def turn
    if @game.current_player == :X
      print "#{@player1}, choose a position between 1-9: "
      spot = gets.strip
    else
      spot = AI.neural_network(@game.counter, @game.place?(4), @game.board, @game.fork_danger?)
    end
    spot = @game.board_index(spot)
    if @game.move_allowed?(spot)
      @game.enter_move(spot, @game.current_player)
      display_board
    else
      puts 'Invalid input value! Please try again.'
      display_board
      turn
    end
  end

  def play
    turn until @game.total
    if @game.won?
      if @game.who_has_won? == :X
        puts 'Congratulations, Human! You Won.'
      else
        puts 'Congratulations, AI! You Won.'
      end
    elsif @game.draw?
      puts 'Game over! Draw.'
    end
  end
end

game = Interface.new
game.start
game.play
