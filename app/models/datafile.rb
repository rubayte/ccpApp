class Datafile
  
  def self
    
  end
  
  def self.updateWikiFile(params)
    
    msg = ""
    filetoedit = params[:editFileName]
    File.open(Rails.root.join('wiki',filetoedit),'wb') do |file|
      file.write(params[:editData])
    end
    msg = "updated"    
    
    return msg
    
  end
  
  def self.createMemberListFile(results)
    
    msg = ""
    File.open(Rails.root.join('memberlist','listofpeople.csv'), 'wb') do |file|
      results.each do |r1,r2,r3,r4,r5,r6,r7|
        file.write(r1 + ",")
        file.write(r2 + ",")
        file.write(r3 + ",")
        file.write(r4 + ",")
        file.write(r5 + ",")
        file.write(r6 + ",")
        file.write(r7 + "\n")     
      end
    end
    msg = "file_created"
    return msg
      
  end
  
  def self.setNewProfileImage(targetFileName)
    
    msg = ""
    File.open(Rails.root.join('app','assets','images',targetFileName), 'wb') do |iostream|
      iostream.write(Rails.root.join('app','assets','images','member_image.png').read)
    end
    msg = "uploaded"
    return msg
    
  end

  def self.updateProfileImage(infile,targetFileName)
    
    msg = ""
    File.open(Rails.root.join('app','assets','images',targetFileName), 'wb') do |iostream|
      iostream.write(infile.read)
    end
    msg = "uploaded"
    return msg
  
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