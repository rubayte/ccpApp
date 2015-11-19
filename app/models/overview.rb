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

    filters = []
    filterString = ""
    
    if params[:cType] != "All"
      #fil = " S.cancer = '" + params[:cType] + "' "
      fil = " S.cancer = '#{params[:cType]}' "
      filters.push(fil)
    end
    if params[:sType] != "All"
      fil = " M.name = '#{params[:sType]}' "
      filters.push(fil)
    end
    if params[:oType] != "All"
      fil = " S.organism = '#{params[:oType]}' "
      filters.push(fil)
    end    
    filterString = filters.join(" and ")  #" S.cancer = '" + params[:cType] + "' and M.name = '" + params[:sType] + "' and S.organism = '" + params[:oType]+ "'" 
    filterString = " where " + filterString    
    
    ccU = Overview.new.self
    qryOverview = ""
    if filters.length == 0
      qryOverview = "select * from model as M inner join sample as S inner join sampleToAnalysis as A inner join sampleToScreening as SCR inner join sampleToDataAnnotation as D " +
      "on M.id = S.model and S.sampleName = A.sample and S.sampleName = SCR.sample and S.sampleName = D.sample "
    else  
      qryOverview = "select * from model as M inner join sample as S inner join sampleToAnalysis as A inner join sampleToScreening as SCR inner join sampleToDataAnnotation as D " +
      "on M.id = S.model and S.sampleName = A.sample and S.sampleName = SCR.sample and S.sampleName = D.sample " + filterString
    end
    
    refOverview = ccU.query(qryOverview)
    ccU.close
    
    return refOverview,refOverview.num_rows
        
  end


end