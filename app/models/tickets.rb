class Tickets
  
  def self
    
  end
  
  def self.create(params,user)   
      valMsg = nil
      ## create file name
      file = user + Time.now().to_s + "_ticket.txt"
      ## check work group type
      if (not(File.exists?(Rails.root.join("tickets"))))
        Dir.mkdir(Rails.root.join("tickets")) 
      end
      ## write the issue
      File.open(Rails.root.join("tickets",file), 'w+') do |fl|
        fl.write(params[:issueSub] + "\n")
        fl.write( params[:issuePriority] + "\n")
        fl.write( params[:issueDesc] + "\n")
      end
      valMsg = "created"
      return valMsg      
  end
  

end