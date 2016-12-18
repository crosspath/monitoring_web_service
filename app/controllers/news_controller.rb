class NewsController < ApplicationController
  http_basic_authenticate_with :name => CONFIG[:auth_user], :password => CONFIG[:auth_password]

  before_filter do
    @redis = Redis.new(url: REDIS[:url], namespace: REDIS[:namespace])
  end
  before_filter do
    @id = params[:id]
  end
  before_filter -> { @news = load_news }, only: :index
  before_filter -> { @news = load_a_news(@id) }, only: %i[show edit]
  before_filter -> { @news = news_params }, only: %i[create update]

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
    redirect_to news_path(1)
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
