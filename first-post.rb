require 'active_support/all'
require 'cinch'

server = "irc.freenode.org"
channel = "#fp-bots"

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "fpb"
    c.server = server
    c.channels = [channel]

    Timer(1) { check_fp }
  end

  $last_fp = { }

  on :message, /fp/ do |m|
    if($last_fp[:date].nil? or !Time.now.day.eql? $last_fp[:date].day)
      m.reply "Dammit"
      $last_fp[:date] = Time.now
      $last_fp[:nick] = m.user.nick
    end
  end

  def check_fp
    if($last_fp[:date].nil?)
      debug "No fp yet"
    elsif(!Time.now.day.eql? $last_fp[:date].day)
      $last_fp[:date] = Time.now
      Channel("#fp-bots").send("fp")
    else
      debug "Waiting for next day: #{how_long} left"
    end
  end

  def how_long
      t=Time.now + 86400
      t2=t.beginning_of_day

      time_left = (t2-Time.now).to_i

      hours_left = (time_left / 3600).to_i
      minutes_left = ((time_left % 3600) / 60).to_i
      seconds_left = (time_left % 60).to_i

      "#{time_left}/#{hours_left}:#{minutes_left}:#{seconds_left}"
  end
end

bot.start
