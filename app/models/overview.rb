class Overview
  

  def self
    con = Mysql.connect('127.0.0.1', 'wwwUser', 'wwwpublic', 'ccpDataOverview')
    return con
  end
  
  ## get data overview
  def self.getDataOverview()
    
    ccU = Overview.new.self
    qryOverview = "select * from model as M inner join sample as S inner join sampleToAnalysis as A inner join sampleToScreening as SCR inner join sampleToDataAnnotation as D " +
    "on M.id = S.model and S.sampleName = A.sample and S.sampleName = SCR.sample and S.sampleName = D.sample"
    refOverview = ccU.query(qryOverview)
    ccU.close
    
    return refOverview,refOverview.num_rows
    
  end
  
  
  ## get data overview by params filter
  def self.getDataOverviewFilter(params)

    filterString = ""
    filterString = " S.cancer = '" + params[:cType] + "' and M.name = '" + params[:sType] + "' and S.organism = '" + params[:oType]+ "'" 
    
    ccU = Overview.new.self
    qryOverview = "select * from model as M inner join sample as S inner join sampleToAnalysis as A inner join sampleToScreening as SCR inner join sampleToDataAnnotation as D " +
    "on M.id = S.model and S.sampleName = A.sample and S.sampleName = SCR.sample and S.sampleName = D.sample where " + filterString
    refOverview = ccU.query(qryOverview)
    ccU.close
    
    return refOverview,refOverview.num_rows
        
  end


end