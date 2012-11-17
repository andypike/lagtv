require 'acceptance/acceptance_helper'

feature 'Replay list without permission' do
  scenario 'disallow access' do
    visit '/replays'
    page.should have_content('You do not have permission to access that page')
  end  

  scenario 'No link in menu' do
    visit '/'
    page.should_not have_link("Replays") 
  end  
end

feature 'Replay list with permission' do
  background do
    admin = Fabricate(:admin)
    wcf = Fabricate(:category, :name => 'When cheese fails')
    normal = Fabricate(:category, :name => 'Normal Game')
    3.times do
      Fabricate(:replay, :category => wcf)
    end
    Fabricate(:replay, :title => 'super-duper 3v3 game replay', :players => '3v3', :category => wcf)
    Fabricate(:replay, :league => 'master', :title => 'Awesome Normal Game', :category => normal)
    Fabricate(:replay, :status => 'broadcasted', :category => wcf)
    Fabricate(:replay, :players => '4v4')
    Fabricate(:replay, :expires_at => DateTime.now.utc - 1.year, :category => wcf)

    login_as(admin)
    visit '/'
    click_link 'Replays'
  end

  scenario 'filter replays by category' do
    select 'Normal Game', :from => 'category_id'
    click_button 'Search'
    
    page.should have_css("table tbody tr", :count => 1)
    page.should have_css("table tbody tr", :text => 'Awesome Normal Game')
  end  

  scenario 'title with count appears' do
    page.should have_content('6 Replays')
  end

  scenario 'list all replays' do
    page.should have_css("table tbody tr", :count => 6)
  end

  scenario 'search replays' do
    fill_in 'query', :with => 'duper'
    click_button 'Search'

    page.should have_css("table tbody tr", :count => 1)
    page.should have_css("table tbody tr", :text => 'duper')
  end 

  scenario 'filter replays by league' do
    select 'Master', :from => 'league'
    click_button 'Search'

    page.should have_css("table tbody tr", :count => 1)
    page.should have_css("table tbody tr", :text => 'Master')
  end  

  scenario 'filter replays by players' do
    select '3v3', :from => 'players'
    click_button 'Search'

    page.should have_css("table tbody tr", :count => 1)
    page.should have_css("table tbody tr", :text => '3v3 game')
  end  

  scenario 'filter replays by status' do
    uncheck 'New'
    uncheck 'Suggested'
    uncheck 'Rejected'
    check 'Broadcasted'
    click_button 'Search'

    page.should have_css("table tbody tr", :count => 1)
    page.should have_css("table tbody tr", :text => 'Broadcasted')
  end    

  scenario 'include expired replays if selected' do
    check 'Include Expired Replays'
    click_button 'Search'

    page.should have_css("table tbody tr", :count => 7)
    page.should have_css("table tbody tr", :text => '(Expired)')
  end

  scenario 'display number of players' do
    page.should have_css("table tbody tr", :text => '4v4')
  end

  scenario 'display races' do
    page.should have_css("table tbody tr", :text => 'PZ')
  end
end

feature 'Editing a replay' do
  background do
    admin = Fabricate(:admin)
    Fabricate(:replay, :title => 'Super Awesome Replay!')
    
    login_as(admin)
    visit '/'
    click_link 'Replays'
  end

  scenario 'clicking a replay title navigates to the replay details' do
    click_link  'Super Awesome Replay!'
    
    page.should have_content('Super Awesome Replay!')
  end  

  scenario 'change the status of a replay' do
    click_link  'Super Awesome Replay!'
    select 'Suggested', :from => 'Status'
    click_button 'Save'

    page.should have_content('You have successfully updated the replay.')
    page.should have_css("table tbody tr", :text => 'Suggested')
  end    
end

