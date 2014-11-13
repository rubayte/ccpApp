class WebportalController < ApplicationController
  
  before_filter :authenticate_user, :only => [:index,:data,:project, :members]
  
  def index
      
  end

  def data
    @dirItems = Hash.new()
    @lungSubDirItems = Hash.new()
    @uploadFromSubTypes = Hash.new()
    ## add default sub types
    @uploadFromSubTypes ['chemicalScreening'] = "1"
    @uploadFromSubTypes ['geneticScreening'] = "1"
    @ftypes = ['data','resource']
    @wgtypes = ['Lung','Melanoma','Colorectal','Breast','Others']
    filelocitems = Dir.glob(Rails.root.join("fileloc").to_s + "/" + "**/*")
    filelocitems.each do |item|

      if (item =~ /Lung/)
        fs = item.split("/")
        if (fs.length == 8)
          lungitem = fs[fs.length - 1]
          if (lungitem =~ /\./)
            if (@dirItems['Lung'])
              @dirItems['Lung'] = @dirItems['Lung'] + ',' + lungitem 
            else
              @dirItems['Lung'] = lungitem
            end
           else
             @uploadFromSubTypes[lungitem] = "1"
           end 
         elsif( fs.length == 9)
           lsubitem = fs[fs.length - 1]
           lsubfol = fs[fs.length - 2]
           if (@dirItems['Lung'])
             @dirItems['Lung'] = @dirItems['Lung'] + ',' + lsubfol + "/" + lsubitem 
           else
             @dirItems['Lung'] = lsubfol + "/" + lsubitem
            end
           #if (@lungSubDirItems[ lsubfol ])
           #  @lungSubDirItems[ lsubfol ] =  @lungSubDirItems[ lsubfol ] + "," + lsubitem
           #else  
           #  @lungSubDirItems[ lsubfol ] = lsubitem
           #end
         else
           ## nothing
         end     
        end
      if (item =~ /Melanoma/)
        fs = item.split("/")
        if (fs.length == 8)
          lungitem = fs[fs.length - 1]
          if (lungitem =~ /\./)
            if (@dirItems['Melanoma'])
              @dirItems['Melanoma'] = @dirItems['Melanoma'] + ',' + lungitem 
            else
              @dirItems['Melanoma'] = lungitem
            end
           else
             @uploadFromSubTypes[lungitem] = "1"
           end 
         elsif( fs.length == 9)
           lsubitem = fs[fs.length - 1]
           lsubfol = fs[fs.length - 2]
           if (@dirItems['Melanoma'])
             @dirItems['Melanoma'] = @dirItems['Melanoma'] + ',' + lsubfol + "/" + lsubitem 
           else
             @dirItems['Melanoma'] = lsubfol + "/" + lsubitem
            end
         else
           ## nothing
         end     
        end
      if (item =~ /Colorectal/)
        fs = item.split("/")
        if (fs.length == 8)
          lungitem = fs[fs.length - 1]
          if (lungitem =~ /\./)
            if (@dirItems['Colorectal'])
              @dirItems['Colorectal'] = @dirItems['Colorectal'] + ',' + lungitem 
            else
              @dirItems['Colorectal'] = lungitem
            end
           else
             @uploadFromSubTypes[lungitem] = "1"
           end 
         elsif( fs.length == 9)
           lsubitem = fs[fs.length - 1]
           lsubfol = fs[fs.length - 2]
           if (@dirItems['Colorectal'])
             @dirItems['Colorectal'] = @dirItems['Colorectal'] + ',' + lsubfol + "/" + lsubitem 
           else
             @dirItems['Colorectal'] = lsubfol + "/" + lsubitem
            end
         else
           ## nothing
         end     
        end
      if (item =~ /Breast/)
        fs = item.split("/")
        if (fs.length == 8)
          lungitem = fs[fs.length - 1]
          if (lungitem =~ /\./)
            if (@dirItems['Breast'])
              @dirItems['Breast'] = @dirItems['Breast'] + ',' + lungitem 
            else
              @dirItems['Breast'] = lungitem
            end
           else
             @uploadFromSubTypes[lungitem] = "1"
           end 
         elsif( fs.length == 9)
           lsubitem = fs[fs.length - 1]
           lsubfol = fs[fs.length - 2]
           if (@dirItems['Breast'])
             @dirItems['Breast'] = @dirItems['Breast'] + ',' + lsubfol + "/" + lsubitem 
           else
             @dirItems['Breast'] = lsubfol + "/" + lsubitem
            end
         else
           ## nothing
         end     
        end
      if (item =~ /Others/)
        fs = item.split("/")
        if (fs.length == 8)
          lungitem = fs[fs.length - 1]
          if (lungitem =~ /\./)
            if (@dirItems['Others'])
              @dirItems['Others'] = @dirItems['Others'] + ',' + lungitem 
            else
              @dirItems['Others'] = lungitem
            end
           else
             @uploadFromSubTypes[lungitem] = "1"
           end 
         elsif( fs.length == 9)
           lsubitem = fs[fs.length - 1]
           lsubfol = fs[fs.length - 2]
           if (@dirItems['Others'])
             @dirItems['Others'] = @dirItems['Others'] + ',' + lsubfol + "/" + lsubitem 
           else
             @dirItems['Others'] = lsubfol + "/" + lsubitem
            end
         else
           ## nothing
         end     
        end
    
    end
  @stypes = @uploadFromSubTypes.keys
  end
  
  def project
    
  end
  
  def members
    (@res,rows) = User.getUsers()
    if rows == 0
      @res = "empty"
    end
  end
  
  def admin
    
  end
  
  def overview
    @ctypes = ['Lung','Melanoma','Colorectal','Breast','Others']
    @stypes = ['sample','cell line']
  end
  
  def filterOverview
    @msg = "under development"
    redirect_to :overview
    flash[:notice] = @msg
    flash[:color]= "invalid"
    return
  end
  
  def authenticateAdmin
    @msg = "under development"
    redirect_to :index
    flash[:notice] = @msg
    flash[:color]= "invalid"
    return
  end


  
  def tickets
    @ptypes = ['low','medium','high']
  end
  
  def createIssues
    @msg = nil
    @msg = Tickets.create(params,session[:user])
    if @msg == "created"
      if params[:createNew] == "1"
        redirect_to :tickets
      else
        redirect_to :index
      end 
      flash[:notice] = "Your ticket has been created"
      flash[:color]= "valid"
      return
    else
      redirect_to :tickets
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"
      return              
    end 
  end
  
  def uploadFiles
    @msg = nil
    @msg = Datafile.validate(params)
    if @msg == "invalid"
      redirect_to :data
      flash[:notice] = "Invalid sub type name. Try agian."
      flash[:color]= "invalid"        
      return      
    elsif @msg == "missingFile"
      redirect_to :data
      flash[:notice] = "Please select a file first."
      flash[:color]= "invalid"        
      return            
    else
    end
    #if (params[:fileType] == "data")
    #  @msg = Datafile.uploadDataFiles(params)
    #else
    @msg = Datafile.uploadResourceFiles(params)  
    #end
    if @msg == "uploaded"
      redirect_to :data
      flash[:notice] = "Your file has been uploaded"
      flash[:color]= "valid"        
      return
    elsif @msg == "exists"
      redirect_to :data
      flash[:notice] = "A file already exists with this name. Rename your file and try again"
      flash[:color]= "invalid"        
      return      
    else
      redirect_to :data
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"
      return              
    end
  end
  
  def download
    send_file Rails.root.join("fileloc", params[:file]), :disposition => 'attachment'      
  end

end