class StaticPagesController < ApplicationController
  def index
    @games = Game.all
  end

  def how_to_play

  end

  def what_is_spot_the_bin

  end
end
