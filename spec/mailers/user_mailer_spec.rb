require "spec_helper"

describe UserMailer do
  context "When sending password reset email" do
    before do
      @user = Fabricate.build(:member)
      @user.password_reset_token = "testToken"
      @mail = UserMailer.password_reset(@user)
    end

    it "Sets correct subject line for the email" do
      @mail.subject.should == "Password Reset for LAGTV Website"
    end

    it "Sends the email to the users email address" do
      @mail.to.should == [@user.email]
    end

    it "Sets the from address for the email" do
      @mail.from.should == ["no-reply@lag.tv"]
    end
  end

  context "When sending a group email" do
    context "sending to members with one member" do
      before do
        @user = Fabricate(:member)
        @email = Fabricate.build(:email, :member => true)
        @mail = UserMailer.group_message(@email)
      end

      it "Sets the subject to the email's subject" do
        @mail.subject.should == @email.subject
      end

      it "Sets the subject to the email's body" do
        @mail.body.should == @email.body
      end

      it "Sets the from address for the email" do
        @mail.from.should == ["no-reply@lag.tv"]
      end

      it "Sets the to address to the only member's email" do
        @mail.to.should == [@user.email]
      end
    end

    context "sending to members with no members" do
      before do
        @email = Fabricate.build(:email, :member => true)
        @mail = UserMailer.group_message(@email)
      end

      it "should return a blank mail object" do
        @mail.from.should == nil
        @mail.to.should == nil
        @mail.subject.should == nil
      end
    end
  end

end
