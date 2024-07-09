class OffensivePlaySet < ApplicationRecord
  include PlaySetTool

  has_many :offensive_play_set_choices, dependent: :destroy

  attr_accessor :weight_correctors

  scope :normal, -> { where("name != 'Dumb Even'") }

  class << self
    OffensivePlaySet.pluck(:name).each do |name|
      method_name = name.titleize.gsub(/\s+/, '').underscore
      define_method method_name do
        instance_variable_get(:"@#{method_name}") \
          || instance_variable_set(:"@#{method_name}", find_by(name: name))
      end
    end
  end

  after_find do
    @weight_correctors = [BasicWeightCorrector.new]
  end

  class BasicWeightCorrector
    # include StrategyTool

    def correct(offensive_play_set_choices, game)
      if game.ball_on >= 100 - 10
        offensive_play_set_choices.each do |choice|
          next if choice.offensive_play.inside_10?
          choice.weight = 0
        end
      elsif game.ball_on >= 100 - 20
        offensive_play_set_choices.each do |choice|
          next if choice.offensive_play.inside_20?
          choice.weight = 0
        end
      elsif !game.ball_on.between?(40, 60) || game.no_huddle
        offensive_play_set_choices.find { |choice|
          choice.offensive_play.razzle_dazzle?
        }.weight = 0
      end
      if game.ball_on <= 15 || game.no_huddle
        offensive_play_set_choices.find { |choice|
          choice.offensive_play.reverse?
        }.weight = 0
      end
      if game.yard_to_go > 1
        offensive_play_set_choices.find { |choice|
          choice.offensive_play.quarterback_keep?
        }.weight = 0
      end
      offensive_play_set_choices
    end
  end

  def choice_for(offensive_play)
    offensive_play_set_choices.find_by(offensive_play: offensive_play)
  end

  def choose(game)
    choices = @weight_correctors.inject(offensive_play_set_choices) do |choices, weight_corrector|
      weight_corrector.correct(choices, game)
    end
    reload
    pick_from(choices).offensive_play
  end

  def update_weights(h_weight_by_offensive_play)
    h_weight_by_offensive_play.each do |offensive_play_id, weight|
      offensive_play = OffensivePlay.find(offensive_play_id)
      weight = Integer(weight)
      choice = choice_for(offensive_play)
      if choice
        choice.update!(weight: weight) if weight != choice.weight
      else
        offensive_play_set_choices.create!(offensive_play: offensive_play, weight: weight)
      end
    end
  end

  def to_s
    name
  end
end
