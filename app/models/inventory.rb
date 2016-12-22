class Inventory < ActiveRecord::Base

  belongs_to :store
  belongs_to :item

  def update_location(loc)
    update_attribute(:location,loc)
  end

  def self.download
    workbook = WriteXLSX.new('tmp/All Stores Inventory.xlsx')
    worksheet = workbook.add_worksheet
    heading_format = workbook.add_format(border: 6,bold: 1,color: 'red',align: 'center')
    table_heading_format = workbook.add_format(bold: 1)
    worksheet.merge_range('A1:G1','Inventory for All Stores', heading_format)
    worksheet.write(1,0,'No',table_heading_format)
    worksheet.write(1,1,'Item Name',table_heading_format)
    worksheet.write(1,2,'Original Number',table_heading_format)
    worksheet.write(1,3,'Main Store',table_heading_format)
    worksheet.write(1,4,'L Store',table_heading_format)
    worksheet.write(1,5,'L Shop',table_heading_format)
    worksheet.write(1,6,'T Shop',table_heading_format)
    item_inv = includes(:item).group_by{|inv| [inv.item_id]}
    item_inv.each_with_index do |(key,invs),index|
      worksheet.write(index+2,0,index+1)
      worksheet.write(index+2,1,invs[0].item.name)
      worksheet.write_string(index+2,2,invs[0].item.original_number)
      invs.each do |inv|
        case inv.store_id
          when 8
            worksheet.write_number(index+2,3,inv.qty)
          when 6
            worksheet.write_number(index+2,4,inv.qty)
          when 5
            worksheet.write_number(index+2,5,inv.qty)
          when 4
            worksheet.write_number(index+2,6,inv.qty)
        end
      end
    end
    workbook.close
    File.open('tmp/All Stores Inventory.xlsx').path
  end

  def self.download_by_store(store_id)
    store = Store.find(store_id.to_i)
    workbook = WriteXLSX.new("tmp/#{store.name} Inventory.xlsx")
    worksheet = workbook.add_worksheet
    heading_format = workbook.add_format(border: 6,bold: 1,color: 'red',align: 'center')
    table_heading_format = workbook.add_format(bold: 1)
    worksheet.merge_range('A1:D1', "Inventory for #{store.name}", heading_format)
    worksheet.write(1,0,'No',table_heading_format)
    worksheet.write(1,1,'Item Name',table_heading_format)
    worksheet.write(1,2,'Original Number',table_heading_format)
    worksheet.write(1,3,'Qty',table_heading_format)
    item_inv = includes(:item).where(store: store)
    item_inv.each_with_index do |inv, index|
      worksheet.write(index+2,0, index+1)
      worksheet.write(index+2,1, inv.item.name)
      worksheet.write_string(index+2,2, inv.item.original_number)
      worksheet.write_number(index+2,3, inv.qty)
    end
    workbook.close
    File.open("tmp/#{store.name} Inventory.xlsx").path
  end

end