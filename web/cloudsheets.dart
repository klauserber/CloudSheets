import 'dart:html';
import 'package:bootjack/bootjack.dart';
import 'package:dquery/dquery.dart';


void main() {
  //Button.use();  
  Transition.use();
  Collapse.use();
  
  
  $("#sidebarToggle").click((QueryEvent ev) {
    
    $("#sidebarContainer").toggle();    
  });
  
  
  
}

