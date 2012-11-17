module ReplayHelper
  def races_to_str(replay)
    str = ''
    str += 'P' if replay.protoss
    str += 'T' if replay.terran
    str += 'Z' if replay.zerg
    str
  end
end