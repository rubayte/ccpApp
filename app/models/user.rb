class User
  

  def self
    con = Mysql.connect('127.0.0.1', 'wwwUser', 'wwwpublic', 'ccp')
    return con
  end
  
  
  ## get publications list
  def self.getPublications()
    
    ccU = User.new.self 
    qryTools = "SELECT * FROM `publications`" 
    refTools = ccU.query(qryTools)
    ccU.close
    
    return refTools,refTools.num_rows

    
  end
  
  ## add edit publicaion
  def self.addEditPub(params,user)
    
    msg = nil
    ccU = User.new.self
    
    if (params[:eid] != nil and params[:eid] != "")
      ## edit item
      qryUpdate = "update `publications` set doi='"+ params[:doi]+"', authors='"+ params[:authors]+"', title='"+ params[:title]+"', magazine='"+ params[:magazine]+"', volume='"+ params[:volume]+"', type='"+ params[:type]+"', last_edit_by='" + user + "', last_edit_at=NOW() where id=" + params[:eid]+ "" 
      ccU.query(qryUpdate)
      msg = "updated"   
    else
      ## insert item
      qryInsert = "insert into `publications`(doi,authors,title,magazine,volume,type,created_by,created_at,last_edit_by,last_edit_at) values('"+ params[:doi] + "','"+ params[:authors] + "','" + params[:title] + "','" + params[:magazine]+ "','"+ params[:volume]+ "','" + params[:type] + "','"+ user + "',NOW(),'-',NOW())"
      ccU.query(qryInsert)
      msg = "created"
    end
    ccU.close
     
    return msg
    
  end
  
  ## get publication details
  def self.getPublicationDetails(pubid)
    
    pubData = []
    ccU = User.new.self
    qrySelect = "select doi,authors,title,magazine,volume,type from publications where id = " + pubid+ ""
    refPub= ccU.query(qrySelect)
    refPub.each do |r|
      r.each do |rtemp|
       pubData.push(rtemp)
      end
    end
    ccU.close
    
    return pubData
    
  end
  
  ## get wiki pages
  def self.getWikiPages()
     
    pages = Hash.new()
    parentPages = []
    
    ccU = User.new.self
    ## get wiki pages
    qryWiki = "select * from `user_created_wikis` as W left join `wiki_structure` as S on W.page = S.`parent_page_name`;"
    refWikis = ccU.query(qryWiki)
    refWikis.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9,r10|
      if pages.has_key?(r3)
        pages[r3] = pages[r3] + "#" + r9
      else
        pages[r3] = r9
      end
    end
    ccU.close
    
    parentPages = User.getParentPages()
    
    return pages,parentPages
     
  end
  
  ## get all target pages to move
  def self.getTargetChildPages()
    
    pages = []
    ccU = User.new.self
    ## get target child pages
    qryChildWiki = "select * from `user_created_wikis` as W left join `wiki_structure` as S on W.page = S.`parent_page_name` where S.`parent_page_name` is NULL and S.`child_page_name` is NULL;"
    refChildWiki = ccU.query(qryChildWiki)
    refChildWiki.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9,r10|
      pages.push(r3)
    end  
    ccU.close
    
    return pages
    
  end
  
  ## get all parent pages
  def self.getParentPages()
    
    pages = []
    ccU = User.new.self
    ## get all possible parent pages
    qryParentWiki = "select * from `user_created_wikis` as W left join `wiki_structure` as S on W.page = S.`child_page_name` where S.`child_page_name` is NULL;"
    refParentWiki = ccU.query(qryParentWiki)
    refParentWiki.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9,r10|
      pages.push(r3)
    end
    ccU.close
    
    return pages
    
  end
  
  ## move wiki pages
  def self.moveChildToParentWiki(params)
    
    msg = nil
    if params[:childPage] == params[:parentPage]
      msg = "same"
    else
      ## move the page
      ccU = User.new.self
      ## check if the page is currently under any parent page
      qryCheck = "select * from `wiki_structure` where `child_page_name` = '" +params[:childPage]+ "'"
      refCheck = ccU.query(qryCheck)
      if refCheck.num_rows > 0
        ## child page is already under some parent; delete the current relation and make insertion
        qryDeleteChild = "delete from `wiki_structure` where `child_page_name` = '" +params[:childPage]+ "'"
        ccU.query(qryDeleteChild)
        if (params[:parentPage] == "wiki root /")
          ## nothing to do
          msg = "moved"
        else
          qryMove = "insert into `wiki_structure`(`parent_page_name`,`child_page_name`) values ('"+params[:parentPage]+"','"+params[:childPage]+"')"
          ccU.query(qryMove)
          msg = "moved"            
        end
      else
        if (params[:parentPage] == "wiki root /")
          ## nothing to do
          msg = "already_in_location"
        else
          ## not present; simply make an insertion with parent page
          qryMove = "insert into `wiki_structure`(`parent_page_name`,`child_page_name`) values ('"+params[:parentPage]+"','"+params[:childPage]+"')"
          ccU.query(qryMove)
          msg = "moved"      
        end
      end
      ccU.close
    end
    
    return msg
    
  end
  
  ## get wiki attachments by page
  def self.getWikiAttachmentByPage(page)
    
    atts = []
    
    ccU = User.new.self
    ## get wiki attachments
    qryWiki = "select page,attachment from `wiki_attachments` where page ='" + page + "';"
    refWikis = ccU.query(qryWiki)
    refWikis.each do |r1,r2|
      atts.push(r2)
    end
    ccU.close

    return atts
    
  end
  
  
  ## create wiki attachment
  def self.createWikiAttachment(params)
    
    msg  = ""
    att = params[:afile].original_filename
    ccU = User.new.self
    ## validate for mysql
    att = validateStr(att)
    ## validate for colon(;) and hash
    att = validateStr2(att)
    qryInsert = "insert into `wiki_attachments`(`page`,`attachment`,`created_on`,`edited_on`) values('" + 
    params[:pageName] + "','" + att + "',NOW(),NULL);"
    ccU.query(qryInsert)
    ccU.close
    msg = "inserted"
    
    return msg,att

  end
  
  
  ## update wiki by page
  def self.updateWikibyPage(user,params)
    
    msg = nil
    ccU = User.new.self
    ## get wiki details
    qryWiki = "update `user_created_wikis` set `last_edit_by` = '"+ user+"' , `last_edit_on` = NOW() where page = '" + params[:pageName] + "'"
    ccU.query(qryWiki)
    ccU.close
    msg = "updated"
    
    return msg
    
  end

  ## get wiki info by page
  def self.getWikiInfoByPage(page)
    
    user = nil
    created_at = nil
    last_edit_by = nil
    last_edit_at = nil
    ccU = User.new.self
    ## get wiki details
    qryWiki = "select username,`created_on`,`last_edit_by`,`last_edit_on` from `user_created_wikis` where page ='" + page + "';"
    refWikis = ccU.query(qryWiki)
    refWikis.each do |r1,r2,r3,r4|
      user= r1
      created_at = r2
      last_edit_by = r3
      last_edit_at = r4
    end
    ccU.close
    
    return user,created_at,last_edit_by,last_edit_at
    
  end  
  
  ## get user email by username
  def self.getUserMail (user)

    useremail = []
    ccU = User.new.self
    ## get user email
    qryEmail = "select email from users where username ='" + user + "';"
    refEmails = ccU.query(qryEmail)
    refEmails.each do |r1|
      useremail= r1
    end
    useremailstr = useremail.join(",")
    return useremailstr
    
  end
  
  ## create wiki page
  def self.createWikiDB(user,params)

    msg  = ""
    useremail = []
    ccU = User.new.self
    ## get user email
    qryEmail = "select email from users where username ='" + user + "';"
    refEmails = ccU.query(qryEmail)
    refEmails.each do |r1|
      useremail= r1
    end
    useremailstr = useremail.join(",")
    ## validate for mysql
    params[:pageName] = validateStr(params[:pageName])
    ## validate for colon(;) and hash
    params[:pageName] = validateStr2(params[:pageName])
    qryInsert = "insert into `user_created_wikis`(`username`,`email`,`page`,`created_on`,`last_edit_by`,`last_edit_on`) values('" + 
    user + "','" + useremailstr + "','" + params[:pageName] + "',NOW(),NULL,NULL);"
    ccU.query(qryInsert)
    ccU.close
    msg = "inserted"
    
    return msg,params[:pageName]
    
  end


  ## get file details by id
  def self.getFileDetails(fileid)
    
    fileDetails = Hash.new()
    ccU = User.new.self
    qryFile = "select * from `user_uploaded_files` where id = " + fileid + ""
    refFile = ccU.query(qryFile)
    if refFile.num_rows > 0
      refFile.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9|
        fileDetails['username'] = r1
        fileDetails['email'] = r2
        fileDetails['type'] = r3
        fileDetails['ctype'] = r4
        fileDetails['subtype'] = r5
        fileDetails['filename'] = r6
        fileDetails['comments'] = r7
        fileDetails['createdon'] = r8
        fileDetails['fileid'] = r9
      end
     end
     ccU.close
        
     return fileDetails   
     
  end
  
  ## get all subtypes from user uploaded files
  def self.getSubtypes()
    
    res = []
    ccU = User.new.self
    qrySubtype = "select distinct subtype from `user_uploaded_files`"
    refSubtype = ccU.query(qrySubtype)
    if refSubtype.num_rows > 0
      refSubtype.each do |r|
        res.push(r)
      end
    end
    ccU.close
    return res
        
  end
  
  ## get all user emails
  def self.getAllUserEmails()
    
    ccU = User.new.self
    qryEmails = "select CONCAT(firstname, ' ' , lastname, ' (', email, ')') from `users`"
    refEmails = ccU.query(qryEmails)
    return refEmails
        
  end
  
  ## edit file in db
  def self.commitFileChanges(params)

    msg = ""    
    fhash = Hash.new
    ccU = User.new.self
    
    ## decide for file location change
    fhash = getFileDetails(params[:fid])
    if fhash['ctype'] == params[:edit_ctype] and fhash['subtype'] == params[:edit_subtype] and fhash['type'] == params[:edit_type] and params[:newSubTypeCheckbox] != "yes"
      ## no change detected
      ## validate for mysql
      params[:edit_comments] = validateStr(params[:edit_comments])
      ## validate for colon(;) and hash
      params[:edit_comments] = validateStr2(params[:edit_comments])
      qryFile = "update `user_uploaded_files` set comments = '"+ params[:edit_comments]+"' where id = " + params[:fid] + ""
      ccU.query(qryFile)
      msg = "updated"
    else
      ## change detected
      ## check on new subtype
      if params[:newSubTypeCheckbox] == "yes"
        
        ## make physical file change first
        msg = Datafile.changeFileLocation(params[:edit_ctype],params[:newSubType],fhash)
        if msg == "changed"
          ## go forward with the database update
          ## validate for mysql
          params[:edit_comments] = validateStr(params[:edit_comments])
          ## validate for colon(;) and hash
          params[:edit_comments] = validateStr2(params[:edit_comments])
          qryFile = "update `user_uploaded_files` set comments = '"+ params[:edit_comments]+"' ,  type = '"+ params[:edit_type]+"' , `cancer_type` = '"+ params[:edit_ctype]+"' " +
          ", `subtype` = '"+ params[:newSubType]+"' where id = " + params[:fid] + ""
          ccU.query(qryFile)
          msg = "updated"        
        else
          msg = "error"
        end   
      else
        ## make physical file change first
        msg = Datafile.changeFileLocation(params[:edit_ctype],params[:edit_subtype],fhash)
        if msg == "changed"
          ## go forward with the database update
          ## validate for mysql
          params[:edit_comments] = validateStr(params[:edit_comments])
          ## validate for colon(;) and hash
          params[:edit_comments] = validateStr2(params[:edit_comments])
          qryFile = "update `user_uploaded_files` set comments = '"+ params[:edit_comments]+"' ,  type = '"+ params[:edit_type]+"' , `cancer_type` = '"+ params[:edit_ctype]+"' " +
          ", `subtype` = '"+ params[:edit_subtype]+"' where id = " + params[:fid] + ""
          ccU.query(qryFile)
          msg = "updated"        
        else
          msg = "error"
        end
      end
    end
    
    ccU.close
    return msg
    
  end
  
  ## map username to session user
  def self.mapSessionUser(login_id)
    
    user = ""
    if (login_id =~ /@/)
      temp = []
      ccU = User.new.self
      ## get user name
      qryUsername = "select username from users where email ='" + login_id + "'"
      refUsername = ccU.query(qryUsername)
      refUsername.each do |r1|
        temp.push(r1)
      end
      user = temp.join(",")
      ccU.close  
    else
      user = login_id  
    end
    
    return user
    
  end
  
  ## get user first name
  def self.getUserFirstName(user)
    
    firstname = []
    ccU = User.new.self
    ## get user first name
    qryName = "select `firstname` from users where username ='" + user + "';"
    refName = ccU.query(qryName)
    refName.each do |r1|
      firstname= r1
    end
    firstnamestr = firstname.join(",")
    
    return firstnamestr    
    
  end


  ## get cancer types
  def self.getCancerTypes()
    
    cancers = []
    ccU = User.new.self
    qryCs = "select distinct `cancer_type` from `user_uploaded_files`"
    refCs = ccU.query(qryCs)
    refCs.each do |r1|
      cancers.push(r1[0])
    end
    
    return cancers
    
  end
  
  
  
  ## get files
  def self.getUserFiles()
    
    fileHash = Hash.new()
    subTypeHash = Hash.new()
    ccU = User.new.self
    qryFiles = "select username,email,type,`cancer_type`,subtype,filename,comments,`created_on`,id from `user_uploaded_files`"
    refFiles = ccU.query(qryFiles)
    refFiles.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9|
      key = r4
      file = r5 + "/" + r6
      if r5 == "chemicalScreening" or r5 == "geneticScreening"
      else  
        subTypeHash[r5] = "1"
      end
      details = r1 + ";" + r2 + ";" + r3 + ";" + r7 + ";" + r8 + ";" + r9
      if fileHash.has_key?(key)
        fileHash [key] = fileHash [key] + "#" + file + ";" + details
      else
        fileHash [key] = file + ";" + details
      end
    end
    
    return fileHash,subTypeHash  
    
  end

  ## get files by folder
  def self.getUserFilesByFolder(cfolder,subfolder)
    
    files = []
    subTypeHash = Hash.new()
    ccU = User.new.self
    qryFiles = ""
    if subfolder == nil
      qryFiles = "select distinct `cancer_type`,subtype from `user_uploaded_files` where `cancer_type` = '" + cfolder + "'"
      refFiles = ccU.query(qryFiles)
      refFiles.each do |r1,r2|
        temp = r1 + ";" + r2
        subTypeHash[r2] = "1"
        files.push(temp)
      end  
    else  
      qryFiles = "select username,email,type,`cancer_type`,subtype,filename,comments,`created_on`,id from `user_uploaded_files` where `cancer_type` = '" + cfolder + "' and subtype = '" + subfolder + "'"
      refFiles = ccU.query(qryFiles)
      refFiles.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9|
        temp = r1 + ";" + r2 + ";" + r3 + ";"+ r4 + ";" + r5+ ";" + r6 + ";" + r7 + ";" + r8 + ";" + r9
        if r5 == "chemicalScreening" or r5 == "geneticScreening"
        else
          subTypeHash[r5] = "1"
        end  
        files.push(temp)
      end
    end
       
    return files,subTypeHash  
    
  end



  ## create new file upload
  def self.createUploadFile(user,type,ctype,subtype,filename,comments)
    
    msg  = ""
    useremail = []
    ccU = User.new.self
    ## get user email
    qryEmail = "select email from users where username ='" + user + "';"
    refEmails = ccU.query(qryEmail)
    refEmails.each do |r1|
      useremail= r1
    end
    useremailstr = useremail.join(",")
    ## validate for mysql
    subtype = validateStr(subtype)
    comments = validateStr(comments)
    ## validate for colon(;) and hash
    subtype = validateStr2(subtype)
    filenmae = validateStr2(filename)
    comments = validateStr2(comments)
    qryInsert = "insert into `user_uploaded_files`(`username`,`email`,`type`,`cancer_type`,`subtype`,`filename`,`comments`,`created_on`) values('" + 
    user + "','" + useremailstr + "','" + type + "','" + ctype + "','" + subtype + "','" + filename + "','" + comments + "',NOW());"
    ccU.query(qryInsert)
    ccU.close
    msg = "inserted"
    
    return msg
    
  end

  ## create new meeting minutes & presentation file
  def self.createUploadMPFile(user,mid,filename,title)
    
    msg  = ""
    useremail = []
    ccU = User.new.self
    ## get user email
    qryEmail = "select email from users where username ='" + user + "';"
    refEmails = ccU.query(qryEmail)
    refEmails.each do |r1|
      useremail= r1
    end
    useremailstr = useremail.join(",")
    title = validateStr(title)
    filename = validateStr2(filename)
    qryInsert = "insert into `meeting_minpre`(`username`,`email`,`meetingid`,`title`,`filename`,`created_at`,`last_edit`) values('" + 
    user + "','" + useremailstr + "'," + mid + ",'" + title + "','"  + filename + "',NOW(),NOW());"
    ccU.query(qryInsert)
    ccU.close
    msg = "inserted"
    
    return msg
    
  end



  ## get valid values from database
  def self.getValidValues()
    
    groups = []
    workinggroups = []
    institutes = []

    ccU = User.new.self
    ## get groups
    qryValid = "select `group` from `valid_groups`;"
    refValid = ccU.query(qryValid)
    refValid.each do |r1|
      groups.push(r1)
    end
    ## get working groups
    qryValid = "select `group` from `valid_working_groups`;"
    refValid = ccU.query(qryValid)
    refValid.each do |r1|
      workinggroups.push(r1)
    end    
    ## get institutes
    qryValid = "select `institute` from `valid_institutes`;"
    refValid = ccU.query(qryValid)
    refValid.each do |r1|
      institutes.push(r1)
    end    
    ccU.close
    
    return groups,workinggroups,institutes
    
  end

  ## get user profile section data
  def self.getUserSectionData(user)

    refUsers = ''
    profile = ""
    count = 0
    
    if user =~ /@/
      ccU = User.new.self
      qryUsers = "select section,section_details from user_profile_sections where email = '" + user + "' order by id"
      refUsers = ccU.query(qryUsers)
      ccU.close
    else
      ccU = User.new.self
      qryUsers = "select section,section_details from user_profile_sections where username = '" + user + "' order by id"
      refUsers = ccU.query(qryUsers)
      ccU.close
    end
    
    refUsers.each do |r1,r2|
      profile = profile + r2
      count = count + 1
    end  

    return profile,count
    
  end

  ## get user data
  def self.getUserData(user)

    if user =~ /@/
      ccU = User.new.self
      qryUsers = "select * from users where email = '" + user + "'"
      refUsers = ccU.query(qryUsers)
      ccU.close
      return refUsers,refUsers.num_rows
    else
      ccU = User.new.self
      qryUsers = "select * from users where username = '" + user + "'"
      refUsers = ccU.query(qryUsers)
      ccU.close
      return refUsers,refUsers.num_rows 
    end
    
  end
  
  ## update user section data
  def self.updateUserSection(user,params)
    
    msg = ""
    ## validate section name and description
    #params[:sectionName] = validateStr(params[:sectionName])
    params[:sectionDesc] = validateStr(params[:sectionDesc]) 
    
    ccU = User.new.self
    (res,rows) = getUserSectionData(params[:username])
    if rows > 0
      ## update
      qryUpdate = "update user_profile_sections set section_details='" + params[:sectionDesc] + "', last_updated='" + "NOW()" + "' where username='" + params[:username] + "' and email='" + params[:useremail] + "' ;"
      ccU.query(qryUpdate)
      msg = "added"
    else  
      ## add new 
      qryinsert = "insert into user_profile_sections(`username`,`email`,`section`,`section_details`,`created_on`,`last_updated`) values('" + 
      params[:username] + "','" + params[:useremail] + "','" + " - " + "','" + params[:sectionDesc] + "',NOW(),NOW());"
      ccU.query(qryinsert)
      msg = "added"
    end
    
    ccU.close
 
    return msg
    
  end

  ## update user data
  def self.updateUser(user,params)
  
    msg = ""
    ccU = User.new.self
    workinggroup = []
    params.each do |key,value|
      if key =~ /chk/
        workinggroup.push(value)
      end
    end      
    workinggroupstr = workinggroup.join(',')
    
    if user =~ /@/
        qryUsers = "update users set `firstname` = '" + params[:edit_firstname] + "'," + " `lastname` = '" + params[:edit_lastname] + "'," + " `institute` = '" + 
        params[:edit_institute] + "'," + " `group` = '" + params[:edit_group] + "'," + " `working_group` = '" + workinggroupstr + "', `last_edit_on` = NOW() where email = '" + user + "'"
        refUsers = ccU.query(qryUsers)
        msg = "updated"
    else
        qryUsers = "update users set `firstname` = '" + params[:edit_firstname] + "'," + " `lastname` = '" + params[:edit_lastname] + "'," + " `institute` = '" + 
        params[:edit_institute] + "'," + " `group` = '" + params[:edit_group] + "', " + " `working_group` = '" + workinggroupstr + "', `last_edit_on` = NOW()  where username = '" + user + "'"
        refUsers = ccU.query(qryUsers)
        msg = "updated"
    end
    ccU.close
    
    ## save pic to target dir
    if (params[:pictureFile])
      targetImageFile = user + ".jpg"
      imgmsg = Datafile.updateProfileImage(params[:pictureFile],targetImageFile)
      if imgmsg != "uploaded"
        msg = "failed_image_uplaod"
      end
    end
    
    return msg
    
  end
  
  
  ## get all users for the project
  def self.getUsers()
    ccU = User.new.self
    qryUsers = "select `username`,`firstname`,`lastname`,`email`,`institute`,`group`,`working_group` from users"
    refUsers = ccU.query(qryUsers)
    ccU.close
    
    return refUsers,refUsers.num_rows
     
  end
  
  ## validate saved user for login
  def self.validateUser(login_id,login_password)
    
    msg = ""
    dbpass = ""
    dbsalt = ""
    
    ## decide on id being username or email
    if (login_id =~ /@/)

      ## email
      ccU = User.new.self
      qryEmail = "select password,salt from users where email = '"+ login_id +"';"
      refEmail = ccU.query(qryEmail)
      if refEmail.num_rows > 0
        refEmail.each do |r1,r2|
          dbpass = r1
          dbsalt = r2
        end
        ## lets add salt to login password to match with the one in database
        passnewtomatch = BCrypt::Engine.hash_secret(login_password,dbsalt)    
        if (passnewtomatch == dbpass)
          msg = "validuser"
        else
          msg = "invaliduser"
        end
      else
        msg = "invaliduser"
      end
      ccU.close
    else

      ## username  
      ccU = User.new.self
      qryUsername = "select password,salt from users where username = '"+ login_id +"';"
      refUsername = ccU.query(qryUsername)
      if refUsername.num_rows > 0
        refUsername.each do |r1,r2|
          dbpass = r1
          dbsalt = r2
        end
        ## lets add salt to login password to match with the one in database
        passnewtomatch = BCrypt::Engine.hash_secret(login_password,dbsalt)    
        if (passnewtomatch == dbpass)
          msg = "validuser"
        else
          msg = "invaliduser"
        end
      else
        msg = "invaliduser"
      end
      ccU.close
    end
    
    return msg

  end
  
  ## create new user
  def self.newUser(params)
    
    msg = ""
    pass = ""
    salt = ""
    
    ## check email validity
    ccU = User.new.self
    qryEmail = "select * from valid_emails where email_address = '"+ params[:login_email] +"';"
    refEmail = ccU.query(qryEmail)
    if refEmail.num_rows == 0
      msg = "invalid_email"
    else
      ## check username and email validity
      qryUsername = "select username from users where username = '"+ params[:login_username] +"';"
      refUsername = ccU.query(qryUsername)
      qryEmail = "select email from users where email = '"+ params[:login_email] +"';"
      refEmail = ccU.query(qryEmail)
      if refUsername.num_rows > 0
        msg = "invalid_username"
      elsif refEmail.num_rows > 0
        msg = "present_email" 
      else
        ## go forward with creating new user
        ## encrypt password and add salt
        (pass,salt) = encrypt_password(params[:login_password])
        params[:login_password] = nil
        params[:login_password_confirm] = nil
        qryInsert = "insert into users(username,email,password,salt,created_on)" +  
        " values('"+ params[:login_username] +"','"+ params[:login_email] +"','"+ pass +"','"+ salt+"',NOW());"
        ccU.query(qryInsert)
        msg = "success"
        
        ## save pic to target dir
        targetImageFile = params[:login_username] + ".jpg"
        imgmsg = Datafile.setNewProfileImage(targetImageFile)
        if imgmsg != "uploaded"
          msg = "failed_image_uplaod"
        end

      end  
    end
    ccU.close
    return msg
    
  end
  
  ## create new forum post
  def self.createNewPostForum (user,params)
    
    msg = ""
    ## validate post title and description
    params[:newPostTitle] = validateStr(params[:newPostTitle])
    params[:newPostDesc] = validateStr(params[:newPostDesc])
    ## get user email
    user_mail = getUserMail(user) 
    ## create new post
    ccU = User.new.self
    qryinsert = "insert into user_forum_posts(`username`,`email`,`ttile`,`desc`,`created_on`,`last_updated`) values('" + 
    user + "','" + user_mail + "','" + params[:newPostTitle] + "','" + params[:newPostDesc] + "',NOW(),NOW());"
    ccU.query(qryinsert)
    msg = "created"
    ccU.close

    return msg
    
  end
  
  ## get all recent posts
  def self.getRecentPosts()

    ccU = User.new.self
    qryPosts = "SELECT * FROM user_forum_posts ORDER BY `created_on` DESC"
    refPosts = ccU.query(qryPosts)
    ccU.close
    
    return refPosts,refPosts.num_rows

  end
  
  ## get post details by post id
  def self.getPostDetailsById(params)
    
    ccU = User.new.self
    qryPost = "SELECT * from user_forum_posts where id=" + params[:postid] + ""
    refPost = ccU.query(qryPost)
    qryPostDetail = "SELECT P.`post_id`,CONCAT(U.`firstname`, ' ',U.lastname),P.comment,P.`created_at`,P.id FROM `post_comments` as P inner join `users` as U on P.username = U.username where P.`post_id` =" + params[:postid] + " ORDER BY `created_at` ASC"
    refPostDetail = ccU.query(qryPostDetail)
    ccU.close
    
    return refPost,refPostDetail
    
  end
  
  ## add comment to posts
  def self.addPostComment(user, params)
    
    msg = ""
    ## validate post comment
    params[:newPostComment] = validateStr(params[:newPostComment])
    ## add comment to post
    ccU = User.new.self
    qryinsert = "insert into post_comments(`post_id`,`username`,`comment`,`created_at`) values(" + 
    params[:hpostid] + ",'" + user + "','" + params[:newPostComment] + "',NOW());"
    ccU.query(qryinsert)
    msg = "created"
    ccU.close
    return msg
    
  end

  ## get all meetings
  def self.getAllMeetingEvents()
 
    allMeetings = Hash.new
    meetingBox = Hash.new
    
    ccU = User.new.self
    ## get requested events
    qryMeetings = "SELECT * FROM `meetings` ORDER BY startDate ASC" 
    refMeetings = ccU.query(qryMeetings)
    refMeetings.each do |r1,r2,r3,r4,r5|
      allMeetings[r5] = r1 + ";" + r2 + ";" + r3 + ";" + r4
      meetingBox[r5] = r1
    end
    ccU.close
    
    return allMeetings,meetingBox     
  end

  ## get next upcoming event
  def self.getNextUpcomingEvent(user,reqid)
    

    mid = nil
    meeting = Hash.new
    currentMeeting = Hash.new
    user_attending = ""
    arrDate = ""
    depDate = ""
    dptHour = ""
    dptMin = ""
    dptAmpm = ""
    arrHour = ""
    arrMin = ""
    arrAmpm = ""

    ccU = User.new.self
    
    ## update mid
    if (reqid == nil or reqid == "")
      mid = mid
      ## get next event
      qryMeetings =  "SELECT * FROM `meetings` WHERE endDate > NOW() + 1 ORDER BY startDate asc limit 1"
      refMeetings = ccU.query(qryMeetings)
      refMeetings.each do |r1,r2,r3,r4,r5|
        currentMeeting[r5] = r1 + ";" + r2 + ";" + r3 + ";" + r4
        mid = r5
      end
    else
      mid = reqid
      ## get requested event
      qryMeetings = "SELECT * FROM `meetings` where id = " + mid + "" 
      refMeetings = ccU.query(qryMeetings)
      refMeetings.each do |r1,r2,r3,r4,r5|
        currentMeeting[r5] = r1 + ";" + r2 + ";" + r3 + ";" + r4
      end
    end
    
    ## initially set the arrival & departure date time according to meeting
    temp = currentMeeting[mid].split(";")
    ## arrival
    atmp = temp[2].split(" ")
    arrDateT = atmp[0]
    (y,m,d) = arrDateT.split("-")
    arrDate = m + "/" + d + "/" + y
    (arrHour,arrMin,arrAmpm) = atmp[1].split(":")
    if arrHour.to_i >= 13
      arrAmpm = "PM"
      arrHour = (arrHour.to_i - 12).to_s
    else
      if (arrHour =~ /^0/)
        arrHour = arrHour[1..arrHour.length-1]
      end
      arrAmpm = "AM"
    end   
    ## departure
    dtmp = temp[3].split(" ")
    depDateT = dtmp[0]
    (y,m,d) = depDateT.split("-")
    depDate = m + "/" + d + "/" + y
    (dptHour,dptMin,dptAmpm) = dtmp[1].split(":")
    if dptHour.to_i >= 13
      dptAmpm = "PM"
      dptHour = (dptHour.to_i - 12).to_s
    else
      if (dptHour =~ /^0/)
        dptHour = dptHour[1..dptHour.length-1]
      end
      dptAmpm = "AM"
    end   
    
    ## get all events
    qryMeetings = "SELECT * FROM `meetings` ORDER BY startDate ASC" 
    refMeetings = ccU.query(qryMeetings)
    refMeetings.each do |r1,r2,r3,r4,r5|
      meeting[r5] = r1 
      #currentMeeting[r5] = r1 + ";" + r2 + ";" + r3 + ";" + r4
      #mid = r5
    end
    
    
    
    ## get meeting attendees
    if mid != nil
      qryAtt = "SELECT CONCAT(U.`firstname`, ' ',U.lastname),M.`email`,M.`attending`,M.`arrivalDate`,M.`departureDate` FROM `meeting_attendance` as M inner join `users` as U on M.username = U.username where meetingid = " + mid + ""
      refAtt = ccU.query(qryAtt)  
    else
      refAtt = []
    end    

    ## get user previous rsvp status and if it exists then update the  rsvp arrival, departure date time and rsvp status
    if mid != nil
    
      qryUAtt = "SELECT attending,arrivalDate,departureDate from `meeting_attendance` where meetingid = " + mid + " and username = '" + user + "'"
      refUAtt = ccU.query(qryUAtt)
      
      if refUAtt.num_rows > 0
       refUAtt.each do |r1,r2,r3|
         user_attending = r1
         if r2 =~ /(\s)+/
           (tempd,tempt) = r2.split(" ")
           arrDate = tempd
           (arrHour,arrMin,arrAmpm) = tempt.split(":")
         else
            arrDate = r2
         end
        
         if r2 =~ /(\s)+/      
           (tempd,tempt) = r3.split(" ")
           depDate = tempd
           (dptHour,dptMin,dptAmpm) = tempt.split(":")
         else
            depDate = r3
          end            
        end
      end
    
    end
    
    ## get meeitng minutes and presentations
    if mid !=nil
      qryMinPre = "SELECT * from `meeting_minpre` where meetingid = " + mid + ""
      refMinPre = ccU.query(qryMinPre)
    end
    
    ccU.close
    return meeting,currentMeeting,refAtt,user_attending,arrDate,depDate,arrHour,arrMin,arrAmpm,dptHour,dptMin,dptAmpm,refMinPre
    
  end

  ## create user rsvp
  def self.createUserRsvp(user, params)
    
    msg = ""
    present = ""
    arrivalDateTime = params[:arrivalDate] + " " + params[:atthour] + ":" + params[:attminute] + ":" + params[:attampm] 
    departureDateTime = params[:departureDate] + " " + params[:dpthour] + ":" + params[:dptminute] + ":" + params[:dptampm]
    ## get user email
    user_mail = getUserMail(user) 
    ## create new post
    ccU = User.new.self
    qryIni = "select * from meeting_attendance where meetingid = " + params[:mid] + " and username = '" + user + "'"
    refIni = ccU.query(qryIni)
    if refIni.num_rows == 0
      ## make insert
      qryinsert = "insert into meeting_attendance (`username`,`email`,`attending`,`arrivalDate`,`departureDate`,`meetingid`,`created_at`,`last_edit`) values('" + 
      user + "','" + user_mail + "','" + params[:attending] + "','" + arrivalDateTime + "','" + departureDateTime + "'," + params[:mid] + ",NOW(),NOW());"
      ccU.query(qryinsert)
      msg = "created"
    else
      ## make update
      qryupdate = "update meeting_attendance set `attending` = '" + params[:attending] + "', `arrivalDate` = '" + arrivalDateTime + "', `departureDate` = '" + 
      departureDateTime + "', `last_edit` = NOW() where meetingid = " + params[:mid] + " and username = '" + user + "'"
      ccU.query(qryupdate)
      msg = "created"
    end    
    ccU.close

    return msg

    
  end

  ## create project tool 
  def self.createTool(user,params)
  
    msg = ""
    
    ## validate params
    params[:tool] = validateStr(params[:tool])
    params[:toolDesc] = validateStr(params[:toolDesc])
    ## add comment to post
    ccU = User.new.self
    qryinsert = "insert into tools(`toolName`,`toolDesc`,`contactPerson`,`publicLink`,`wikiLink`,`created_by`,`created_at`,`last_edit`) values('" + 
    params[:tool] + "','" + params[:toolDesc] + "','" + params[:contactPerson] + "','" + params[:publink] + "','" + params[:wikilink] + "','" + user +  "',NOW(),NOW());"
    ccU.query(qryinsert)
    msg = "created"
    ccU.close
    return msg 
  
  end  

  ## get all project tools
  def self.getTools()
    
    ccU = User.new.self 
    qryTools = "SELECT * FROM `tools`" 
    refTools = ccU.query(qryTools)

    return refTools,refTools.num_rows
        
  end

  ## get project tool by id
  def self.getToolById(toolid)
    
    ccU = User.new.self 
    qryTools = "SELECT * FROM `tools` where id = " + toolid + "" 
    refTools = ccU.query(qryTools)
    
    return refTools
  
  end

  ## update tool by id
  def self.updateTool(user,params)
    
    msg = ""
    
    ## validate params
    params[:etool] = validateStr(params[:etool])
    params[:etoolDesc] = validateStr(params[:etoolDesc])
    ccU = User.new.self 
    qryupdate = "update tools set `toolName` = '"+ params[:etool]+"',`toolDesc` = '"+params[:etoolDesc]+"',`contactPerson` = '"+ params[:econtactPerson] +"',`publicLink` = '"+params[:epublink]+"',`wikiLink`='"+params[:ewikilink]+"',`last_edit` = NOW() where id = "+params[:eid]+""
    ccU.query(qryupdate)
    msg = "updated"
    
  end

  ## encrypt password
  def self.encrypt_password(password)
    salt = ""
    encrypted_password = ""
    unless password.blank?
      salt = BCrypt::Engine.generate_salt
      encrypted_password = BCrypt::Engine.hash_secret(password, salt)
    end
    return encrypted_password,salt
  end

  ## validate strings with single qoutes and \r\n for mysql 
  def self.validateStr(str)
    retStr = ""
    
    ## single qoute
    if (str =~ /\'/)
      retStr = str.gsub(/\'/,"\"")
    else
      retStr = str
    end
    ## \r\n
    # retStr.gsub!(/\r/,"")
    # retStr.gsub!(/\n/,"")
      
    return retStr   
  end

  ## validate for colon and hash in string
  def self.validateStr2(str)
    retStr = ""
    retStr = str.gsub(/\;/,",")
    retStr = str.gsub(/\#/," ")
    return retStr    
  end

end
