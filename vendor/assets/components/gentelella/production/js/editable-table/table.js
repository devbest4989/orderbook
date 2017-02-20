function Table (o) {

    var s = o || {};

    // Debug messages to console.log
    this.debug = s.debug || false;
    // Set the id of the table
    this._id(s.id);
    // Data as Array of Arrays
    this.data = s.data || [];
    // Fields as Key Objects pairs
    this.fields = s.fields || {};
    // Direction
    this.direction = s.direction || "asc";

    this.log("Initializing Table"+this.id);
    this._init();

    return;
}

Table.prototype._init = function() {

    // Set initial data types
    this._datatypes();

    // Attach events
    this._events();
}

Table.prototype._calc_extra = function() {
    var self = this;

    var table_id = this._id();
    var cols = this._count("cols", "table") -1;
    var rows = this._count("rows", "table") -1;    

    var sub_total = 0, discount_total = 0, tax_total = 0, total = 0;
    for(r = 0; r <= rows; r++){
        var discount_id = table_id+"_"+r+"_3";
        var tax_id = table_id+"_"+r+"_4";
        var line_total_id = table_id+"_"+r+"_6";

        var discount_rate = self._getcell(discount_id);
        var tax_rate = self._getcell(tax_id);
        var line_total = self._getcell(line_total_id);

        sub_total += isNaN(parseFloat(line_total)) ? 0 : parseFloat(line_total);

        discount_total -= discount_rate * line_total * 0.01;
        tax_total += tax_rate * line_total * 0.01;
    }

    total += sub_total + discount_total + tax_total;

    $("td#sub_total_cell").text(sub_total);
    $("td#discount_total_cell").text(discount_total);    
    $("td#tax_total_cell").text(tax_total);
    $("td#total_cell").text(total);
    $('#sales_order_amount_paid').val(total);
}

Table.prototype._calc = function(id, o) {

    var self = this;

    var pos = this._position(id);
    var cols = this._count("cols", "table") -1;
    var rows = this._count("rows", "table") -1;    

    var val;

    for (var i=0; i<o.length; i++) {
        for (var op in o[i]) {

            var param = o[i][op];

            if ( param.length !== 2 ) {
                self.log("Insufficient parameters supplied to "+op+" function");
            }

            if(param[0].d){
                var x = param[0].d;
            } else {
                var c1 = (param[0].c) ? (Number(pos.col)+Number(param[0].c)) : Number(pos.col);
                var r1 = (param[0].r) ? (Number(pos.row)+Number(param[0].r)) : Number(pos.row);
                if ( self._inrange(c1, r1, cols, rows) === false ) { return ""; }

                var id1 = pos.table_id+"_"+r1+"_"+c1;
                var x = (c1 == pos.col && r1 == pos.row) ? val : self._getcell(id1);

            }

            if(param[1].d){
                var y = param[1].d;
            } else {
                var c2 = (param[1].c) ? (Number(pos.col)+Number(param[1].c)) : Number(pos.col);
                var r2 = (param[1].r) ? (Number(pos.row)+Number(param[1].r)) : Number(pos.row);
                if ( self._inrange(c2, r2, cols, rows) === false ) { return ""; }
                var id2 = pos.table_id+"_"+r2+"_"+c2;
                var y = (c2 == pos.col && r2 == pos.row) ? val : self._getcell(id2);                
            }


            switch(op) {
                case "subtract":
                    val = (x - y);
                    break;
                case "sum":
                    val = (x + y);
                case "divide":
                    val = (x / y);
                    break;
                case "multiply":
                    val = (x * y);
                    break;
                case "datediff":
                    // IE doesn't accept dates as strings, resulting in NaN.
                    // Instead we'll use regex to parse the string and set
                    // the date using Date.setFullYear().
                    var rx = /^\s*(\d{4})-(\d\d)-(\d\d)\s*$/;
                    var xparts = rx.exec(x);
                    var yparts = rx.exec(y);
                    var day = 24*60*60*1000;

                    var d1 = new Date(NaN);
                    var d2 = new Date(NaN);
                    d1.setFullYear(xparts[1], (xparts[2] - 1), xparts[3]);
                    d2.setFullYear(yparts[1], (yparts[2] - 1), yparts[3]);

                    //self.log("("+ d1.getTime() +" - "+ d2.getTime() +") / "+day)
                    val = Math.round(Math.abs((d1.getTime()-d2.getTime())/(day)));
                    break;
            }

            self.log("Formula: "+op+"("+x+", "+y+") : "+val);
        }        
    }

    if ( isNaN(val) ) {
        val = "";
    }
    else {
        // Float
        if ( val - Math.floor(val) != 0 ) {
            val = parseFloat(val).toFixed(2);
        }
        // Int
        else {
            val = parseInt(val);
        }
    }

    return val;
}

Table.prototype._datatypes = function(type) {

    var self = this;

    // Set data types
    if ( this.datatypes === undefined ) {

        this.datatypes = {
            "calc": {
                "default": "",
                "placeholder": "",
                "format": function(val) { return val; },
                "formula": function(id, o) {
                    return self._calc(id, o);
                }
            },
            "date": {
                "default": "",
                "placeholder": "YYYY-MM-DD",
                "format": function(val) {
                    var d = new Date(val);
                    if ( d == "Invalid Date" || isNaN(d) ) {
                        return false;
                    }
                    return d.toISOString().slice(0,10);
                }
            },
            "float": {
                "default": "0.0",
                "placeholder": "",
                "format": function(val) {
                    val = String(val).replace(/[^\d\.\-]+/g, "");
                    if ( isNaN(val) ) { return false; }
                    return parseFloat(val).toFixed(2);
                }
            },
            "int": {
                "default": "0",
                "placeholder": "",
                "format": function(val) {
                    val = String(val).replace(/[^\d\-]+/g, "");
                    if ( isNaN(val) || ! /^[0-9]+$/.test(val) ) { 
                        return false;
                    }
                    return parseInt(val);
                }
            },
            "money": {
                "default": "0.00",
                "placeholder": "",
                "format": function(val) {
                    if ( val === undefined || val == "" ) { val = 0.00; }
                    val = String(val).replace(/[^\d\.\-]+/g, "");
                    if ( isNaN(val) ) { 
                        return false;
                    }
                    return parseFloat(val).toFixed(2);
                }
            },
            "string": {
                "default": "",
                "placeholder": "",
                "format": function(val) { return val; }
            }
        };

        // Set the data types in an easy lookup array
        this.types = [];

        for (var key in this.datatypes) {
            this.types.push(key);
        }
    }

    // Get specified data type
    if ( type !== undefined ) {

        if ( this.datatypes[type] !== undefined ) {
            
            return this.datatypes[type]
        }
        return false;
    }
}

Table.prototype._events = function() {

    var self = this;

    $(document).on("click", function(event) {

        var target = $(event.target);

        // Click an editable table cell
        if ( target.is("td") && target.hasClass("edit") && 
             target.parent("table"+self.id) ) {

            var cid = target.attr("id");

            // Save any cells open for edit except the one clicked
            $("table"+self.id+" > tbody > tr > td.edit")
                .children("input").each(function() {

                var oid = $(this).parent("td").attr("id")

                if ( oid !== cid ) {
                    self.saveCell(oid);
                }
            });

            // Save any cells open for edit except the one clicked
            $("table"+self.id+" > tbody > tr > td.edit")
                .children("select").each(function() {

                var oid = $(this).parent("td").attr("id")

                if ( oid !== cid ) {
                    self.saveCell(oid);
                }
            });

            // Save cell if its open for edit without error
            if (( $(target).children("input").length ) && 
                (! $(target).children("input").hasClass("error") )) {

                self.saveCell(cid);
            } else if (( $(target).children("select").length ) && 
                (! $(target).children("select").hasClass("error") )) {

                self.saveCell(cid);
            }
            // Edit cell
            else {
                self.editCell(cid);
                //$(target).children("input").focus().select();
            }
        }
        // Click anywhere
        else {

            if ( target.is("input") && target.parent("td.edit") ) {

                self.log("clicked already open cell");
                target.focus().select();
            }
            else {

                // Save any editable cells
                $("table"+self.id+" > tbody > tr > td.edit")
                    .children("input").each(function() {

                    var cid = $(this).parent("td").attr('id');
                    self.saveCell(cid);
                });
            }
        }
    }).on('keydown', function(event) {

        var target = $(event.target);

        // Tab or Enter an editable cell
        if ( (target.is("input") || target.is("span")) && target.parent("td.edit") ) {

            var code = (event.keyCode ? event.keyCode : event.which);
            var cid = $(target).parent("td").attr("id");

            switch(code) {
                case 13:
                case 9:
                    var editcells = $("table"+self.id+" > tbody").find("td.edit");

                    if ( event.shiftKey ) {
                        
                        for (var i=(editcells.length-1); i>=0; i--) {
                            
                            if ( $(editcells[i]).attr("id") == cid ) {

                                if ( editcells[(i-1)] === undefined ) {
                                    $(editcells[(editcells.length-1)]).click();
                                }
                                else {
                                    $(editcells[(i-1)]).click();
                                }
                            }
                        };
                    }
                    else {
                        
                        for (var i=0; i<editcells.length; i++) {
                            
                            if ( $(editcells[i]).attr("id") == cid ) {

                                if ( editcells[(i+1)] === undefined ) {
                                    $(editcells[0]).click();
                                }
                                else {
                                    $(editcells[(i+1)]).click();
                                }
                            }
                        };
                    }
                    event.stopPropagation();
                    return false;
                    break;
                    /*
                case 13:
                    $(target).parent("td").click();
                    break;
                    */
            }
        }
    });
}

// Get or set id of table
Table.prototype._id = function(id) {

    // Get the table id
    if ( id === undefined ) {

        if ( this.id.charAt( 0 ) === '#' ) {
            return this.id.slice( 1 );
        }
        else {
            return this.id || "";
        }
    }
    // Set the table id
    else {

        this.id = "#"+id;
    }
}

Table.prototype._has = function(p) {

    switch (p) {
        case "data":
            if ( $.isArray(this.data) && this.data.length > 0 ) {
                return true;
            }
        case "fields":
            if (( $.isPlainObject(this.fields) ) && 
                ( ! $.isEmptyObject(this.fields) )) {
                return true;
            }
    }

    return false;
}

// Return a count of the existing rows
Table.prototype._count = function(p, src) {

    var p = p || "rows";
    var s = src || "table";

    switch(s) {
        case "data":
            switch(p) {
                case "cells":
                    return this.data.length * this.data[0].length; 
                case "cols":
                    return this.fields;
                case "rows":
                    return this.data.length;
                default:
                    return 0;
            }
            break;
        case "table":
            switch(p) {
                case "cells":
                    return $("table"+this.id+" > tbody").find("td").length;
                case "cols":
                    return $("table"+this.id+" > tbody > tr:first").find("td").length;
                case "rows":
                    return $("table"+this.id+" > tbody").find("tr").length;
                default:
                    return 0;
            }
            break;
    }
}

Table.prototype._inrange = function(c, r, col, row) {

    var cols = col || this._count("cols", "table") -1;
    var rows = row || this._count("rows", "table") -1;

    if ( c < 0 || c > cols ) {
        this.log("Col: "+c+" is out of range");
        return false;
    }
    if ( r < 0 || r > rows ) {
        this.log("Row: "+r+" is out of range");
        return false;
    }

    return true;
}

Table.prototype._getcell = function(id) {

    var self = this;

    if ( $("td#"+id) ) {

        var type = this._gettype(id);
        var val = "";

        if ( $("td#"+id).children("input").length ) {
            val = $("td#"+id+" > input").val();
        }
        else {
            val = $("td#"+id).text();
        }

        self.log("Cell: "+id+" has value: "+val);

        return val;
    }

    return false;
}

// Get the cell data type
Table.prototype._gettype = function(id) {

    if ( $("td#"+id) ) {

        var pos = this._position(id);

        var c = 0;
        for (field in this.fields) {
            if ( c == pos.col ) {
                return this.fields[field].type || "";
            }
            c++;
        }
    }
}

// Get the cell data type
Table.prototype._getfield = function(id) {

    if ( $("td#"+id) ) {

        var pos = this._position(id);

        var c = 0;
        for (field in this.fields) {
            if ( c == pos.col ) {
                return field || "";
            }
            c++;
        }
    }
}

// Get the cell field name
Table.prototype._getfieldname = function(id) {
    if ( $("td#"+id) ) {

        var pos = this._position(id);

        var c = 0;
        for (field in this.fields) {
            if ( c == pos.col ) {
                return this.fields[field].field_name || "";
            }
            c++;
        }
    }
}

// Get the cell field name
Table.prototype._getfielddata = function(id) {
    if ( $("td#"+id) ) {

        var pos = this._position(id);

        var c = 0;
        for (field in this.fields) {
            if ( c == pos.col ) {
                return this.fields[field] || "";
            }
            c++;
        }
    }
}

// Test if a specified table exists
Table.prototype._isvalid = function() {

    if ( $("table"+this.id) === undefined ) {

        this.log("table"+this.id+" not found"); 
        return false;
    }

    return true;
}

// Get cell coordinates
Table.prototype._position = function(id) {

    if ( $("td#"+id) ) {

        var ids = id.match(/^((.+)_(\d+))_(\d+)$/) || [];
        // ["test_0_1", "test_0", "test", "0", "1", index: 0, input: "test_0_1"]

        if ( ids.length < 5 ) { return false; }

        return {
            "table_id": this._id(),
            "row_id": ids[1],
            "cell_id": id,
            "row": ids[3],
            "col": ids[4]
        };
    }

    return false;
}
Table.prototype._getlastcolcell = function(id) {
    var self = this;
    var pos = self._position(id);    
    var cols = self._count("cols", "table") - 1;
    return pos.table_id + "_" + pos.row + "_" + cols;        

}

// Debug logger
Table.prototype.log = function(str) {

    if ( this.debug == false ) { return; }
    console.log(str);
}

Table.prototype.editCell = function(id) {

    var self = this;
    var cell = $("td#"+id);
    var pos = this._position(id);

    switch(pos.col){
    case '0':
        if ( $(cell).find("span").length > 0 ) { 
            return false;
        }
        // Retrieve the cell data
        var text = $(cell).text() || "";
        var val = $("td#"+self._getlastcolcell(id)).text() || "" ;
        var cellclass = $("td#"+id).attr("class");
        var cellAttr = {
            "style": "width:100%"
        };
        
        var select_html = (text == '') ? '<select></select>' : '<select><option value="'+val+'">'+text+'</option></select>';
        var cellInput = $(select_html).attr(cellAttr);

        $(cell).empty().append(cellInput);

        $(cellInput).on("focus", function() {
            $(this).removeClass("error");
        });        

        var req_url = '/products/list_by_name';
        var $product_select = $(cellInput).select2({
          ajax: {
            url: req_url,
            type: 'post',
            dataType: 'json',
            delay: 250,
            data: function (params) {
              return {
                term: params.term
              };
            },
            processResults: function (data, params) {
                var results = (data.Records == null) ? [] : data.Records;
                return{
                    results: results
                }                
            }
          },
          placeholder: "Select a Product",
          allowClear: true
        });

        $product_select.data('select2').$container.addClass("product-select");
        $product_select.data('select2').$selection.focus().select();

        $(cellInput).on('change', function(){            
            self.fillCell(id, function(){
                var nextcell = pos.table_id + "_" + pos.row + "_" + 1;
                $('td#'+nextcell).click();
                $('td#'+nextcell).children('input')[0].focus();                        
            });
        });
        break;
    default:
        if ( $(cell).find("input").length > 0 ) { 
            return false;
        }

        // Retrieve the cell data
        var val = $(cell).text() || "";
        var cellclass = $("td#"+id).attr("class");
        
        var dtype = this._gettype(id);
        var dt = this._datatypes(dtype);

        var cellAttr = {
            "type": "text",
            "class": "editcell",
            "placeholder": dt.placeholder,
            "value": val,
            "id": "autocomplete"
        };

        var cellInput = $('<input />').attr(cellAttr);

        $(cell).empty().append(cellInput);

        $(cellInput).on("focus", function() {
            $(this).removeClass("error");
        });

        $(cellInput).focus().select();      
        break;
    }
}

Table.prototype.formatCell = function(id) {

    var self = this;
    var cell = $("td#"+id);
    var pos = self._position(id);    
    var val = (pos.col > 0) ? $(cell).children("input").val() : $(cell).children("select").text();

    var dtype = this._gettype(id);
    var dt = this._datatypes(dtype);
    val = dt.format(val);

    self.log("format cell as: "+dtype+", original: "+ 
        $(cell).children("input").val() +", new: "+val);

    return val;
}

Table.prototype.fillCell = function(id, callback) {
    var self = this;
    var cell = $("td#"+id);
    var pos = self._position(id);    
    var cols = self._count("cols", "table") - 1;
    var lastcellid = pos.table_id + "_" + pos.row + "_" + cols;    
    var namecell = pos.table_id + "_" + pos.row + "_0";
    var pricecell = pos.table_id + "_" + pos.row + "_2";    
    var taxcell = pos.table_id + "_" + pos.row + "_4";    

    var lastcell = $("td#"+lastcellid);
    var oldlast = $(lastcell).text();    
    if($(cell).children("select").val()){
        $(lastcell).empty().text($(cell).children("select").val());
        if(oldlast != $(lastcell).text()){
            $.ajax({
              url: "/products/list_by_id",
              type: "post",
              datatype: 'json',
              data: {
                id: $(cell).children("select").val()
              },
              success: function(data){
                $('td#'+namecell).empty().text(data.product.name);
                $('td#'+pricecell).empty().text(data.product.selling_price);
                $('td#'+taxcell).empty().text(data.tax.rate);
                callback();
              },
              error:function(){
                $('td#'+namecell).empty().text('');
              }   
            });         
        } else {
            $(cell).text($(cell).children("select").text());
        }
    } else {
        $(lastcell).empty().text('0');
        $('td#'+namecell).empty().text('');
    }
}

Table.prototype.saveCell = function(id) {

    var self = this;
    var cell = $("td#"+id);
    var val = self.formatCell(id)

    if ( val === false ) {

        $(cell).children("input").addClass("error");
        self.log("save cell: "+id+" failed - invalid format");
        
        return false;
    }
    else {

        var pos = self._position(id);    
        if(pos.col <= 0){
            self.fillCell(id);
        } else {
            $(cell).empty().text(val);
            self.renderCalc();            
        }
    }
}

// Calculate formula based cells
Table.prototype.renderCalc = function() {

    var self = this;

    $("table"+this.id+" > tbody > tr > td.calc").each(function () {

        var cid = $(this).attr("id");
        var dtype = self._gettype(cid);
        var field = self._getfield(cid);

        if ( dtype == "calc" ) {
            var dt = self._datatypes(dtype);
            var fml = self.fields[field].formula || [];
            var val = dt.formula(cid, fml);
            $(this).empty().text(val);
            self._calc_extra();
        }
    });
}

Table.prototype.renderHead = function(fields) {

    if ( ! this._isvalid() ) { return false; }

    if ( $.isPlainObject(fields) && fields.length ) {
        this.fields = fields;
    }

    if ( this._has("fields") ) {

        // Truncate the existing data if it exists
        this.removeHead();

        // Re add header fields
        if ( ! $("table"+this.id).find("thead").length ) {
            $("table"+this.id).append('<thead />');
        }

        $("table"+this.id+" > thead").append('<tr></tr>');

        for (var key in this.fields) {
            this.log("Adding header: "+key);
            field_name = (this.fields[key].field_name) ? this.fields[key].field_name : "";
            $("table"+this.id+" > thead > tr").append('<th '+ this.fields[key].css +' field_name="'+field_name+'" >'+key+'</th>');
        }
    }
    else {
        this.log("Table fields Object is not defined");
        return false;
    }
}

Table.prototype.removeHead = function() {

    if ( ! this._isvalid() ) { return false; }

    // Truncate the existing header data if it exists
    $("table"+this.id+" > thead").empty();
}

Table.prototype.removeBody = function() {

    if ( ! this._isvalid() ) { return false; }

    // Truncate the existing body data if it exists
    $("table"+this.id+" > tbody").empty();   
}

Table.prototype.addRow = function(o) {

    var self = this;

    var o = o || {};
    var row = o.data || undefined;
    var dir = o.direction || self.direction;

    // Create the tbody if necessary
    if ( ! $("table"+this.id).find("tbody").length ) {
        $("table"+this.id).append('<tbody />');
    }

    // Convert object to an array
    if ( row === Object(row) ) {
        var rdata = [];
        for (var key in row) {
            rdata.push(row[key]);
        }
        row = rdata;
    }

    var r = this._count("rows");
    var rid = this._id()+'_'+r;
    var rowAttr = { "id": rid };

    // Add row based on direction
    switch(dir) {
        case "asc":
            // Ascending, append
            var rowEl = $('<tr />').attr(rowAttr);
            $("table"+this.id+" > tbody:last").append(rowEl);
            break;
        case "desc":
            // Descending, prepend
            var rowEl = $('<tr />').attr(rowAttr);
            $(rowEl).prependTo("table"+this.id+" > tbody:last");
            break;
    }

    // Populate the row with cells
    var c = 0;

    for (var key in this.fields) {

        var cid = rid+'_'+c;

        // Determine the data type
        var dtype = this.fields[key].type || "";
        var dt = this._datatypes(dtype);
        // Set the cell class
        var cellclass = this.fields[key]["class"] || "";
        var cellstyle = this.fields[key]["style"] || "";

        cellclass += (dtype) ? " "+ dtype : "";

        // Set the default cell value
        var val = dt["default"] || "";
        // Set value from the provided data if any
        if ( $.isArray(row) && row.length >= (c-1) ) {
            val = row[c];
        }

        // Append the table cell to the row
        var cellAttr = {
            "id": cid,
            "class": cellclass,
            "style": cellstyle
        };

        var cell;
        if(dtype == 'html'){
            var deleteHtml = '<a class="btn btn-xs delete-row" data-id= "'+rid+'"><i class="fa fa-minus-circle"></i></a>';
            cell = $("<td />").attr(cellAttr).html(deleteHtml);            
        } else {
            cell = $("<td />").attr(cellAttr).text(val);            
        }
        $("table"+this.id+" > tbody > tr#"+rid).append(cell);

        // Increment the cell id
        c++;
    }

    $('td#'+rid+'_'+0).click();
}

Table.prototype.delRow = function (id) {
    var self = this;
    var pos = this._position(id + '_0');
    var rows = this._count("rows", "table");    
    var cols = this._count("cols", "table");    
    $("tr#"+id).remove();

    for(i = parseInt(pos.row)+1; i < parseInt(rows); i++){
        rowid = pos.table_id + '_' + i;
        newrowid = pos.table_id + '_' + parseInt(i-1);
        $("tr#"+rowid).attr("id", newrowid);
        for(j = 0; j < cols; j++){
            colid = rowid + '_' + j;
            newcolid = newrowid + '_' + j;
            $("td#"+colid).find('a.delete-row').attr("data-id", newrowid);
            $("td#"+colid).attr("id", newcolid);
        }
    }

    // Calculate formula based cells
    this._calc_extra();
    return;
}

Table.prototype.render = function(direction) {

    var self = this;
    var dir = direction || self.direction;

    if ( ! this._isvalid() ) { return false; }

    // Drop the table if it exists
    this.drop();
    // Re add the header
    this.renderHead();

    // Add a row for each data set
    for (var i=0; i<this.data.length; i++) {

        this.addRow({ "data": this.data[i], "direction": dir });
    }

    // Calculate formula based cells
    this.renderCalc();
}

Table.prototype.drop = function() {

    if ( ! this._isvalid() ) { return false; }

    this.removeHead();
    this.removeBody();
}

Table.prototype.serialize = function(direction) {

    var self = this;
    var dir = direction || self.direction;

    var data = [];
    var rows;

    // Serialize data based on table data direction
    switch(dir) {
        case "asc":
            rows = $("table"+this.id+" > tbody > tr");
            break;
        case "desc":
            rows = $($("table"+this.id+" > tbody > tr").get().reverse());
            break;
    }

    $(rows).each(function () {

        var row = {};

        $(this).children("td").each(function () {

            var cid = $(this).attr("id");
            var field = (self._getfieldname(cid) == undefined) ? "" : self._getfieldname(cid);
            var val = $(this).text() || "";
            if(field != ''){
                row[field] = val;                
            }
        });

        data.push(row);
    });

    return data;
}

Table.prototype.setdata = function(data) {
    this.data = data;
}