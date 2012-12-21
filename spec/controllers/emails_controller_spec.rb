require 'spec_helper'

describe EmailsController do
  before do
    @ability = stub_abilities_for_controller
  end

  describe "GET 'new'" do
    it "returns http success if admin" do
      @current_user = Fabricate.build(:admin)
      @controller.stub(:current_user) { @current_user }
      @ability.can :create, Email
      get 'new'
      response.should be_success
    end

    it "redirects if not admin" do
      @current_user = Fabricate.build(:member)
      @controller.stub(:current_user) { @current_user }
      @ability.cannot :create, Email
      get 'new'
      response.should be_redirect
    end
  end

  describe "POST 'create'" do
    before do
      @current_user = Fabricate.build(:admin)
      @controller.stub(:current_user) { @current_user }
      @ability.can :create, Email
    end

    it "returns http success if admin with no data sent" do
      post 'create'
      response.should be_success
      response.should render_template("new")
    end

    it "returns http success if admin with no role selected" do
      post 'create', {:email => {:subject => 'Hello mister man', :body => 'You are looking quite dashing today'}}
      response.should be_success
      response.should render_template("new")
    end

    it "returns http success if admin with good data" do
      post 'create', :email => {:subject => 'Hi', :body => 'Howzit?', :admin => 'true'}
      response.should be_redirect
    end

    it "redirects if not admin" do
      @current_user = Fabricate.build(:member)
      @controller.stub(:current_user) { @current_user }
      @ability.cannot :create, Email
      post 'create'
      response.should be_redirect
      response.should redirect_to '/'
    end
  end

  describe "GET 'show'" do
    before do
      @current_user = Fabricate.build(:admin)
      @controller.stub(:current_user) { @current_user }
      @ability.can :create, Email
      @email = Fabricate(:email)
    end

    it "should show data for an email" do
      get 'show', id: @email.id
      response.should be_success
      response.should render_template("show")
    end

    it "redirects if not admin" do
      @current_user = Fabricate.build(:member)
      @controller.stub(:current_user) { @current_user }
      @ability.cannot :create, Email
      get 'show', id: @email
      response.should be_redirect
      response.should redirect_to '/'
    end
  end

  describe "GET 'index'" do
    before do
      @current_user = Fabricate.build(:admin)
      @controller.stub(:current_user) { @current_user }
      @ability.can :create, Email
      @email = Fabricate(:email)
    end

    it "should show list of emails" do
      get 'index'
      response.should be_success
      response.should render_template("index")
    end

    it "redirects if not admin" do
      @current_user = Fabricate.build(:member)
      @controller.stub(:current_user) { @current_user }
      @ability.cannot :create, Email
      get 'index'
      response.should be_redirect
      response.should redirect_to '/'
    end
  end
end
