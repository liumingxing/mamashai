class NaProfile < ActiveRecord::Base
  belongs_to :gou
  upload_column :picture1 , :versions => {:thumb255=>"c255x255", :thumb180=>"c180x180", :thumb150=>"c150x150",:thumb80 => "c80x80",:thumb120=>"c120x120",:thumb16=>"c16x16"}
  upload_column :picture2 , :versions => {:thumb255=>"c255x255", :thumb180=>"c180x180", :thumb150=>"c150x150",:thumb80 => "c80x80",:thumb120=>"c120x120",:thumb16=>"c16x16"}
  upload_column :picture3 , :versions => {:thumb255=>"c255x255", :thumb180=>"c180x180", :thumb150=>"c150x150",:thumb80 => "c80x80",:thumb120=>"c120x120",:thumb16=>"c16x16"}
  upload_column :picture4 , :versions => {:thumb255=>"c255x255", :thumb180=>"c180x180", :thumb150=>"c150x150",:thumb80 => "c80x80",:thumb120=>"c120x120",:thumb16=>"c16x16"}
  upload_column :picture5 , :versions => {:thumb255=>"c255x255", :thumb180=>"c180x180", :thumb150=>"c150x150",:thumb80 => "c80x80",:thumb120=>"c120x120",:thumb16=>"c16x16"}
end
