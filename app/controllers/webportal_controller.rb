class WebportalController < ApplicationController
  
  before_filter :authenticate_user, :only => [:index,:data,:project, :members]
  
  def index
    @firstname = User.getUserFirstName(session[:user])    
  end

  def  getProfile
    (@groups,@workinggroups,@institutes) = User.getValidValues()
    @profile = {}
    (res,rows) = User.getUserData(params[:useridvalue])
    (@resS,rowsS) = User.getUserSectionData(params[:useridvalue])
    if rows > 0
      res.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13|
        @profile['username'] = r1
        @profile['firstname'] = r2
        @profile['lastname'] = r3
        @profile['email'] = r4
        @profile['institute'] = r5
        @profile['group'] = r6
        @profile['workinggroup'] = r7
        @profile['picture'] = r1 + '.jpg'
      end
    end
    if rowsS == 0
      @resS = "empty"
    end
    @workinggroups = @profile['workinggroup'].split(",")  
  end

  def getMembersList
    (res,rows) = User.getUsers()
    if rows > 0
      msg = Datafile.createMemberListFile(res)
      if (msg == "file_created")
        send_file Rails.root.join("memberlist", 'listofpeople.csv'), :disposition => 'attachment'
      end
    end
  end


  def data
    @ftypes = ['data','resource']
    @wgtypes =  User.getCancerTypes()  ## ['Lung','Melanoma','Colorectal','Breast','Others']
    @stypes = ['chemicalScreening','geneticScreening']
    (@dirItems,subDirItems) = User.getUserFiles()
    if subDirItems.length > 0
      @stypes = @stypes + subDirItems.keys 
    end  
  end

  def folderLookInto
    @level = "0"
    @cfolderLebel = params[:cfolder]
    @subfolderLebel = params[:subfolder]
    @ftypes = ['data','resource']
    @wgtypes = User.getCancerTypes() ## ['Lung','Melanoma','Colorectal','Breast','Others']
    @stypes = ['chemicalScreening','geneticScreening']
    (@fitems,subDirs) = User.getUserFilesByFolder(params[:cfolder],params[:subfolder])
    if params[:subfolder] == nil
     @level = "1"
    else
      @level = "2"
    end
    @stypes = @stypes + subDirs.keys
  end

  def data_bak
    @ftypes = ['data','resource']
    @wgtypes = ['Lung','Melanoma','Colorectal','Breast','Others']
    @stypes = ['chemicalScreening','geneticScreening']
    (@dirItems,subDirItems) = User.getUserFiles()
    if subDirItems.length > 0
      @stypes = @stypes + subDirItems.keys 
    end  
  end

  
  def project
    
  end
  
  def editWikiPage
    file = params[:pageid]
    @file = params[:pageid][0..-6]
    @contents = File.read(Rails.root.join('wiki',file))
  end

  def editWikiFiles
    valmsg = ""
    valmsg = Datafile.updateWikiFile(session[:user],params)
    if valmsg == "updated"
      redirect_to :wiki
      flash[:notice] = "Page has been updated!"
      flash[:color]= "valid"
      return
    elsif valmsg == "att_exists"
      redirect_to :wiki
      flash[:notice] = "Page has been updated but attachment exists. Please try another attachment !!"
      flash[:color]= "invalid"
      return
    else
      redirect_to :wiki
      flash[:notice] = "Something went wrong. Try again !"
      flash[:color]= "invalid"
      return        
    end
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
    @otypes = ['All','mouse','human']
    @ctypes = ['All','Lung','Melanoma','Colorectal','Breast','Others']
    @stypes = ['All','tumor sample','normal sample','cell line','gemm','pdx']
    @res = []
    @res,rows = Overview.getDataOverview()
    if rows == 0
      @res = nil
    end
  end
  
  def overviewFilter
    @otypes = ['All','mouse','human']
    @ctypes = ['All','Lung','Melanoma','Colorectal','Breast','Others']
    @stypes = ['All','tumor sample','normal sample','cell line','gemm','pdx']
    @res = []
    @ctypeschosen = params[:cType]
    @stypeschosen = params[:sType]
    @otypeschosen = params[:oType]
    @res,rows = Overview.getDataOverviewFilter(params)
    if rows == 0
      @res = nil
    end
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
    @pTypes = ['Any','low','medium','high']
    @statusTypes = ['open','resolved','Any']
    (@res,rows) = Tickets.getTickets()
    if rows == 0
      @res = "empty"
    end
  end
  
  def ticketsFilter
    @ptypes = ['low','medium','high']
    @pTypes = ['Any','low','medium','high']
    @statusTypes = ['open','resolved','Any']
    @pTypesChosen = params[:priorityType]
    @statusTypesChosen = params[:statusType]
    (@res,rows) = Tickets.getTicketsFilter(params)
    if rows == 0
      @res = "empty"
    end    
  end
  
  def createIssues
    @msg = nil
    @msg = Tickets.validate(params)
    if @msg == "missingFields"
      redirect_to :tickets, flash: { newTicket: true, :notice => "All fields are mandatry", :color => "invalid" }
      return
    end
    @msg = Tickets.create(params,session[:user])
    if @msg == "created"
      if params[:createNew] == "1"
        redirect_to :tickets, flash: { newTicket: true, :notice => "Your ticket has been created", :color => "valid" }
        return
      else
        redirect_to :tickets
        flash[:notice] = "Your ticket has been created"
        flash[:color]= "valid"
        return
      end 
    else
      redirect_to :tickets
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"
      return              
    end 
  end
  
  def uploadFiles
    @msg = nil
    @autocorrect = nil
    @msg,@autocorrect = Datafile.validate(params)
    if @msg == "invalid"
      redirect_to :data, flash: { uploadFile: true, :notice => "Invalid sub folder name. Try with this -> " + @autocorrect, :color => "invalid" }
      return
    elsif @msg == "missingFile"
      redirect_to :data, flash: { uploadFile: true, :notice => "Please select a file first.", :color => "invalid" }
      return
    else
    end
    @msg = Datafile.uploadResourceFiles(session[:user],params)  
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
  
  def downloadFolder
    targetdiectory = "fileloc"+"/"+params[:folder]
    temp = params[:folder].gsub(/\//,"_")
    zipfolder = "download" + "/" + temp
    status = `zip -r #{zipfolder} #{targetdiectory}`
    send_file Rails.root.join(zipfolder + ".zip"), :disposition => 'attachment' 
  end
  
  def downloadWikiAtatchment
    send_file Rails.root.join("wikiattachments", params[:page][0..-6], params[:file]), :disposition => 'attachment'
  end
  
  def updateFileDetails
    @ctypes = ['Lung','Melanoma','Colorectal','Breast','Others']
    @subtypes = User.getSubtypes()
    @types = ['data','resource']
    @fileDetails = Hash.new()
    @fileDetails = User.getFileDetails(params[:fileid])    
  end
  
  def commitUpdateFileDetails
    msg = nil
    autocorrect = nil
    (msg,autocorrect) = Datafile.validateSubType(params)
    if msg == "invalid" or msg == nil
      redirect_to :controller => "webportal", :action => "updateFileDetails", :fileid => params[:fid]
      flash[:notice] = "Invalid sub folder name. Try with this -> " + autocorrect
      flash[:color]= "invalid"
      return
    elsif msg == "valid"
      msg = User.commitFileChanges(params)
      if msg == "updated"
        redirect_to :controller => "webportal", :action => "folderLookInto", :cfolder => params[:edit_ctype] , :subfolder => params[:edit_subtype]
        flash[:notice] = "Your file details have been updated !!"
        flash[:color]= "valid"
        return              
       else
        redirect_to :controller => "webportal", :action => "folderLookInto", :cfolder => params[:edit_ctype] , :subfolder => params[:edit_subtype]
        flash[:notice] = "Something went wrong"
        flash[:color]= "invalid"
        return                      
      end 
    else
    end    
    
  end

  def profile
    redirect_to :controller => "users", :action => "profile"
    return
  end
  
  def wiki
    @filetoshow = nil
    @pages = Dir.glob(Rails.root.join("wiki","*.*"))
    if params[:pageid] == nil
      @filetoshow = "project.wiki"
      @cby,@cat,@leby,@leat = User.getWikiInfoByPage("project")
      @atts = User.getWikiAttachmentByPage("project") 
    else
      @filetoshow = params[:pageid] + ".wiki"
      @cby,@cat,@leby,@leat = User.getWikiInfoByPage(params[:pageid])
      @atts = User.getWikiAttachmentByPage(params[:pageid])
    end  
  end

  def createWikiPage
    @pagename = nil
    @pagedesc = nil
  end
  
  def newPage
    msg = ""
    msg = Datafile.createWikiPage(session[:user], params)
    if msg == "created"
      redirect_to :wiki
      flash[:notice] = "Your page has been created !!"
      flash[:color]= "valid"
      return              
    elsif msg == "exists"
      redirect_to :createWikiPage
      flash[:notice] = "this page already exists. Try a new name !!"
      flash[:color]= "invalid"
      return                    
    elsif msg == "att_exists"
      redirect_to :wiki
      flash[:notice] = "Page has been created but attachment already exists. Try a new file to attach !!"
      flash[:color]= "invalid"
      return                    
    else
      redirect_to :wiki
      flash[:notice] = "Something went wrong. Try again."
      flash[:color]= "invalid"
      return                      
    end
  end

end