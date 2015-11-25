class ApplicationController < ActionController::Base
  protect_from_forgery
  protected

  #This method is for preventing users to access confidential pages withuot logging in 
  def authenticate_user
    if session[:user]
      return true
    else
      session[:return_to] = request.fullpath
      redirect_to(:controller => 'users', :action => 'login')
      flash[:notice] = "You need to login to view the requested page! "
      flash[:color]= "invalid"
      return false
    end
  end

  #This method is for preventing users to access Signup & Login Page without logout
  def save_login_state
    if session[:user]
      redirect_to(:controller => 'webportal', :action => 'index')
      return false
    else
      return true
    end
  end
  
  ## this method allows people to only submit the survey once
  def done_with_survey?
    if session[:user]
      ## check on users survey
      response = Datafile.checkSurveyByUser(session[:user])
      if response == "yes"
        redirect_to(:controller => 'webportal', :action => 'index')
        flash[:notice] = "You have already submitted your survey! Thank you!!"
        flash[:color] = "valid"
        return false
      else
        return true  
      end
    else
      session[:return_to] = request.fullpath
      redirect_to(:controller => 'users', :action => 'login')
      flash[:notice] = "You need to login to view the requested page! "
      flash[:color]= "invalid"
      return false
    end    
  end  

end
