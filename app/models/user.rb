class User
  

  def self
    con = Mysql.connect('127.0.0.1', 'root', '', 'ccp')
    return con
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
  
  ## update user data
  def self.updateUser(user,params)
  
    msg = ""
    ccU = User.new.self    
    
    if user =~ /@/
        qryUsers = "update users set `firstname` = '" + params[:edit_firstname] + "'," + " `lastname` = '" + params[:edit_lastname] + "'," + " `institute` = '" + 
        params[:edit_institute] + "'," + " `group` = '" + params[:edit_group] + "'," + " `working_group` = '" + params[:edit_workinggroup] + "' where email = '" + user + "'"
        refUsers = ccU.query(qryUsers)
        msg = "updated"
    else
        qryUsers = "update users set `firstname` = '" + params[:edit_firstname] + "'," + " `lastname` = '" + params[:edit_lastname] + "'," + " `institute` = '" + 
        params[:edit_institute] + "'," + " `group` = '" + params[:edit_group] + "', " + " `working_group` = '" + params[:edit_workinggroup] + "' where username = '" + user + "'"
        refUsers = ccU.query(qryUsers)
        msg = "updated"
    end
    ccU.close
    
    ## save pic to target dir
    targetImageFile = user + ".jpg"
    imgmsg = Datafile.updateProfileImage(params[:pictureFile],targetImageFile)
    if imgmsg != "uploaded"
      msg = "failed_image_uplaod"
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
  def self.newUser(user,params)
    
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
        targetImageFile = user + ".jpg"
        imgmsg = Datafile.updateProfileImage(params[:pictureFile],targetImageFile)
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
