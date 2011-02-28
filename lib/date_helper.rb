module DateHelper
  
  def DateHelper.format(date)
    return date.strftime('%m/%d/%y')
  end
  
  def DateHelper.verify(string)
    begin
      return Time.zone.parse(string) ? true : false
    rescue
      return false
    end
  end
  
end