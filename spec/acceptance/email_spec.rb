require 'acceptance/acceptance_helper'

feature 'Send an email to groups' do
  background do
    admin = Fabricate(:admin)
    login_as(admin)
    visit new_email_path
  end

  scenario 'email analysts' do
    fill_in 'Subject', :with => 'Welcome to lag.tv'
    fill_in 'Body', :with => 'Hope you enjoy yourselves. Buy some schwag!'
    select 'Admin', :from => 'Role'
    click_button 'Send'

    page.should have_content('Your email has been sent')
    page.should have_content('Sending rate')
    page.should have_content('Time of completion')
  end

  scenario 'email without a role' do
    fill_in 'Subject', :with => 'Welcome to lag.tv'
    fill_in 'Body', :with => 'Hope you enjoy yourselves. Buy some schwag!'
    click_button 'Send'

    page.should have_content("can't be blank")
  end

  scenario 'email as a member (who lacks permission)' do
    member = Fabricate(:member)
    login_as(member)
    visit '/emails/new'
    page.should have_content('You do not have permission to access that page')
  end  
end

feature 'Show an email' do
  background do
    admin = Fabricate(:admin)
    login_as(admin)
  end

  scenario 'Not started email' do
    email = Fabricate(:email, started_at: nil)
    visit "/emails/#{email.id}"
    page.should have_content('Your email is being processed')
    page.should have_content("Hasn't started yet")
  end

  scenario 'Halfway finished email' do
    email = Fabricate(:email, started_at: Time.now - 5.minutes, ended_at: nil, total_sent: 300, total_recipients: 600)
    visit "/emails/#{email.id}"
    page.should have_content('Your email is being processed')
    page.should_not have_content("Hasn't started yet")
    page.should have_content('Still sending...')
    page.should have_content('Total emails sent: 300')
    page.should have_content('Total remaining: 300')
    page.should have_content('Sending rate: 1 per second')
  end

  scenario 'Finished email' do
    email = Fabricate(:email, started_at: Time.now - 5.minutes, ended_at: Time.now, total_sent: 600, total_recipients: 600)
    visit "/emails/#{email.id}"
    page.should have_content('Your email has been sent.')
    page.should_not have_content("Hasn't started yet")
    page.should_not have_content('Still sending...')
    page.should have_content('Total emails sent: 600')
    page.should have_content('Total remaining: 0')
    page.should have_content('Sending rate: 2 per second')
  end
  

  scenario 'As a member (who lacks permission)' do
    email = Fabricate(:email)
    member = Fabricate(:member)
    login_as(member)
    visit "/emails/#{email.id}"
    page.should have_content('You do not have permission to access that page')
  end
end

feature 'List emails' do
  background do
    admin = Fabricate(:admin)
    login_as(admin)
  end

  scenario 'Show normal list for admin' do
    Fabricate(:finished_email)
    Fabricate(:not_started_email)
    Fabricate(:processing_email)
    visit "/emails"
    page.should have_content "Emails"
    page.should have_content "Total Sent"
    page.should have_content "Recipients"
    page.should have_content "Status"
    page.should have_content "Done"
    page.should have_content "Not Started"
    page.should have_content "Processing"
  end

  scenario 'Show empty list for admin' do
    visit "/emails"
    page.should_not have_content "Total Sent"
    page.should_not have_content "Recipients"
    page.should_not have_content "Status"
    page.should have_content "Emails"
    page.should have_content "No emails to list"
  end

  scenario 'Show list as a member (who lacks permission)' do
    email = Fabricate(:email)
    member = Fabricate(:member)
    login_as(member)
    visit "/emails"
    page.should have_content('You do not have permission to access that page')
  end
end