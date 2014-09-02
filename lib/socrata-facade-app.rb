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

module SocrataFacade
  class App < Sinatra::Base
    
    helpers do
      include Sinatra::ContentFor
      register Sinatra::StaticAssets     
      
  #    def dataset_link(id)
  #      return "http://" + ENV["SOCRATA_CATALOG"] + "/datasets/" + id
  #    end
  #
  #    def dataset_endpoint(id)
  #      return "http://" + ENV["SOCRATA_CATALOG"] + "/resource/" + id
  #    end
  #    
  #    def download_link(id, format)
  #      return "http://" + ENV["SOCRATA_CATALOG"] + "/api/views/" + id + "/rows." + format + "?accessType=DOWNLOAD"
  #    end
      
      set :uris, SocrataFacade::URIFactory.new(ENV["SOCRATA_CATALOG"])
        
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
      @datasets = datasets()
      @datasets.sort! {|x,y| x["modified"] <=> y["modified"] }.reverse![0..5]
      erb :index
    end  
    
    get "/datasets" do
      @datasets = datasets()
      @datasets.sort! {|x,y| x["modified"] <=> y["modified"] }.reverse!
      erb :datasets
    end
    
    get "/datasets/:id" do
      @dataset = dataset(params[:id])
      @size = dataset_size(params[:id])
      erb :dataset
    end
    
#    get "/compare" do
#      puts params["fieldset"]
#      @datasets = views()
#      erb :compare
#    end
      
    def dataset(id)
      response = RestClient.get settings.uris.dataset_metadata(id)
      return JSON.parse( response.to_str )
    end 
    
    def dataset_size(id)
      response = RestClient.get settings.uris.dataset_endpoint(id), {:params => {"$select" => "count(*)"} }    
      result = JSON.parse( response.to_str )
      return result[0]["count"].to_i
    end
    
    def datasets()
      response = RestClient.get settings.uris.catalog_dcat()    
      result = JSON.parse( response.to_str )
      #ignore first entry which is the catalog
      return result[1..-1]
    end
    
    def views()
      response = RestClient.get settings.uris.views()    
      result = JSON.parse( response.to_str )
      return result.select{ |v| v["displayType"] == "table" }
    end    
    
    not_found do
      'Not Found'
    end
      
  end
end