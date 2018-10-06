defmodule Hangman do
  @moduledoc """
  Documentation for Hangman.
  Christian Ventura
  """

  #the defined struct
  defstruct game_state: :initializing, turns_left: 7, letters: [], used: [], last_guess: "", word: ""


  def word_to_blank([_ | []]) do
    ["_"]                                #reached the end of the string, so return
  end
 
  def word_to_blank([_ | tail]) do
    ["_" | word_to_blank(tail)]   # turn a string into underscores
  end

  #replace underscores with previous guesses. For the last character in the string
  def word_to_blank([guess_head | []], [actual_head | []], guess) do
    if ( guess_head == actual_head) do
      [guess_head]
    else 
      if (actual_head == guess) do
        [guess]
      else
        ["_"]
      end
    end
  end

  #Replace underscores with correct guesses. Remember to keep previous guesses
  def word_to_blank([guess_head | guess_tail], [actual_head | actual_tail], guess) do
    if ( guess_head == actual_head) do 
      [guess_head | word_to_blank(guess_tail, actual_tail, guess)]
    else 
      if (actual_head == guess) do
        [guess | word_to_blank(guess_tail, actual_tail, guess)]
      else
        ["_" | word_to_blank(guess_tail, actual_tail, guess)]
      end
    end
  end

  def new_game() do
    word = String.graphemes(Dictionary.random_word())   #turn string into characters
    word = "#{word}" |> String.replace("\r", "") |> String.graphemes()
    IO.puts(word)                                       #debugging: show word
    blank_word = word_to_blank(word)                       #turn the letters in a word into blanks
    
    %Hangman{letters: blank_word, word: word}
  end

  def tally(game = %{game_state: :won}) do
      %{ game_state: game.game_state, turns_left: game.turns_left, letters: game.letters, used: game.used, last_guess: game.last_guess}
  end

  def tally(game = %{game_state: :lose}) do
      %{ game_state: game.game_state, turns_left: game.turns_left, letters: game.letters, used: game.used, last_guess: game.last_guess}
  end
  
  def tally(game) do
      %{ game_state: game.game_state, turns_left: game.turns_left, letters: game.letters, used: game.used, last_guess: game.last_guess}
  end

  # def auto_win(game) do           #debug
  #   %{game | game_state: :won}
  # end

  # def auto_lose(game) do          #debug
  #    %{game | game_state: :lose}
  # end

  def make_move(game = %{game_state: :won}, _) do
    {game, tally(game)}
  end

  def make_move(game = %{game_state: :lose}, _) do
    {game, tally(game)}
  end

  def make_move(game, guess) do
    game |> already_used?(guess) |> process_if_not(guess)
    {game, tally(game)}
  end

  def already_used?(game, guess) do
    if (guess in game.used) do
      %{game | game_state: :already_used}
    else
      game
    end
  end

  def process_if_not(game = %{game_state: :already_used}, _) do
    game
  end

  def process_if_not(game, guess) do
    record_guess(game, guess) |> good_guess?(guess) |> decide_turns_left(guess) |> decide_state |> return_tally()
  end

  def record_guess(game, guess) do
    game = %{game | used: Enum.sort(game.used ++ [guess])}
  end

  def good_guess?(game) do
    if (guess in game.word) do
      game = %{game | game_state: :good_guess}
    else
      game = %{game | game_state: :bad_guess}
    end
  end

  def decide_turns_left(game = %{game_state}) do
  end

  def decide_turns_left() do
  end

  # def make_move(game, guess) do 
  #   if (guess in game.used) do                                     #if user already guessed that character, tell them so
  #       IO.puts("Already guessed that letter!")
  #       {game, tally(game)}
  #   else                                                              #user guessed a new character that is in the word
  #     new_used = %{game | used: Enum.sort(game.used ++ ["#{guess}"])}     #Add the new guess to the used list
  #     new_guess = %{new_used | last_guess: "#{guess}"}
  #     newgame = new_guess
  #     if( guess in newgame.word ) do                                      #replace underscores with correct guess
  #         new_word = word_to_blank(newgame.letters, newgame.word, guess)  #Add the guess characters to the 'in progress' word
  #         new_letters = %{new_guess | letters: new_word}                   #update the struct with the new word
  #         if(new_letters.letters == new_letters.word) do                  #If the 'in progress' word has been completed, the game is won
  #           game = %{new_letters | game_state: :won}
  #           {game, tally(game)}
  #         else                                                            #Otherwise, just tell the user it was a good guess
  #           game = %{new_letters | game_state: :good_guess}
  #           {game, tally(game)}
  #         end
  #     else                                                                 #bad answer! -1 turn
  #       newgame = %{newgame | turns_left: game.turns_left-1}              
  #       if (newgame.turns_left == 0) do                                    #If the user is out of chances, end the game
  #         game = %{newgame | game_state: :lose}
  #         {game, tally(game)}
  #       else
  #         game = %{newgame | game_state: :bad_guess}
  #         {game, tally(game)}
  #       end
  #     end
  #   end
  # end
end
