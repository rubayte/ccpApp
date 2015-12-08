class Overview
  

  def self
    con = Mysql.connect('127.0.0.1', 'wwwUser', 'wwwpublic', 'ccpDataOverview')
    return con
  end
  
  
  ## get overall data overview
  def self.getPieData()

    dataC = Hash.new()
    dataO = Hash.new()
    dataA = Hash.new()
    
    ccU = Overview.new.self
    
    qryOverview = "select cancer,count(*) from sample group by cancer"
    refOverview = ccU.query(qryOverview)
    refOverview.each do |cancer,count|
      dataC[cancer] = count
    end
    
    qryOverview = "select organism,count(*) from sample group by organism"
    refOverview = ccU.query(qryOverview)
    refOverview.each do |org,count|
      dataO[org] = count
    end
    
    qryOverview = "select  sum(IF(`analysisVariantCalling`=1,true,false)),sum(if(`analysisCNVCalling`=1,true,false)),sum(if(`analysisExpression`=1,true,false)),sum(if(`wgs`=1,true,false)),sum(if(`wes`=1,true,false)),sum(if(`s360s`=1,true,false)),sum(if(`lcovs`=1,true,false)),sum(if(`rnas`=1,true,false)),sum(if(`gearray`=1,true,false)),sum(if(`meth`=1,true,false)),sum(if(`siRNA`=1,true,false)),sum(if(`shRNA`=1,true,false)),sum(if(`crispr`=1,true,false)),sum(if(`enu`=1,true,false)),sum(if(`im`=1,true,false)),sum(if(`ssr`=1,true,false)),sum(if(`csr`=1,true,false)) " +
                  "from model as M inner join sample as S inner join sampleToAnalysis as A inner join sampleToScreening as SCR inner join sampleToDataAnnotation as D on M.id = S.model and S.sampleName = A.sample and S.sampleName = SCR.sample and S.sampleName = D.sample"
    
    #qryOverview = "select  sum(`analysisVariantCalling`),sum(`analysisCNVCalling`),sum(`analysisExpression`),sum(`wgs`),sum(`wes`),sum(`s360s`),sum(`lcovs`),sum(`rnas`),sum(`gearray`),sum(`meth`),sum(`siRNA`),sum(`shRNA`),sum(`crispr`),sum(`enu`),sum(`im`),sum(`ssr`),sum(`csr`) " + 
    #               "from model as M inner join sample as S inner join sampleToAnalysis as A inner join sampleToScreening as SCR inner join sampleToDataAnnotation as D on M.id = S.model and S.sampleName = A.sample and S.sampleName = SCR.sample and S.sampleName = D.sample"
    refOverview = ccU.query(qryOverview)
    refOverview.each do |r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16,r17|
    #refOverview.each do | cols |
      #cols.each do |c| 
        dataA['VarinatCalls'] = r1
        dataA['CNVCalls'] = r2
        dataA['Expression'] = r3
        dataA['WGS'] = r4
        dataA['WES'] = r5
        dataA['Sanger360'] = r6
        dataA['LowCoverage'] = r7
        dataA['RNAseq'] = r8
        dataA['GEArray'] = r9
        dataA['Methylation'] = r10
        dataA['siRNA'] = r11
        dataA['shRNA'] = r12
        dataA['CRISPR'] = r13
        dataA['ENU'] = r14
        dataA['IM'] = r15
        dataA['SingleScreens'] = r16
        dataA['CombiScreens'] = r17
      #end  
    end
      
    ccU.close
    
    return dataC,dataO,dataA
    
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