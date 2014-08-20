require 'sinatra'
require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/static_assets'
require 'sinatra/url_for'
require 'rack/linkeddata'
require 'json'
require 'rack/conneg'
require 'uri'
require 'dotenv'
require 'rest_client'

Dotenv.load

class Facade < Sinatra::Base
  
  helpers do
    include Sinatra::ContentFor
    register Sinatra::StaticAssets     
    
    def dataset_link(id)
      return "http://" + ENV["SOCRATA_DOMAIN"] + "/datasets/" + id
    end

    def dataset_endpoint(id)
      return "http://" + ENV["SOCRATA_DOMAIN"] + "/resource/" + id
    end
    
    def download_link(id, format)
      return "http://" + ENV["SOCRATA_DOMAIN"] + "/api/views/" + id + "/rows." + format + "?accessType=DOWNLOAD"
    end
    
  end 
  
  #Configure application level options
  configure do |app|
    set :static, true    
    set :views, File.dirname(__FILE__) + "/../site/views"
    set :public_dir, File.dirname(__FILE__) + "/../site/public"
  end
  
  use(Rack::Conneg) { |conneg|
    conneg.set :accept_all_extensions, false
    conneg.set :fallback, :html
    conneg.ignore_contents_of(File.join(File.dirname(__FILE__),'/../site/public'))
    conneg.provide([:json, :ttl, :rdf])
  }

  get "/" do
    erb :index
  end  
  
  get "/datasets/:id" do
    @dataset = dataset(params[:id])
    @size = dataset_size(params[:id])
    erb :dataset
  end
    
  def dataset(id)
    response = RestClient.get "#{ENV["SOCRATA_DOMAIN"]}/views/#{id}.json"
    return JSON.parse( response.to_str )
  end 
  
  def dataset_size(id)
    response = RestClient.get "#{ENV["SOCRATA_DOMAIN"]}/resource/#{id}.json", {:params => {"$select" => "count(*)"} }    
    result = JSON.parse( response.to_str )
    return result[0]["count"].to_i
  end
  
  not_found do
    'Not Found'
  end
    
end