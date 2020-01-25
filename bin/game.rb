# frozen_string_literal: true

require 'ruby-fann'
require 'csv'
require 'progress_bar'
require 'tty-pie'
require_relative '../lib/game_board.rb'
require_relative '../lib/progress_bar.rb'

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
        puts 'Congratulations, Human! You Won.'
      else
        puts 'Congratulations, AI! You Won.'
      end
    elsif @game.draw?
      puts 'Game over! Draw.'
    end
  end

  def first_move
    progress
    if !@game.place?(4)
      puts "\nAI MOVE: 5"
      5
    else
      puts "\nAI MOVE: 1"
      1
    end
  end

  def progress
    0.step(80, 5) do |i|
      printf("\rAI works. Please wait... [%-16s]", '#' * (i / 5))
      sleep(0.1)
    end
    puts
  end

  def nn_arrays
    unacceptable_moves_array = []
    array_of_moves_to_fork = []
    angle_attack_moves_array = []
    current_position = @game.board.to_s
    print_info_3
    # Create a list of unacceptable moves, a list of moves leading to fork, a list of attacking moves:
    CSV::WithProgressBar.foreach('ss.csv', headers: false) do |row|
      row.each do |e|
        next unless e == current_position

        if row[6].to_i - row[3].to_i == 2 && row[4] == 'O' && row[2].to_f != 0.2
          unacceptable_moves_array << row[0]
        # Find moves that inevitably lead to a fork:
        elsif fork_danger? && row[3].to_i == 3 && row[0].to_i.odd?
          unacceptable_moves_array << row[0]
        end
        next if row[5].nil?

        # Find moves that may lead to a fork:
        array_of_moves_to_fork << row[0] if row[3].to_i == row[5].to_i
        # Find attacking moves:
        if row[3].to_i == row[5].to_i && row[6].to_i < 7 && row[0].to_i.odd?
          angle_attack_moves_array << row[0]
        end
      end
    end
    [unacceptable_moves_array, array_of_moves_to_fork, angle_attack_moves_array]
  end

  def fork_danger?
    @game.fork_danger?
  end

  def print_info(a, b, c)
    print "\n"
    [[a, "\n Unacceptable moves: "],
     [b, "\n List of moves leading to fork: "],
     [c, "\n Angle attack moves: "]].each do |i|
      print i[1] + i[0].uniq.to_s + "\n" if i[0].any?
    end
    print "\n"
  end

  def print_info_1(a, b, c)
    print "\n x_data=" + a.to_s + "\n"
    print "\n FANN results: " + b.to_s + "\n"
    puts ''
    chart(a, b)
    puts ''
    puts "\n AI MOVE: " + c.to_s
  end

  def print_info_2
    puts "\n AI sees no way to continue the game. :( Try deleting ss.csv and run the program again."
  end

  def print_info_3
    puts 'AI works. Please wait...'
  end

  def chart(a, b)
    tmp = []
    colors = %i[cyan red green yellow white magenta]
    data = [
      a.zip(b).uniq.each_with_index do |i, index|
        tmp << { name: i[0].join.to_i, value: i[1].join.to_f, color: colors[index], fill: i[0].join.to_s }
      end
    ]
    pie_chart = TTY::Pie.new(data: tmp, radius: 6, legend: { format: '%<label>s %<percent>.2f%%' })
    print pie_chart
  end

  def nn_data
    current_position = @game.board.to_s
    x_data = []
    y_data = []
    arrays = nn_arrays
    print_info(arrays[0], arrays[1], arrays[2])
    print_info_3
    CSV::WithProgressBar.foreach('ss.csv', headers: false) do |row|
      row.each do |e|
        next unless e == current_position

        unless arrays[0].include? (row[0])
          if row[6].to_i - row[3].to_i == 1
            x_data.push([row[0].to_i])
            y_data.push([1])
          elsif row[6].to_i - row[3].to_i == 3
            if arrays[2].include? (row[0])
              x_data.push([row[0].to_i])
              y_data.push([0.7])
            elsif arrays[1].include? (row[0])
              x_data.push([row[0].to_i])
              y_data.push([0.3])
            end
          else
            x_data.push([row[0].to_i])
            y_data.push([row[2].to_f])
          end
        end
      end
    end
    [x_data, y_data]
  end

  def run
    data = nn_data
    fann_results_array = []
    begin
      train = RubyFann::TrainData.new(inputs: data[0], desired_outputs: data[1])
      model = RubyFann::Standard.new(
        num_inputs: 1,
        hidden_neurons: [4],
        num_outputs: 1
      )
      model.train_on_data(train, 5000, 500, 0.01)
      data[0].flatten.each do |i|
        fann_results_array << model.run([i])
      end
    rescue StandardError
      []
      print_info_2
      exit
    end
    result = data[0][fann_results_array.index(fann_results_array.max)]
    print_info_1(data[0], fann_results_array, result[0])
    result[0]
  end

  def neural_network
    if @game.counter == 1
      first_move
    else
      run
    end
  end
end

game = Interface.new
game.start
game.play
