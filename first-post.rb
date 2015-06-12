require 'active_support/all'
require 'cinch'

bot = Cinch::Bot.new do
  $server = "irc.atrum.org"
  $channel = "#zacon"

  $last_fp = { }
  $joining_channel = 0

  configure do |c|
    c.nick = "fpb"
    c.server = $server
    c.channels = []

    Timer(1) { check_fp(self) }
  end

  on :message, /^fp$/ do |m|
    if($last_fp[:date].nil? or !Time.now.day.eql? $last_fp[:date].day)
      m.reply "Damn you humans! Our day is coming!"
      $last_fp[:date] = Time.now
      $last_fp[:nick] = m.user.nick
    end
  end

  on :message, /^hfuesahlfeusl$/ do |m|
    $last_fp[:date] = Time.now - 86400
  end

  def check_fp(bot)
    seconds_left = how_many_seconds?

    if($last_fp[:date].nil?)
      $last_fp[:date] = Time.now
    elsif(!Time.now.day.eql? $last_fp[:date].day)
      if !bot.channels.include? $channel
        bot.join $channel
      else
        $last_fp[:date] = Time.now

        Channel($channel).send("fp")
        Channel($channel).send("boom!")
      end
    else
      debug "Waiting for next day: #{how_long?} left"
      if bot.channels.include? $channel and (Time.now - $last_fp[:date]).to_i > 10
        bot.part $channel
      end
    end

  end

  def how_many_seconds?
      t=Time.now + 86400
      t2=t.beginning_of_day

      (t2-Time.now).to_i
  end

  def how_long?
      time_left = how_many_seconds?

      hours_left = (time_left / 3600).to_i
      minutes_left = ((time_left % 3600) / 60).to_i
      seconds_left = (time_left % 60).to_i

      "#{time_left}/#{hours_left}:#{minutes_left}:#{seconds_left}"
  end
end

bot.start
