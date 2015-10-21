module WapHelper
  def wrap_wap_url(url,op={})
    op.merge!(:msid=>@msid)
    op.merge!(:page=>params[:page]) if params[:page].present?
    args=[]
    op.each_pair do |k,v|
      args << "#{k.to_s}=#{v}"
    end
    return "#{url}?#{URI.escape(args.join("&")).gsub('&','&amp;')}"
  end
end
