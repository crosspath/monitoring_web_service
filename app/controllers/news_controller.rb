class NewsController < ApplicationController
  http_basic_authenticate_with(
    name:     name: ENV['ADMIN_USER'],
    password: password: ENV['ADMIN_PASSWORD']
  )

  before_action -> { @id = params[:id] }
  before_action -> { @news = NewsRepo.load_news }, only: :index
  before_action -> { @news = NewsRepo.load_a_news(@id) }, only: %i[show edit]
  before_action -> { @news = News.new(news_params.merge(id: @id)) }, only: %i[create update]
  before_action -> { @news = News.new(id: @id) }, only: :destroy

  def index
  end

  def show
  end

  def edit
  end

  def new
  end

  def create
    @news.save
    redirect_to news_path(0)
  end

  def update
    @news.save
    redirect_to news_path(@id)
  end

  def destroy
    @news.destroy
    redirect_to news_index_path
  end

  private

  def news_params
    params.require(:news).permit(:title, :content, :date)
  end
end
