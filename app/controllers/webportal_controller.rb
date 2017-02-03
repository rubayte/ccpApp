class WebportalController < ApplicationController
  
  # before_filter :authenticate_user, :only => [:index,:data,:project, :members]
  before_filter :authenticate_user, :only => [:index,:data,:project,:members,
  :getProfile,:getMembersList,:folderLookInto,:editWikiPage,:editWikiFiles,:admin,:overview,:overviewFilter,
  :filterOverview,:authenticateAdmin,:tickets,:viewTicket,:updateticket,:ticketsFilter,:createIssues,:uploadFiles,:addeditpub,:publications,:createEditPublication,
  :download,:downloadFolder,:downloadWikiAtatchment,:updateFileDetails,:commitUpdateFileDetails,:profile,:wiki,:createWikiPage,
  :newPage,:forum,:createPost,:viewPostById,:createPostComment,:meetings,:createMeetingRsvp,:createForumPost,:createAgenda, :tools, 
  :createTool, :editTool,:viewTextFile, :dataViewFile, :viewPdfFile, :viewSampleDetails, :publics, :editPublicSection, :newsletter, :editNewsletterSection, :allmeetings, :allnewsletters, :surveyResults]
  
  before_filter :done_with_survey?, :only => [:survey,:submitSurveyResults]
  
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
    filename = Time.now.strftime("%d-%m-%Y-%H-%M") + "_listofpeople.csv"
    (res,rows) = User.getUsers()
    if rows > 0
      msg = Datafile.createMemberListFile(res,filename)
      if (msg == "file_created")
        send_file Rails.root.join("memberlist", filename), :disposition => 'attachment'
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
      redirect_to :controller => "webportal", :action => "wiki", :pageid => params[:pageName]
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
    (@piedataC,@piedataO,@piedataA) = Overview.getPieData()
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
  
  def viewTicket
    @pTypes = ['low','medium','high']
    @statusTypes = ['open','resolved']
    (@res,rows) = Tickets.getTicketById(params)
    if rows == 0
      @res = "empty"
    end
  end
  
  def updateticket
    @msg = nil
    @msg = Tickets.updateTicketById(params)
    if @msg == "updated"
      redirect_to :tickets
      flash[:notice] = "Ticket details have been updated!"
      flash[:color]= "valid"
      return
    else
      redirect_to :tickets
      flash[:notice] = "Something went wrong. Try again!"
      flash[:color]= "invalid"
      return
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
    (@msg,targetCfolder,targetSubfolder) = Datafile.uploadResourceFiles(session[:user],params)  
    if @msg == "uploaded"
      redirect_to :controller => "webportal", :action => "folderLookInto", :cfolder => targetCfolder , :subfolder => targetSubfolder
      flash[:notice] = "Your file has been uploaded"
      flash[:color]= "valid"        
      return
    elsif @msg == "exists"
      redirect_to :controller => "webportal", :action => "folderLookInto", :cfolder => targetCfolder , :subfolder => targetSubfolder
      flash[:notice] = "A file already exists with this name. Rename your file and try again"
      flash[:color]= "invalid"        
      return      
    else
      redirect_to :controller => "webportal", :action => "folderLookInto", :cfolder => targetCfolder , :subfolder => targetSubfolder
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"
      return              
    end
  end
  
  
  def uploadAgenda
    @msg = nil
    @msg = Datafile.uploadAgendaFile(session[:user],params)  
    if @msg == "uploaded"
      redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:mid], :tab => "agenda"
      flash[:notice] = "Your file has been uploaded"
      flash[:color]= "valid"        
      return
    elsif @msg == "exists"
      redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:mid], :tab => "agenda"
      flash[:notice] = "A file already exists with this name. Rename your file and try again"
      flash[:color]= "invalid"        
      return      
    else
      redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:mid], :tab => "agenda"
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"
      return              
    end
  end

  def createAgenda
    @mid = params[:mid]
    @agendaContent = ""
    ## check if agenda file exists
    if (File.exists?(Rails.root.join('meetings','agenda',params[:mid],"agenda.wiki")))
      File.open(Rails.root.join("meetings","agenda", params[:mid], "agenda.wiki"), 'rb') do |infile|
        while line = infile.gets()
          @agendaContent =  @agendaContent + line
        end   
      end        
    end
  end
  
  def createAgendaFile
    @msg = nil
    @msg = Datafile.createAgenda(session[:user],params)
    if @msg == "created"
      redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:meetingId], :tab => "agenda"
      flash[:notice] = "Meeting agenda has been created"
      flash[:color]= "valid"        
      return
    else
      redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:meetingId], :tab => "agenda"
      flash[:notice] = "Something went wrong. Tyr again!"
      flash[:color]= "invalid"        
      return
    end
  end

  def uploadMp
    @msg = nil
    @msg = Datafile.uploadMpFile(session[:user],params)  
    if @msg == "uploaded"
      redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:mid], :tab => "minutes"
      flash[:notice] = "Your file has been uploaded"
      flash[:color]= "valid"        
      return
    elsif @msg == "exists"
      redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:mid], :tab => "minutes"
      flash[:notice] = "A file already exists with this name. Rename your file and try again"
      flash[:color]= "invalid"        
      return      
    else
      redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:mid], :tab => "minutes"
      flash[:notice] = "Something went wrong"
      flash[:color]= "invalid"
      return              
    end    
  end
  
  def download
    send_file Rails.root.join("fileloc", params[:file]), :disposition => 'attachment'      
  end
  
  def downloadAgenda
    send_file Rails.root.join("meetings", params[:type], params[:mid], params[:file]), :disposition => 'attachment'      
  end

  def viewAgenda
    send_file(Rails.root.join("meetings", params[:type], params[:mid], params[:file]), :filename => "your_document.pdf", :disposition => 'inline', :type => "application/pdf")
  end
  
  def viewPdfFile
    params[:page] = params[:page][0..-6]
    send_file(Rails.root.join("wikiattachments", params[:page], params[:file]), :filename => params[:file], :disposition => 'inline', :type => "application/pdf")
  end
  
  def dataViewFile
    ## get file mime type
    #mtype = MIME::Types.type_for(Rails.root.join("fileloc", params[:file])).first.content_type # => "image/gif"
    mtypes = FileMagic.new(FileMagic::MAGIC_MIME).file(Rails.root.join("fileloc", params[:file]).to_s)
    mtypesa = mtypes.split(';')
    mtype = mtypesa[0]
    
    ## show files
    if (mtype == "application/pdf")
      send_file(Rails.root.join("fileloc", params[:file]), :filename => "test file", :disposition => 'inline', :type => mtype)
    elsif (mtype.starts_with?"image/")
      send_file(Rails.root.join("fileloc", params[:file]), :filename => "test file", :disposition => 'inline', :type => mtype)
    elsif (mtype == "text/plain")
      redirect_to :controller => "webportal", :action => "viewTextFile", :cfolder => params[:cfolder], :subfolder => params[:subfolder], :file => params[:file], :baselocation => "fileloc"
      #self.viewTextFile("fileloc",params)
    else
      redirect_to :controller => "webportal", :action => "folderLookInto", :cfolder => params[:cfolder], :subfolder => params[:subfolder]
      flash[:notice] = "Viewing this file type is not supported. File MIME type: " + mtype
      flash[:color]= "invalid"
      return
    end
    
  end
  
  def viewTextFile
   
   @seps = Hash["Select separator" => "Select separator", "\t" => "Tab", ',' => 'Comma']
   @dir = params[:baselocation]
   @file = params[:file]
   @cfolderLebel = params[:cfolder]
   @subfolderLebel = params[:subfolder]
   @filesep = nil
   @basefilename = params[:file].split('/')[2]
   if @basefilename.ends_with? "csv"
     @filesep = ","
   elsif @basefilename.ends_with? "tsv"
     @filesep = "\t"
   else
     @filesep = nil
   end
   
   if (params[:sep] != "Select separator")
     @filesep = params[:sep]  
   end
   
   @FileViewType = params[:showFullFile]
    
   @data = []
   @header = []
   linenum = 0
   File.open(Rails.root.join(@dir,@file), 'rb') do |infile|
     while line = infile.gets()
       
        if linenum == 0 and params[:firstLineHeader] == "1"
            if  @filesep != nil 
              @header.push(line.split(@filesep))
              linenum += 1
            else
              if line != ""
                @header.push(line)
                linenum += 1
               end 
            end
        else
           if  @filesep != nil 
             temp = line.split(@filesep)
             @data.push(temp)
             linenum += 1
             if (linenum == 100 and params[:showFullFile] != "1")
               break
             end
           else
             if line != ""
               @data.push(line)
               linenum += 1
               if (linenum == 100 and params[:showFullFile] != "1")
                 break
               end
             end  
           end  
        end
        
       end
     end
     

    
  end  
  
  def viewSampleDetails
    @sample = params[:sample]

    if (params[:data] == nil or params[:data] == "")
      @res = "empty!"      
    else
      @res = params[:data]      
    end

  end
  
  def viewScreenDetails
    @sample = params[:sample]

    if (params[:screenDescription] == nil or params[:screenDescription] == "")
      @res = "empty!"      
    else
      @res = params[:screenDescription]      
    end    
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
    @ctypes = User.getCancerTypes() ## ['Lung','Melanoma','Colorectal','Breast','Others']
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
    # @pages = Dir.glob(Rails.root.join("wiki","*.*"))
    (@pages,@parentPages) = User.getWikiPages()
    @pagestomove = User.getTargetChildPages()
    @possibleParentPages = User.getParentPages()
    @possibleParentPages.push('wiki root /')
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
  
  def reorderWikiPage
    msg = ""
    msg = User.moveChildToParentWiki(params)
    if msg == "same"
      redirect_to :wiki, flash: { reorderPages: true, :notice => "Page to move and new location can't be same!", :color => "invalid" }
      return
    elsif msg == "moved"
      redirect_to :controller => "webportal", :action => "wiki", :pageid => params[:childPage]
      flash[:notice] = "You page has been moved"
      flash[:color] = "valid"
      return
    elsif msg == "already_in_location"
      redirect_to :controller => "webportal", :action => "wiki", :pageid => params[:childPage]
      flash[:notice] = "You page is already in that location"
      flash[:color] = "valid"
      return
    else
      redirect_to :wiki, flash: { reorderPages: true, :notice => "Something went wrong!", :color => "invalid" }
      return
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
      redirect_to :controller => "webportal", :action => "wiki", :pageid => params[:pageName]
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
  
  def forum
    (@res,rows) = User.getRecentPosts()
    if rows == 0
      @res = "empty"
    end
  end
  
  def createPost
    msg = ""
    if params[:newPostTtile] == "" or params[:newPostDesc] == ""
      redirect_to :forum, flash: { createPost: true, :notice => "New post title or description cant be empty!", :color => "invalid" }
      return
    else
      msg = User.createNewPostForum(session[:user],params)
      if msg == "created"
        redirect_to :forum
        flash[:notice] = "Your post has been created."
        flash[:color]= "valid"
      else
        redirect_to :forum
        flash[:notice] = "Something went wrong. Try again."
        flash[:color]= "invalid"
      end
    end
  end

  def viewPostById
    @postid = params[:postid]
    (@post, @comments) = User.getPostDetailsById(params)
  end 
  
  def createPostComment
    msg = ""
    if params[:newPostComment] == ""
      redirect_to :controller => "webportal", :action => "viewPostById", :postid => params[:hpostid]
      flash[:notice] = "Comment cant be empty!"
      flash[:color]= "invalid" 
      return
    else
      msg = User.addPostComment(session[:user], params)
      if msg == "created"
        redirect_to :controller => "webportal", :action => "viewPostById", :postid => params[:hpostid] 
        flash[:notice] = "Your comment has been added."
        flash[:color]= "valid"
        return
      else
        redirect_to :controller => "webportal", :action => "viewPostById", :postid => params[:hpostid] 
        flash[:notice] = "Something went wrong. Try again."
        flash[:color]= "invalid"
        return
      end
    end
  end

  def meetings
    @tabactive = "agenda"
    if (params[:tab] == nil or params[:tab] == "")
      @tabactive = "agenda"
    else
      @tabactive = params[:tab]
    end

    @hour = ['1','2','3','4','5','6','7','8','9','10','11','12']
    @minute = ['00','15','30','45']
    @ampm = ['AM','PM']
    if (params[:mtnid] == nil or params[:mtnid] == "")
      (@res,@curres,@attres,@uatt,@uad,@udd,@uah,@uam,@uaap,@udh,@udm,@udap,@minpre) = User.getNextUpcomingEvent(session[:user],"")
      @meetingId = @curres.keys[0]      
    else
      (@res,@curres,@attres,@uatt,@uad,@udd,@uah,@uam,@uaap,@udh,@udm,@udap,@minpre) = User.getNextUpcomingEvent(session[:user],params[:mtnid])
      @meetingId = params[:mtnid]        
    end
  end
  
  def allmeetings
    (@res,@rescb) = User.getAllMeetingEvents()
  end

  def createMeetingRsvp
    msg = ""
    msg = User.createUserRsvp(session[:user],params)
    if msg == "created"
        redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:mid], :tab => "attendees"
        flash[:notice] = "Your attendance details have been saved for this meeting."
        flash[:color]= "valid"
        return
    else
        redirect_to :controller => "webportal", :action => "meetings", :mtnid => params[:mid], :tab => "attendees" 
        flash[:notice] = "Something went wrong."
        flash[:color]= "invalid"
        return
    end
  end

  def createForumPost
    
  end
  
   
  def publications
    (@res,@rows) = User.getPublications()
  end
  
  def addeditpub
    @editId = nil
    @pubinfo = [nil,nil,nil,nil,nil,nil]
    @typesOfPub = ['Refereed Papers/Articles','Non-refereed Papers/Articles','Book','Chapter','Thesis','Conference Papers/Articles','Presentation/Talk','Patents','Posters',"Others"]
    if params[:pubid] != nil and params[:pubid] != ""
      @editId = params[:pubid]
      @pubinfo = User.getPublicationDetails(params[:pubid])
    end    
  end
  
  def createEditPublication
    msg = User.addEditPub(params,session[:user])
    if msg == "created" or msg == "updated"
        redirect_to :publications
        flash[:notice] = "Your item has been added/updated to the list."
        flash[:color]= "valid"
        return
    else
        redirect_to :publications 
        flash[:notice] = "Something went wrong."
        flash[:color]= "invalid"
        return
    end

  end
  
  def tools
    
    @emails = User.getAllUserEmails()
    (@res,@rows) = User.getTools()  
    
  end

  def createTool
    msg = nil
    msg = User.createTool(session[:user],params)
    if msg == "created"
        redirect_to :tools
        flash[:notice] = "Your tool has been added to the list."
        flash[:color]= "valid"
        return
    else
        redirect_to :tools 
        flash[:notice] = "Something went wrong."
        flash[:color]= "invalid"
        return
    end
  end

  def editTool
    @emails = User.getAllUserEmails()
    @res = User.getToolById(params[:tid])
  end

  def editToolAction
    msg = nil
    msg = User.updateTool(session[:user],params)
    if msg == "updated"
        redirect_to :tools
        flash[:notice] = "Your tool details have been updated."
        flash[:color]= "valid"
        return
    else
        redirect_to :tools 
        flash[:notice] = "Something went wrong."
        flash[:color]= "invalid"
        return
    end    
  end
  
  def publics
    
    @editsection = nil
    @contents = nil
    @sectionToEdit = nil
    
    if params[:sectionedit] != nil
      @sectionToEdit = params[:sectionName] + ".wiki"
      @contents = File.read(Rails.root.join('publicContent',@sectionToEdit))
      @editsection = "true"
    end
    
  end
  
  def publicsView
    
  end
  
  def editPublicSection
    
    msg = nil
    targetFile = params[:pageSection] + ".wiki"
    targetFile = Rails.root.join('publicContent') + targetFile
    
    File.open(targetFile,'wb') do |iostream|
      iostream.write(params[:pageDesc])
    end
    msg = "updated"
    if msg == "updated"
        redirect_to :publics
        flash[:notice] = "Section " + params[:pageSection] + " has been updated!"
        flash[:color]= "valid"
        return
    else
        redirect_to :publics 
        flash[:notice] = "Something went wrong."
        flash[:color]= "invalid"
        return
    end  
  end

  def newsletter

    @editsection = nil
    @contents = nil
    
    if params[:edit] != nil
      @contents = File.read(Rails.root.join('newsletter','template.wiki'))
      @editsection = "true"
    end
    
  end

  def editNewsletterSection
    msg = nil
    
    File.open(Rails.root.join('newsletter','template.wiki'),'wb') do |iostream|
      iostream.write(params[:pageDesc])
    end
    msg = "updated"
    if msg == "updated"
        redirect_to :newsletter
        flash[:notice] = "Newsletter template has been updated!"
        flash[:color]= "valid"
        return
    else
        redirect_to :newsletter 
        flash[:notice] = "Something went wrong."
        flash[:color]= "invalid"
        return
    end      
  end 

  def allnewsletters

    @filetoshow = nil
    @newsletters = []
    newsletterHash = Hash.new()
    nlsArray = Dir.glob(Rails.root.join("newsletter_prod","*.wiki"))
    nlsArray.each do |item|
      itemp = item.split("/")
      filename = itemp[itemp.length - 1].split(".")
      temp = filename[0].split("_")
      if (newsletterHash.key?(temp[1].to_i))
        newsletterHash[temp[1].to_i] = newsletterHash[temp[1].to_i] + "," + temp[0]
      else
        newsletterHash[temp[1].to_i] = temp[0]
      end    
    end
    
    @years = newsletterHash.keys.sort.reverse
    @years.each do |y|
      monthVals = newsletterHash[y]
      months = monthVals.split(",")
      mtemp = []
      months.each do |m|
        mtemp.push(m.to_i)
      end
      mtemps = mtemp.sort.reverse
      mtemps.each do |ms|
        nl = ""
        if ms < 10
          ms = "0" + ms.to_s
          nl = ms.to_s + "_" + y.to_s
        end  
        nl = ms.to_s + "_" + y.to_s
        @newsletters.push(nl)
      end
    end
    
    if params[:newsletterid] == nil
      if @newsletters.length > 0
        @filetoshow = @newsletters[0]
      else
        @filetoshow = nil        
      end
    else
      @filetoshow = params[:newsletterid]
    end  

  end

  def publishnewsletter
    
    draft = "template.wiki"
    newsletter = params[:newsletterName]
    @gnewsletter = newsletter
    msg = Datafile.publishNewsletter(draft,newsletter,params[:overwrite])
    
    if msg == "published"
      redirect_to :controller => "webportal", :action => "allnewsletters", :newsletterid => newsletter
      flash[:notice] = "Newsletter has been published!"
      flash[:color]= "valid"
      return
    elsif msg == "fileExists"
      redirect_to :newsletter
      flash[:notice]= "Newsletter with same name already exists. Either provide a new name or tick the overwrite check box to publish."
      flash[:color] = "invalid"
      return
    else
      redirect_to :newsletter 
      flash[:notice] = "Something went wrong."
      flash[:color]= "invalid"
      return  
    end
    
  end
  
  def test
    [{label: 'node1',children: [{ label: 'child1' },{ label: 'child2' }]},{label: 'node2',children: [{ label: 'child3' }]}].to_json
  end
  
  def survey
    
    @ccuseful = Hash['Yes' => false,'No' => false]
    @sppublic = Hash['Yes' => false,'No' => false]
    @rnnumber = Hash['0' => false,'1' => false,'2' => false,'3' => false]
    @gmlist = Hash['Yes' => false,'No' => false]
    @majanuary = Hash['Yes' => false,'No' => false]
    @mresources = Hash['Yes' => false,'No' => false]
    @cmlist = Hash['Never' => false, 'Alo' => false, 'Lm' => false]
    @tiportal = Hash['Tickets' => false, 'Gu' => false,  'Ac' => false, 'Email' => false]
    @sdoverview = Hash['Never' => false, 'Alo' => false, 'Lm' => false]
    @ddownload = Hash['Never' => false, 'Alo' => false, 'Lm' => false]   
    @dupload = Hash['Never' => false, 'Alo' => false, 'Lm' => false]  
    @text_sdo = nil 
    @wpuse = Hash['Never' => false, 'Alo' => false, 'Lm' => false]
    @wpcreate = Hash['Never' => false, 'Alo' => false, 'Lm' => false]
    @iwgood = Hash['Yes' => false,'No' => false]
    @text_sw = nil  
    @ydadoverview = Hash['Don\'t know' => false, 'No' => false,  'Partially' => false, 'Yes' => false]
    @kforum = Hash['Yes' => false,'No' => false]
    @fuseful = Hash['useful' => false, 'cbuseful' => false, 'nuseful' => false]
    @ffailure = Hash['exist' => false, 'noteasy' => false, 'starttopic' => false, 'discuss' => false, 'usemail' => false, 'other' => false]
    @text_s = nil
    @public_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @members_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @wiki_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @files_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @do_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @tickets_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @forum_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @meetings_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @profile_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @tools_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    @newsletter_section = Hash['dks' => false, 'nui' => false, 'uift' => false, 'em' => false, 'ew' => false]
    
    if params[:sub_suggestion] != nil
      @text_s = params[:sub_suggestion]
    end

    if params[:sub_suggestion_do] != nil
      @text_sdo = params[:sub_suggestion_do]
    end

    if params[:sub_suggestion_wiki] != nil
      @text_sw = params[:sub_suggestion_wiki]
    end

    
    if ( params[:submittedAnswers] != nil)

      if params[:submittedAnswers][:combat_cancer_useful] == "Yes"
        @ccuseful["Yes"] = true  
      end
      if params[:submittedAnswers][:combat_cancer_useful] == "No"      
        @ccuseful["No"] = true
      end

      if params[:submittedAnswers][:some_pages_public] == "Yes"
        @sppublic["Yes"] = true  
      end
      if params[:submittedAnswers][:some_pages_public] == "No"      
        @sppublic["No"] = true
      end

      if params[:submittedAnswers][:read_newsletter_number] == "0"
        @rnnumber["0"] = true  
      end
      if params[:submittedAnswers][:read_newsletter_number] == "1"
        @rnnumber["1"] = true
      end
      if params[:submittedAnswers][:read_newsletter_number] == "2"
        @rnnumber["2"] = true
      end
      if params[:submittedAnswers][:read_newsletter_number] == "3"
        @rnnumber["3"] = true  
      end

      if params[:submittedAnswers][:get_member_list] == "Yes"
        @gmlist["Yes"] = true  
      end
      if params[:submittedAnswers][:get_member_list] == "No"
        @gmlist["No"] = true
      end

      if params[:submittedAnswers][:meeting_attendance_january] == "Yes"
        @majanuary["Yes"] = true  
      end
      if params[:submittedAnswers][:meeting_attendance_january] == "No"
        @majanuary["No"] = true
      end

      if params[:submittedAnswers][:meeting_resources] == "Yes"
        @mresources["Yes"] = true  
      end
      if params[:submittedAnswers][:meeting_resources] == "No"
        @mresources["No"] = true
      end

      if params[:submittedAnswers][:check_member_list] == "Never"
        @cmlist["Never"] = true  
      end
      if params[:submittedAnswers][:check_member_list] == "At least once"
        @cmlist["Alo"] = true
      end
      if params[:submittedAnswers][:check_member_list] == "In the last month"
        @cmlist["Lm"] = true  
      end

      if params[:submittedAnswers][:trouble_in_portal] == "Tickets"
        @tiportal["Tickets"] = true  
      end
      if params[:submittedAnswers][:trouble_in_portal] == "Give up"
        @tiportal["Gu"] = true
      end
      if params[:submittedAnswers][:trouble_in_portal] == "Ask a colleague"
        @tiportal["Ac"] = true
      end
      if params[:submittedAnswers][:trouble_in_portal] == "Email Rubayte/Magali"
        @tiportal["Email"] = true  
      end

      if params[:submittedAnswers][:saw_data_overview] == "Never"
        @sdoverview["Never"] = true  
      end
      if params[:submittedAnswers][:saw_data_overview] == "At least once"
        @sdoverview["Alo"] = true
      end
      if params[:submittedAnswers][:saw_data_overview] == "In the last month"
        @sdoverview["Lm"] = true  
      end
      
      if params[:submittedAnswers][:data_download] == "Never"
        @ddownload["Never"] = true  
      end
      if params[:submittedAnswers][:data_download] == "At least once"
        @ddownload["Alo"] = true
      end
      if params[:submittedAnswers][:data_download] == "In the last month"
        @ddownload["Lm"] = true  
      end

      if params[:submittedAnswers][:data_upload] == "Never"
        @dupload["Never"] = true  
      end
      if params[:submittedAnswers][:data_upload] == "At least once"
        @dupload["Alo"] = true
      end
      if params[:submittedAnswers][:data_upload] == "In the last month"
        @dupload["Lm"] = true  
      end

      if params[:submittedAnswers][:wiki_page_use] == "Never"
        @wpuse["Never"] = true  
      end
      if params[:submittedAnswers][:wiki_page_use] == "At least once"
        @wpuse["Alo"] = true
      end
      if params[:submittedAnswers][:wiki_page_use] == "In the last month"
        @wpuse["Lm"] = true  
      end

      if params[:submittedAnswers][:wiki_page_creation] == "Never"
        @wpcreate["Never"] = true  
      end
      if params[:submittedAnswers][:wiki_page_creation] == "At least once"
        @wpcreate["Alo"] = true
      end
      if params[:submittedAnswers][:wiki_page_creation] == "In the last month"
        @wpcreate["Lm"] = true  
      end

      if params[:submittedAnswers][:is_wiki_good] == "Yes"
        @iwgood["Yes"] = true  
      end
      if params[:submittedAnswers][:is_wiki_good] == "No"
        @iwgood["No"] = true
      end
      
      # Hash['Don\'t know' => false, 'No' => false,  'Partially' => false, 'Yes' => false]
      if params[:submittedAnswers][:your_data_at_do] == "Don\'t know"
        @ydadoverview["Don\'t know"] = true  
      end
      if params[:submittedAnswers][:your_data_at_do] == "No"
        @ydadoverview["No"] = true
      end
      if params[:submittedAnswers][:your_data_at_do] == "Partially"
        @ydadoverview["Partially"] = true
      end
      if params[:submittedAnswers][:your_data_at_do] == "Yes"
        @ydadoverview["Yes"] = true  
      end

      if params[:submittedAnswers][:know_forum] == "Yes"
        @kforum["Yes"] = true  
      end
      if params[:submittedAnswers][:know_forum] == "No"
        @kforum["No"] = true
      end
      
      # Hash['useful' => false, 'cbuseful' => false, 'nuseful' => false]
      if params[:submittedAnswers][:forum_usefullness] == "useful"
        @fuseful["useful"] = true  
      end
      if params[:submittedAnswers][:forum_usefullness] == "could be useful"
        @fuseful["cbuseful"] = true
      end
      if params[:submittedAnswers][:forum_usefullness] == "not useful"      
        @fuseful["nuseful"] = true  
      end
      
      # Hash['exist' => false, 'noteasy' => false, 'starttopic' => false, 'discuss' => false, 'usemail' => false, 'other' => false]
      if params[:submittedAnswers][:forum_failure] == "did not know it existed"
        @ffailure["exist"] = true  
      end
      if params[:submittedAnswers][:forum_failure] == "not easy to use"
        @ffailure["noteasy"] = true  
      end
      if params[:submittedAnswers][:forum_failure] == "I dont want to start a topic"
        @ffailure["starttopic"] = true  
      end
      if params[:submittedAnswers][:forum_failure] == "I have nothing to discuss"
        @ffailure["discuss"] = true  
      end
      if params[:submittedAnswers][:forum_failure] == "if I want to discuss something, I use email"
        @ffailure["usemail"] = true  
      end
      if params[:submittedAnswers][:forum_failure] == "other"
        @ffailure["other"] = true  
      end
      
      if params[:submittedAnswers][:useage_of_public_section] == "dont_know_this_section"
        @public_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_public_section] == "never_used_it"
        @public_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_public_section] == "used_it_few_times"      
        @public_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_public_section] == "every_month"      
        @public_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_public_section] == "every_week"      
        @public_section["ew"] = true  
      end

      if params[:submittedAnswers][:useage_of_members_section] == "dont_know_this_section"
        @members_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_members_section] == "never_used_it"
        @members_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_members_section] == "used_it_few_times"      
        @members_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_members_section] == "every_month"      
        @members_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_members_section] == "every_week"      
        @members_section["ew"] = true  
      end

      if params[:submittedAnswers][:useage_of_wiki_section] == "dont_know_this_section"
        @wiki_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_wiki_section] == "never_used_it"
        @wiki_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_wiki_section] == "used_it_few_times"      
        @wiki_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_wiki_section] == "every_month"      
        @wiki_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_wiki_section] == "every_week"      
        @wiki_section["ew"] = true  
      end

      if params[:submittedAnswers][:useage_of_files_section] == "dont_know_this_section"
        @files_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_files_section] == "never_used_it"
        @files_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_files_section] == "used_it_few_times"      
        @files_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_files_section] == "every_month"      
        @files_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_files_section] == "every_week"      
        @files_section["ew"] = true  
      end


      if params[:submittedAnswers][:useage_of_data_overview_section] == "dont_know_this_section"
        @do_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_data_overview_section] == "never_used_it"
        @do_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_data_overview_section] == "used_it_few_times"      
        @do_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_data_overview_section] == "every_month"      
        @do_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_data_overview_section] == "every_week"      
        @do_section["ew"] = true  
      end

      if params[:submittedAnswers][:useage_of_tickets_section] == "dont_know_this_section"
        @tickets_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_tickets_section] == "never_used_it"
        @tickets_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_tickets_section] == "used_it_few_times"      
        @tickets_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_tickets_section] == "every_month"      
        @tickets_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_tickets_section] == "every_week"      
        @tickets_section["ew"] = true  
      end


      if params[:submittedAnswers][:useage_of_forum_section] == "dont_know_this_section"
        @forum_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_forum_section] == "never_used_it"
        @forum_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_forum_section] == "used_it_few_times"      
        @forum_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_forum_section] == "every_month"      
        @forum_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_forum_section] == "every_week"      
        @forum_section["ew"] = true  
      end


      if params[:submittedAnswers][:useage_of_meetings_section] == "dont_know_this_section"
        @meetings_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_meetings_section] == "never_used_it"
        @meetings_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_meetings_section] == "used_it_few_times"      
        @meetings_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_meetings_section] == "every_month"      
        @meetings_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_meetings_section] == "every_week"      
        @meetings_section["ew"] = true  
      end


      if params[:submittedAnswers][:useage_of_profile_section] == "dont_know_this_section"
        @profile_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_profile_section] == "never_used_it"
        @profile_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_profile_section] == "used_it_few_times"      
        @profile_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_profile_section] == "every_month"      
        @profile_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_profile_section] == "every_week"      
        @profile_section["ew"] = true  
      end

      if params[:submittedAnswers][:useage_of_tools_section] == "dont_know_this_section"
        @tools_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_tools_section] == "never_used_it"
        @tools_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_tools_section] == "used_it_few_times"      
        @tools_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_tools_section] == "every_month"      
        @tools_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_tools_section] == "every_week"      
        @tools_section["ew"] = true  
      end

      if params[:submittedAnswers][:useage_of_newsletter_section] == "dont_know_this_section"
        @newsletter_section["dks"] = true  
      end
      if params[:submittedAnswers][:useage_of_newsletter_section] == "never_used_it"
        @newsletter_section["nui"] = true
      end
      if params[:submittedAnswers][:useage_of_newsletter_section] == "used_it_few_times"      
        @newsletter_section["uift"] = true  
      end
      if params[:submittedAnswers][:useage_of_newsletter_section] == "every_month"      
        @newsletter_section["em"] = true  
      end
      if params[:submittedAnswers][:useage_of_newsletter_section] == "every_week"      
        @newsletter_section["ew"] = true  
      end



    end  
    
  end
  
  def submitSurveyResults
    
    @msg = nil
    @msg = Datafile.createSurveyFile(params, session[:user])
    if @msg == "created"
      redirect_to :index 
      flash[:notice] = "Your survey has been saved. Thank you for your time and feedback!"
      flash[:color]= "valid"
      return
    elsif @msg == "incomplete"
      redirect_to :controller => "webportal", :action => "survey" , :submittedAnswers => params[:survey], :sub_suggestion => params[:suggestion], :sub_suggestion_wiki => params[:suggestion_wiki], :sub_suggestion_do => params[:suggestion_data_overview]
      flash[:notice] = "Please fill in all the questions. Only the suggestion text boxes are optional!"
      flash[:color]= "invalid"
      return
    else
      redirect_to :survey 
      flash[:notice] = "try agian!"
      flash[:color]= "invalid"
      return
    end  
  end
  
  def surveyResults
    
  end

end