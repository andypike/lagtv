require 'spec_helper'

describe Email do
  context "When validating a mail" do
    before do
      @email = Fabricate(:email)
    end

    it { @email.should ensure_length_of(:subject).is_at_least(1).is_at_most(78) }
    it { @email.should ensure_length_of(:body).is_at_least(5) }
    it { @email.should validate_presence_of(:subject) }
    it { @email.should validate_presence_of(:body) }

    it "should create error when no roles are selected" do
      @email = Fabricate.build(:roleless_email)
      @email.send(:at_least_one_role)
      @email.errors[:member].should be_present
    end

    it "should validate that at least one role is selected" do
      @email = Fabricate.build(:roleless_email)
      @email.admin = true
      @email.send(:at_least_one_role)
      @email.errors[:member].should be_blank
    end
  end

  context "When getting role_list" do
    it "should create an array of roles based off of booleans, with two roles" do
      @email = Fabricate(:roleless_email, :admin => true, :member => true, :moderator => true)
      groups = @email.role_list
      groups.class.should == Array
      groups.length.should == 3
      groups.include?('admin').should == true
      groups.include?('member').should == true
      groups.include?('moderator').should == true
    end

    it "should create an array of roles based off of booleans, with one role" do
      @email = Fabricate(:roleless_email, :admin => true)
      groups = @email.role_list
      groups.class.should == Array
      groups.length.should == 1
      groups.include?('admin').should == true
    end
  end

  context "Estimated time remaining string" do
    it "should estimate 20 minutes for 100 emails remaining at 5 a minute" do
      @email = Fabricate(:email, :started_at => Time.now - 1.minute, :ended_at => nil, :total_sent => 5, :total_recipients => 105)
      str = @email.estimated_completion_str
      str.should == "00:20"
    end

    it "should estimate 0 minutes for 0 emails remaining at 5 a minute" do
      @email = Fabricate(:email, :started_at => Time.now - 20.minute, :ended_at => Time.now, :total_sent => 100, :total_recipients => 100)
      str = @email.estimated_completion_str
      str.should == "00:00"
    end

    it "should estimate infinite minutes for 1 emails remaining at 0 a minute" do
      @email = Fabricate(:email, :started_at => Time.now, :ended_at => nil, :total_sent => 0, :total_recipients => 1)
      str = @email.estimated_completion_str
      str.should == "Never"
    end
  end

  context "Estimated send rate" do
    it "should estimate rate at 11 per second for 121 emails sent in 11 seconds" do
      @email = Fabricate(:email, :started_at => Time.now - 11.seconds, :ended_at => nil, :total_sent => 121)
      rate = @email.estimated_send_rate
      rate.should == 11
    end

    it "should estimate rate at 0 per second for 0 emails sent in 11 seconds" do
      @email = Fabricate(:email, :started_at => Time.now - 11.seconds, :ended_at => nil, :total_sent => 0)
      rate = @email.estimated_send_rate
      rate.should == 0
    end

    it "should estimate rate at 0 per second for 100 emails sent in 0 seconds" do
      now = Time.now
      Time.stub(:now) { now }
      @email = Fabricate(:email, :started_at => Time.now, :ended_at => nil, :total_sent => 100)
      rate = @email.estimated_send_rate
      rate.should == 0
    end

    it "should estimate rate at 1 per second for 1 email sent in 1 second" do
      now = Time.now
      Time.stub(:now) { now }
      @email = Fabricate(:email, started_at: Time.now - 1.second, ended_at: nil, total_sent: 1)
      rate = @email.estimated_send_rate
      rate.should == 1
    end
  end

  context "total_remaining" do
    it "should return 3 when 1 email has been sent with 4 recipients" do
      @email = Fabricate(:email, total_sent: 1, total_recipients: 4)
      @email.total_remaining.should == 3
    end
  end

  context "done?" do
    it "should return false if it hasn't started sending" do
      @email = Fabricate(:email, total_sent: 0, total_recipients: 0, started_at: nil)
      @email.done?.should == false
    end

    it "should return false if it has started sending but hasn't sent all emails" do
      @email = Fabricate(:email, total_sent: 2, total_recipients: 10, started_at: Time.now)
      @email.done?.should == false
    end

    it "should return true if it has started sending and has sent all emails" do
      @email = Fabricate(:email, total_sent: 10, total_recipients: 10, started_at: Time.now)
      @email.done?.should == true
    end
  end
end
