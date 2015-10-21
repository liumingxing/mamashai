namespace :mamashai do
  desc "regenerate baby_book_page thumb"
  task :regenerate_page_thumb  => [:environment] do
    BabyBookPage.all.each do |page|
      begin
      page.logo.copy_to(page.logo.thumb.path)
      page.logo.thumb.process!("82x58")
      puts "#{page.id} is fine"
      rescue
      end
    end
  end
end
