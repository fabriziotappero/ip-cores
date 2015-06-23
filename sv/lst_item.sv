////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014  Ken Campbell
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
/////////////////////////////////////

  ////////////////////////////////
  //  list class.  enables a list of items to be
  //      created and accessed by an index or text.
typedef class lst_item;
class lst_item;
  string  name;
  string  txt;
  integer val;
  integer index;
  lst_item next;
  lst_item prev;

  extern function new(string ID);
  extern function void print();
  extern function void add_itm(lst_item item);
  extern function lst_item get(integer idx);
  extern function lst_item find(string txt);
  extern function void set(integer idx, integer val);
  
endclass // lst_item
  
  /////////////////////////////////////////////////
  //  lst_item methods
  //   function lst_item::new
  function lst_item::new(string ID);
    name = ID;
    txt  =   "";
    val  =   0;
    index =  0;
    next  =  null;
    prev  =  null;
  endfunction // new

//////////////////////////////////////////////////
  // function lst_item::print
  function void lst_item::print();
    lst_item lst;
    lst = this;
    while(lst != null) begin
      $display("%s  %s  %d  %d", lst.name, lst.txt, lst.val, lst.index);
      lst = lst.next;
    end
    //$display("%s  %s  %d  %d", lst.name, lst.txt, lst.val, lst.index);
  endfunction // print

////////////////////////////////////////////////////////
  //  function lst_item::set
  function void lst_item::set(integer idx, integer val);
    lst_item  tmp_itm;
    
    tmp_itm  =  this;
    while (tmp_itm != null) begin
      if (tmp_itm.index == idx) begin
        tmp_itm.val = val;
        break;
      end
      tmp_itm = tmp_itm.next;
    end
    
  endfunction  //  lst_item::set

/////////////////////////////////////////////////
  //  function  lst_item::add_itm
  function void lst_item::add_itm(lst_item item);
    lst_item tmp_itm;
    lst_item new_itm;
    tmp_itm  =  this;
    //  first item
    if((tmp_itm.next == null) && (tmp_itm.txt == ""))begin
      tmp_itm.txt = item.txt;
      tmp_itm.val = item.val;
      tmp_itm.prev = null;
    // second item
    end else if((tmp_itm.next == null) && (tmp_itm.txt != ""))begin
      new_itm = new("");
      new_itm.index = tmp_itm.index + 1;
      new_itm.txt   = item.txt;
      new_itm.val   = item.val;
      tmp_itm.next  = new_itm;
      new_itm.prev  = tmp_itm;
    //  other items
    end else begin
      while (tmp_itm.next != null) begin
        tmp_itm = tmp_itm.next;
      end
      new_itm = new("");
      new_itm.index = tmp_itm.index + 1;
      new_itm.txt   = item.txt;
      new_itm.val   = item.val;
      tmp_itm.next  = new_itm;
      new_itm.prev  = tmp_itm;
    end
    //this = tmp_itm;
  endfunction // lst_item::add_itm

////////////////////////////////////////////////////////////
  //  function  lst_item::get  index
  function lst_item lst_item::get(integer idx);
    lst_item tmp_itm;
    tmp_itm  = new("");
    tmp_itm  =  this;
    while (tmp_itm != null) begin
      if (tmp_itm.index == idx) begin
        return tmp_itm;
      end
      tmp_itm = tmp_itm.next;
    end
    
    check_lst_item_get : assert (tmp_itm) else begin
      $warning("Item index  >>> %4d <<< was not found on the %s list.", idx, this.name);
    end
    //if (tmp_itm.index != idx) begin
    //  $display("ERROR: lst_item.get  Index not found !!  Returning NULL object");
    //  tmp_itm  = new("");
    //  return tmp_itm;
    //end
    
    return tmp_itm;
  endfunction // get

///////////////////////////////////////////////////////////
  //  function  lst_item::find  txt
  function lst_item lst_item::find(string txt);
    lst_item tmp_itm;
    tmp_itm  = new("");
    tmp_itm  =  this;
    //  go through the list
    while (tmp_itm != null) begin
      if (tmp_itm.txt == txt) begin
        break;
      end
      tmp_itm = tmp_itm.next;
    end
    //  check for  found
    check_lst_item_find : assert (tmp_itm) else begin
      $warning("Item >>> %s <<< was not found on the %s list.", txt, this.name);
    end
    return tmp_itm;
  endfunction //  find
