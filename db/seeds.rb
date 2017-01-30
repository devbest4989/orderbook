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
					role: 2)

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


