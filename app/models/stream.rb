require 'net/https'

class Stream < ActiveRecord::Base
  attr_accessible :name, :live

  def self.update_live_state
    poll('lagtvmaximusblack', 'maximusblack')
    poll('novawar', 'novawar')
  end

  def self.poll(stream, person)
    begin
      uri = URI("https://api.twitch.tv/kraken/streams/#{stream}")
      response = ''
      Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        request = Net::HTTP::Get.new uri.request_uri
        response = http.request(request).body
      end
      live = JSON.parse(response)['stream'] != nil
      logger.debug "#{person}'s stream is #{live ? '' : 'not'} live"
      find_by_name(person).update_attribute(:live, live)
    rescue => e
      logger.error "Twitch polling of #{person}'s stream failed with exception: #{e}"
    end
  end

  def self.maximusblack
    Stream.find_by_name('maximusblack')
  end

  def self.novawar
    Stream.find_by_name('novawar')
  end
end