class EmailsController < ApplicationController
  before_filter { authorize! :create, Email }

  def new
    @email = Email.new
  end

  def create
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

  def index
    @emails = Email.order('created_at desc')
  end
end
