class UsersController < ApplicationController
  
  before_filter :save_login_state, :only => [:login, :autheticateUser]

  def login
    
  end


  def profile
    @profile = {}
    (res,rows) = User.getUserData(session[:user])
    if rows > 0
      res.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12|
        @profile['username'] = r1
        @profile['firstname'] = r2
        @profile['lastname'] = r3
        @profile['email'] = r4
        @profile['institute'] = r5
        @profile['group'] = r6
        @profile['workinggroup'] = r7
        @profile['picture'] = r8
      end
    end  
  end
  
  def updateUserData
    valmsg = ""
    valmsg = User.updateUser(session[:user],params)
    if valmsg == "updated"
      redirect_to :profile
      flash[:notice] = "Profile saved !!"
      flash[:color]= "valid"
      return            
    elsif valmsg == "failed_image_uplaod"
      redirect_to :profile
      flash[:notice] = "Profile image could not be upladed. Try again !!"
      flash[:color]= "invalid"
      return
    else
      redirect_to :profile
      flash[:notice] = "Something went wrong !!"
      flash[:color]= "invalid"
      return                  
    end
  end
  
  def autheticateUser
    valmsg = ""
    if (params[:login_id] == "" or params[:login_password] == "")
      redirect_to :login
      flash[:notice] = "All fields must entered correctly !!"
      flash[:color]= "invalid"
      return      
    else
      valmsg = User.validateUser(params[:login_id],params[:login_password])
    end
    if (valmsg == 'validuser')
      session[:user] = params[:login_id]
      redirect_to :controller => 'webportal', :action => 'index'
    else
      redirect_to :login
      flash[:notice] = "Login credentials mismatch ! Please try again !!"
      flash[:color]= "invalid"
      return
    end
  end
  
  def createUser
    valmsg = ""
    if (params[:login_username] == "" or params[:login_email] == "" or params[:login_password] == "" or params[:login_password_confirm] == "")
      redirect_to :login
      flash[:notice] = "All fields must entered correctly !!"
      flash[:color]= "invalid"
      return
    elsif (params[:login_username] =~ /@/)
      redirect_to :login
      flash[:notice] = "Invalid character '@' in username !!"
      flash[:color]= "invalid"
      return  
    elsif(params[:login_password] != params[:login_password_confirm])
      redirect_to :login
      flash[:notice] = "Please enter you password carefully in both fields !!"
      flash[:color]= "invalid"
      return      
    elsif(params[:login_password].length < 6)
      redirect_to :login
      flash[:notice] = "Please enter a proper password. Your password is too short !!"
      flash[:color]= "invalid"
      return
    else
      valmsg = User.newUser(params)          
    end
    if valmsg == "invalid_email"
      redirect_to :login
      flash[:notice] = "This is not a valid email. Please contact administrator !!"
      flash[:color]= "invalid"
      return            
    elsif valmsg == "invalid_username"
      redirect_to :login
      flash[:notice] = "Username already taken. Please try a different username !!"
      flash[:color]= "invalid"
      return
    elsif valmsg == "present_email"
      redirect_to :login
      flash[:notice] = "Email already present. If you forgot your password, then contact administrator !!"
      flash[:color]= "invalid"
      return
    elsif valmsg == "success"
      redirect_to :login
      flash[:notice] = "Your account has been successfully created. Please login now !!"
      flash[:color]= "valid"
      return            
    else
      redirect_to :login
      flash[:notice] = "Something went wrong !!"
      flash[:color]= "invalid"
      return            
    end
  end
  
  def logout     
    session[:user] = nil
    redirect_to :login
  end
  
end
