class Invoice < ActiveRecord::Base
    has_many :invoice_items, class_name: 'InvoiceItem'
    has_many :payments, class_name: 'Payment'

    belongs_to :sales_order, class_name: 'SalesOrder'
    
    enum status: [:draft, :confirmed, :sent, :partial, :paid]

    scope :ordered, -> { order(:token) }
    scope :draft, -> { where(:status => "draft") }
    scope :confirmed, -> { where(:status => "confirmed") }
    scope :sent, -> { where(:status => "sent") }
    scope :partial, -> { where(:status => "partial") }
    scope :paid, -> { where(:status => "paid") }

    def file_name_path
        '/invoices/' + file_name
    end

    def is_updated_pdf
        updated_at = self.updated_at.to_i.to_s + ".pdf"
        ori_filename = (self.file_name.blank?) ? "" : self.file_name
        pdf_updated_at = ori_filename[11..-1]
        return updated_at == pdf_updated_at
    end    

    def status_class
        case status
        when "draft"
          "label-default"
        when "confirmed"
          "label-info"
        when "sent"
          "label-danger"
        when "partial"
          "label-warning"
        when "paid"
          "label-success"
        end
    end

    def status_text
        case status
        when "draft"
          "Draft"
        when "confirmed"
          "Approved"
        when "sent"
          "Not Paid"
        when "partial"
          "Partial Paid"
        when "paid"
          "Paid"
        end
    end

    def payment_date
        if self.sales_order.payment_term.after_days?
            self.sales_order.order_date.next_day(self.sales_order.payment_term.days)
        else
            due_date = self.sales_order.order_date.change({ day: self.sales_order.payment_term.days })
            due_date.next_month(1) if due_date < self.sales_order.order_date
            due_date
        end
    end

    def total_paid
        payments.sum(:amount)
    end

    def add_payment!
        if self.total_paid >= self.total
            self.status = 'paid'
        else
            self.status = 'partial'
        end
        save!
        self.sales_order.invoice!
    end

end
