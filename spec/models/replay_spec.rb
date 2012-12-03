require 'spec_helper'

describe Replay do
  context "When updating the replays average rating" do
    before do
      @replay = Fabricate(:replay)
    end

    it "calculates the average rating of only the comments for the replay" do
      another_replay = Fabricate(:replay)
      Fabricate(:comment, :replay => @replay, :rating => 4)
      Fabricate(:comment, :replay => @replay, :rating => 3)
      Fabricate(:comment, :replay => another_replay, :rating => 5)

      @replay.update_average_rating
      @replay.average_rating.should == 3.5
    end

    it "saves the replay" do
      @replay.should_receive(:save)
      @replay.update_average_rating
    end
  end

  context "When updating replay statuses in bulk" do
    before do
      @replay1 = double.as_null_object
      @replay2 = double.as_null_object
      @replays = [@replay1, @replay2]
      Replay.stub(:find) { @replays }
    end

    def do_update
      Replay.bulk_change_status(["1", "2"], "rejected")
    end

    it "loads the selected replays" do
      Replay.should_receive(:find).with(["1", "2"]) { @replays }
      do_update
    end

    it "changes the status for each replay" do
      @replay1.should_receive(:status=).with('rejected')
      @replay2.should_receive(:status=).with('rejected')
      do_update
    end

    it "saves each of the replays" do
      @replay1.should_receive(:save)
      @replay2.should_receive(:save)
      do_update
    end
  end

  context "When checking if a replay has expired" do
    it "returned true if the expiry date is in the past" do
      replay = Fabricate.build(:replay, :expires_at => DateTime.now - 1.year)
      replay.expired?.should == true
    end

    it "returned false if the expiry date is in the future" do
      replay = Fabricate.build(:replay, :expires_at => DateTime.now + 1.year)
      replay.expired?.should == false
    end
  end

  context "When loading a paged list of replays" do
    it "paginates all replays" do
      Replay.should_receive(:paginate).with(:page => 5, :per_page => 25) { stub.as_null_object }
      Replay.all_paged(:page => 5)
    end

    context "and searching" do
      before do
        @will_cheese_fail = Fabricate(:category)
        @normal_game = Fabricate(:category)
        user = Fabricate(:member)

        @replay1 = Fabricate(:replay, :status => 'new', :players => '2v2', :league => 'silver', :title => 'Super Awesome cheese', :description => "blah", :category => @will_cheese_fail, :user => user)
        @replay2 = Fabricate(:replay, :status => 'rejected', :players => '1v1', :league => 'gold', :title => 'Macro game', :description => "foo", :category => @will_cheese_fail, :user => user)
        @replay3 = Fabricate(:replay, :status => 'suggested', :players => '1v1', :league => 'master', :title => 'Lots of BM', :description => "Plenty of cheese", :category => @normal_game, :user => user)
        @expired = Fabricate(:replay, :status => 'new', :expires_at => DateTime.now - 1.year, :category => @will_cheese_fail, :user => user)

        @replay1.average_rating = 3
        @replay1.save
        @replay2.average_rating = 1
        @replay2.save
        @replay3.average_rating = 4
        @replay3.save
      end

      it "only returns matching relays by status" do
        Replay.all_paged(:statuses => %w{new rejected}).should == [@replay2, @replay1]
      end

      it "defaults to returning only new and suggested replays (rejected, broadcasted and expired are not returned)" do
        Replay.all_paged().should == [@replay3, @replay1]
      end

      it "only returns matching queries against title and description" do
        Replay.all_paged(:statuses => '', :query => "cheese").should == [@replay3, @replay1]
      end

      it "only returns matching replays by league" do
        Replay.all_paged(:statuses => '', :league => 'silver').should == [@replay1]
      end

      it "only returns matching replays by players" do
        Replay.all_paged(:statuses => '', :players => '1v1').should == [@replay3, @replay2]
      end

      it "only returns matching replays by category" do
        Replay.all_paged(:statuses => '', :category_id => @will_cheese_fail.id).should == [@replay2, @replay1]
      end

      it "returns expired replays if required" do
        Replay.all_paged(:include_expired => true).should == [@expired, @replay3, @replay1]
      end

      it "returns only replays with a minimum rating" do
        Replay.all_paged(:statuses => '', :rating => 3).should == [@replay3, @replay1]
      end
    end
  end

  context "When validating a replay" do
    before do
      @replay = Fabricate(:replay, :category => Fabricate(:category), :user => Fabricate(:member))
    end
    
    it { @replay.should validate_presence_of(:title) }
    #it { @replay.should validate_presence_of(:replay_file) }
    it { @replay.should validate_presence_of(:category_id) }
    it { @replay.should validate_presence_of(:user_id) }
    it { @replay.should validate_presence_of(:expires_at) }

    it { @replay.should validate_presence_of(:players) }    
    it { @replay.should allow_value("1v1").for(:players) }
    it { @replay.should allow_value("2v2").for(:players) }
    it { @replay.should allow_value("3v3").for(:players) }
    it { @replay.should allow_value("4v4").for(:players) }
    it { @replay.should allow_value("FFA").for(:players) }
    it { @replay.should_not allow_value("blah").for(:players) }

    it { @replay.should validate_presence_of(:league) }
    it { @replay.should allow_value("bronze").for(:league) }
    it { @replay.should allow_value("silver").for(:league) }
    it { @replay.should allow_value("gold").for(:league) }
    it { @replay.should allow_value("platinum").for(:league) }
    it { @replay.should allow_value("diamond").for(:league) }
    it { @replay.should allow_value("master").for(:league) }
    it { @replay.should allow_value("grand_master").for(:league) }
    it { @replay.should_not allow_value("blah").for(:league) }

    it { @replay.should validate_presence_of(:expansion_pack) }
    it { @replay.should allow_value("WoL").for(:expansion_pack) }
    it { @replay.should allow_value("HotS").for(:expansion_pack) }
    #it { @replay.should allow_value("LotV").for(:expansion_pack) }

    it { @replay.should validate_presence_of(:status) }    
    it { @replay.should allow_value("new").for(:status) }
    it { @replay.should allow_value("rejected").for(:status) }
    it { @replay.should allow_value("suggested").for(:status) }
    it { @replay.should allow_value("broadcasted").for(:status) }
    it { @replay.should_not allow_value("blah").for(:status) }

    it "checks that a 1v1 game cannot contain 3 races" do
      @replay.players = '1v1'
      @replay.terran = true
      @replay.protoss = true
      @replay.zerg = true
      @replay.valid?.should be_false
    end

    it "checks that a 2v2 game can contain 3 races" do
      @replay.players = '2v2'
      @replay.terran = true
      @replay.protoss = true
      @replay.zerg = true
      @replay.valid?.should be_true
    end
  end
end
