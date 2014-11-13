class Datafile
  
  def self
    
  end
  
  def self.uploadDataFiles(params)   
      valMsg = nil
      ## check work group type
      if (not(File.exists?(Rails.root.join("fileloc",params[:wgType]))))
        Dir.mkdir(Rails.root.join("fileloc", params[:wgType])) 
      end
      ## check sub type
      if (params[:newSubType] != nil)
        if (not(File.exists?(Rails.root.join("fileloc",params[:wgType], params[:newSubType]))))
          Dir.mkdir(Rails.root.join("fileloc", params[:wgType], params[:newSubType])) 
        end
        ## save uploaded file
        if (params[:file].original_filename !~ /\./)
          params[:file].original_filename = params[:file].original_filename + ".txt"
        end
        if (not(File.exists?(Rails.root.join("fileloc",params[:wgType],params[:newSubType],params[:file].original_filename)))) 
          File.open(Rails.root.join('fileloc',params[:wgType],params[:newSubType],params[:file].original_filename), 'w') do |file|
            file.write(params[:file].read)
          end
          valMsg = "uploaded"
        else
          valMsg = "exists"
        end    
      else
        if (not(File.exists?(Rails.root.join("fileloc",params[:wgType], params[:sType]))))
          Dir.mkdir(Rails.root.join("fileloc", params[:wgType], params[:sType])) 
        end
        ## save uploaded file
        if (params[:file].original_filename !~ /\./)
          params[:file].original_filename = params[:file].original_filename + ".txt"
        end
        if (not(File.exists?(Rails.root.join("fileloc",params[:wgType],params[:sType],params[:file].original_filename)))) 
          File.open(Rails.root.join('fileloc',params[:wgType],params[:sType],params[:file].original_filename), 'w') do |file|
            file.write(params[:file].read)
          end
          valMsg = "uploaded"
        else
          valMsg = "exists"
        end    
      end  
      return valMsg      
  end
  
  def self.uploadResourceFiles(params)
      valMsg = nil
      ## check work group type
      if (not(File.exists?(Rails.root.join("fileloc",params[:wgType]))))
        Dir.mkdir(Rails.root.join("fileloc", params[:wgType])) 
      end
      ## check sub type
      if (params[:newSubType] != nil)
        if (not(File.exists?(Rails.root.join("fileloc",params[:wgType], params[:newSubType]))))
          Dir.mkdir(Rails.root.join("fileloc", params[:wgType], params[:newSubType])) 
        end
        ## save uploaded file
        if (params[:file].original_filename !~ /\./)
          params[:file].original_filename = params[:file].original_filename + ".iostream"
        end
        if (not(File.exists?(Rails.root.join("fileloc",params[:wgType],params[:newSubType],params[:file].original_filename)))) 
          File.open(Rails.root.join('fileloc',params[:wgType],params[:newSubType],params[:file].original_filename), 'wb') do |iostream|
            iostream.write(params[:file].read)
          end
          valMsg = "uploaded"
        else
          valMsg = "exists"
        end    
      else
        if (not(File.exists?(Rails.root.join("fileloc",params[:wgType], params[:sType]))))
          Dir.mkdir(Rails.root.join("fileloc", params[:wgType], params[:sType])) 
        end
        ## save uploaded file
        if (params[:file].original_filename !~ /\./)
          params[:file].original_filename = params[:file].original_filename + ".iostream"
        end
        if (not(File.exists?(Rails.root.join("fileloc", params[:wgType], params[:sType],params[:file].original_filename))))
          File.open(Rails.root.join("fileloc", params[:wgType], params[:sType],params[:file].original_filename),'wb') do |iostream|
            iostream.write(params[:file].read)
          end 
          valMsg = "uploaded"
        else
          valMsg = "exists"
        end    
      end  
      return valMsg      
  end


  def self.validate(params)
    valMsg = nil
    
    ## validate missing file name
    if (params[:file] == nil)
      valMsg = "missingFile"
      return valMsg
    end
    
    ## valite new sub type
    if (params[:newSubType] =~ /\./)
      valMsg = "invalid"
    elsif (params[:newSubType] =~ /^\//)
      valMsg = "invalid"
    elsif (params[:newSubType] =~ /\s/)
      valMsg = "invalid"
    else
      valMsg = "valid"
    end
  
    return valMsg     
  end







end