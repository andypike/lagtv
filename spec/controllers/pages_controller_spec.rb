require 'spec_helper'

describe PagesController do
  context "When showing the about page" do
    before do
      get :about
    end

    it { should respond_with(:success) }
    it { should render_template(:about) }
    it { should_not set_the_flash } 
  end

  context "When showing the homepage of the site" do
    context "renders the page correctly" do
      before do
        get :home
      end

      it { should respond_with(:success) }
      it { should render_template(:home) }
      it { should_not set_the_flash } 
    end

    context "When getting the latest forum activity" do
      it "retrieves the latest updated forum topics" do
        ForumService.should_receive(:latest_topics)
        get :home
      end
    end

    context "When loading the YouTube data" do
      before do
        @lagtv1_service = double.as_null_object
        @lagtv2_service = double.as_null_object
        YouTubeService.stub(:new).with('lifesaglitchtv', @controller.cache_store) { @lagtv1_service }
        YouTubeService.stub(:new).with('lifesaglitchtv2', @controller.cache_store) { @lagtv2_service }
      end

      it "gets the YouTube channel data for lifesaglitchtv" do 
        @lagtv1_service.should_receive(:channel)
        get :home
      end

      it "gets the YouTube channel data for lifesaglitchtv2" do 
        @lagtv2_service.should_receive(:channel)
        get :home
      end
    end

    context "When building the replay form" do
      before do
        @ability = stub_abilities_for_controller
        @current_user = double.as_null_object
        @controller.stub(:current_user) { @current_user }
      end

      context "for a user without permission" do
        before do
          @ability.cannot :create, Replay
          get :home
        end

        it "doesn't assign the replay instance" do      
          should_not assign_to(:replay)
        end

        it "assigns categories" do
          should_not assign_to(:categories)
        end
      end

      context "with permission" do
        before do
          @ability.can :create, Replay
          get :home
        end

        it "assigns the replay instance" do
          should assign_to(:replay)
        end

        it "assigns categories" do
          should assign_to(:categories)
        end
      end
    end
  end

  context "When showing stream information" do
    it "should assign @streams when nobody is streaming" do
      Stream.stub(maximusblack: Fabricate(:maximusblack_stream))
      Stream.stub(novawar: Fabricate(:novawar_stream))
      Stream.stub(lagtv: Fabricate(:lagtv_stream))
      get :streams
      should assign_to(:streams)
      should respond_with(:success)
    end
  end
end