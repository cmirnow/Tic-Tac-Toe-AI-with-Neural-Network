# frozen_string_literal: true

require 'ruby-fann'
require 'csv'
require_relative '../lib/game_board.rb'
require_relative '../lib/player.rb'

class Interface
  def initialize
    @game = GameBoard.new(@players)
  end

  def start
    puts ' '
    puts '********* TIC TAC TOE ***********'
    puts 'Welcome to Game with Artificial Intelligence!'
    puts '--------------------------------'
    @player1 = 'Human'
    @player2 = 'AI'
    puts "Player X is #{@player1} & Player O is #{@player2}"
    puts ' '
    display_board
  end

  def final
    puts 'Thank you for playing Tic Tac Toe'
end

  def display_board
    puts " #{@game.board[0]} | #{@game.board[1]} | #{@game.board[2]} "

    puts ' ---------- '

    puts " #{@game.board[3]} | #{@game.board[4]} | #{@game.board[5]} "

    puts ' ---------- '

    puts " #{@game.board[6]} | #{@game.board[7]} | #{@game.board[8]} "
  end

  def turn
    if @game.current_player == :X
      print "\n #{@player1}, choose a position between 1-9: "
      spot = gets.strip
    else
      print "\n AI works. Please wait..."
      spot = neural_network
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
        puts "CONGRATULATIONS #{@player1}! You Won"
      else
        puts "CONGRATULATIONS #{@player2}! You Won"
      end
    elsif @game.draw?
      puts "It's a draw!"
    end
  end

  def first_move
    if !@game.place?(4)
      puts 5
      5
    else
      puts 1
      1
    end
  end

  def neural_network
    if @game.counter == 1
      first_move
    else
      x_data = []
      y_data = []
      fann_results_array = []
      unacceptable_moves_array = []
      array_of_moves_to_fork = []
      current_position = @game.board.to_s

      # Create a list of unacceptable moves and a list of moves leading to fork:
      CSV.foreach('ss.csv', headers: false) do |row|
        row.each do |e|
          next unless e == current_position
          if row[6].to_i - row[3].to_i == 2 && row[4] == 'O' && row[2].to_f != 0.4
            unacceptable_moves_array << row[0]
          end
          unless row[5].nil?
            array_of_moves_to_fork << row[0] if row[3].to_i == row[5].to_i
          end
        end
      end

      print "\n Unacceptable moves: " + unacceptable_moves_array.uniq.to_s + "\n"
      print "\n List of moves leading to fork: " + array_of_moves_to_fork.uniq.to_s + "\n"
      print "\n"

      CSV.foreach('ss.csv', headers: false) do |row|
        row.each do |e|
          next unless e == current_position
          next unless row[4] == 'O'
          unless unacceptable_moves_array.include? (row[0])
            if row[6].to_i - row[3].to_i == 1
              x_data.push([row[0].to_i])
              y_data.push([1])
            elsif row[6].to_i - row[3].to_i == 3 || row[6].to_i - row[3].to_i == 5
              if array_of_moves_to_fork.include? (row[0])
                x_data.push([row[0].to_i])
                y_data.push([0.3])
              else
                x_data.push([row[0].to_i])
                y_data.push([0.5])
              end
            else
              x_data.push([row[0].to_i])
              y_data.push([row[2].to_f])
            end
          end
        end
      end

      begin
        train = RubyFann::TrainData.new(inputs: x_data, desired_outputs: y_data)
        model = RubyFann::Standard.new(
          num_inputs: 1,
          hidden_neurons: [4],
          num_outputs: 1
        )
        model.train_on_data(train, 5000, 500, 0.01)
        x_data.flatten.each do |i|
          fann_results_array << model.run([i])
        end
      rescue StandardError
        []
        puts "\n AI sees no way to continue the game. :("
        exit
      end

      print "\n x_data=" + x_data.to_s
      print "\n FANN results" + fann_results_array.to_s
      result = x_data[fann_results_array.index(fann_results_array.max)]
      puts ''
      puts "\n AI MOVE: " + result[0].to_s
      puts ''
      result[0]
    end
  end
end

game = Interface.new
game.start
game.play
game.final
