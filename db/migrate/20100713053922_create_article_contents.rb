class CreateArticleContents < ActiveRecord::Migration
  def self.up
    create_table :article_contents do |t|
      t.text :content, :limit => 4.megabyte
      t.references :article

      t.timestamps
    end
  end

  def self.down
    drop_table :article_contents
  end
end
