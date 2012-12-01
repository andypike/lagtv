class ReplaysController < ApplicationController
  def new
    authorize! :create, Replay
    @replay = current_user.replays.build

    prep_form_for(@replay)
  end

  def create
    @replay = current_user.build_replay(params[:replay])
    authorize! :create, @replay

    if @replay.save
      redirect_to root_path, :notice => "Your replay was successfully uploaded."
    else
      prep_form_for(@replay)
      render 'new'
    end
  end

  def user_page
    @user = User.find(params[:user_id])
    authorize! :edit, @user
    @replays = @user.replays.paginate(:page => params[:page], :per_page => 5, :order => 'created_at desc')
    render :partial => 'page', :layout => false
  end

  def index
    authorize! :manage, Replay
    @replays = Replay.all_paged(params.slice(*Replay::DEFAULT_FILTERS.keys).symbolize_keys)
    @filters = params.reverse_merge(Replay::DEFAULT_FILTERS)
    @categories = Category.ordered
  end

  def edit
    @replay = Replay.find(params[:id])
    authorize! :edit, @replay
    prep_form_for(@replay)
  end

  def update
    @replay = Replay.find(params[:id])
    authorize! :edit, @replay
    if @replay.update_attributes(params[:replay])
       redirect_to replays_path, :notice => 'You have successfully updated the replay.'
    else
      prep_form_for(@replay)
      render 'edit'
    end
  end

  def bulk_update
    authorize! :edit, Replay
    Replay.bulk_change_status(params[:selected], params[:status])
    redirect_to replays_path, :notice => 'You have successfully updated the selected replays.'
  end

  def download
    authorize! :manage, Replay
    zip_binary_data = Replay.zip_replay_files(params[:selected])
    send_data(zip_binary_data, :type => 'application/zip', :filename => "replays-#{DateTime.now.utc}.zip", :disposition => 'attachment' )
  end

private 
  def prep_form_for(replay)
    @comment = Comment.new
    @categories = Category.only_active
    @comments = replay.comments.paginate(:page => params[:page], :per_page => 5)
  end
end