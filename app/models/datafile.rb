class Datafile
  
  def self
    
  end
  
  def self.changeFileLocation(ctype,subtype,details)
    msg = nil
    
    if(File.exists?(Rails.root.join('fileloc', ctype, subtype)))
      cpath = Rails.root.join('fileloc',details['ctype'],details['subtype'],details['filename'])
      tpath = Rails.root.join('fileloc',ctype,subtype,details['filename'])
      File.rename cpath, tpath
      msg = "changed"
    else
      ## make new sub folder 
      Dir.mkdir(Rails.root.join('fileloc',ctype,subtype))
      cpath = Rails.root.join('fileloc',details['ctype'],details['subtype'],details['filename'])
      tpath = Rails.root.join('fileloc',ctype,subtype,details['filename'])
      File.rename cpath, tpath
      msg = "changed"
    end   
    
    return msg
  end
  
  def self.updateWikiFile(user,params)
    
    msg = ""
    filetoedit = params[:pageName] + ".wiki"
    File.open(Rails.root.join('wiki',filetoedit),'wb') do |file|
      file.write(params[:pageDesc])
    end
    ## log to db
    msg = User.updateWikibyPage(user,params)
    ## save attachment and log to db
    if (params[:afile] != nil)
      if(not(File.exists?(Rails.root.join('wikiattachments',params[:pageName]))))
        Dir.mkdir(Rails.root.join('wikiattachments',params[:pageName]))
          if (not(File.exists?(Rails.root.join('wikiattachments',params[:pageName],params[:afile].original_filename))))
            ## log to db
            msg,attname = User.createWikiAttachment(params)
            if msg == "inserted"
              File.open(Rails.root.join("wikiattachments", params[:pageName], attname),'wb') do |iostream|
                iostream.write(params[:afile].read)
              end
              msg = "updated"
            else
              msg = nil
            end    
          else
            msg = "att_exists"
          end
      else
        if (not(File.exists?(Rails.root.join('wikiattachments',params[:pageName],params[:afile].original_filename))))
          ## log to db
          msg,attname = User.createWikiAttachment(params)
          if msg == "inserted"
            File.open(Rails.root.join("wikiattachments", params[:pageName], attname),'wb') do |iostream|
              iostream.write(params[:afile].read)
            end
            msg = "updated"
          else
            msg = nil
          end    
        else
          msg = "att_exists"
        end                
      end  
     end
    
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
  
  def self.uploadResourceFiles(user,params)
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
          ## log to db
          valMsg = User.createUploadFile(user,params[:fileType],params[:wgType],params[:newSubType],params[:file].original_filename,params[:comments])
          if valMsg == "inserted"
            valMsg = "uploaded"
          end
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
          ## log to db
          valMsg = User.createUploadFile(user,params[:fileType],params[:wgType],params[:sType],params[:file].original_filename,params[:comments])
          if valMsg == "inserted"
            valMsg = "uploaded"
          end
        else
          valMsg = "exists"
        end    
      end  
      return valMsg      
  end


  def self.validate(params)
    valMsg = nil
    suggestsfname = nil
    
    ## validate missing file name
    if (params[:file] == nil)
      valMsg = "missingFile"
      return valMsg
    end
    
    ## valite new sub type
    if (params[:newSubType] =~ /\./)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/\./,"")
    elsif (params[:newSubType] =~ /\'/)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/\'/,"")
    elsif (params[:newSubType] =~ /\"/)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/\"/,"")
    elsif (params[:newSubType] =~ /\//)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/\//,"")
    elsif (params[:newSubType] =~ /\s/)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/(\s)+/,"")
    else
      valMsg = "valid"
    end
  
    return valMsg,suggestsfname    
  end

  def self.validateSubType(params)
    valMsg = nil
    suggestsfname = nil
    
    ## valite new sub type
    if (params[:newSubType] =~ /\./)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/\./,"")
    elsif (params[:newSubType] =~ /\'/)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/\'/,"")
    elsif (params[:newSubType] =~ /\"/)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/\"/,"")
    elsif (params[:newSubType] =~ /\//)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/\//,"")
    elsif (params[:newSubType] =~ /\s/)
      valMsg = "invalid"
      suggestsfname = params[:newSubType].gsub(/(\s)+/,"")
    else
      valMsg = "valid"
    end
  
    return valMsg,suggestsfname    
  end



  def self.createWikiPage(user,params)
    
    valMsg = nil
    filename = params[:pageName] + ".wiki"
    
    if (not(File.exists?(Rails.root.join('wiki',filename))))
      ## log to db
      valMsg,filename = User.createWikiDB(user,params)
      filename = filename + ".wiki"
      if valMsg == "inserted"
        ## create page file
        File.open(Rails.root.join('wiki',filename),'wb') do |file|
          file.write(params[:pageDesc])
        end
        ## save attachment
        if (params[:afile] != nil)
          if(not(File.exists?(Rails.root.join('wikiattachments',params[:pageName]))))
            Dir.mkdir(Rails.root.join('wikiattachments',params[:pageName]))
            if (not(File.exists?(Rails.root.join('wikiattachments',params[:pageName],params[:afile].original_filename))))
              ## log to db
              valMsg,attname = User.createWikiAttachment(params)
              if valMsg == "inserted"
                File.open(Rails.root.join("wikiattachments", params[:pageName], attname),'wb') do |iostream|
                  iostream.write(params[:afile].read)
                end
              else
                valMsg = nil
              end    
            else
              valMsg = "att_exists"
            end
          else
            if (not(File.exists?(Rails.root.join('wikiattachments',params[:pageName],params[:afile].original_filename))))
              ## log to db
              valMsg,attname = User.createWikiAttachment(params)
              if valMsg == "inserted"
                File.open(Rails.root.join("wikiattachments", params[:pageName], attname),'wb') do |iostream|
                  iostream.write(params[:afile].read)
                end
              else
                valMsg = nil
              end    
            else
              valMsg = "att_exists"
            end                
          end  
        end
        valMsg = "created"
      else
        valMsg = nil
      end    
    else
      valMsg = "exists"
    end        
    
    return valMsg

  end


end