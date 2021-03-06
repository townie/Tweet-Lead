
class Account < ActiveRecord::Base
	validates_presence_of :username
	validates_uniqueness_of :username
	
	validate :valid_tokens
  
  has_many :tweets
  
  # Obtain our own tweets
  def get_timeline
    config = {:count => 200}
    config[:since_id] = self.last_own_tweet_id unless self.last_own_tweet_id.nil?
    
    tws = self.tc.user_timeline config
    
    # Por cada tweet
    tws.each do |t|
      next if Tweet.exists?({:status_id => t.id})
     
      # Verificamos si ya existe el profile
      # el primer if se puede borrar porque la regex obtiene siempre el username
      if t.in_reply_to_screen_name.nil? 
        screen_name = t.text.scan(/@(\w+)/i).flatten.first
        next if screen_name.nil?
      else
        screen_name = t.in_reply_to_screen_name
      end

      p = Profile.get(screen_name, self)
      
      next if p == false;
      
      data = t.to_hash.select{ |k,v| [ :coordinates, :created_at,
          :in_reply_to_screen_name, :in_reply_to_status_id, 
          :in_reply_to_status_id, :in_reply_to_user_id, :in_reply_to_user_id_str,
          :retweet_count, :retweeted, :source, :text
        ].include?(k)
      }
      # seteamos datos extras
      data['account_id'] = self.id
      data['profile_id'] = p.id
      data['status_id'] = t.id
      data['status_id_str'] = t.id
      data['from_account'] = true
      self.last_own_tweet_id = t.id
      
      # guardamos el tweet
      t = Tweet.new(data)
      t.save
    end
    self.save
  end

  
  #	 -------- Oauth methods
	def valid_tokens
		if tokens?
			# @ToDo this method return error if credentials arent valid, should return false. fix it
			if !self.tc.verify_credentials
				errors.add(:token, "tokens arent valid")
			end
		end
	end

	# Already have authentication tokens
	def tokens?
		!self.token.empty? && !self.token_secret.empty?
	end

  # holds the twitter client
  attr_accessor :twitter_client

  def tc
    self.twitter_client = Twitter::Client.new(
        :oauth_token => self.token,
        :oauth_token_secret => self.token_secret
    ) if self.twitter_client.nil?
      
    self.twitter_client
  end

  def follow user
    user = Integer user rescue user
    self.tc.follow user
    true 
  end
 
  # Get the oldest used account 
  def self.oldest_used
    self.order("updated_at").first
  end
  
  class << self

    attr_accessor :normal_tweets
    # this send SearchResult + Normal Tweets
    def launch_senders
      accounts = Account.all
      replies = SearchesResult.select([:id, :reply]).to_sent.limit 30
      puts "lanzando robots de twitteo con #{replies.count} tweets a enviar"

      self.normal_tweets = File.readlines("vendor/normal.txt").map { |i| SearchesResult.new({:reply => i}) }
      mutex = Mutex.new

      threads = []
      Thread.abort_on_exception = true
      accounts.each do |a|
        threads << Thread.new {
          until replies.empty?
            to_send = []
            mutex.synchronize do
              to_send = replies.slice!(0..4) + self.normal_tweets.sample(3)
            end
            puts " @#{a.username}: #{to_send.map(&:id).join(', ')}"
            to_send.shuffle.each do |sr|
              sr.account = a
              sr.tweet_it #_test
              sleep(rand(480..700).seconds) #80..200
            end
            sleep 1
          end
          puts "Finished thread #{a.username}"
        }
        threads.last.abort_on_exception = true
      end
      # puts threads.join
      threads.each { |t| t.join }
    end
  end
end
