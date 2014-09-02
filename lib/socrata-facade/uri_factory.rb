# encoding: utf-8

module SocrataFacade
  class URIFactory
    
    attr_reader :base
    
    def initialize(base)
      @base = base || ENV["SOCRATA_CATALOG"]
    end
    
    def uri(path)
      return "http://#{@base}/#{path}"
    end
  
    #Returns the JSON document that contains complete list of all Socrata views
    #this includes datasets and other types of resource.
    def views()
      return uri("api/views/")
    end
    
    #Return list of datasets expressed using DCAT terms in JSON
    def catalog_dcat()
      return uri("api/dcat.json")
    end
    
    def dataset_home(id)
      return uri("datasets/" + id)
    end  
    
    #Detailed metadata for a dataset, using Socrata JSON format. Includes custom metadata
    def dataset_metadata(id)
      return uri("views/" + id + ".json")
    end
    
    #The default API for the dataset
    def dataset_endpoint(id)
      return uri("resource/" + id)
    end
    
    def dataset_download_link(id, format)
      return uri("api/views/" + id + "/rows." + format + "?accessType=DOWNLOAD")
    end
      
  end
end
