require 'acceptance/acceptance_helper'

feature 'Homepage renders' do

  background do
    visit '/'
  end

  scenario 'register button message appears' do
    page.should have_content('Send us your replays')
  end

  scenario 'starcraft tab' do
    page.should have_css('.tab', :text => 'LAGTV')
  end

  scenario 'the latest starcraft video' do
    page.should have_css(".lagtv1.latest_video")
  end

  scenario '24 recent starcraft videos' do
    page.should have_css(".lagtv1 .video_thumbnail", count: 24)
  end

  scenario 'lets play tab' do
    page.should have_css('.tab', :text => 'LAGTV2')
  end

  scenario 'the latest lets play video' do
    page.should have_css(".lagtv2.latest_video")
  end

  scenario '24 recent lets play videos' do
    page.should have_css(".lagtv2 .video_thumbnail", count: 24)
  end

  scenario 'lagtv is streaming' do
    # it'd be nice to check the title here too, but I can't figure out how
    page.should have_css(".twitch.live", text: 'L')
    page.should have_css(".twitch.offline", text: 'M')
    page.should have_css(".twitch.offline", text: 'N')
  end
end
