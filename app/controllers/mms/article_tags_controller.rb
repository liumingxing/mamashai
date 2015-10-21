class Mms::ArticleTagsController < Mms::MmsBackEndController
  def index
    @tag_types = ArticleTagType.all
  end
  
  def new_type
    @type = ArticleTagType.new
  end
  
  def create_type
    @type = ArticleTagType.new(params[:type])
    @type.save
    redirect_to :action=>"index"
  end
  
  def edit_type
    @type = ArticleTagType.find(params[:id])
  end
  
  def update_type
    @type = ArticleTagType.find(params[:id])
    @type.update_attributes(params[:type])
    redirect_to :action=>"index"
  end
  
  def delete_type
    ArticleTagType.find(params[:id]).destroy
    redirect_to :action=>"index"
  end
  
  def list_tags
    @type = ArticleTagType.find(params[:id])
    @tags = @type.article_tags
  end
  
  def new_tag
    @type = ArticleTagType.find(params[:id])
    @tag = ArticleTag.new
  end
  
  def create_tag
    tag = ArticleTag.new(params[:tag])
    tag.article_tag_type_id = params[:id]
    tag.save
    redirect_to :action=>"list_tags", :id=>params[:id]
  end
  
  def edit_tag
    @tag = ArticleTag.find(params[:id])
    @type = @tag.article_tag_type
  end
  
  def update_tag
    @tag = ArticleTag.find(params[:id])
    @tag.update_attributes(params[:tag])
    redirect_to :action=>"list_tags", :id=>@tag.article_tag_type_id
  end
  
  def delete_tag
    @tag = ArticleTag.find(params[:id]).destroy
    redirect_to :action=>"list_tags", :id=>@tag.article_tag_type_id
  end

end
