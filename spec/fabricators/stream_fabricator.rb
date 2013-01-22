Fabricator(:stream) do
  name "maximusblack"
  live false
end

Fabricator(:maximusblack_stream, from: :stream) do
  name "maximusblack"
  live false
end

Fabricator(:novawar_stream, from: :stream) do
  name "novawar"
  live false
end

Fabricator(:lagtv_stream, from: :stream) do
  name "lagtv"
  live false
end