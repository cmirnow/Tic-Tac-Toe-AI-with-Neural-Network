require_relative './game.rb'
puts ' '
puts '********* MASTERPRO.WS PROJECT ***********'
puts 'Welcome to Tic Tac Toe with Artificial Intelligence!'
puts '--------------------------------'
puts 'Loading data...'
puts 'Please wait.'
puts ' '

class Starting
  Array_of_games = CSV::WithProgressBar.read('ss.csv').each.to_a

  def self.beginning_of_game
    game = Interface.new
    game.start
    game.play
  end
end

Starting.beginning_of_game
