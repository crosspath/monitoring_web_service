class PagesController < ApplicationController
  def heartbeat
    @specs = ResultsRepo.all
    @news  = NewsRepo.load_news[0..2]
  end
end
