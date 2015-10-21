namespace :mamashai do
  desc "生成报表"
  task :make_report  => [:environment] do
    now = Time.new
    day = now.ago(24.hours)

    details = AOrderDetail.find_by_sql(%!
  SELECT count(a_order_details.id) as count, a_order_details.price, a_products.code, a_products.id as a_product_id, a_products.brand, a_products.name, a_products.english_name
  FROM a_order_details, a_orders, a_products
  where a_orders.status = '待发货' and  a_orders.pay_at > '#{day.at_beginning_of_day}' and a_orders.pay_at < '#{day.end_of_day()}' and a_order_details.a_order_id = a_orders.id and a_products.id = a_order_details.a_product_id
  group by a_product_id order by a_products.category_id!
)
    AReport.delete_all("date = '#{Time.new.to_date}'")
    for detail in details
      r = AReport.new
      r.count = detail["count"]
      r.code  = detail["code"]
      r.a_product_id = detail["a_product_id"]
      r.brand = detail["brand"]
      r.product_name = detail["name"]
      r.product_name_eng = detail["english_name"]
      r.price = detail.price
      r.date  = now.to_date
      r.save
    end

    for report in AReport.all
      if report.a_product.composit_codes.to_s.size > 0
        codes = report.a_product.composit_codes.split(",")
        for code in codes
          product = AProduct.find_by_code(code)
          r = AReport.find_by_a_product_id(product.id)
          if r
            r.count += report.count
          else
            p code
            r = AReport.new(:a_product_id=>product.id, :count=>report.count)
            r.count = report.count
            r.code = product.code
            r.brand = product.brand
            r.product_name = product.name
            r.product_name_eng = product.english_name
            r.price = product.price
            r.date = now.to_date
          end
          r.save
        end
        report.destroy
      end
    end
  end
end