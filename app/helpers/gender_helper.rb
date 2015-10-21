module GenderHelper
  def download(url, name, tp=2)
    if @user
      if tp == 2
        "<a href='http://www.mamashai.com/mms_tools/download/#{url}' target='_blank'>#{name}</a>"
      elsif tp == 1
        "<a href='http://www.mamashai.com/mms_tools/show/#{url}' target='_blank'>"
      end
    else
      if tp == 2
        "<a href='#' onclick='revealModal(\"modalPage\", \"register\")'>#{name}</a>"
      elsif tp == 1
        "<a href='#' onclick='revealModal(\"modalPage\", \"register\")'>"
      end
    end
  end
end
