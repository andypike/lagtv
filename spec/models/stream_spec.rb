require 'spec_helper'

describe Stream do
  context "Polling api.twitch.tv for stream status" do
    before do
      # maximusblack isn't streaming
      FakeWeb.register_uri(:get, 'https://api.twitch.tv/kraken/streams/lagtvmaximusblack', :body =>
      '{
        "stream": null,
        "_links": {
          "channel": "https://api.twitch.tv/kraken/channels/lagtvmaximusblack",
          "self": "https://api.twitch.tv/kraken/streams/lagtvmaximusblack"
        }
      }')
    end

    it "should say maximusblack is not streaming and novawar is streaming" do
      # novawar is streaming
      FakeWeb.register_uri(:get, 'https://api.twitch.tv/kraken/streams/novawar', :body =>
      '{
        "stream": {
          "game": "StarCraft II: Wings of Liberty",
          "name": "novawar",
          "created_at": "Tue Jul 24 13:22:26 2012",
          "viewers": 3505,
          "updated_at": "Tue Jul 24 15:33:39 2012",
          "channel_id": 20248706,
          "_links": {
            "self": "https://api.twitch.tv/kraken/streams/novawar",
            "channel": "https://api.twitch.tv/kraken/channels/novawar"
          },
          "_id": 138658440,
          "delay_length": 0,
          "broadcaster": "fme",
          "geo": "CA",
          "channel": {
            "name": "novawar",
            "game": "StarCraft II: Wings of Liberty",
            "created_at": "2011-02-07T06:24:25Z"
          },
          "status": "Novawar: stomping toadstools since 1988"
        },
        "_links": {
          "self": "https://api.twitch.tv/kraken/streams/novawar"
        }
      }')

      Stream.maximusblack.live.should == false
      Stream.novawar.live.should == false

      Stream.update_live_state

      Stream.maximusblack.live.should == false
      Stream.novawar.live.should == true
    end

    it "should handle non-JSON response by catching exception and leaving stream booleans alone" do
      # novawar is breaking twitch.tv
      FakeWeb.register_uri(:get, 'https://api.twitch.tv/kraken/streams/novawar', :body => 'hey, whats up?')

      Stream.maximusblack.live.should == false
      Stream.novawar.live.should == false

      lambda { Stream.update_live_state }.should_not raise_exception

      Stream.maximusblack.live.should == false
      Stream.novawar.live.should == false
    end
  end

  context "helper methods" do
    it "should retrieve maximusblack's stream" do
      Stream.maximusblack.should == Stream.find_by_name('maximusblack')
    end

    it "should retrieve novawar's stream" do
      Stream.novawar.should == Stream.find_by_name('novawar')
    end
  end
end
