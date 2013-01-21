class EmailsController < ApplicationController
  before_filter { authorize! :create, Email }

  def new
    @email = Email.new
  end

  def create
    params[:email][:roles] = roles_to_str if params[:email] && params[:email]
    @email = Email.new(params[:email])
    if @email.save
      @email.deliver
      redirect_to email_path(@email)
    else
      render :new
    end
  end

  def show
    @email = Email.find(params[:id])
  end

  private

  def roles_to_str
    params[:roles].select{|k,v| v.to_i == 1}.keys.join(' ') if params[:roles]
  end

  def index
    @emails = Email.order('created_at desc')
  end
end
