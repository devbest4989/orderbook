class Invoice < ActiveRecord::Base
    has_many :invoice_items, class_name: 'InvoiceItem'
    has_many :invoice_extra_items, class_name: 'InvoiceExtraItem'
    has_many :paid_extra_items, as: 'paid_invoice', class_name: 'InvoiceExtraItem'

    has_many :payments, class_name: 'Payment'

    belongs_to :sales_order, class_name: 'SalesOrder'
    
    enum status: [:draft, :confirmed, :sent, :partial, :paid, :cancelled, :write_off, :credit_note]

    scope :ordered, -> { order({token: :desc}) }
    scope :draft, -> { where(:status => "draft") }
    scope :confirmed, -> { where(:status => "confirmed") }
    scope :sent, -> { where(:status => "sent") }
    scope :partial, -> { where(:status => "partial") }
    scope :paid, -> { where(:status => "paid") }
    scope :cancelled, -> { where(status: 'cancelled') }
    scope :write_off, -> { where(status: 'write_off') }
    scope :credit_note, -> { where(status: 'credit_note') }

    def file_name_path
        '/invoices/' + file_name
    end

    def is_updated_pdf
        updated_at = self.updated_at.to_i.to_s + ".pdf"
        ori_filename = (self.file_name.blank?) ? "" : self.file_name
        pdf_updated_at = ori_filename[11..-1]
        return updated_at == pdf_updated_at
    end    

    def write_off_items
        invoice_extra_items.where(extra_type: 0)
    end

    def credit_note_items
        invoice_extra_items.where(extra_type: 1)
    end

    def status_class
        case status
        when "draft"
          "label-default"
        when "confirmed"
          "label-info"
        when "sent"
          "label-primary"
        when "partial"
          "label-warning"
        when "paid"
          "label-success"
        when "cancelled"
          "label-danger"
        when "write_off"
          "label-danger"
        when "credit_note"
          "label-danger"
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
        when "cancelled"
          "Cancelled"
        when "write_off"
          "Write Off"
        when "credit_note"
          "Credit Note"
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
        payments.sum(:amount) + total_paid_back
    end

    def total_paid_back
        paid_extra_items.sum(:total)
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

    def remove_payment!
        if self.total_paid >= self.total
            self.status = 'paid'
        elsif self.total_paid == 0
            self.status = 'sent'
        else
            self.status = 'partial'
        end
        save!
        self.sales_order.invoice!
    end

    def remove_extra_item!
        if self.is_write_off?
            self.status = 'write_off'
        elsif self.is_credit_note?
            self.status = 'credit_note'
        elsif self.total_paid >= self.total
            self.status = 'paid'
        elsif self.total_paid == 0
            self.status = 'sent'
        else
            self.status = 'partial'
        end
        save!        
        self.sales_order.invoice!
    end

    def total_credit_note
       invoice_extra_items.where(extra_type: 1).sum(:total)
    end

    def is_credit_note?
        invoice_extra_items.where(extra_type: 1).count() != 0
    end

    def is_write_off?
        invoice_extra_items.where(extra_type: 0).count() != 0
    end

end
