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
      
      ## create ticket in atlassian jira
      data = "{\\\"fields\\\":{\\\"project\\\":{\\\"key\\\":\\\"SUP\\\"},\\\"summary\\\":\\\"combatcancer-#{params[:issueSub]}\\\",\\\"description\\\":\\\"#{params[:issueDesc]}\\\",\\\"issuetype\\\":{\\\"name\\\":\\\"Task\\\"},\\\"customfield_10004\\\":2}}"
      issuecreateCmd = "curl -D- -u user:pass -X POST --data \"#{data}\" -H \"Content-Type: application/json\" https://nki-research-it.atlassian.net/rest/api/latest/issue/"
      system(issuecreateCmd)
      valMsg = "created"
      
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
    qryTickets = "SELECT `subject`,`details`,`priority`,`user`,`created_on`,`status`,`last_update`,`id` FROM tickets  WHERE `status` = 'open' ORDER BY `created_on` DESC"
    refTickets = ccU.query(qryTickets)
    ccU.close
    
    return refTickets,refTickets.num_rows
     
  end
  
  ## get ticket by id
  def self.getTicketById(params)
    
    ccU = Tickets.new.self
    qryTickets = "SELECT `subject`,`details`,`priority`,`user`,`created_on`,`status`,`last_update`,`id` FROM tickets  WHERE `id` = " + params[:tid] + ""
    refTickets = ccU.query(qryTickets)
    ccU.close
    
    return refTickets,refTickets.num_rows    
    
  end
  
  ## update ticket details by id
  def self.updateTicketById(params)
    
    msg = nil
      
    ccU = Tickets.new.self
    qryUpdateTicket = "update tickets set `details` = '"+ params[:updateDetails]+"',`priority` = '"+ params[:updatePriority]+"',`status` = '"+ params[:updateStatus]+"',`last_update` = NOW() WHERE `id` = " + params[:tid] + ""
    ccU.query(qryUpdateTicket)
    ccU.close
    
    msg = "updated"
    
    return msg      
    
  end
  
  ## get filtered tickets
  def self.getTicketsFilter(params)

    filters = []
    filterString = ""
    
    if params[:statusType] != "Any"
      fil = " T.`status` = '" + params[:statusType] + "' "
      filters.push(fil)
    end
    if params[:priorityType] != "Any"
      fil = " T.`priority` = '" + params[:priorityType] + "' "
      filters.push(fil)
    end

    filterString = filters.join(" and ")  
    filterString = " where " + filterString    

    ccU = Tickets.new.self
    qryTickets = ""
    if filters.length == 0
      qryTickets = "select T.`subject`,T.`details`,T.`priority`,T.`user`,T.`created_on`,T.`status`,T.`last_update`,`id` from tickets as T order by T.`created_on` desc"
    else
      qryTickets = "select T.`subject`,T.`details`,T.`priority`,T.`user`,T.`created_on`,T.`status`,T.`last_update`,`id` from tickets as T" + filterString + " order by T.`created_on` desc"    
    end
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