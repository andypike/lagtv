Fabricator(:email) do
  id { sequence(:id) }
  subject { "Weekly Update ##{rand(1000) + 1}" }
  body { "Hey there, hi there, ho there." }
  started_at { Time.now - 200 - rand(1000) }
  ended_at { rand(2) == 1 ? Time.now - rand(150) : nil }
  total_sent { rand(1000) }
  total_recipients { 1000 + rand(10000) }
  member { rand(2) == 1 }
  analyst { rand(2) == 1 }
  dev_team { rand(2) == 1 }
  moderator { rand(2) == 1 }
  community_manager { rand(2) == 1 }
  admin { true }
end

Fabricator(:roleless_email, from: :email) do
  member false
  analyst false
  dev_team false
  moderator false
  community_manager false
  admin false
end

Fabricator(:finished_email, from: :email) do
  ended_at Time.now
  total_sent 100
  total_recipients 100
end

Fabricator(:processing_email, from: :email) do
  ended_at nil
  total_sent 30
  total_recipients 100
end

Fabricator(:not_started_email, from: :email) do
  started_at nil
  ended_at nil
  total_sent 0
  total_recipients 100
end