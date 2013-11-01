##
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
# 
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
# 
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
#  0. You just DO WHAT THE FUCK YOU WANT TO.
##

require 'cinch'
require 'json'
require 'open-uri'
require 'htmlentities'

class String
  def nl2(wat)
    self.gsub(/\r\n?/, wat)
  end
  
  def decode
    HTMLEntities.new.decode self
  end
end

class Quotone
  def self.get(url, n = nil)
    open(url) { |f|
      quote = JSON.parse(f.read)
      quote = quote[n] if n.is_a? Fixnum
      return "\##{quote['id']} - #{quote['source']} (#{quote['tags']})\n#{quote['quote'].nl2(' / ').decode}"
    }
  end
  
  def self.page(page_id, n)
    self.get "http://www.quotone.unsigned.it/api/page/#{page_id}.json", n
  end
  
  def self.latest
    self.get 'http://www.quotone.unsigned.it/api/get/latest.json'
  end
  
end

Cinch::Bot.new {
  configure do |c|
    c.nick    = 'quotone'
    c.server  = 'irc.niggazwithattitu.de'
    c.channels = ['#nerdz']
  end

  on :message, 'quotone!' do |m|
    m.reply "Retrieving the last quote published..."
    m.reply Quotone.latest
  end

  on :message, /^quotone!\s([0-9])$/ do |m, page_id|
    m.reply "Retrieving the first quote on page #{page_id}..."
    m.reply Quotone.page(page_id, 1)
  end

  on :message, /^quotone!\s([0-9])\s([0-9])$/ do |m, page_id, n|
    m.reply "Retrieving the quote \##{n} on page #{page_id}..."
    m.reply Quotone.page(page_id, n.to_i)
  end
}.start
