# frozen_string_literal: true

require 'csv'
require_relative '../lib/game_board.rb'
require_relative '../lib/player.rb'
require_relative '../lib/interface.rb'

total_number_moves = []
resulting_array = []

# You can change the number of training parties:
30_000.times do
  game = Interface.new
  game.start
  game.play

  class Array
    def clip(n = 1)
      take size - n
    end
  end

  prioritization = []
  game.players_move_order.map do |i|
    prioritization << if i == game.check
                        0.3
                      elsif game.check == 'draw'
                        0.2
                      else
                        0.1
                      end
  end

  game.count_spots.uniq.last.times do
    total_number_moves << game.count_spots.uniq.last
  end

  tmp = []
  game.forks.each do |i|
    game.forks.size.times { tmp << (i - 1) } if i != 10
  end

  resulting_array << game.spots.zip(
    game.board_all.each_slice(9).to_a.uniq.clip,
    prioritization,
    game.count_spots.uniq,
    game.players_move_order,
    tmp
  )

  # The End of iterations
end

tmp = []
resulting_array.flatten(1).zip(total_number_moves).each do |i|
  tmp << i.flatten(1)
end
# Create a csv file:
File.write('ss.csv', tmp.map(&:to_csv).join)
