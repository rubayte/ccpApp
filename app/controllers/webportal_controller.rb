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
    @wgtypes = ['Lung','Melanoma','Colorectal','Breast','Others']
    @stypes = ['chemicalScreening','geneticScreening']
    (@dirItems,subDirItems) = User.getUserFiles()
    if subDirItems.length > 0
      @stypes = @stypes + subDirItems.keys 
    end  
  end

  def data_bak
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
    (@res,rows) = Tickets.getTickets()
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
    @msg = Datafile.validate(params)
    if @msg == "invalid"
      redirect_to :data, flash: { uploadFile: true, :notice => "Invalid sub type name. Try agian.", :color => "invalid" }
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
  
  def downloadWikiAtatchment
    send_file Rails.root.join("wikiattachments", params[:page][0..-6], params[:file]), :disposition => 'attachment'
  end
  
  def updateFileDetails
    @fileDetails = Hash.new()
    @fileDetails = User.getFileDetails(params[:fileid])    
  end
  
  def commitUpdateFileDetails
    msg = User.commitFileChanges(params)
    if msg == "updated"
      redirect_to :data
      flash[:notice] = "Your file details have been updated !!"
      flash[:color]= "valid"
      return              
    else
      redirect_to :commitUpdateFileDetails
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"
      return                      
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