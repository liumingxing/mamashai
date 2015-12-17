class Mms::BokergenVoteController < Mms::MmsBackEndController
  def index
    @bokergen_votes = BokergenVote.preload(:user).paginate :page=>params[:page], :per_page => 20, :order=>"id desc"
  end

  def give_score
      bokergen_vote = BokergenVote.find(params[:id])
      redirect_to(action: :index, alert: '已经给过豆豆') and return if bokergen_vote.status == 'processed'
      Mms::Score.trigger_event(:make_bokergen_vote, "给伯克生物投票", 50, 1, {:user => bokergen_vote.user})
      bokergen_vote.update_attribute(:status, 'processed')
      redirect_to params[:back], notice: '操作成功。'
    end

end