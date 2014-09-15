require_relative 'board2'

puts "Start Testing!\n"
b = Board.new('X')
b.update_board(4, 'X')
b.update_board(5, 'X')
b.update_board(6, 'X')
b.display()
print "Winner: #{b.winner}\n"
