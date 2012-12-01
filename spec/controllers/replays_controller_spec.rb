require 'spec_helper'

describe ReplaysController do
  before do
    @ability = stub_abilities_for_controller
    @current_user = double
    @controller.stub(:current_user) { @current_user }
    @posted_replay = { "title" => 'Blah' }
  end

  context "When update replay status in bulk" do
    def do_update
      get :bulk_update, { :selected => ["1", "2"], :status => 'rejected' }
    end

    context "without permission" do
      before do
        @ability.cannot :edit, Replay
        do_update
      end
      
      it { should redirect_to("http://test.host/") }
      it { should set_the_flash.to(:alert => "You do not have permission to access that page") }
    end  

    context "with permission" do
      before do
        Replay.stub(:bulk_change_status)
        @ability.can :edit, Replay
      end

      it "updates the status of each selected replay" do
        Replay.should_receive(:bulk_change_status).with(["1", "2"], 'rejected')
        do_update
      end

      it "redirects to the replay list" do
        do_update
        @controller.should redirect_to replays_path
      end

      it "sets a flash success message" do
        do_update
        @controller.should set_the_flash.to(/successfully/i)
      end      
    end
  end

  context "When downloading a set of replay files" do
    def do_download
      get :download, { :selected => ["1", "2"] }
    end

    context "without permission" do
      before do
        @ability.cannot :manage, Replay
        do_download
      end
      
      it { should redirect_to("http://test.host/") }
      it { should set_the_flash.to(:alert => "You do not have permission to access that page") }
    end

    context "with permission" do
      before do
        @zip_data = double
        @ability.can :manage, Replay
      end

      it "builds a zip file in memory from the selected replays" do
        Replay.should_receive(:zip_replay_files).with(["1", "2"]) { @zip_data }
        do_download
      end

      it "sends the zip file data down to the client as an attachment" do
        Replay.stub(:zip_replay_files) { @zip_data }
        @controller.should_receive(:send_data) { @controller.render :nothing => true }
        do_download
      end
    end
  end

  context "When showing the list of users" do
    context "without permission" do
      before do
        @ability.cannot :manage, Replay
        get :index
      end
      
      it { should redirect_to("http://test.host/") }
      it { should set_the_flash.to(:alert => "You do not have permission to access that page") }
    end

    context "with permission" do
      before do
        @ability.can :manage, Replay
      end

      context "rendering checks" do
        before do
          Replay.stub(:all_paged)
          get :index
        end

        it { should respond_with(:success) }
        it { should render_template(:index) }
        it { should_not set_the_flash } 
      end

      it "loads the replay list" do
        params = { :page => "1" }
        Replay.should_receive(:all_paged).with(params)
        get :index, params
      end
    end
  end

  context "When editing a replay" do
    before do
      @replay = double.as_null_object
      Replay.stub(:find) { @replay }
    end 

    it "loads the replay for editing" do
      Replay.should_receive(:find).with("1") { @replay }
      get :edit, { :id => "1" }
    end

    context "without permission" do
      before do
        @ability.cannot :edit, @replay
        get :edit, { :id => "1" }
      end

      it { should redirect_to("http://test.host/") }
      it { should set_the_flash.to(:alert => "You do not have permission to access that page") }
    end    

    context "with permission" do
      before do
        @ability.can :edit, @replay
        get :edit, { :id => "1" }
      end

      it { should assign_to(:replay) }
      it { should respond_with(:success) }
      it { should render_template(:edit) }
      it { should_not set_the_flash } 
    end
  end

  context "When updating a replay" do
    before do
      @replay = Fabricate.build(:replay)
      Replay.stub(:find){ @replay }
    end

    def do_post
      post :update, { :id => "1", :replay => @posted_replay }
    end

    it "load the replay being updated" do
      Replay.should_receive(:find).with("1") { @replay }
      do_post
    end

    context "without permission" do
      before do
        @ability.cannot :edit, @replay
        do_post
      end

      it { should redirect_to("http://test.host/") }
      it { should set_the_flash.to(:alert => "You do not have permission to access that page") }
    end

    context "with permission" do
      before do
        @ability.can :edit, @replay
      end

      it "updates the replay" do
        @replay.should_receive(:update_attributes).with(@posted_replay) { true }
        do_post
      end

      context "and saving is successful" do
        before do
          @replay.stub(:update_attributes) { true }
          do_post
        end

        it "redirects to the home page after successfully saving" do
          @controller.should redirect_to replays_path
        end

        it "adds a flash message after successfully saving" do
          @controller.should set_the_flash.to(/successfully/i)
        end
      end

      context "and saving fails" do
        before do
          @replay.stub(:update_attributes) { false }
          do_post
        end

        it "renders the edit view" do
          @controller.should render_template(:edit)
        end

        it "assigns the categories list" do
          should assign_to(:categories)
        end
      end
    end
  end

  context "When creating a new replay" do
    def do_post
      post :create, { :replay => @posted_replay }
    end

    before do
      @replay = Fabricate.build(:replay)
      @current_user.stub(:build_replay) { @replay }
    end

    context "without permission" do
      before do
        @ability.cannot :create, @replay
        do_post
      end

      it { should redirect_to("http://test.host/") }
      it { should set_the_flash.to(:alert => "You do not have permission to access that page") }
    end

    context "with permission" do
      before do
        @ability.can :create, @replay
      end

      it "builds a new replay for the current user" do
        @current_user.should_receive(:build_replay).with(@posted_replay) { @replay }
        do_post
      end

      context "and saving is successful" do
        before do
          @replay.stub(:save) { true }
        end

        it "saves the new replay" do
          @replay.should_receive(:save) { true }
          do_post
        end    

        it "redirects to the home page after successfully saving" do
          do_post
          @controller.should redirect_to root_url
        end

        it "adds a flash message after successfully saving" do
          do_post
          @controller.should set_the_flash.to(/successfully/i)
        end
      end

      context "and saving fails" do
        before do
          @replay.stub(:save) { false }
        end

        it "renders the new view" do
          do_post
          @controller.should render_template(:new)
        end

        it "assigns the categories list" do
          do_post
          should assign_to(:categories)
        end
      end
    end
  end

  context "when getting more replays from the edit user page" do
    before do
      @user = Fabricate.build(:member)
      @ability.can :edit, @user
      User.stub(:find) { @user }
    end

    it "gives a small group of more replays" do
      10.times do
        Fabricate.build(:replay, :user => @user)
      end
      get :user_page, :user_id => @user.id, :page => 1
      @controller.should render_template(:page)
      should assign_to(:user)
      should assign_to(:replays)
    end
  end
end