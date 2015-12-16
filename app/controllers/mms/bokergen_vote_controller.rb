class Mms::BokergenVoteController < Mms::MmsBackEndController
  def index
    @bokergen_votes = BokergenVote.paginate :page=>params[:page], :per_page => 20, :order=>"id desc"
  end

  def give_score
    redirect_to action: :index, notice: '操作成功。'
  end

end