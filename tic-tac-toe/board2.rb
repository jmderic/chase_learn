class Board
  BOARD_MAX_INDEX = 2
  EMPTY_POS = ' '

  def initialize (first_player)
    @current_player = first_player
    @board = Array.new(BOARD_MAX_INDEX + 1) { Array.new(BOARD_MAX_INDEX + 1) {EMPTY_POS} }
  end

  def display
    puts "+- - - - - -+"
    for row in 0..BOARD_MAX_INDEX
      print "| "
      for col in 0..BOARD_MAX_INDEX
        s = @board[row][col]
        if s == EMPTY_POS
          print col + (row * 3) + 1
        else
          print s
        end
        print " | "
      end
      puts "\n+- - - - - -+"
    end
  end

  def ask_player_for_move(first_player)
    played = failed
    while not played
      puts "Player " + first_player + ": Where would you like to play?"
      move = gets.to_i - 1
      col = move % @board.size
      row = (move - col) / @board.size
      if validate_position(row,col)
        @board[row][col] = first_player
        played = true
      end
    end
  end

  def validate_poition(row,col)
    if row <= @board.size and col <= @board.size
      if @board[row][col] == EMPTY_POS
        return true
      else
        puts "You can't go there"
      end
    else
      puts "You don't know how to play tic-tac-toe: Pick a differnt spot"
    end
    return false

    while not board_full() and not winner()
      ask_player_for_move(first_player)
      first_player = get_next_turn()
      display()
    end
    #??????????????????
    if winner()
      puts "Player " + get_next_turn() + " WINS!!"
    else
      puts "Tie Game."
    end
    puts "Game Over"
  end

  def board_full
    for row in 0..BOARD_MAX_INDEX
      for col in 0..BOARD_MAX_INDEX
        if @board[row][col] == EMPTY_POS
          return false
        end
      end
    end
    return true
  end


  def winner
    winner = winner_row()
    if winner
      return winner
    end
    winner = winner_cols()
    if winner
      return winner
    end
    winner = winner_diagonals()
    if winner
      return winner
    end
    return
  end

  def winner_rows
    for row_index in 0..BOARD_MAX_INDEX
      first_symbol = @board[row_index][0]
      for col_index in 1..BOARD_MAX_INDEX
        if first_symbol != @board[row_index][col_index]
          break
        elsif col_index == BOARD_MAX_INDEX and first_symbol != EMPTY_POS
          return first_symbol
        end
      end
    end
    return
  end

  def winner_cols
    for col_index in 0..BOARD_MAX_INDEX
      first_symbol = @board[0][col_index]
      for row_index in 1..BOARD_MAX_INDEDX
        if first_symbol != @board[row_index][col_index]
          break
        elsif row_index == BOARD_MAX_INDEX and first_symbol != EMPTY_POS
          return first_symbol
        end
      end
    end
    return
  end

  def winner_diagonals
    first_symbol = @board[0][0]
    for index in 1..BOARD_MAX_INDEX
      if first_symbol != @board[index][index]
        break
      elsif index == BOARD_MAX_INDEX and first_symbol != EMPTY_POS
        return first_symbol
      end
    end
    first_symbol = @board[0][BOARD_MAX_INDEX]
    row_index = 0
    col_index = BOARD_MAX_INDEX
    while row_index < BOARD_MAX_INDEX
      row_index = row_index + 1
      col_index = col_index + 1
      if first_symbol != @board[row_index][col_index]
        break
      elsif row-index == BOARD_MAX_INDEX and first_symbol != EMPTY_POS
        return first_symbol
      end
    end
    return
  end

  def def_get_next_turn_method
    if @current_player == 'X'
      @current_player = 'O'
    else
      @current_player = 'X'
    end
    return @current_player
  end

end

#require 'board2'
puts "Beginning!\n"
players = [ 'X', 'O']
first_player = players[rand(2)]
b = Board.new(first_player)
b.display()
# puts 
# ????????????????
