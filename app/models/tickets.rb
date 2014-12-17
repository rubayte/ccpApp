class Tickets
  
  def self
    con = Mysql.connect('127.0.0.1', 'wwwUser', 'wwwpublic', 'ccp')
    return con
  end
  
  def self.create(params,user)   

      valMsg = nil
      ## validate subject and description
      params[:issueSub] = validateStr(params[:issueSub])
      params[:issueDesc] = validateStr(params[:issueDesc])
      qryInsert = "insert into tickets(subject,details,priority,user,created_on,status,last_update)" +  
      " values('"+ params[:issueSub] +"','"+ params[:issueDesc] +"','"+ params[:issuePriority] +"','"+ user +"', NOW(),'open',NOW());"
      ccU = Tickets.new.self
      ccU.query(qryInsert)
      valMsg = "created"
      ccU.close
      
      return valMsg      
  
  end
  
  def self.validate(params)
    
    valmsg = ""
    
    if (params[:issueSub] == "" or params[:issueDesc] == "")
      valmsg = "missingFields"
    end
    
    return valmsg
    
  end
  
  ## get all tickets
  def self.getTickets()
    
    ccU = Tickets.new.self
    qryTickets = "select `subject`,`details`,`priority`,`user`,`created_on`,`status`,`last_update` from tickets order by `id` desc"
    refTickets = ccU.query(qryTickets)
    ccU.close
    
    return refTickets,refTickets.num_rows
     
  end

  ## validate strings with single qoute and \r\n for mysql 
  def self.validateStr(str)
    retStr = ""
    
    ## single qoute
    if (str =~ /\'/)
      retStr = str.gsub(/\'/,"\"")
    else
      retStr = str
    end
    ## \r\n
    retStr.gsub!(/\r/,"")
    retStr.gsub!(/\n/,"")
      
    return retStr   
  end
  

end