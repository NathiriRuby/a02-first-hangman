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
    word = word |> String.replace("\r", "") |> String.graphemes()
    IO.puts(word)                                       #debugging: show word
    blank_word = word_to_blank(word)                       #turn the letters in a word into blanks
    
    %Hangman{letters: blank_word, word: word}
  end

  def new_game(user_word) do
    word = user_word |> String.replace("\r", "") |> String.graphemes()
    IO.puts(word)                                       #debugging: show word
    blank_word = word_to_blank(word)                       #turn the letters in a word into blanks
    
    %Hangman{letters: blank_word, word: user_word}
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
  end

  def already_used?(game, guess) do
    if (guess in game.used) do
      IO.puts("Already Used!")
      game = %{game | game_state: :already_used}
      game
    else
      game
    end
  end

  def process_if_not(game = %{game_state: :already_used}, _) do
    IO.puts("Try another letter!")
    game = %{game | game_state: :clear}
    {game, tally(game)}
  end

  def process_if_not(game, guess) do
    IO.puts("Guess accepted!")
    record_guess(game, guess) |> good_guess?(guess) |> decide_turns_left(guess) |> decide_state() |> return_tally()
  end

  def record_guess(game, guess) do
    IO.puts("guess added!")
    game = %{game | used: Enum.sort(game.used ++ [guess])}
    game
  end

  def good_guess?(game, guess) do
    if (guess in game.word) do
      IO.puts("good guess!")
      game = %{game | game_state: :good_guess}
      game
    else
      IO.puts("bad guess!")
      game = %{game | game_state: :bad_guess}
      game
    end
  end

  def decide_turns_left(game = %{game_state: :bad_guess}, _) do
    IO.puts("-1 turn!")
    game = %{game | turns_left: game.turns_left-1}
    game
  end

  def decide_turns_left(game = %{game_state: :good_guess}, guess) do
    IO.puts("guess added to word!")
    new_word = word_to_blank(game.letters, game.word, guess)
    game = %{game | letters: new_word}
    game
  end

  def decide_state(game = %{turns_left: 0}) do
    IO.puts("You lose!")
    game = %{game | game_state: :lose}
    game
  end

  def decide_state(game) do
    if(game.letters == game.word) do
      IO.puts("You win!")
      game = %{game | game_state: :won}
      game
    else
      game
    end
  end

  def return_tally(game) do
    IO.puts("Tally returned!")
    {game, tally(game)}
  end
end
