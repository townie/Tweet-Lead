class SearchesController < ApplicationController
  # GET /searches
  # GET /searches.json
  def index
    @searches = Search.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @searches }
    end
  end

  # GET /searches/1
  # GET /searches/1.json
  def show
    @search = Search.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @search }
    end
  end

  # GET /searches/new
  # GET /searches/new.json
  def new
    @search = Search.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @search }
    end
  end

  # GET /searches/1/edit
  def edit
    @search = Search.find(params[:id])
  end

  # POST /searches
  # POST /searches.json
  def create
    @search = Search.new(params[:search])

    respond_to do |format|
      if @search.save
        format.html { redirect_to @search, notice: 'Search was successfully created.' }
        format.json { render json: @search, status: :created, location: @search }
      else
        format.html { render action: "new" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /searches/1
  # PUT /searches/1.json
  def update
    @search = Search.find(params[:id])

    respond_to do |format|
      if @search.update_attributes(params[:search])
        format.html { redirect_to @search, notice: 'Search was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /searches/1
  # DELETE /searches/1.json
  def destroy
    @search = Search.find(params[:id])
    @search.destroy

    respond_to do |format|
      format.html { redirect_to searches_url }
      format.json { head :ok }
    end
  end
  
  def process_all
    
    #carga todas las busquedas

    Search.all.each do |s|
      logger.info s.process 
    end
    raise "finish"
  end
  
  def terminator
    while true
      self.process_all
      self.launch_senders
    end
  end
  
  attr_accessor :normal_tweets
  def launch_senders
    accounts = Account.all
    replies = SearchesResult.select([:id, :reply]).to_sent
    self.normal_tweets = File.readlines("vendor/normal.txt").map { |i| SearchesResult.new({:reply => i})  }
    
    10.times { puts "-------------"  }
    sleep 1
    puts "Iniciando en 3..."
    sleep 1
    puts "2.."
    sleep 1
    puts "1.."
    sleep 1
    puts " DESPEGUEEEEE "
    10.times { puts "-------------"  }
    
    # cuerpos para los robotcitos
    threads = []
    accounts.each do |a|
      threads << Thread.new {
        while !replies.empty? #Mientras hayan huevos
          to_send = replies.slice!(0..4) + self.normal_tweets.slice(0..4)
          puts " ---> enviando desde #{a.username} #{to_send.count} mensajes"
          self.sender a, to_send.shuffle
        end
        puts "-----------------> terminado thread #{a.username}"
      }
    end
  end
  
  def sender a, to_send
    to_send.each do |sr|
      puts "#{a.username}: #{sr.id} #{sr.reply}"
      a.tc.update sr.reply
      sr.update_attribute(:sent, true) if sr.id
      sleep(rand(80..200).seconds)
    end
  end
end
