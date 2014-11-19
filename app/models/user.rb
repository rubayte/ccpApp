class User
  

  def self
    con = Mysql.connect('127.0.0.1', 'wwwUser', 'wwwpublic', 'ccp')
    return con
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
  
  ## edit file in db
  def self.commitFileChanges(params)

    msg = ""    
    ccU = User.new.self
    qryFile = "update `user_uploaded_files` set comments = '"+ params[:edit_comments]+"' where id = " + params[:id] + ""
    ccU.query(qryFile)
    ccU.close
    msg = "updated"
    
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

  ## get files
  def self.getUserFiles()
    
    fileHash = Hash.new()
    subTypeHash = Hash.new()
    ccU = User.new.self
    qryFiles = "select * from `user_uploaded_files`"
    refFiles = ccU.query(qryFiles)
    refFiles.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9|
      key = r4
      file = r5 + "/" + r6
      if r5 == "chemicalScreening" or r5 == "geneticScreening"
      else  
        subTypeHash[r5] = "1"
      end
      details = r1 + "," + r2 + "," + r3 + "," + r7 + "," + r8 + "," + r9
      if fileHash.has_key?(key)
        fileHash [key] = fileHash [key] + "#" + file + ";" + details
      else
        fileHash [key] = file + ";" + details
      end
    end
    
    return fileHash,subTypeHash  
    
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
    qryInsert = "insert into `user_uploaded_files`(`username`,`email`,`type`,`cancer_type`,`subtype`,`filename`,`comments`,`created_on`) values('" + 
    user + "','" + useremailstr + "','" + type + "','" + ctype + "','" + subtype + "','" + filename + "','" + comments + "',NOW());"
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

    if user =~ /@/
      ccU = User.new.self
      qryUsers = "select section,section_details from user_profile_sections where email = '" + user + "' order by id"
      refUsers = ccU.query(qryUsers)
      ccU.close
      return refUsers,refUsers.num_rows
    else
      ccU = User.new.self
      qryUsers = "select section,section_details from user_profile_sections where username = '" + user + "' order by id"
      refUsers = ccU.query(qryUsers)
      ccU.close
      return refUsers,refUsers.num_rows 
    end
    
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
    ccU = User.new.self
    qryinsert = "insert into user_profile_sections(`username`,`email`,`section`,`section_details`,`created_on`,`last_updated`) values('" + 
    params[:username] + "','" + params[:email] + "','" + params[:sectionName] + "','" + params[:sectionDesc] + "',NOW(),NOW());"
    ccU.query(qryinsert)
    msg = "added"
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


end
