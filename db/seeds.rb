# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
p "Create admin users..."
admin = User.create(email: "admin@orderbook.com", 
					password: "password", 
					first_name: "Admin",
					last_name: "Manager",
					role: 0)

p "Create Tax..."
Tax.create(rate: 15, name: "GST15", description: "Goods Service Tax")
Tax.create(rate: 10, name: "NT10", description: "Normal Tax")

p "Create Global Settings..."
Setting.create(key: "company.name", 	value: "Kinjal Pandel Ltd", 	conf_type: 1)
Setting.create(key: "company.trading", 	value: "KP Ltd", 				conf_type: 1)
Setting.create(key: "company.address", 	value: "Street", 				conf_type: 1)
Setting.create(key: "company.phone", 	value: "39789437589", 			conf_type: 1)
Setting.create(key: "company.fax", 		value: "438795473895", 			conf_type: 1)
Setting.create(key: "company.email", 	value: "kinjal@local.com", 		conf_type: 1)
Setting.create(key: "company.url", 		value: "http://orderbook.com", 	conf_type: 1)

p "Create Default Currency"
Setting.create(key: "format.currency",  value: "$", 					conf_type: 2)

p "Create Tax Details..."
PaymentTerm.create(name: "7-Days : Due on 7 days after Date of Invoice Issued", days: 7, term_type: 0)
PaymentTerm.create(name: "14-Days : Due on 14 days after Date of Invoice Issued", days: 14, term_type: 0)
PaymentTerm.create(name: "30-Days : Due on 30 days after Date of Invoice Issued", days: 30, term_type: 0)
PaymentTerm.create(name: "20th of Following Month : Due on 20th of following month", days: 20, term_type: 1)

p "Create Shipping Method"
ShippingMethod.create(name: "Ground Shipping")

p "Create Terms & Service"
ConditionTerm.create(title: "Terms & Condition", description: "Terms & Condition")

p "Create Unit of Category"
UnitCategory.create(name: "Quantity")

p "Create Unit of Measure"
UnitMeasure.create(name: "each", ratio: 1, unit_category_id: 1)
UnitMeasure.create(name: "box", ratio: 6, unit_category_id: 1)
UnitMeasure.create(name: "dozen", ratio: 12, unit_category_id: 1)
