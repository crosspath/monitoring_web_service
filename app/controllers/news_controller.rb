class NewsController < ApplicationController
  http_basic_authenticate_with :name => Rails.configuration.app[:auth_user],
      :password => Rails.configuration.app[:auth_password]

  before_action :connect_redis
  before_action -> { @id = params[:id] }
  before_action -> { @news = load_news }, only: :index
  before_action -> { @news = load_a_news(@id) }, only: %i[show edit]
  before_action -> { @news = news_params }, only: %i[create update]

  def index
  end

  def show
    @news['index'] = @id
  end

  def edit
  end

  def new
  end

  def create
    create_news(@news)
    redirect_to news_path(0)
  end

  def update
    update_news(@news, @id)
    redirect_to news_path(@id)
  end

  def destroy
    delete_news(@id)
    redirect_to news_index_path
  end

  private

  def news_params
    params.require(:news).permit(:title, :content, :date)
  end
end
