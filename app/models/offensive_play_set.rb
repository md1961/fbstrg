class OffensivePlaySet < ActiveRecord::Base
  include PlaySetTool

  has_many :offensive_play_set_choices

  attr_accessor :weight_correctors

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
    def correct(offensive_play_set_choices, game)
      if game.ball_on >= 100 - 10
        offensive_play_set_choices.each do |choice|
          next if choice.offensive_play.number <= 12
          choice.weight = 0
        end
      elsif game.ball_on >= 100 - 20
        offensive_play_set_choices.each do |choice|
          next if choice.offensive_play.number <= 16
          choice.weight = 0
        end
      end
      offensive_play_set_choices
    end
  end

  def choose(game)
    choices = @weight_correctors.inject(offensive_play_set_choices) do |choices, weight_corrector|
      weight_corrector.correct(choices, game)
    end
    reload
    pick_from(choices).offensive_play
  end

  def to_s
    name
  end
end