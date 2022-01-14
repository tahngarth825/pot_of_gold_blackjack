# frozen_string_literal: true

require_relative 'deck'
require_relative 'hand'

class Game
  STARTING_MONEY = 500
  MINIMUM_BET = 5

  FINISH_STATES = %w[won lost push blackjack].to_set.freeze

  BASE_ACTIONS = %w[pass hit].freeze

  FREE_SPLIT  = 'free_split'
  SPLIT       = 'split'
  FREE_DOUBLE = 'free_double'
  DOUBLE      = 'double'

  def self.start
    new.start
  end

  def initialize
    @money = STARTING_MONEY
    @bet = nil
  end

  def start
    reset_state

    bet_money
    bet_side

    draw_initial_cards

    result = play

    resolve_game(result)
    prompt_play_again
  end

  private

  def bet_money
    puts "Bet your main amount. Min: #{MINIMUM_BET}, Max: #{@money}"

    @bet = prompt_bet
  end

  def bet_side
    puts 'Bet your side bet. Enter 0 to skip.'

    @side_bet = prompt_bet(optional: true)
  end

  def prompt_bet(optional: false)
    if @money < MINIMUM_BET
      return 0 if optional

      raise "Not enough money left! You have only have $#{@money}."
    end

    bet_amount = nil

    while bet_amount.nil?
      bet_amount = gets.chomp.to_i

      break if bet_amount.between?(MINIMUM_BET, @money)

      return 0 if optional && bet_amount < MINIMUM_BET

      puts "Your bet of $#{bet_amount} must be between $#{MINIMUM_BET} and $#{@money}"
      bet_amount = nil
    end

    @money -= bet_amount
    puts "You bet $#{bet_amount}, and you have $#{@money} left."

    bet_amount
  end

  def reset_state
    @deck = Deck.new
    @actions_available = []
    @dealer_hand = Hand.new
    @player_hand = Hand.new
    @gold_coins = 0
    @bet = 0
    @side_bet = 0
  end

  def draw_initial_cards
    2.times do
      @player_hand << @deck.draw
      @dealer_hand << @deck.draw
    end
  end

  def play
    state = determine_state
    pass = false

    until FINISH_STATES.include?(state)
      display_cards
      # TODO
      possible_actions = determine_actions
      # display_options
      # offer player actions
      # once player passes (and hasn't lost), dealer auto-plays
    end

    state
  end

  def display_cards
    puts "Your hand: #{@player_hand}"
    puts "Dealer card showing: #{@dealer_hand.first}"
  end

  def determine_state
    if @player_hand.blackjack?
      'blackjack'
    elsif @player_hand.bust?
      'lost'
    elsif dealer_sum == 22
      'push'
    elsif @dealer_hand.bust?
      'won'
    elsif dealer_sum >= 17 && !@dealer_hand.soft17?
      if player_sum > dealer_sum
        'won'
      elsif dealer_sum > player_sum
        'lost'
      else
        'push'
      end
    end
  end

  def determine_actions
    actions = BASE_ACTIONS.dup

    if @player_hand.can_free_split?
      actions << FREE_SPLIT
    elsif @player_hand.can_split?
      actions << SPLIT
    end

    if @player_hand.can_free_double?
      actions << FREE_DOUBLE
    elsif @player_hand.can_double?
      actions << DOUBLE
    end

    actions
  end

  def player_sum
    @player_hand.sum
  end

  def dealer_sum
    @dealer_hand.sum
  end

  def resolve_game(result)
    # TODO
    case result
    when 'won'
    when 'lost'
    when 'push'
    when 'blackjack'
    end
  end

  def prompt_play_again
    # TODO
  end
end
