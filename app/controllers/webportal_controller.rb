class WebportalController < ApplicationController
  
  # before_filter :authenticate_user, :only => [:index,:data,:project, :members]
  before_filter :authenticate_user, :only => [:index,:data,:project,:members,
  :getProfile,:getMembersList,:folderLookInto,:editWikiPage,:editWikiFiles,:admin,:overview,:overviewFilter,
  :filterOverview,:authenticateAdmin,:tickets,:viewTicket,:updateticket,:ticketsFilter,:createIssues,:uploadFiles,
  :download,:downloadFolder,:downloadWikiAtatchment,:updateFileDetails,:commitUpdateFileDetails,:profile,:wiki,:createWikiPage,
  :newPage,:forum,:createPost,:viewPostById,:createPostComment,:meetings,:createMeetingRsvp,:createForumPost,:createAgenda, :tools, 
  :createTool, :editTool,:viewTextFile, :dataViewFile, :viewPdfFile, :viewSampleDetails, :publics, :editPublicSection, :newsletter, :editNewsletterSection, :allmeetings, :allnewsletters]
  
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
    @res = params[:data]
    @sample = params[:sample]
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
    @newsletters = Dir.glob(Rails.root.join("newsletter_prod","*.wiki"))
    if params[:newsletterid] == nil
      if @newsletters.length > 0
        @filetoshow = @newsletters[0]
      else
        @filetoshow = nil        
      end
    else
      @filetoshow = params[:newsletterid] + ".wiki"
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
  

end